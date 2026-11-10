import test from 'node:test'
import assert from 'node:assert/strict'
import { mkdtemp, rm, readFile } from 'node:fs/promises'
import { join } from 'node:path'
import { tmpdir } from 'node:os'
import vm from 'node:vm'
import { ProjectStore, selectModelRoute, validateAiRequest } from '../../app/assets/engine/forms/mobile-core.mjs'

test('a signed-in DeepSeek account replaces the unavailable API-key default', () => {
  const route = selectModelRoute({ provider: 'deepseek-official', model: 'deepseek-flash' }, [
    { id: 'deepseek-account', models: [{ id: 'deepseek-flash', name: 'Flash', inputModalities: ['text','image'] }] },
  ])
  assert.equal(route.provider, 'deepseek-account')
  assert.ok(route.inputModalities.includes('image'))
})
test('an available explicit model is kept and network failures never silently switch billing routes', () => {
  const groups = [ {id:'custom', models:[{id:'one', name:'one'}]}, {id:'deepseek-account', models:[{id:'flash',name:'flash'}]} ]
  assert.equal(selectModelRoute({provider:'custom',model:'one'},groups).provider,'custom')
  assert.throws(() => selectModelRoute({provider:'custom',model:'one'},groups.slice(1),[{id:'custom'}]), /UNAVAILABLE/)
  assert.throws(() => selectModelRoute({},[]), /NOT_CONFIGURED/)
})
test('Creator drafts retain their real session and published entry through restart; removal preserves siblings', async t => {
  const dir = await mkdtemp(join(tmpdir(),'wish-creator-'))
  t.after(() => rm(dir,{recursive:true,force:true}))
  const store = new ProjectStore(dir)
  await store.create('local-plants','植物收藏夹','Make a plant collection')
  await store.bind('local-plants','session-1234')
  await store.write('local-plants','records',[{name:'mint'}])
  await store.publish('local-plants','雨林小屋','local-plants')
  await store.create('local-books','Books')
  await store.write('local-books','records',[{title:'kept'}])
  const restored = new ProjectStore(dir)
  const project = (await restored.projects()).find(p=>p.id==='local-plants')
  assert.equal(project.panel,'local-plants');assert.equal(project.sessionId,'session-1234')
  assert.deepEqual(await restored.read('local-plants','records'),[{name:'mint'}])
  await restored.removeProject('local-plants')
  assert.deepEqual((await restored.projects()).map(p=>p.id),['local-books'])
  assert.deepEqual(await restored.read('local-books','records'),[{title:'kept'}])
  await assert.rejects(restored.create('../web','bad'))
  assert.throws(() => restored.publish('local-books','Books','../outside'))
})
test('model requests reject oversized inputs and non-image media types before dispatch', () => {
  assert.throws(()=>validateAiRequest({prompt:'x'.repeat(40001)}),/INVALID_REQUEST/)
  assert.throws(()=>validateAiRequest({prompt:'read',image:{data:'abc',mediaType:'text/html'}}),/INVALID_IMAGE/)
})
test('rebinding a missing imported conversation preserves prior Creator identity and all work data', async t => {
  const root = await mkdtemp(join(tmpdir(), 'wish-creator-rebind-'))
  t.after(() => rm(root, {recursive:true, force:true}))
  const store = new ProjectStore(root)
  await store.create('local-imported', 'Radar', 'Compare products')
  await store.bind('local-imported', 'session-original')
  await store.write('local-imported', 'records', [{id:'kept'}])
  await store.bind('local-imported', 'session-local')
  await store.bind('local-imported', 'session-local')
  const restored = new ProjectStore(root)
  const project = (await restored.projects())[0]
  assert.equal(project.sessionId, 'session-local')
  assert.deepEqual(project.creatorSessionHistory, ['session-original'])
  assert.deepEqual(await restored.read('local-imported', 'records'), [{id:'kept'}])
})
test('Web bridge matches document nonce, propagates cancellation and exposes no generic RPC', async () => {
  const source = await readFile(new URL('../../app/assets/web/dsh_wish.js',import.meta.url),'utf8')
  const posted=[]; const window={ DshWish:{postMessage:message=>posted.push(JSON.parse(message))}, dispatchEvent:()=>{} };window.top=window
  const context=vm.createContext({window,Event:class{},setTimeout,clearTimeout})
  vm.runInContext(`(${source})({nonce:'doc-one',projectId:'local-plants'})`,context)
  assert.equal(window.dshWish.rpc,undefined)
  let opened = 0
  const unregister = window.dshWish.registerPanel('local-plants',()=>opened++)
  assert.equal(window.dshWish.openPanel('local-plants'),true)
  assert.equal(opened,1)
  unregister(); assert.equal(window.dshWish.openPanel('local-plants'),false)
  const reading=window.dshWish.data.read('records')
  const request=posted[0]
  window.__dshWishReply({nonce:'another-document',id:request.id,ok:true,value:'wrong'})
  window.__dshWishReply({nonce:'doc-one',id:request.id,ok:true,value:[{name:'mint'}]})
  assert.deepEqual(await reading,[{name:'mint'}])
  const call=window.dshWish.ai.complete({prompt:'hi'})
  window.__dshWishReply({nonce:'doc-one',id:posted[1].id,ok:false,error:'cancelled'})
  await assert.rejects(call,/cancelled/)
  let refreshedOpen = 0
  window.dshWish.registerPanel('local-plants',()=>refreshedOpen++)
  const obsolete = window.dshWish.data.read('records')
  const previousBridge = window.dshWish
  const rejected = assert.rejects(obsolete,/cancelled by navigation/)
  vm.runInContext(`(${source})({nonce:'doc-two',projectId:'local-plants'})`,context)
  await rejected
  assert.notEqual(window.dshWish,previousBridge,'mounted clients can retry loading after document renewal')
  assert.equal(window.dshWish.openPanel('local-plants'),true)
  assert.equal(refreshedOpen,1)
  const refreshed = window.dshWish.data.read('records')
  const latest = posted.at(-1)
  assert.equal(latest.nonce,'doc-two')
  window.__dshWishReply({nonce:'doc-one',id:latest.id,ok:true,value:'obsolete'})
  window.__dshWishReply({nonce:'doc-two',id:latest.id,ok:true,value:'current'})
  assert.equal(await refreshed,'current')
  const frame={top:{},dispatchEvent:()=>{}}; const child=vm.createContext({window:frame})
  vm.runInContext(`(${source})({nonce:'x',projectId:'local-plants'})`,child)
  assert.equal(frame.dshWish,undefined)
})


test('unpublish retains installed entry, Creator session and namespace data across restart', async () => {
  const root = await mkdtemp(join(tmpdir(), 'wish-unpublish-'))
  try {
    const store = new ProjectStore(root)
    await store.create('local-preserve', 'Timer', 'Build a timer')
    await store.bind('local-preserve', 'session-preserved')
    await store.write('local-preserve', 'records', [{minutes:25}])
    await store.publish('local-preserve', 'Timer', 'local-preserve')
    const draft = await store.unpublish('local-preserve')
    assert.equal(draft.state, 'draft')
    assert.equal(draft.panel, 'local-preserve')
    assert.equal(draft.sessionId, 'session-preserved')
    const reopened = new ProjectStore(root)
    assert.deepEqual(await reopened.read('local-preserve','records',null), [{minutes:25}])
    assert.equal((await reopened.projects())[0].state, 'draft')
  } finally { await rm(root, {recursive:true,force:true}) }
})

test('public phone and reminder calls cannot supply a different work namespace', async () => {
  const source = await readFile(new URL('../../app/assets/web/dsh_wish.js', import.meta.url),'utf8')
  const posted = []; const window = {dispatchEvent(){},DshWish:{postMessage: s => posted.push(JSON.parse(s))}}
  window.top = window
  vm.runInNewContext(`(${source})({projectId:'local-one',nonce:'one'})`, {window,Event:class{},Map,Promise,Date,setTimeout,clearTimeout,Object,Error})
  const finish = async promise => {
    const m = posted.at(-1)
    window.__dshWishReply({id:m.id,nonce:m.nonce,ok:true,value:{ok:true}})
    await promise; return m
  }
  const phoneTask = await finish(window.dshWish.agent.start('Compare this item'))
  assert.equal(phoneTask.method, 'agent.start')
  assert.equal(phoneTask.args.phone, true)
  const linkTask = await finish(window.dshWish.agent.start('Compare this shared link', {phone:false}))
  assert.equal(linkTask.method, 'agent.start')
  assert.equal(linkTask.args.phone, false)
  assert.equal(linkTask.projectId, undefined)
  const call = await finish(window.dshWish.phone.call('lease','screen',{}))
  assert.deepEqual(call.args, {ticket:'lease',tool:'screen',args:{}})
  const alarm = await finish(window.dshWish.reminders.schedule({id:'timer',at:12345,title:'Done'}))
  assert.equal(alarm.method, 'reminders.schedule')
  assert.equal(alarm.projectId, undefined)
  assert.equal(window.dshWish.projectId,'local-one')
})


test('shared task component reflects native pause and agent stop and disposes its polling', async () => {
  const source = await readFile(new URL('../../app/assets/web/dsh_wish.js', import.meta.url),'utf8')
  class Element {
    constructor(tag) { this.tag=tag; this.children=[]; this.style={};this.dataset={};this.value='';this.attributes={}; }
    append(...items){this.children.push(...items)}
    appendChild(item){this.children.push(item)}
    replaceChildren(...items){this.children=items}
    setAttribute(k,v){this.attributes[k]=v}
    remove(){this.removed=true}
  }
  const calls=[];let paused=false,running=true,cleared=0,tick
  const document={documentElement:{lang:'zh'},createElement:tag=>new Element(tag)}
  const window={dispatchEvent(){},DshWish:{postMessage(raw){
    const m=JSON.parse(raw);calls.push(m)
    let value
    if(m.method==='agent.status')value={running,events:[{type:'tool',name:'mcp__phone__screen'}]}
    if(m.method==='capabilities.status')value={phoneStatus:{task:{paused}}}
    if(m.method==='phone.pause'){paused=m.args.paused;value=true}
    if(m.method==='agent.stop'){running=false;value=true}
    if(m.method==='agent.steer')value=true
    window.__dshWishReply({nonce:m.nonce,id:m.id,ok:true,value})
  }}}
  window.top=window
  vm.runInNewContext(`(${source})({projectId:'local-task',nonce:'task',locale:'zh'})`,{window,document,Event:class{},Map,Promise,Date,setTimeout,clearTimeout,Object,Error,
    setInterval:f=>{tick=f;return 1},clearInterval:()=>cleared++})
  const host=new Element('div');const control=window.dshWish.ui.mountTaskControl(host)
  await new Promise(resolve=>setImmediate(resolve))
  const details=host.children[0],summary=details.children[0],title=summary.children[0],actions=summary.children[1]
  assert.equal(title.textContent,'正在执行')
  assert.equal(actions.children[0].disabled,false)
  assert.equal(calls.some(c=>c.method==='agent.start'),false)
  actions.children[0].onclick({preventDefault(){},stopPropagation(){}})
  await new Promise(resolve=>setImmediate(resolve))
  assert.equal(paused,true);assert.equal(title.textContent,'已暂停')
  actions.children[1].onclick({preventDefault(){},stopPropagation(){}})
  await new Promise(resolve=>setImmediate(resolve))
  assert.equal(running,false);assert.equal(actions.children[1].disabled,true)
  control.dispose();const n=calls.length;await tick()
  assert.equal(calls.length,n);assert.equal(cleared,1);assert.equal(details.removed,true)
})
