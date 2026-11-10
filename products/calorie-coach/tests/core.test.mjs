import test from 'node:test';import assert from 'node:assert/strict';
import {createCoachCore} from '../coach-core.mjs';
const C=createCoachCore();
function storage(initial={}){const db=new Map(Object.entries(structuredClone(initial))),writes=[];return {db,writes,fail:null,async read(k){assert.match(k,/^[a-zA-Z][a-zA-Z0-9]{0,40}$/);return db.has(k)?structuredClone(db.get(k)):[];},async write(k,v){assert.match(k,/^[a-zA-Z][a-zA-Z0-9]{0,40}$/);writes.push(k);if(this.fail===k)throw new Error('simulated disk failure');db.set(k,structuredClone(v));return {saved:true};}};}
test('legacy patch keeps unknown fields, invisible rows and long values while applying explicit edits',()=>{
 const raw={v:3,custom:{kept:true},profile:{name:'演示',notes:'长'.repeat(600),future:42},meals:[{id:'one',name:'原名',secretExtension:7},null,{legacy:'unparsed'},{id:'two',kcal:200}],health:[]};
 const before={profile:{name:'演示',notes:'长'.repeat(400)},meals:[{id:'one',name:'原名'},{id:'two',kcal:200}],health:[]};
 const after=structuredClone(before);after.profile.name='新称呼';after.meals[0].name='新名称';after.meals.splice(1,1);after.meals.push({id:'new',name:'新的'});
 const result=C.patchRecord(raw,before,after);
 assert.equal(result.profile.notes.length,600);assert.equal(result.profile.future,42);assert.deepEqual(result.custom,{kept:true});assert.equal(result.meals[0].secretExtension,7);assert.equal(result.meals[0].name,'新名称');assert.equal(result.meals.filter(x=>x?.id==='two').length,0);assert.ok(result.meals.includes(null));assert.ok(result.meals.some(x=>x?.legacy==='unparsed'));assert.ok(result.meals.some(x=>x?.id==='new'));assert.equal(raw.profile.name,'演示');
});
test('record writer snapshots before first mutation and never overwrites its original backup',async()=>{
 const data=storage({records:{profile:{name:'旧称呼'},meals:Array.from({length:900},(_,i)=>({id:String(i),kcal:i}))}});const original=structuredClone(data.db.get('records'));
 const writer=new C.RecordWriter(data);await writer.save({...original,profile:{name:'新称呼'}});await writer.save({...original,profile:{name:'再次修改'}});
 assert.deepEqual(data.db.get('recordsV3Backup').value,original);assert.equal(data.db.get('records').meals.length,900);assert.equal(data.db.get('records').profile.name,'再次修改');
});
test('backup failure blocks record replacement, and retry succeeds',async()=>{
 const data=storage({records:{meals:[{id:'kept'}]}});data.fail='recordsV3Backup';const writer=new C.RecordWriter(data);await assert.rejects(writer.save({meals:[{id:'changed'}]}));assert.equal(data.db.get('records').meals[0].id,'kept');data.fail=null;await writer.save({meals:[{id:'changed'}]});assert.equal(data.db.get('recordsV3Backup').value.meals[0].id,'kept');
});
test('writes serialize in revision order and survive a failed predecessor',async()=>{
 const data=storage({records:{value:0}});let release;const baseWrite=data.write.bind(data);let held=true;data.write=async(k,v)=>{if(k==='records'&&held){held=false;await new Promise(r=>release=r);}return baseWrite(k,v);};
 const writer=new C.RecordWriter(data);const one=writer.save({value:1}),two=writer.save({value:2});while(!release)await new Promise(r=>setTimeout(r,0));release();await Promise.all([one,two]);assert.equal(data.db.get('records').value,2);
 data.fail='records';await assert.rejects(writer.save({value:3}));data.fail=null;await writer.save({value:4});assert.equal(data.db.get('records').value,4);
});
test('size guard throws instead of dropping record history',()=>{
 const value={meals:Array.from({length:1000},(_,i)=>({id:String(i),note:'数据'.repeat(300)}))};assert.throws(()=>C.checked(value),/未被删减/);assert.equal(value.meals.length,1000);
});
test('chat pages survive reload and do not truncate a long conversation',async()=>{
 const data=storage(),repo=new C.Repository(data);await repo.load();const thread=repo.newThread('持续聊天');thread.messages=Array.from({length:80},(_,i)=>({id:'m'+i,role:i%2?'assistant':'user',text:'第'+i+'条 '+('正文'.repeat(100)),at:C.now(),state:'complete'}));
 const saved=await repo.saveThread(thread);assert.ok(saved.pages.length>=4);const again=new C.Repository(data);await again.load();assert.deepEqual((await again.readThread(thread.id)).messages,thread.messages);
});
test('a failed catalog commit keeps the prior committed thread intact',async()=>{
 const data=storage(),repo=new C.Repository(data);await repo.load();const thread=repo.newThread('不丢数据');thread.messages=[{id:'a',role:'user',text:'已提交',at:C.now()}];await repo.saveThread(thread);
 data.fail='coachCatalog';thread.messages.push({id:'b',role:'assistant',text:'未确认回复',at:C.now()});await assert.rejects(repo.saveThread(thread));
 const again=new C.Repository(data);await again.load();assert.equal((await again.readThread(thread.id)).messages.length,1);data.fail=null;await repo.saveThread(thread);const third=new C.Repository(data);await third.load();assert.equal((await third.readThread(thread.id)).messages.length,2);
});
test('unknown storage versions are refused without clearing old files',async()=>{
 const data=storage({coachCatalog:{version:9,threads:[{id:'future'}]}});await assert.rejects(new C.Repository(data).load(),/保留原文件/);assert.equal(data.writes.length,0);
});
test('memory requires exact user evidence and rejects invented, assistant or temporary facts',async()=>{
 const data=storage(),repo=new C.Repository(data);await repo.load();const user={id:'user1',threadId:'t1',role:'user',text:'我长期不吃香菜。今天吃得有点撑。'};
 const result=await repo.remember([
 {category:'preference',evidence:'我长期不吃香菜',messageId:'user1',durability:'long-term'},
 {category:'restriction',evidence:'我对花生过敏',messageId:'user1',durability:'long-term'},
 {category:'context',evidence:'今天吃得有点撑',messageId:'user1',durability:'long-term'},
 {category:'goal',evidence:'要多运动',messageId:'assistant1',durability:'long-term'}], [user,{id:'assistant1',role:'assistant',text:'要多运动'}]);
 assert.equal(result.added,1);assert.equal(result.rejected,3);assert.equal(repo.memory.facts[0].text,'我长期不吃香菜');assert.equal(repo.memory.facts[0].source.messageId,'user1');
});
test('memory disabled means no additions and no recalled facts',async()=>{
 const data=storage(),repo=new C.Repository(data);await repo.load();await repo.addFact('我喜欢清淡饮食','preference');await repo.setMemoryEnabled(false);assert.equal(C.retrieve(repo.memory,'饮食').length,0);await repo.remember([{category:'goal',evidence:'长期保持体重',messageId:'u',durability:'long-term'}],[{id:'u',role:'user',text:'长期保持体重'}]);assert.equal(repo.memory.facts.length,1);
});
test('conflicting goal is pending until explicitly confirmed; the older goal is retained as archived',async()=>{
 const repo=new C.Repository(storage());await repo.load();await repo.addFact('我的长期目标是保持体重','goal');const previous=repo.memory.facts[0].id;
 await repo.remember([{category:'goal',evidence:'我的长期目标改成增加力量',messageId:'u',durability:'long-term'}],[{id:'u',role:'user',text:'我的长期目标改成增加力量'}]);
 const next=repo.memory.facts.find(f=>f.id!==previous);assert.equal(next.status,'pending');assert.equal(C.retrieve(repo.memory,'目标').length,1);await repo.editFact(next.id,{status:'active'});assert.equal(repo.memory.facts.find(f=>f.id===previous).status,'archived');assert.equal(C.retrieve(repo.memory,'目标')[0].id,next.id);
});
test('forget removes the fact and suppresses its source message from future prompts',async()=>{
 const repo=new C.Repository(storage());await repo.load();const message={id:'u1',threadId:'t1',role:'user',text:'我长期不吃香菜'};
 await repo.remember([{category:'preference',evidence:message.text,messageId:message.id,durability:'long-term'}],[message]);const fact=repo.memory.facts[0];await repo.forget(fact.id);assert.equal(repo.memory.facts.length,0);
 const prompt=C.prompt({messages:[message]},{profile:{}},repo.memory);assert.ok(!prompt.includes('我长期不吃香菜'));assert.match(prompt,/用户已要求忘记/);
 await repo.remember([{category:'preference',evidence:message.text,messageId:message.id,durability:'long-term'}],[message]);assert.equal(repo.memory.facts.length,0);
});
test('retrieval prioritizes relevant preferences while excluding expired and pending facts',()=>{
 const memory={enabled:true,facts:[{id:'1',category:'preference',text:'喜欢清淡的晚餐',status:'active'},{id:'2',category:'routine',text:'每周去游泳',status:'active'},{id:'3',category:'goal',text:'晚餐加餐',status:'pending'},{id:'4',category:'preference',text:'晚餐很晚',status:'active',expiresAt:'2020-01-01'}]};assert.deepEqual(C.retrieve(memory,'晚餐怎么吃',1).map(f=>f.id),['1']);
});
test('structured responses parse and plain-text fallback never invents memory',()=>{assert.equal(C.parseResponse('```json\n{"reply":"你好","memories":[]}\n```').reply,'你好');assert.deepEqual(C.parseResponse('一段普通回答'),{reply:'一段普通回答',memories:[]});assert.throws(()=>C.parseResponse(''));});
test('legacy advice seeds conversation without turning model suggestions into user memories',()=>{
 assert.match(C.adviceText({headline:'之前的建议',diet:[{title:'一餐',detail:'正常吃饭'}],text:'原文'}),/原文/);assert.equal(C.snapshot({profile:{name:'演示'},meals:[],health:[]}).profile.name,'演示');
});
test('future backup formats are preserved and block unsafe replacement',async()=>{const data=storage({records:{value:1},recordsV3Backup:{backupVersion:2,value:{future:true}}});await assert.rejects(new C.RecordWriter(data).save({value:2}),/保留原备份/);assert.equal(data.db.get('records').value,1);assert.equal(data.db.get('recordsV3Backup').backupVersion,2);});
test('forget still suppresses conversation evidence after a manual memory correction',async()=>{const repo=new C.Repository(storage());await repo.load();const user={id:'u',threadId:'t',role:'user',text:'我长期不吃香菜'};await repo.remember([{category:'preference',evidence:user.text,messageId:'u',durability:'long-term'}],[user]);const id=repo.memory.facts[0].id;await repo.editFact(id,{text:'我不喜欢香菜的味道'});await repo.forget(id);assert.ok(!C.prompt({messages:[user]},{profile:{}},repo.memory).includes(user.text));});
