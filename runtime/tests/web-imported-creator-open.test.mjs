import test from 'node:test'
import assert from 'node:assert/strict'
import {readFile} from 'node:fs/promises'
import vm from 'node:vm'

const source = await readFile(new URL('../../app/assets/web/dsh_web_open.js', import.meta.url), 'utf8')
async function open({delay=0, actual='session-imported', legacy=false}={}) {
  let now=0, hops=0
  const reports=[], saved=new Map([['dsh.sessions.current',JSON.stringify({sessionId:'session-imported'})]])
  const context={URL,Date:class extends Date { static now(){return now} },
    setTimeout(fn,ms){now+=ms;queueMicrotask(fn)},
    localStorage:{getItem:k=>saved.get(k),setItem:(k,v)=>saved.set(k,v)},
    sessionStorage:{getItem:()=>null,removeItem(){},setItem(){}},
    location:{href:'http://127.0.0.1:3000/',replace(){hops++}},history:{replaceState(){}},
    document:{addEventListener(){},querySelector(q){
      if(q==='[data-slot="sidebar"]')return {}
      if(q==='[data-slot="conversation.session"]'&&legacy)return {}
      return null
    },querySelectorAll(q){return q==='[data-conversation-session]'&&!legacy&&now>=delay
      ? [{getAttribute:()=>actual}] : []}},
    DshAppOpen:{postMessage:m=>reports.push(JSON.parse(m))}}
  context.window=context
  vm.runInNewContext(source,context)
  context.__dshAppOpen({session:'session-imported'})
  await context.__dshAppOpening
  return {reports,hops,now}
}
test('an imported empty Creator is recognized by its official session identity',async()=>{
  const result=await open()
  assert.equal(result.reports.at(-1).ok,true);assert.equal(result.hops,0)
})
test('cold Creator rendering longer than three seconds does not trigger a false missing-session hop',async()=>{
  const result=await open({delay:5400})
  assert.equal(result.reports.at(-1).ok,true);assert.equal(result.hops,0);assert.ok(result.now>=5400)
})
test('another conversation on screen cannot satisfy the imported Creator target',async()=>{
  const result=await open({actual:'session-other'})
  assert.equal(result.hops,1);assert.equal(result.reports.length,0)
})
test('older clients without the session identity attribute retain their view-slot fallback',async()=>{
  assert.equal((await open({legacy:true})).reports.at(-1).ok,true)
})
