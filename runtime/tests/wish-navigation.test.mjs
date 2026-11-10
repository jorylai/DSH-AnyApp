import {test} from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import vm from 'node:vm';
const source=readFileSync(new URL('../../app/assets/web/dsh_wish.js',import.meta.url),'utf8');
function boot(){
  const messages=[];const listeners=new Map();
  const context={Map,Date,Promise,Object,Error,JSON,String,setTimeout,clearTimeout,Event:class{constructor(type){this.type=type;}},CustomEvent:class{constructor(type,args){this.type=type;this.detail=args.detail;}},requestAnimationFrame:fn=>fn(),
    document:{head:{appendChild(){}},getElementById:()=>null,createElement:()=>({}),querySelector:()=>null,documentElement:{style:{setProperty(){}},toggleAttribute(){} }},
    DshWish:{postMessage:text=>messages.push(JSON.parse(text))},dispatchEvent:e=>(listeners.get(e.type)||[]).forEach(fn=>fn(e)),innerWidth:384,innerHeight:600};
  context.window=context;context.top=context;
  vm.runInNewContext(`(${source})({nonce:'test',projectId:'local-test',locale:'zh'})`,context);
  return{window:context,messages};
}
test('work root never enters generic DSH panel/chat history',()=>{
  const {window:w}=boot();let layers=0,subpage=true;
  w.__dshAppBack=options=>{assert.equal(options.layersOnly,true);layers++;return 'none';};
  const off=w.dshWish.ui.registerNavigation({back:()=>{if(subpage){subpage=false;return true;}return false;},settings:()=>{}});
  assert.equal(w.__dshWishBack(),true);assert.equal(w.__dshWishBack(),false);assert.equal(layers,2);
  off();assert.equal(w.__dshWishBack(),false);
});
test('topmost DSH popup closes before a work subpage',()=>{
  const {window:w}=boot();let called=false;
  w.__dshAppBack=()=> 'popup';w.dshWish.ui.registerNavigation({back:()=>{called=true;return true;}});
  assert.equal(w.__dshWishBack(),true);assert.equal(called,false);
});

test('travel deletion crosses the scoped Android bridge and awaits the host result', async()=>{
  const {window:w,messages}=boot();
  const removed=w.dshWish.travel.remove('trip-test');
  const message=messages.at(-1);
  assert.equal(message.method,'travel.remove');assert.equal(message.args.id,'trip-test');
  w.__dshWishReply({nonce:'test',id:message.id,ok:true,value:{removed:true}});
  assert.equal((await removed).removed,true);
});
