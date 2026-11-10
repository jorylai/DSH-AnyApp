import {readFile,writeFile,mkdir} from 'node:fs/promises';
import {dirname,resolve} from 'node:path';
import {fileURLToPath} from 'node:url';
import {createHash} from 'node:crypto';
import vm from 'node:vm';
import {buildRadar} from '../radar-release/build.mjs';
const root=dirname(fileURLToPath(import.meta.url));
const sha=value=>createHash('sha256').update(value).digest('hex');
const read=path=>readFile(resolve(root,path),'utf8');
const core=(await read('core.mjs')).replace('export function createStarterCore()','function createStarterCore()');
const common=await read('common.js'),style=await read('style.css');
const definitions=[{kind:'radar',title:'比价雷达',en:'Price Radar',desc:'分享或粘贴商品，核对规格与可访问来源，保存有据可查的价格。',icon:'radar'},{kind:'pomodoro',title:'番茄钟',en:'Pomodoro',desc:'按真实时间专注与休息，离开页面继续计时，结束后收到系统提醒。',icon:'clock'}];
for(const def of definitions){
 if(def.kind==='radar') {
  const envelope=await buildRadar(resolve(root,'radar.anyapp'));
  console.log(JSON.stringify({kind:'radar',version:envelope.declaredVersion,hash:envelope.hash}));
  continue;
 }
 const id=`local-preset-${def.kind}`,dir=resolve(root,'package',def.kind);await mkdir(resolve(dir,'locale'),{recursive:true});
 const body=(core+'\n'+common+'\n'+await read(def.kind+'.js')).replaceAll('__WORK_ID__',id).replaceAll('__ICON__',def.icon);
 const client=`window.__ModuleLoader__.load({id:'@local/${id}',factory(require){\n${body}\n}});\n`;
 new vm.Script(client,{filename:def.kind+'/client.js'});
 const svg=def.kind==='radar'?`<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 128 128"><defs><linearGradient id="g" x2="1" y2="1"><stop stop-color="#304471"/><stop offset="1" stop-color="#111e34"/></linearGradient></defs><rect x="3" y="3" width="122" height="122" rx="34" fill="url(#g)" stroke="#a9bdff" stroke-opacity=".25"/><g fill="none" stroke="#b9caff" stroke-width="3"><circle cx="64" cy="64" r="38" opacity=".28"/><circle cx="64" cy="64" r="25" opacity=".45"/><path d="M64 26v38l27-27" stroke-linecap="round"/></g><circle cx="64" cy="64" r="5" fill="#d3ddff"/><circle cx="85" cy="77" r="6" fill="#9adbc7"/><circle cx="42" cy="46" r="3" fill="#9aafff"/></svg>`:`<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 128 128"><defs><linearGradient id="g" x2="1" y2="1"><stop stop-color="#313f6d"/><stop offset="1" stop-color="#131e34"/></linearGradient></defs><rect x="3" y="3" width="122" height="122" rx="34" fill="url(#g)" stroke="#a9bdff" stroke-opacity=".25"/><circle cx="64" cy="69" r="34" fill="none" stroke="#b9caff" stroke-width="3"/><path d="M64 47v23l15 9M55 20h18M64 20v13M91 39l6-6" fill="none" stroke="#b9caff" stroke-width="4" stroke-linecap="round"/><path d="M44 101a37 37 0 0 0 49-17" fill="none" stroke="#9adbc7" stroke-width="4" stroke-linecap="round"/><circle cx="64" cy="69" r="4" fill="#9adbc7"/></svg>`;
 const pkg={name:`@local/${id}`,version:'1.0.0',private:true,type:'module',description:def.desc,exports:{'.':'./index.js','./client':'./client.js','./icon':'./icon.svg','./locale/*.json':'./locale/*.json'},files:['client.js','cordis.patch.yml','icon.svg','index.js','locale/*.json','style.css'],dsh:{bundle:{patch:'./cordis.patch.yml'},client:{platform:'web',immediately:true,inject:['@deepseek-ai/dsh-client-ui-conversation']}}};
 // The official client loader does not load loose CSS automatically. Keep a
 // portable source file and inject the same bytes through its scoped plugin.
 const styled=client.replace("const React=require('react')",`const STYLE=${JSON.stringify(style)};\nconst React=require('react')`).replace("function registerProduct(App,title){return",`function registerProduct(App,title){return`).replace("apply(ctx){ctx.effect(()=>{let remove;",`apply(ctx){ctx.effect(()=>{let remove;let css=document.getElementById(ID+'-style');if(!css){css=document.createElement('style');css.id=ID+'-style';css.textContent=STYLE;document.head.appendChild(css);}`).replace("return()=>{remove?.();window.removeEventListener('dsh-wish-ready',bind);};",`return()=>{remove?.();css.remove();window.removeEventListener('dsh-wish-ready',bind);};`);
 new vm.Script(styled,{filename:def.kind+'/styled-client.js'});
 const content={'client.js':styled,'cordis.patch.yml':`- insert:\n    - id: ${id}\n      name: '@local/${id}'\n`,'icon.svg':svg,'index.js':'export function apply() {}\n','locale/en.json':JSON.stringify({title:def.en})+'\n','locale/zh.json':JSON.stringify({title:def.title})+'\n','package.json':JSON.stringify(pkg,null,2)+'\n','style.css':style};
 const files=[];for(const path of Object.keys(content).sort()){const bytes=Buffer.from(content[path]);await writeFile(resolve(dir,path),bytes);files.push({path,data:bytes.toString('base64'),sha256:sha(bytes)});}
 const envelope={format:'dsh-anyapp-plugin/1',api:2,portable:true,sourceId:id,title:def.title,declaredVersion:pkg.version,hash:sha(JSON.stringify(files)),files};
 const json=JSON.stringify(envelope);await writeFile(resolve(root,def.kind+'.anyapp'),json);console.log(JSON.stringify({kind:def.kind,id,title:def.title,sourceBytes:Object.values(content).reduce((sum,text)=>sum+Buffer.byteLength(text),0),bytes:Buffer.byteLength(json),hash:envelope.hash}));
}
