// Authenticated Typert RPC, using the same source-mode binding as AppAuth.
import { createRequire } from 'node:module'
import { pathToFileURL } from 'node:url'
import { join } from 'node:path'
import { homedir } from 'node:os'
import { FormStore, checkId } from './store.mjs'

let protocol
for (const anchor of [process.argv[1], '/opt/dsh/node_modules/@deepseek-ai/dsh/lib/bin.js']) {
  try { protocol = await import(pathToFileURL(createRequire(anchor).resolve('@deepseek-ai/dsh-typert-protocol')).href); break } catch (_) {}
}
if (!protocol) throw new Error('dsh-protocol-unavailable')
const { TypertRemoteService, Remote, RemoteError } = protocol
const SAFE_ERRORS = new Set(['invalid-calories', 'invalid-food-items', 'invalid-food-item', 'invalid-local-date', 'wrong-profile', 'action-not-ready', 'candidate-changed', 'actions-not-ready', 'undeclared-collection', 'clone-before-editing'])
const marks = []
export default class AppForm extends TypertRemoteService {
  constructor(ctx, config) {
    super(ctx, 'appForm')
    for (const mark of marks) mark.call(this)
    this.form = config?.form || null
    this.store = new FormStore(join(process.env.DSH_HOME || join(homedir(), '.dsh'), 'wish'))
    this.handlers = new Map()
  }
  // Plugins register actions only in the profile launched for this form.
  register(id, actions) {
    if (id !== this.form) throw new Error('wrong-profile')
    for (const action of Object.keys(actions)) if (this.handlers.has(action)) throw new Error('duplicate-action')
    for (const [action, handler] of Object.entries(actions)) {
      if (this.handlers.has(action)) throw new Error('duplicate-action')
      this.handlers.set(action, handler)
    }
    return () => { for (const [action, handler] of Object.entries(actions)) if (this.handlers.get(action) === handler) this.handlers.delete(action) }
  }
  async read(collection, fallback) {
    if (!(await this.store.candidate(this.form)).manifest.data.collections.includes(collection)) throw new Error('undeclared-collection')
    return this.store.read(this.form, collection, fallback)
  }
  async write(collection, value) {
    if (!(await this.store.candidate(this.form)).manifest.data.collections.includes(collection)) throw new Error('undeclared-collection')
    return this.store.write(this.form, collection, value)
  }
  list() { return this.store.list() }
  begin(form) { return this.store.begin(form) }
  clone(form, source) { return this.store.clone(form, source) }
  prepare(form) { return this.store.prepare(form) }
  candidate(form) { return this.store.candidate(form) }
  async health(form) {
    checkId(form)
    if (form !== this.form) throw new Error('wrong-profile')
    const c = await this.store.candidate(form)
    const missing = c.manifest.surface.dsh.actions.filter(a => !this.handlers.has(a))
    return { ready: missing.length === 0, missing, profile: `app-${form}`, hash: c.hash }
  }
  async accept(form, hash) {
    if (!(await this.health(form)).ready) throw new Error('actions-not-ready')
    return this.store.accept(form, hash)
  }
  remove(form) {
    if (this.form === form) throw new Error('stop-form-before-removing')
    return this.store.remove(form)
  }
  async invoke(form, action, args) {
    if (form !== this.form) throw new Error('wrong-profile')
    const candidate = await this.store.candidate(form)
    if (!candidate.manifest.surface.dsh.actions.includes(action) || !this.handlers.has(action)) throw new Error('action-not-ready')
    // Serializing mutations prevents lost updates from two taps. RPC callers
    // must await settlement; a timeout never automatically retries a write.
    return this.store.serial(async () => {
      const started = Date.now()
      try {
        const data = await this.handlers.get(action)(args ?? {})
        const metric = candidate.manifest.statusMetric
        if (metric && data && ['string', 'number'].includes(typeof data[metric])) {
          try { await this.store.write(form, 'status', { value: data[metric], date: args?.today ?? null }) } catch (_) {}
        }
        await this.audit(form, action, 'ok', started)
        return data ?? {}
      } catch (error) {
        await this.audit(form, action, 'failed', started)
        const code = SAFE_ERRORS.has(error?.message) ? error.message : 'action-failed'
        throw new RemoteError(`app-form/${code}`, code)
      }
    })
  }
  async audit(form, action, result, started) {
    // Metadata only: no arguments, record contents, photos, keys or cookies.
    try {
      const events = await this.store.read(form, 'audit', [])
      events.push({ at: new Date().toISOString(), action, result, durationMs: Date.now() - started })
      await this.store.write(form, 'audit', events.slice(-200))
    } catch (_) { /* A diagnostic write must not turn a committed action into a retry. */ }
  }
  async boundary(operation, args) {
    try { return await operation.apply(this, args) }
    catch (error) {
      if (error instanceof RemoteError) throw error
      // Only expose stable validation codes; never serialize paths or plugin
      // exceptions, which can contain private user data.
      const code = error?.code === 'ENOENT' ? 'missing-artifact'
        : error instanceof SyntaxError ? 'invalid-artifact-json'
        : /^(invalid-|unsupported-|missing-|undeclared-|artifact-|bundle-|camera-|symlink-|too-many-|wrong-profile$|action-not-ready$|actions-not-ready$|candidate-changed$|clone-before-editing$|stop-form-before-removing$)/.test(error?.message ?? '')
          && /^[a-z-]+$/.test(error.message) ? error.message : 'operation-failed'
      throw new RemoteError(`app-form/${code}`, code)
    }
  }
}
// Source-mode Typert derives the wire argument names from the method source.
// Keep explicit parameters on each wrapper (a rest parameter invalidates RPC).
const wrap = {
  list: op => function () { return this.boundary(op, []) },
  clone: op => function (form, source) { return this.boundary(op, [form, source]) },
  accept: op => function (form, hash) { return this.boundary(op, [form, hash]) },
  invoke: op => function (form, action, args) { return this.boundary(op, [form, action, args]) },
}
for (const name of ['list', 'begin', 'clone', 'prepare', 'candidate', 'health', 'accept', 'remove', 'invoke']) {
  const operation = AppForm.prototype[name]
  AppForm.prototype[name] = (wrap[name] ?? (op => function (form) { return this.boundary(op, [form]) }))(operation)
  Remote(AppForm.prototype[name], { kind: 'method', name, static: false, private: false, addInitializer: initializer => marks.push(initializer) })
}
