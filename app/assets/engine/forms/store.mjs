// App Form artifacts are data until the user approves installation. No code is
// imported by this module. Profiles separate configuration, not OS privileges.
import { mkdir, readFile, writeFile, rename, readdir, lstat, realpath, rm } from 'node:fs/promises'
import { join, resolve, relative, isAbsolute } from 'node:path'
import { createHash, randomUUID } from 'node:crypto'

export const ID = /^local-[a-z0-9][a-z0-9-]{0,42}$/
const TYPES = new Set(['text', 'input', 'camera', 'button', 'metric', 'list'])
const CAPS = new Set(['camera', 'ai'])
const fail = (code) => { throw new Error(code) }
const object = (x) => x && typeof x === 'object' && !Array.isArray(x)
export function checkId(id) { if (typeof id !== 'string' || !ID.test(id)) fail('invalid-form-id'); return id }
export function checkPath(path) {
  if (typeof path !== 'string' || !path || path.includes('\\') || isAbsolute(path) || path.split('/').some(p => !p || p === '.' || p === '..')) fail('invalid-artifact-path')
  return path
}
export async function atomic(path, value) {
  const temp = `${path}.${randomUUID()}.tmp`
  await writeFile(temp, JSON.stringify(value), { mode: 0o600 })
  await rename(temp, path)
}
async function json(path, fallback) {
  try { return JSON.parse(await readFile(path, 'utf8')) }
  catch (e) { if (e.code === 'ENOENT' && fallback !== undefined) return fallback; throw e }
}

export function validate(manifest, view, id) {
  checkId(id)
  if (!object(manifest) || manifest.schemaVersion !== 1 || manifest.id !== id || manifest.runtime?.profile !== `app-${id}` || manifest.data?.namespace !== id) fail('invalid-manifest-identity')
  if (typeof manifest.name !== 'string' || !manifest.name.trim() || manifest.name.length > 80) fail('invalid-name')
  if (manifest.surface?.kind !== 'hybrid' || manifest.surface.native?.renderer !== 'm3') fail('unsupported-surface')
  checkPath(manifest.surface.native.view)
  if (!Array.isArray(manifest.capabilities) || manifest.capabilities.some(c => !CAPS.has(c))) fail('unsupported-capability')
  if (!Array.isArray(manifest.permissions) || manifest.permissions.some(c => !manifest.capabilities.includes(c))) fail('invalid-permissions')
  if (!Array.isArray(manifest.data.collections) || manifest.data.collections.some(c => !/^[a-zA-Z][a-zA-Z0-9]{0,40}$/.test(c))) fail('invalid-collections')
  const actions = manifest.surface.dsh?.actions
  if (!Array.isArray(actions) || !actions.length || new Set(actions).size !== actions.length || actions.some(a => !/^[a-z][a-zA-Z0-9]*\.[a-zA-Z0-9]+$/.test(a) || a.startsWith('host.'))) fail('invalid-actions')
  const bundles = manifest.runtime.bundles
  if (!Array.isArray(bundles) || !bundles.length || bundles.length > 8 || bundles.some(b => !object(b) || !b.name?.startsWith('@local/') || !b.path?.startsWith('bundles/'))) fail('invalid-bundles')
  for (const b of bundles) checkPath(b.path)
  if (!object(view) || view.schemaVersion !== 1 || !Array.isArray(view.components) || view.components.length > 60) fail('invalid-view')
  if (!actions.includes(view.load)) fail('missing-load-action')
  for (const c of view.components) {
    if (!object(c) || !TYPES.has(c.type)) fail('unsupported-component')
    if (c.type === 'camera' && !manifest.capabilities.includes('camera')) fail('camera-not-declared')
    if (c.type === 'button' && !actions.includes(c.action)) fail('undeclared-action')
    if (['input', 'camera', 'metric', 'list'].includes(c.type) && typeof c.bind !== 'string') fail('missing-binding')
    if (c.type === 'camera' && c.bind !== 'photo') fail('invalid-camera-binding')
    if (c.type === 'list' && (!object(c.item) || typeof c.item.title !== 'string')) fail('invalid-list-item')
    if (c.bind !== undefined && (typeof c.bind !== 'string' || !/^[a-zA-Z][a-zA-Z0-9]*$/.test(c.bind))) fail('invalid-binding')
  }
  return { manifest, view }
}

export class FormStore {
  constructor(root) { this.root = root; this.queue = Promise.resolve() }
  async init() {
    for (const dir of ['workspaces', 'releases', 'data']) await mkdir(join(this.root, dir), { recursive: true })
  }
  workspace(id) { return join(this.root, 'workspaces', checkId(id)) }
  async begin(id) { await this.init(); await mkdir(this.workspace(id), { recursive: true }); return { path: this.workspace(id) } }
  async files(dir, prefix = '') {
    const result = []
    for (const name of (await readdir(join(dir, prefix))).sort()) {
      if (name === 'node_modules' || name.startsWith('.')) fail('unsupported-artifact-file')
      const path = prefix ? `${prefix}/${name}` : name
      const stat = await lstat(join(dir, path))
      if (stat.isSymbolicLink()) fail('symlink-not-allowed')
      if (stat.isDirectory()) result.push(...await this.files(dir, path))
      else if (stat.isFile() && stat.size <= 512 * 1024) result.push(path)
      else fail('artifact-too-large')
      if (result.length > 100) fail('too-many-artifact-files')
    }
    return result
  }
  async prepare(id) {
    await this.init()
    if ((await this.list()).some(f => f.manifest.id === id)) fail('clone-before-editing')
    const source = this.workspace(id)
    if ((await lstat(source)).isSymbolicLink()) fail('symlink-not-allowed')
    const paths = await this.files(source)
    if (!paths.includes('dsh-wish.app.json')) fail('missing-artifact')
    let total = 0
    const contents = new Map()
    const digest = createHash('sha256')
    for (const path of paths) {
      const real = await realpath(join(source, path))
      if (relative(await realpath(source), real).startsWith('..')) fail('artifact-outside-workspace')
      const bytes = await readFile(real)
      total += bytes.length
      if (total > 2 * 1024 * 1024) fail('artifact-too-large')
      contents.set(path, bytes); digest.update(path + '\0').update(bytes).update('\0')
    }
    const read = p => JSON.parse(contents.get(p)?.toString() ?? 'null')
    const manifest = read('dsh-wish.app.json')
    if (manifest?.surface?.native?.view && !contents.has(manifest.surface.native.view)) fail('missing-view')
    const view = read(manifest?.surface?.native?.view)
    validate(manifest, view, id)
    for (const b of manifest.runtime.bundles) {
      const pkg = read(`${b.path}/package.json`)
      if (!pkg || pkg.name !== b.name || pkg.type !== 'module' || pkg.scripts || Object.keys(pkg.dependencies ?? {}).length || Object.keys(pkg.devDependencies ?? {}).length || Object.keys(pkg.optionalDependencies ?? {}).length || Object.keys(pkg.peerDependencies ?? {}).length) fail('bundle-must-be-self-contained')
      checkPath(pkg.main)
      if (!contents.has(`${b.path}/${pkg.main}`)) fail('missing-bundle-entry')
      if (pkg.dsh?.bundle?.patch !== './cordis.patch.yml' || !contents.has(`${b.path}/cordis.patch.yml`)) fail('missing-bundle-patch')
    }
    const hash = digest.digest('hex')
    const release = join(this.root, 'releases', id, hash)
    await mkdir(release, { recursive: true })
    for (const [path, bytes] of contents) {
      const target = join(release, path)
      await mkdir(resolve(target, '..'), { recursive: true })
      await writeFile(target, bytes, { mode: 0o600 })
    }
    const prepared = { manifest, view, hash, specs: manifest.runtime.bundles.map(b => join(release, b.path)) }
    await atomic(join(this.root, 'releases', id, 'candidate.json'), prepared)
    return prepared
  }
  async candidate(id) { return json(join(this.root, 'releases', checkId(id), 'candidate.json')) }
  async clone(id, source) {
    await this.begin(id)
    const old = (await this.list()).find(f => f.manifest.id === checkId(source))
    if (!old || id === source) fail('invalid-clone-source')
    const release = join(this.root, 'releases', source, old.hash)
    for (const path of await this.files(release)) {
      const target = join(this.workspace(id), path)
      await mkdir(resolve(target, '..'), { recursive: true })
      const text = (await readFile(join(release, path), 'utf8')).replaceAll(source, id)
      await writeFile(target, text)
    }
    for (const collection of old.manifest.data.collections) await this.write(id, collection, await this.read(source, collection))
    return { path: this.workspace(id) }
  }
  async list() { await this.init(); return json(join(this.root, 'catalog.json'), []) }
  async accept(id, hash) {
    const candidate = await this.candidate(id)
    if (candidate.hash !== hash) fail('candidate-changed')
    return this.serial(async () => {
      const catalog = await this.list()
      const previous = catalog.find(f => f.manifest.id === id)
      const accepted = { ...candidate, acceptedAt: new Date().toISOString(), previous: previous ? { ...previous, previous: undefined } : null }
      await atomic(join(this.root, 'catalog.json'), [...catalog.filter(f => f.manifest.id !== id), accepted])
      return accepted
    })
  }
  serial(operation) {
    const work = this.queue.then(operation, operation)
    this.queue = work.catch(() => {})
    return work
  }
  async remove(id) {
    checkId(id)
    return this.serial(async () => {
      const list = await this.list()
      await atomic(join(this.root, 'catalog.json'), list.filter(f => f.manifest.id !== id))
      await rm(join(this.root, 'data', id), { recursive: true, force: true })
      await rm(join(this.root, 'workspaces', id), { recursive: true, force: true })
      await rm(join(this.root, 'releases', id), { recursive: true, force: true })
      await rm(join(this.root, 'work-versions', id), { recursive: true, force: true })
      await rm(join(this.root, 'agent-workspaces', id), { recursive: true, force: true })
      await rm(join(this.root, '..', 'profiles', `app-${id}`), { recursive: true, force: true })
      return { removed: id }
    })
  }
  async read(id, collection, fallback = []) {
    checkId(id)
    if (!/^[a-zA-Z][a-zA-Z0-9]{0,40}$/.test(collection)) fail('invalid-collection')
    return json(join(this.root, 'data', id, `${collection}.json`), fallback)
  }
  async write(id, collection, data) {
    await this.read(id, collection)
    const dir = join(this.root, 'data', id)
    await mkdir(dir, { recursive: true })
    await atomic(join(dir, `${collection}.json`), data)
  }
}
