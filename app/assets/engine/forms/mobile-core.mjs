import { join, sep } from 'node:path'
import { readFile, mkdir, realpath } from 'node:fs/promises'
import { FormStore, atomic, checkId } from './store.mjs'

const checkText = (value, max) => {
  if (typeof value !== 'string' || !value.trim() || value.length > max) throw new Error('invalid-project')
  return value.trim()
}
export class ProjectStore extends FormStore {
  async projects() {
    await this.init()
    try { return JSON.parse(await readFile(join(this.root, 'projects.json'), 'utf8')) }
    catch (e) { if (e.code === 'ENOENT') return []; throw e }
  }
  async create(id, title, request = '') {
    await this.begin(id)
    return this.serial(async () => {
      const list = await this.projects()
      if (list.some(p => p.id === id)) throw new Error('project-already-exists')
      const project = { id, title: checkText(title, 80), request: checkText(request || title, 10000), profile: `app-${id}`, state: 'draft', createdAt: new Date().toISOString() }
      await atomic(join(this.root, 'projects.json'), [...list, project])
      return { ...project, path: this.workspace(id) }
    })
  }
  async agentWorkspace(id) {
    checkId(id);await this.begin(id)
    const root=await realpath(this.root), base=join(root,'agent-workspaces')
    await mkdir(base,{recursive:true})
    if(await realpath(base)!==base)throw new Error('agent-workspace-outside-work')
    const path=join(base,id);await mkdir(path,{recursive:true})
    if(await realpath(path)!==path||!path.startsWith(root+sep))throw new Error('agent-workspace-outside-work')
    return {path,results:join(this.workspace(id),'agent-results.json')}
  }
  async update(id, changes) {
    checkId(id)
    return this.serial(async () => {
      const list = await this.projects()
      const old = list.find(p => p.id === id)
      if (!old) throw new Error('project-not-found')
      const next = { ...old, ...changes, id, profile: `app-${id}`, updatedAt: new Date().toISOString() }
      await atomic(join(this.root, 'projects.json'), list.map(p => p.id === id ? next : p))
      return next
    })
  }
  async bind(id, sessionId) {
    if (typeof sessionId !== 'string' || !/^session-[a-zA-Z0-9-]{1,80}$/.test(sessionId)) throw new Error('invalid-session')
    checkId(id)
    return this.serial(async () => {
      const list = await this.projects(), previous = list.find(p => p.id === id)
      if (!previous) throw new Error('project-not-found')
      const history = [...new Set([...(previous.creatorSessionHistory || []), previous.sessionId].filter(s => typeof s === 'string' && s !== sessionId))]
      const next = {...previous, sessionId, creatorSessionHistory:history, updatedAt:new Date().toISOString()}
      await atomic(join(this.root, 'projects.json'), list.map(p => p.id === id ? next : p))
      return next
    })
  }
  publish(id, title, panel) {
    checkText(title, 80)
    if (typeof panel !== 'string' || !/^[a-zA-Z][a-zA-Z0-9._-]{0,100}$/.test(panel)) throw new Error('invalid-panel')
    return this.update(id, { title: title.trim(), panel, state: 'published' })
  }
  unpublish(id) { return this.update(id, { state: 'draft' }) }
  async removeProject(id) {
    checkId(id)
    // FormStore.remove has its own queue; do not nest that queue here.
    await this.remove(id)
    return this.serial(async () => {
      const list = await this.projects()
      await atomic(join(this.root, 'projects.json'), list.filter(p => p.id !== id))
      return { removed: id }
    })
  }
}

// An account login and a provider API key are different routes. Retain a
// usable explicit default. An unavailable uncredentialed default can select
// the signed-in account, just as DSH's initializeDefaultModel does.
export function selectModelRoute(defaultSelection, groups, failures = []) {
  const current = groups.find(g => g.id === defaultSelection?.provider)?.models.find(m => m.id === defaultSelection?.model)
  if (current) return { ...defaultSelection, name: current.name, inputModalities: current.inputModalities ?? ['text'] }
  if (failures.some(f => f.id === defaultSelection?.provider)) throw new Error('MODEL_ROUTE_UNAVAILABLE')
  const group = groups.find(g => g.id === 'deepseek-account') ?? groups.find(g => g.models.length)
  const model = group?.models[0]
  if (!model) throw new Error('MODEL_NOT_CONFIGURED')
  return { provider: group.id, model: model.id, name: model.name, inputModalities: model.inputModalities ?? ['text'] }
}

export function validateAiRequest(request) {
  if (!request || typeof request.prompt !== 'string' || !request.prompt.trim() || request.prompt.length > 40000) throw new Error('INVALID_REQUEST')
  if (request.image != null && (typeof request.image.data !== 'string' || request.image.data.length > 2800000 ||
      !['image/jpeg', 'image/png', 'image/webp'].includes(request.image.mediaType))) throw new Error('INVALID_IMAGE')
  return request
}
