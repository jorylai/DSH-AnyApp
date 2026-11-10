// One authenticated DSH service for Creator projects and model calls. OAuth
// grants stay with DSH's provider; neither Flutter nor web plugins receive them.
import { join, sep } from 'node:path'
import { realpath, stat, readFile } from 'node:fs/promises'
import { homedir } from 'node:os'
import { randomUUID } from 'node:crypto'
import { hostImport } from './host.mjs'
import { ProjectStore, selectModelRoute, validateAiRequest } from './mobile-core.mjs'
import { checkId } from './store.mjs'
import { WorkReleases } from './releases.mjs'
const { TypertRemoteService, Remote, RemoteError } = await hostImport('@deepseek-ai/dsh-typert-protocol')
const { createUserMessage, BlockAssembler } = await hostImport('@deepseek-ai/dsh-llm')
// Stable code-only import failures; never expose paths, code or account data.
async function releaseCall(run) {
  try { return await run() } catch(e) {
    const message=String(e?.message||'')
    const code=/^(release|invalid|modified|missing|unexpected|project|source|agent)-[a-z0-9-]{1,70}$/.test(message)?message:
      ({ENOSPC:'release-storage-full',EACCES:'release-storage-denied',EEXIST:'release-import-conflict',ENOENT:'release-file-missing'})[e?.code]||'release-operation-failed'
    throw new RemoteError('wish-release/'+code,code)
  }
}
const initializers = []
export default class WishMobile extends TypertRemoteService {
  static inject = ['llm', 'attachments', 'agentDefaultModel']
  constructor(ctx, config) {
    super(ctx, 'wishMobile')
    for (const initialize of initializers) initialize.call(this)
    this.form = config?.form || null
    this.store = new ProjectStore(join(process.env.DSH_HOME || join(homedir(), '.dsh'), 'wish'))
    this.pending = 0
    this.operationTokens = new Set()
    this.calls = new Set()
    ctx.effect(() => () => { for (const call of this.calls) call.abort() })
  }
  own(form) { if (checkId(form) !== this.form) throw new RemoteError('wish/wrong-profile', 'wrong-profile') }
  projects() { return this.store.projects() }
  create(form, title, request) { this.own(form); return this.store.create(form, title, request) }
  bind(form, sessionId) { this.own(form); return this.store.bind(form, sessionId) }
  read(collection) {
    this.own(this.form)
    return this.store.read(this.form, collection, null)
  }
  write(collection, value) {
    this.own(this.form)
    if (JSON.stringify(value).length > 1000000) throw new RemoteError('wish/data-too-large', 'data-too-large')
    return this.store.serial(async () => { await this.store.write(this.form, collection, value); return { saved: true } })
  }
  async publish(form, title, panel) {
    this.own(form)
    const bundles = await this.ctx.get('pluginManager')?.listBundles()
    const bundle = bundles?.find(b => b.name === `@local/${form}` && b.installed && b.enabled && !b.error)
    if (!bundle) throw new RemoteError('wish/plugin-not-installed', 'plugin-not-installed')
    return this.store.publish(form, title, panel)
  }
  async preview(form) {
    this.own(form)
    const bundles = await this.ctx.get('pluginManager')?.listBundles()
    if (!bundles?.some(b => b.name === `@local/${form}` && b.installed && b.enabled && !b.error))
      throw new RemoteError('wish/plugin-not-installed', 'plugin-not-installed')
    return this.store.update(form, { panel: form })
  }
  unpublish(form) { this.own(form); return this.store.unpublish(form) }
  remove(form) {
    if (form === this.form) throw new RemoteError('wish/stop-before-removing', 'stop-before-removing')
    return this.store.removeProject(form)
  }
  hostBusy() { return {busy:this.pending>0 || this.operationTokens.size>0} }
  beginOperation(token) { if(typeof token!=='string'||token.length>80)throw new Error('invalid-operation');this.operationTokens.add(token);return true }
  endOperation(token) { this.operationTokens.delete(token);return true }
  async releaseSpec() {
    this.own(this.form)
    const rows=await this.ctx.get('pluginManager')?.listBundles()
    const bundle=rows?.find(b=>b.name===`@local/${this.form}` && b.installed)
    return bundle?.installTarget?.spec || this.store.workspace(this.form)
  }
  async releaseCheckpoint() {
    this.own(this.form)
    const project=(await this.store.projects()).find(p=>p.id===this.form)
    return releaseCall(async()=>new WorkReleases(this.store).checkpoint(this.form,await this.releaseSpec(),project?.title))
  }
  releaseList() { this.own(this.form); return new WorkReleases(this.store).list(this.form) }
  async releaseRestore(hash) { this.own(this.form);await this.releaseCheckpoint();return new WorkReleases(this.store).restore(this.form,hash) }
  async releaseExport() { this.own(this.form);const project=(await this.store.projects()).find(p=>p.id===this.form);return releaseCall(async()=>new WorkReleases(this.store).export(this.form,await this.releaseSpec(),project?.title)) }
  async releaseUpgrade(envelope, expectedHash) {
    this.own(this.form)
    return new WorkReleases(this.store).upgrade(this.form,envelope,await this.releaseSpec(),expectedHash)
  }
  releaseImport(envelope) { this.own(this.form);return releaseCall(()=>new WorkReleases(this.store).import(this.form,envelope)) }
  travelList() { this.own(this.form); return this.store.read(this.form, 'wishTravel', []) }
  travelSave(entry) {
    this.own(this.form)
    if (!entry || typeof entry !== 'object' || !/^[a-zA-Z0-9_-]{1,64}$/.test(entry.id || '') || typeof entry.title !== 'string' || !entry.title.trim() || entry.title.length > 200 || JSON.stringify(entry).length > 12000)
      throw new RemoteError('wish/invalid-travel-entry', 'invalid-travel-entry')
    for (const key of ['start', 'end']) if (entry[key] != null && (typeof entry[key] !== 'string' || !Number.isFinite(Date.parse(entry[key])))) throw new RemoteError('wish/invalid-travel-time', 'invalid-travel-time')
    return this.store.serial(async () => {
      const rows = await this.store.read(this.form, 'wishTravel', [])
      const saved = { ...entry, updatedAt: new Date().toISOString() }
      const next = rows.filter(row => row.id !== entry.id).concat(saved)
      if (next.length > 300 || JSON.stringify(next).length > 1000000) throw new RemoteError('wish/travel-limit', 'travel-limit')
      await this.store.write(this.form, 'wishTravel', next)
      return saved
    })
  }
  travelRemove(id) {
    this.own(this.form)
    return this.store.serial(async () => { const rows = await this.store.read(this.form, 'wishTravel', []); await this.store.write(this.form, 'wishTravel', rows.filter(row => row.id !== id)); return {removed:true} })
  }
  agentWorkspace() { this.own(this.form);return this.store.agentWorkspace(this.form) }
  async agentResults() {
    this.own(this.form)
    try {
      const root = await realpath(this.store.workspace(this.form))
      const file = await realpath(join(root, 'agent-results.json'))
      if (!file.startsWith(root + sep) || (await stat(file)).size > 1000000) throw new Error('invalid-agent-results')
      return JSON.parse(await readFile(file, 'utf8'))
    } catch (e) { if (e.code === 'ENOENT') return null; throw new RemoteError('wish/invalid-agent-results', 'invalid-agent-results') }
  }
  async modelStatus() {
    // Subscription grants are shared, but pi-ai route declarations belong to
    // each profile. Reuse dsh-go's existing repair, without touching the grant.
    await this.ctx.get('appAuth')?.list()
    const groups = [], failures = []
    for (const provider of this.ctx.llm.listProviders()) {
      try {
        const models = await this.ctx.llm.listModels(provider.id)
        if (models.length) groups.push({ id: provider.id, models })
      } catch (_) { failures.push({ id: provider.id }) }
    }
    try {
      const route = selectModelRoute(this.ctx.agentDefaultModel.currentSelection(), groups, failures)
      return { ready: true, ...route }
    } catch (e) { return { ready: false, code: e.message } }
  }
  async complete(request) {
    const controller = new AbortController()
    const timer = setTimeout(() => controller.abort(), 90000)
    const requestId = randomUUID()
    let route, result = 'failed'
    const started = Date.now()
    try {
      validateAiRequest(request)
      if (this.pending >= 2) throw new Error('BUSY')
      this.pending++; this.calls.add(controller)
      route = await this.modelStatus()
      if (!route.ready) throw new Error(route.code)
      const call = await this.ctx.llm.prepareCall({ provider: route.provider, model: route.model, maxTokens: 8192 }, controller.signal,
        (controls, model) => ({ ...controls, ...(model.reasoning?.efforts.some(e => e.id === 'off') ? { reasoningEffort: 'off' } : {}) }))
      const content = [{ type: 'text', text: request.prompt }]
      if (request.image != null) {
        if (!call.inputModalities?.includes('image')) throw new Error('VISION_UNAVAILABLE')
        const admitted = await this.ctx.attachments.admitPromptContent([{ type: 'image', ...request.image }])
        content.push(...admitted)
      }
      const messages = [createUserMessage({ content, source: { kind: 'dsh-wish-mobile' } })]
      const assembler = new BlockAssembler()
      for await (const chunk of call.stream({ ...call.config, messages, system: '', tools: [], purpose: 'wish-plugin', signal: controller.signal })) assembler.push(chunk)
      const finish = assembler.finish
      if (finish.kind === 'error') throw Object.assign(new Error('MODEL_FAILED'), { code: finish.failure?.code })
      if (finish.kind !== 'stop') throw new Error(finish.kind === 'max-tokens' ? 'OUTPUT_LIMIT' : 'MODEL_INTERRUPTED')
      const text = assembler.blocks().filter(b => b.type === 'text').map(b => b.text).join('')
      if (!text.trim()) throw new Error('EMPTY_RESPONSE')
      result = 'ok'
      return { text, provider: route.provider, model: route.model, requestId }
    } catch (e) {
      const code = controller.signal.aborted ? 'TIMEOUT' : e?.code || e?.message
      const safe = /^[A-Z][A-Z0-9_]{1,64}$/.test(code ?? '') ? code : 'MODEL_FAILED'
      throw new RemoteError(`wish-ai/${safe}`, safe)
    } finally {
      clearTimeout(timer)
      if (this.calls.delete(controller)) this.pending--
      if (this.form) {
        // No prompts, photos, answers, tokens or user identity in diagnostics.
        try {
          await this.store.serial(async () => {
            const rows = await this.store.read(this.form, 'aiAudit', [])
            rows.push({ requestId, at: new Date().toISOString(), provider: route?.provider, model: route?.model, result, durationMs: Date.now() - started })
            await this.store.write(this.form, 'aiAudit', rows.slice(-200))
          })
        } catch (_) {}
      }
    }
  }
}
for (const name of ['projects', 'create', 'bind', 'read', 'write', 'publish', 'preview', 'unpublish', 'remove', 'modelStatus', 'complete', 'agentResults', 'agentWorkspace', 'travelList', 'travelSave', 'travelRemove', 'releaseCheckpoint', 'releaseList', 'releaseRestore', 'releaseExport', 'releaseImport', 'releaseUpgrade', 'hostBusy', 'beginOperation', 'endOperation']) {
  Remote(WishMobile.prototype[name], { kind: 'method', name, static: false, private: false, addInitializer: f => initializers.push(f) })
}
