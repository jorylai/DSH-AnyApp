/* Own preset sources. Packaging includes code/assets only; no user data. */
const {mkdirSync,writeFileSync}=require('node:fs');
const {join}=require('node:path');
const {createHash}=require('node:crypto');
const root=join(__dirname,'../app/assets/presets');mkdirSync(root,{recursive:true});
const hash=bytes=>createHash('sha256').update(bytes).digest('hex');
for(const kind of ['notes','brief']){
 const id=`local-preset-${kind}`,title=kind==='notes'?'拾光笔记':'晨间简报';
 const client=`window.__ModuleLoader__.load({id:'@local/${id}',factory(require){
const React=require('react'),h=React.createElement,ID='${id}';
function App(){
 const [ready,setReady]=React.useState(false),[items,setItems]=React.useState([]),[text,setText]=React.useState(''),[busy,setBusy]=React.useState(false),[error,setError]=React.useState(''),[imports,setImports]=React.useState([]);
 const zh=(navigator.language||'zh').startsWith('zh'),t=(a,b)=>zh?a:b;
 React.useEffect(()=>{let live=true;async function boot(){if(!window.dshWish||!live)return;try{const saved=await dshWish.data.read('entries');if(live){setItems(Array.isArray(saved)?saved:[]);setImports(await dshWish.imports.list());setReady(true);await dshWish.ui.ready();}}catch(e){if(live)setError(e.message);}}
 boot();window.addEventListener('dsh-wish-ready',boot);return()=>{live=false;window.removeEventListener('dsh-wish-ready',boot)};},[]);
 async function save(value){setBusy(true);setError('');try{let answer=value;if('${kind}'==='brief')answer=(await dshWish.ai.complete({prompt:value})).text;const next=[{id:Date.now(),title:value,text:answer},...items].slice(0,100);await dshWish.data.write('entries',next);setItems(next);setText('');}catch(e){setError(e.message)}finally{setBusy(false)}}
 async function readImport(id){setError('');try{const value=await dshWish.imports.read(id);setText(value.text||value.url||t('此条分享包含附件，可在作品记录中查看。','This share contains a file. Open work records to inspect it.'));}catch(e){setError(e.message)}}
 return h('main',{className:'wish-app wish-scaffold'},h('div',{className:'wish-page'},
 h('header',{className:'wish-header'},h('h1',null,t('${title}','${kind==='notes'?'Collected notes':'Morning brief'}'))),
 h('div',{className:'wish-content wish-stack'},h('p',{className:'wish-muted'},t('${kind==='notes'?'收下片刻，留给日后。':'把值得知道的，留给清晨。'}','${kind==='notes'?'Save a thought for later.':'Make room for what matters today.'}')),
 '${kind}'==='brief'&&h('button',{className:'wish-button','data-variant':'secondary',onClick:()=>dshWish.background.open().catch(e=>setError(e.message)),disabled:!ready},t('定时任务与结果','Scheduled tasks and results')),
 imports.length>0&&h('section',{className:'wish-card'},h('h2',null,t('从分享中收集','Shared with this work')),imports.map(item=>h('button',{key:item.id,className:'wish-button','data-variant':'secondary',onClick:()=>readImport(item.id)},item.title||item.name||t('查看分享','Open share')))),
 !ready&&h('div',{className:'wish-skeleton',role:'status','aria-label':t('正在读取','Loading')}),
 ready&&!items.length&&h('section',{className:'wish-empty'},t('第一条记录，会从这里开始。','Your first entry starts here.')),
 items.map(item=>h('article',{className:'wish-card',key:item.id},h('h2',null,item.title),h('p',{style:{whiteSpace:'pre-wrap'}},item.text))),
 busy&&h('div',{className:'wish-skeleton',role:'status','aria-label':t('正在处理','Working')}),error&&h('p',{className:'wish-error',role:'alert'},error)),
 h('form',{className:'wish-composer',onSubmit:e=>{e.preventDefault();if(text.trim()&&!busy)save(text.trim());}},h('textarea',{className:'wish-input',rows:2,value:text,maxLength:10000,onChange:e=>setText(e.target.value),placeholder:t('${kind==='notes'?'记下此刻…':'想让 AI 整理什么？'}','${kind==='notes'?'A thought to keep…':'What would you like to explore?'}'),'aria-label':t('输入内容','Your text'),style:{maxHeight:140,overflow:'auto'}}),h('button',{className:'wish-button',type:'submit',disabled:!ready||busy||!text.trim()},t('${kind==='notes'?'保存':'提问'}','${kind==='notes'?'Save':'Ask'}')))))
}
return {inject:['slots','layout'],apply(ctx){ctx.effect(()=>{let remove;function attach(){if(window.dshWish){remove?.();remove=dshWish.registerPanel(ID,()=>ctx.layout.selectPanel(ID));}}attach();window.addEventListener('dsh-wish-ready',attach);return()=>{remove?.();window.removeEventListener('dsh-wish-ready',attach)}});ctx.slots.inject('main',()=>ctx.slots.register({name:'main',key:ID},App));ctx.slots.inject('sidebar.panellist',()=>ctx.slots.register({name:'sidebar.panellist',id:ID,order:12,label:()=>'${title}'},()=>h('span',null,'◈')));}}
}});`;
 const pkg={name:`@local/${id}`,version:'1.0.0',private:true,type:'module',exports:{'.':'./index.js','./client':'./client.js'},files:['index.js','client.js','cordis.patch.yml'],dsh:{bundle:{patch:'./cordis.patch.yml'},client:{platform:'web',immediately:true,inject:['@deepseek-ai/dsh-client-ui-conversation']}}};
 const sources={'package.json':JSON.stringify(pkg,null,2)+'\n','index.js':'export function apply() {}\n','client.js':client,'cordis.patch.yml':`- insert:\n    - id: ${id}\n      name: '@local/${id}'\n`};
 const files=Object.keys(sources).sort().map(path=>{const bytes=Buffer.from(sources[path]);return {path,data:bytes.toString('base64'),sha256:hash(bytes)}});
 writeFileSync(join(root,`${kind}.anyapp`),JSON.stringify({format:'dsh-anyapp-plugin/1',api:2,portable:true,sourceId:id,title,declaredVersion:'1.0.0',hash:hash(JSON.stringify(files)),files}));
}
