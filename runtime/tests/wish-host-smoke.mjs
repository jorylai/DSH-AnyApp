import assert from 'node:assert/strict'
import { spawn } from 'node:child_process'
import { mkdir, cp, writeFile, readFile, rm, realpath } from 'node:fs/promises'
import { resolve, join } from 'node:path'
import { randomUUID } from 'node:crypto'
import { tmpdir } from 'node:os'
import { fileURLToPath } from 'node:url'
if (!process.env.DSH_WISH_HOST_CLI) throw new Error('Set DSH_WISH_HOST_CLI to the pinned DSH CLI (0.2.1-rc.4).')
const base = join(await realpath(tmpdir()), 'dsh-wish-smoke-'+randomUUID())
await rm(base, { recursive: true, force: true }); await mkdir(base, { recursive: true })
const home = join(base, 'home')
const cli = await realpath(resolve(process.env.DSH_WISH_HOST_CLI))
const bridge = fileURLToPath(new URL('../../app/assets/engine/forms/index.mjs', import.meta.url))
const mobile = fileURLToPath(new URL('../../app/assets/engine/forms/mobile.mjs', import.meta.url))
const sample = fileURLToPath(new URL('../../app/assets/forms/food-camera/', import.meta.url))
await mkdir(join(home, 'wish/workspaces'), { recursive: true })
await cp(sample, join(home, 'wish/workspaces/local-food-camera'), { recursive: true })
const patch = join(base, 'overlay.yml')
await writeFile(patch, `- insert:\n    - id: dsh-wish-app-form\n      name: ${JSON.stringify(bridge)}\n      config:\n        form: local-food-camera\n    - id: dsh-wish-mobile\n      name: ${JSON.stringify(mobile)}\n      config:\n        form: local-food-camera\n- id: plugin-manager\n  config:\n    pnpmCommand: ${process.env.DSH_WISH_PNPM_COMMAND || 'pnpm'}\n`)
let child, cookie, origin, log = ''
async function start(fresh) {
  log = ''
  child = spawn(process.execPath, [cli, '--profile', 'app-local-food-camera', ...(fresh ? ['--from-default-profile', 'web'] : []), '--patch', patch, '--no-open', '--host', '127.0.0.1', '--port', '18719'], { env: { ...process.env, DSH_HOME: home, DSH_AGENTS_HOME: join(base, 'agents'), PATH: process.env.PATH }, stdio: ['ignore', 'pipe', 'pipe'] })
  const address = await new Promise((resolveReady, reject) => {
    const timer = setTimeout(() => reject(new Error('boot-timeout: '+log.slice(-5000).replace(/token=[^\s]+/g,'token=REDACTED'))), 60000)
    const collect = chunk => {
      log += chunk.toString()
      const match = log.match(/http:\/\/127\.0\.0\.1:18719\/\?token=([^\s\x1b]+)/)
      if (match) { clearTimeout(timer); resolveReady(`http://127.0.0.1:18719/?token=${match[1]}`) }
    }
    child.stdout.on('data', collect); child.stderr.on('data', collect)
    child.once('exit', code => { clearTimeout(timer); reject(new Error(`boot-exit-${code}: ${log.slice(-5000).replace(/token=[^\s]+/g,'token=REDACTED')}`)) })
  })
  origin = new URL(address).origin
  const login = await fetch(address, { redirect: 'manual' })
  cookie = login.headers.getSetCookie().map(s => s.split(';')[0]).join('; ')
  assert.ok(cookie, 'login issues a cookie')
}
async function stop() {
  if (!child || child.exitCode !== null) return
  const current = child
  const ended = new Promise(r => current.once('exit', r))
  current.kill('SIGTERM')
  const timer = setTimeout(() => current.kill('SIGKILL'), 8000)
  await ended; clearTimeout(timer)
}
async function rpc(method, args = {}) {
  const res = await fetch(`${origin}/api/${method}`, { method: 'POST', headers: { cookie, 'Content-Type': 'application/json' }, body: JSON.stringify({ type: 'client-request', rpcId: randomUUID(), method, payload: { args } }), signal: AbortSignal.timeout(60000) })
  const envelope = await res.json(); const body = envelope.result ?? envelope
  if (!body.ok) throw new Error(`${method}: ${JSON.stringify(body)}`)
  return body.value
}
try {
  await start(true)
  assert.deepEqual(await rpc('appForm/list'), [])
  await rpc('appForm/begin', {form: 'local-empty'})
  await assert.rejects(rpc('appForm/prepare', {form: 'local-empty'}), /app-form\/missing-artifact/)
  await rpc('appForm/remove', {form: 'local-empty'})
  assert.deepEqual(await rpc('wishMobile/projects'), [])
  const project = await rpc('wishMobile/create', {form:'local-food-camera', title:'Creator draft', request:'Create a custom panel'})
  const session = await rpc('session/create', {request:{cwd:project.path,agentPreset:'cordis'}})
  assert.equal(session.agentPreset,'cordis','session/create must return the actual Creator preset')
  assert.equal((await rpc('session/projections',{request:{sessionId:session.sessionId}})).values.agentPreset,'cordis')
  const presets = await rpc('agentPresets/list')
  assert.ok(presets.presets.some(p=>p.id==='cordis' && !p.broken))
  const creator = await rpc('agentPresets/read',{agentPreset:'cordis'})
  for (const tool of ['dsh-tool-cordis','dsh-tool-skill','dsh-plugin-manager/tools']) assert.ok(creator.content.includes(tool),tool)
  console.log('PASS actual Creator preset selection, projection and plugin-development tool declarations')
  await rpc('wishMobile/bind',{form:'local-food-camera', sessionId:session.sessionId})
  await rpc('wishMobile/write',{collection:'notes',value:[{text:'kept'}]})
  assert.deepEqual(await rpc('wishMobile/read',{collection:'notes'}),[{text:'kept'}])
  assert.equal((await rpc('wishMobile/modelStatus')).ready, false)
  await assert.rejects(rpc('wishMobile/complete',{request:{prompt:'No real credential in this test'}}), /wish-ai\/MODEL_NOT_CONFIGURED/)
  await assert.rejects(rpc('wishMobile/publish',{form:'local-food-camera',title:'Not installed',panel:'local-food-camera'}), /plugin-not-installed/)
  const trip={id:'test-trip',title:'Reviewed flight',start:'2026-11-10T10:00:00+08:00',end:'2026-11-10T04:00:00Z',timeZone:'Asia/Shanghai',missing:[]}
  assert.equal((await rpc('wishMobile/travelSave',{entry:trip})).id,trip.id)
  await rpc('wishMobile/travelSave',{entry:{...trip,title:'Reviewed update'}})
  assert.equal((await rpc('wishMobile/travelList')).length,1)
  assert.equal((await rpc('wishMobile/travelList'))[0].title,'Reviewed update')
  await assert.rejects(rpc('wishMobile/travelSave',{entry:{...trip,id:'../escape'}}), /invalid-travel-entry/)
  await rpc('wishMobile/travelRemove',{id:trip.id})
  assert.deepEqual(await rpc('wishMobile/travelList'),[])
  console.log('PASS real work-scoped travel RPC, upsert, validation and removal')
  console.log('PASS Creator project/session binding, data RPC and honest missing-model error')
  const form = await rpc('appForm/prepare', { form: 'local-food-camera' })
  assert.equal(form.specs.length, 2)
  console.log('PASS real authenticated Typert bridge: prepare/list')
  for (const spec of form.specs) {
    const outcome = await rpc('pluginManager/installBundle', { spec, options: { enabled: true, requestId: randomUUID() } })
    assert.ok(['applied','restart-required'].includes(outcome.application), JSON.stringify(outcome))
  }
  console.log('PASS real DSH plugin manager installs both local bundles')
  await stop(); await start(false)
  const health = await rpc('appForm/health', { form: 'local-food-camera' })
  assert.equal(health.ready, true, JSON.stringify(health))
  const invoke = (action, args) => rpc('appForm/invoke', { form: 'local-food-camera', action, args })
  assert.equal((await invoke('food.today', { today: '2026-11-06' })).todayKcal, 0)
  const saved = await invoke('food.save', { today: '2026-11-06', name: 'rice', kcal: '174', items: [{ name: 'rice', kcal: 174, staple: true }] })
  assert.equal(saved.todayKcal, 174)
  await assert.rejects(invoke('food.save', {today:'2026-11-06', kcal:'-2'}), /app-form\/invalid-calories/)
  const audit = await readFile(join(home,'wish/data/local-food-camera/audit.json'),'utf8'); assert.ok(!audit.includes('rice')); assert.ok(audit.includes('food.save'))
  await rpc('appForm/accept', { form: 'local-food-camera', hash: form.hash })
  console.log('PASS cold boot health, real plugin action and acceptance')
  await stop(); await start(false)
  const reloaded = await invoke('food.today', { today: '2026-11-06' })
  assert.equal(reloaded.todayKcal, 174)
  assert.equal(reloaded.todayFood[0].items[0].staple, true)
  assert.equal((await rpc('appForm/list')).length, 1)
  assert.equal((await rpc('wishMobile/projects'))[0].sessionId,session.sessionId)
  assert.deepEqual(await rpc('wishMobile/read',{collection:'notes'}),[{text:'kept'}])
  console.log('PASS data and accepted catalog persist across DSH restart')
  await writeFile(join(base, 'result.json'), JSON.stringify({ passed: true, engine: '0.2.1-rc.4', checks: ['authenticated-rpc','actual-bundle-installation','profile-restart','health','invoke','accept','persistence'] }, null, 2))
} finally { await stop(); await rm(base, {recursive:true,force:true}) }
