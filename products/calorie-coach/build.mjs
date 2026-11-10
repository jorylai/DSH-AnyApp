import {readFile,writeFile,mkdir,copyFile} from 'node:fs/promises';
import {resolve,dirname} from 'node:path';
import {fileURLToPath} from 'node:url';
import {createHash} from 'node:crypto';
const root=dirname(fileURLToPath(import.meta.url));const read=name=>readFile(resolve(root,name),'utf8');
const output=resolve(root,'package');await mkdir(output,{recursive:true});
let client=await read('legacy/client.js');
const original=client;
function replace(from,to){if(!client.includes(from))throw new Error('Missing anchor: '+from.slice(0,80));client=client.replace(from,to);}
const core=(await read('coach-core.mjs')).replace('/** Local, work-scoped conversation and evidence-backed memory. No network or credentials. */','').replace('export function createCoachCore()','function createCoachCore()');
replace("    const PANEL_ID =",'    // @anyapp/calorie-coach:v2\n    '+core+'\n    const CoachCore = createCoachCore();\n\n    const PANEL_ID =');
replace("      send: '","      up: 'M12 19V5M5 12l7-7 7 7',\n      send: '");
replace("    const CSS = `",'    const CSS = `');
replace('`;\n\n    //#region utilities',await read('coach-style.css')+'`;\n\n    //#region utilities');
// Keep all saved rows visible; retention must never delete old user data on write.
client=client.replace(/\.slice\(-(MEAL_LIMIT|HEALTH_LIMIT|ADVICE_LIMIT|INSIGHT_LIMIT|REPORT_LIMIT)\)/g,'');
replace('    function normalizeStore(raw) {','    function normalizeStoreLegacy(raw) {');
const a=client.indexOf('    function trimStore(store) {'),b=client.indexOf('    //#endregion',a);
client=client.slice(0,a)+`    function normalizeStore(raw) { return normalizeStoreLegacy(raw); }
    function trimStore(store) { return CoachCore.checked(store); }
`+client.slice(b);
const numberStart=client.indexOf('    function NumberSetting(props) {'),numberEnd=client.indexOf('    function KV(props)',numberStart);
client=client.slice(0,numberStart)+(await read('number-setting.js'))+client.slice(numberEnd);
replace('    function SettingsView(props) {','    function LegacySettingsView(props) {');
replace('    function PhotoView(props) {',`    function SettingsView(props) {
      const [section,setSection]=useState('profile');
      return h('div',{className:'kc-settingsHost','data-section':section,'data-goal':props.store.profile.goal},
        h('nav',{className:'kc-settings-nav',role:'tablist','aria-label':'设置分类'},
          [['profile','我的资料'],['reminders','提醒'],['sources','设备与能力'],['data','数据与备份']].map(([key,label])=>h('button',{key,role:'tab',type:'button','aria-selected':section===key,onClick:()=>setSection(key)},label))),
        h(LegacySettingsView,props),
        section==='data'?h('section',{className:'kc-card'},h('h3',null,'教练对话与记忆'),h('p',{className:'kc-hint'},'对话与记忆独立保存在本作品中。可以查看来源、修改、忘记或导出。'),h('button',{className:'wish-button kc-sm','data-variant':'secondary',onClick:props.onMemory,type:'button',style:{marginTop:14}},'查看对话与记忆')):null);
    }

    function PhotoView(props) {`);
replace('    //#region app\n    function App() {',await read('coach-ui.js')+'\n    //#region app\n    function App() {');
replace('      const storeRef = useRef(store);',`      const rawStoreRef = useRef(null);
      const recordViewRef = useRef(store);
      const recordWriterRef = useRef(null);
      const recordRevision = useRef(0);
      const coachBackRef = useRef(null);
      const [coachDepth,setCoachDepth] = useState('');
      const [coachSeed,setCoachSeed] = useState(null);
      const onCoachDepth = useCallback(title=>setCoachDepth(title),[]);
      const storeRef = useRef(store);`);
replace('      const saveTimer = useRef(null);\n      const savePending = useRef(null);\n','');
// Defer positive save notifications until their corresponding write is acknowledged.
replace("        setToast({ text: text, tone: tone || 'info', id: Date.now() });",`        if (/^(已保存|已记录|已添加|已删除|已更新)/.test(text) && recordWriterRef.current) {
          recordWriterRef.current.flush().then(function () {
            setToast({text:text,tone:tone||'good',id:Date.now()});
            if(toastTimer.current)window.clearTimeout(toastTimer.current);
            toastTimer.current=window.setTimeout(function(){setToast(null);},4200);
          }).catch(function(){});
          return;
        }
        setToast({ text: text, tone: tone || 'info', id: Date.now() });`);
const saveStart=client.indexOf('      const commit = useCallback(function (next) {'),saveEnd=client.indexOf('      useEffect(function () {',saveStart);
client=client.slice(0,saveStart)+`      const commit = useCallback(function (next) {
        const stamped = Object.assign({},next,{updatedAt:new Date().toISOString()});
        const original = rawStoreRef.current || {};
        const persisted = CoachCore.patchRecord(original,recordViewRef.current,stamped);
        rawStoreRef.current = persisted;
        recordViewRef.current = stamped;
        storeRef.current=stamped;setStore(stamped);
        const revision=++recordRevision.current;
        setSaveState({state:'saving',message:''});
        if(!recordWriterRef.current && bridgeRef.current?.data)recordWriterRef.current=new CoachCore.RecordWriter(bridgeRef.current.data);
        if(!recordWriterRef.current){setSaveState({state:'error',message:'暂时无法连接本机存储，请重试。'});return Promise.resolve(false);}
        let task;
        try{task=recordWriterRef.current.save(persisted);}catch(e){task=Promise.reject(e);}
        return task.then(function(){if(revision===recordRevision.current)setSaveState({state:'saved',message:''});return true;})
          .catch(function(e){if(revision===recordRevision.current)setSaveState({state:'error',message:errorReason(e)});return false;});
      }, []);
      const retrySave = useCallback(function () {
        if(!recordWriterRef.current)return;
        const revision=++recordRevision.current;setSaveState({state:'saving',message:''});
        let task;try{task=recordWriterRef.current.save(rawStoreRef.current||storeRef.current);}catch(e){task=Promise.reject(e);}
        task.then(function(){if(revision===recordRevision.current)setSaveState({state:'saved',message:''});notify('已保存');})
          .catch(function(e){if(revision===recordRevision.current)setSaveState({state:'error',message:errorReason(e)});});
      }, [notify]);
      const flushSave = useCallback(function () { return recordWriterRef.current?.flush().catch(function(){}); }, []);

`+client.slice(saveEnd);
client=client.replace('          if (saveTimer.current) window.clearTimeout(saveTimer.current);\n','');
replace('            const next = normalizeStore(raw);',`            const next = normalizeStore(raw);
            rawStoreRef.current = CoachCore.clone(raw);
            recordViewRef.current = next;
            recordWriterRef.current = new CoachCore.RecordWriter(bridge.data);`);
replace("                const current = routeRef.current;\n                if (MAIN_ROUTES.indexOf(current.name) >= 0) return false;",`                const current = routeRef.current;
                if(current.name==='coach' && coachBackRef.current && coachBackRef.current())return true;
                if (MAIN_ROUTES.indexOf(current.name) >= 0) return false;`);
// Add a continuation action without altering any stored legacy advice.
replace("        content = h(AdviceDetailView, {\n          advice: showAdvice,",`        content = h(AdviceDetailView, {
          onContinue:function(){setCoachSeed(showAdvice);goTab('coach');},
          advice: showAdvice,`);
replace("          advice.model ? h('p', { className: 'kc-note' }, '模型：' + advice.model) : null,",`          advice.model ? h('p', { className: 'kc-note' }, '模型：' + advice.model) : null,
          h('button',{type:'button',className:'wish-button',onClick:props.onContinue,style:{width:'100%',marginTop:18}},'接着和教练聊'),`);
const coachAt=client.indexOf("      } else if (routeName === 'coach') {"),coachEnd=client.indexOf('\n      const headerProps',coachAt);
client=client.slice(0,coachAt)+`      } else if (routeName === 'coach') {
        content = h(CoachExperience,{store:store,bridge:bridge,seed:coachSeed,navigationRef:coachBackRef,onDepth:onCoachDepth});
      }
`+client.slice(coachEnd);
replace("        title: titles[routeName] || '热量教练',","        title: routeName==='coach'&&coachDepth?coachDepth:titles[routeName] || '热量教练',");
replace("        subtitle: subtitles[routeName] || '',","        subtitle: routeName==='coach'&&coachDepth?'':subtitles[routeName] || '',");
replace("        badge: bridge ? '本机' : '预览',","        badge: null,");
replace('        onBack: subpage ? goBack : null,',"        onBack: routeName==='coach'&&coachDepth?()=>coachBackRef.current?.():subpage ? goBack : null,");
replace("{ className: 'wish-app wish-scaffold kc-root', 'data-active': active ? 'true' : 'false' }","{ className: 'wish-app wish-scaffold kc-root', 'data-active': active ? 'true' : 'false', 'data-coach-nested': routeName==='coach'&&!!coachDepth ? 'true':'false' }");
replace("          MAIN_ROUTES.indexOf(routeName) >= 0\n            ? h(Tabs", "          MAIN_ROUTES.indexOf(routeName) >= 0 && !(routeName==='coach'&&coachDepth)\n            ? h(Tabs");
replace("        coach: '教练建议',","        coach: '你的教练',");
replace("        coach: '基于你的真实记录',","        coach: '把习惯养好，也把自己照顾好',");
// Preserve the original, unprojected document in record exports.
client=client.replace(/trimStore\(storeRef.current\)/g,'trimStore(rawStoreRef.current || storeRef.current)');
// Settings entry opens the shared coach surface.
replace("        content = h(SettingsView, {","        content = h(SettingsView, {\n          onMemory:function(){goTab('coach');},");
// Long disclosures become explicit options instead of seven full settings sections.
replace("'数据只存在本作品的隔离存储里，不上传；导出后可以自己备份。'","'记录保存在本机。仅在你发起 AI 功能时，将所需信息发送给当前模型处理；可以随时导出备份。'");
replace("'提醒由系统 AlarmManager 持久保存，离开页面也会触发；显示“可能延迟”时请留出几分钟余量。'","'离开页面后，系统仍可提醒。系统限制或省电模式可能让提醒稍有延迟，状态以实际同步结果为准。'");
replace("actionLabel: '重试', onAction: props.onRetrySave", "actionLabel: '重试保存', onAction: props.onRetrySave");
client=client.replace("h('button', { type: 'button', className: 'wish-button kc-sm', 'data-variant': 'danger', onClick: function () { props.onClear(false); } }, '全部删除'),",'');
client=client.replace("'会保留你的资料和提醒设置，删掉所有饮食、健康和建议记录。'","'会保留资料和提醒设置，清空饮食、身体和旧建议记录；教练对话与记忆会继续保留。'");
client=client.replace("'清空饮食与健康记录？'","'清空饮食与身体记录？'");
client=client.replace('已保存|已记录|已记下|已添加|已删除|已更新','已保存|已记录|已记下|已添加|已删除|已更新|已清空|已全部删除');
// Existing meals are editable in place; identity, timestamps and item detail survive.
const mealAt=client.indexOf('    function MealRow(props) {'),mealEnd=client.indexOf('    function FoodNoteCard',mealAt);
let mealRow=client.slice(mealAt,mealEnd);
mealRow=mealRow.replace("'div',\n          { className: 'kc-mealBody' },","'button',\n          { type:'button', className: 'kc-mealBody kc-editMeal', 'aria-label':'编辑这餐', onClick:function(){if(props.onEdit)props.onEdit(meal);} },");
client=client.slice(0,mealAt)+mealRow+client.slice(mealEnd);
client=client.replaceAll('meal: meal, onDelete: props.onDeleteMeal','meal: meal, onDelete: props.onDeleteMeal, onEdit:props.onEditMeal');
client=client.replaceAll('onDeleteMeal: deleteMeal,',"onDeleteMeal: deleteMeal,\n          onEditMeal:function(meal){setManualInitial(meal);navigate('manual',true);},");
replace('        const meal = normalizeMeal(Object.assign({}, draft, { id: uid(), date: draft.date || localDate(), at: new Date().toISOString() }));',
  "        const existing=current.meals.find(function(item){return item.id===draft.id;});\n        const meal = normalizeMeal(Object.assign({},existing||{}, draft, { id: existing?existing.id:uid(), date: draft.date || localDate(), at: existing?existing.at:new Date().toISOString() }));");
replace('commit(Object.assign({}, current, { meals: current.meals.concat([meal]) }));',
  'commit(Object.assign({}, current, { meals: existing?current.meals.map(function(item){return item.id===existing.id?meal:item;}):current.meals.concat([meal]) }));');
replace("else notify('已记下 ' + Math.round(meal.kcal) + ' 千卡', 'good');", "else notify(existing?'已更新这一餐':'已记下 ' + Math.round(meal.kcal) + ' 千卡', 'good');");
const manualAt=client.indexOf('    function ManualMealView(props) {'),manualEnd=client.indexOf('    function CalcView',manualAt);
let manual=client.slice(manualAt,manualEnd).replace('        props.onSave({\n          type:', '        props.onSave({\n          id:init&&init.id, items:init&&init.items||[], at:init&&init.at,\n          type:').replace("source: 'manual',", "source: init&&init.source||'manual',");
manual=manual.replace("onClick: save }, '保存'", "onClick: save }, init&&init.id?'保存修改':'保存这一餐'");
manual=manual.replace('      const save = function () {',"      const save = function () {\n        const fields=Array.from(document.querySelectorAll('input[id^=\"mm-\"]'));if(fields.some(input=>!input.reportValidity()))return;");
client=client.slice(0,manualAt)+manual+client.slice(manualEnd);
replace("        manual: '手动记录饮食',", "        manual: manualInitial&&manualInitial.id?'修改这一餐':'手动记录饮食',");
client=client.replace('已保存|已记录|已添加|已删除|已更新','已保存|已记录|已记下|已添加|已删除|已更新');

// Simplify the dashboard's stale one-shot advice section into a coach entry.
const todayStart=client.indexOf('    function TodayView(props) {'),todayEnd=client.indexOf('    function LogView(props)',todayStart);
let today=client.slice(todayStart,todayEnd);const hintAt=today.indexOf("        h(SectionHead, { title: '教练提示'");
if(hintAt<0)throw new Error('today coach anchor');
today=today.slice(0,hintAt)+`        h('section',{className:'kc-card'},h('h3',null,'把想法说给教练听'),h('p',{className:'kc-hint'},'今天哪里难坚持，或下一餐怎么安排，都可以接着聊。'),h('button',{type:'button',className:'wish-button kc-sm','data-variant':'secondary',onClick:props.onCoach,style:{marginTop:15}},'和教练聊聊')),
      );
    }

`;
client=client.slice(0,todayStart)+today+client.slice(todayEnd);
if(client.includes('savePending.current')||client.includes('saveTimer.current'))throw new Error('old save timer still referenced');
await writeFile(resolve(output,'client.js'),client);
for(const name of ['index.js','icon.svg','cordis.patch.yml','locale/zh.json','locale/en.json']){await mkdir(dirname(resolve(output,name)),{recursive:true});await copyFile(resolve(root,'legacy',name),resolve(output,name));}
const pkg=JSON.parse(await read('legacy/package.json'));pkg.version='1.1.0';pkg.description='热量教练：记录饮食与身体变化，持续对话，记住你的偏好、目标和习惯。';pkg.files=pkg.files.filter(x=>x!=='README.md');
await writeFile(resolve(output,'package.json'),JSON.stringify(pkg,null,2)+'\n');
const envelope=JSON.parse(await read('legacy/envelope.json'));envelope.declaredVersion=pkg.version;envelope.files=[];
for(const path of ['client.js','cordis.patch.yml','icon.svg','index.js','locale/en.json','locale/zh.json','package.json']){
 const bytes=await readFile(resolve(output,path));envelope.files.push({path,data:bytes.toString('base64'),sha256:createHash('sha256').update(bytes).digest('hex')});
}
envelope.hash=createHash('sha256').update(JSON.stringify(envelope.files)).digest('hex');
await writeFile(resolve(root,'calorie-coach-1.1.0.anyapp'),JSON.stringify(envelope));
const canonical=(text,work)=>text.split(work).join('__WORK_ID__').split(work.replaceAll('-','_')).join('__WORK_RPC__');
const baseline=createHash('sha256').update(canonical(original,envelope.sourceId)).digest('hex');
await writeFile(resolve(root,'update.json'),JSON.stringify({kind:'calorie',version:'1.1.0',sourceId:envelope.sourceId,baselineClientHashes:[baseline],targetClientHash:createHash('sha256').update(canonical(client,envelope.sourceId)).digest('hex'),bundleHash:envelope.hash},null,2)+'\n');
console.log(JSON.stringify({clientBytes:Buffer.byteLength(client),packageHash:envelope.hash,baselineClient:baseline}));
