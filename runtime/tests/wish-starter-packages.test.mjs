import test from 'node:test';
import assert from 'node:assert/strict';
import {readFile,mkdtemp,rm} from 'node:fs/promises';
import {tmpdir} from 'node:os';
import {join} from 'node:path';
import vm from 'node:vm';
import {ProjectStore} from '../../app/assets/engine/forms/mobile-core.mjs';
import {WorkReleases,validateWorkPackage} from '../../app/assets/engine/forms/releases.mjs';
test('updated radar imports into independent works and boots with empty personal records',async t=>{
 const envelope=JSON.parse(await readFile(new URL('../../app/assets/presets/radar.anyapp',import.meta.url),'utf8'));
 validateWorkPackage(envelope);
 assert.equal(envelope.title,'比价雷达');assert.equal(envelope.declaredVersion,'1.25.0');
 assert(envelope.files.some(f=>f.path==='icon.svg'));
 const root=await mkdtemp(join(tmpdir(),'anyapp-radar-'));t.after(()=>rm(root,{recursive:true,force:true}));
 const store=new ProjectStore(root),releases=new WorkReleases(store);
 for(const id of ['local-radar-first','local-radar-second']){
  await store.create(id,envelope.title,'starter');
  const imported=await releases.import(id,envelope);
  const pkg=JSON.parse(await readFile(join(imported.spec,'package.json'),'utf8'));
  assert.equal(pkg.name,'@local/'+id);assert.equal(pkg.version,'1.25.0');
  let source=await readFile(join(imported.spec,'client.js'),'utf8');
  assert(!source.includes(envelope.sourceId));
  source=source.replace('return module.exports.default;', 'return {plugin: module.exports.default, records: normalizeRecords(null), candidates: normalizeCandidates(null), memory: defaultMemory(), actions: buildActions(defaultMemory(),defaultSettings())};');
  let loaded;
  vm.runInNewContext(source,{window:{__ModuleLoader__:{load(p){assert.equal(p.id,'@local/'+id);loaded=p.factory(name=>{assert.equal(name,'react');return {createElement(){}};});}}},console},{timeout:1000});
  assert.equal(typeof loaded.plugin.apply,'function');
  const state=JSON.parse(JSON.stringify(loaded));
  assert.deepEqual(state.records,[]);assert.deepEqual(state.candidates,[]);
  assert.equal(state.memory.updatedAt,0);
  assert(Object.values(state.memory.platforms).every(p=>p.notes===''));
  assert.equal(state.actions.length,1);assert.equal(state.actions[0].kind,'agent');
  assert.deepEqual(await releases.import(id,envelope),imported);
 }
 await store.write('local-radar-first','records',{synthetic:true});
 assert.deepEqual(await store.read('local-radar-second','records'),[]);
});
for(const name of ['voyo','calorie']){
 test(`shipped ${name} imports twice into separate namespaces with empty initial data`,async t=>{
  const envelope=JSON.parse(await readFile(new URL(`../../app/assets/presets/${name}.anyapp`,import.meta.url),'utf8'));
  validateWorkPackage(envelope);assert.equal(envelope.portable,true);
  const root=await mkdtemp(join(tmpdir(),'anyapp-starter-'));t.after(()=>rm(root,{recursive:true,force:true}));
  const store=new ProjectStore(root),releases=new WorkReleases(store);
  const ids=[`local-${name}-one`,`local-${name}-two`];
  for(const id of ids){
   await store.create(id,envelope.title,'starter');const imported=await releases.import(id,envelope);
   const pkg=JSON.parse(await readFile(join(imported.spec,'package.json'),'utf8'));assert.equal(pkg.name,'@local/'+id);
   let source=await readFile(join(imported.spec,'client.js'),'utf8');assert(!source.includes(envelope.sourceId));assert(!source.includes(ids.find(x=>x!==id)));
   const a=source.lastIndexOf("    return {\n      inject: ['slots', 'layout'");assert(a>0);let initial;
   source=source.slice(0,a)+`return ${name==='calorie'?'normalizeStore(null)':'emptyRecord()'};\n},\n});`;
   vm.runInNewContext(source,{window:{__ModuleLoader__:{load(p){initial=p.factory(module=>{assert.equal(module,'react');return{createElement(){}};});}}},Intl,Date},{timeout:1000});
   initial=JSON.parse(JSON.stringify(initial));
   for(const key of name==='calorie'?['meals','health','advices','reports','insights','reminders']:['trips','itineraries','checks','reminders'])assert.deepEqual(initial[key],[]);
   if(name==='calorie'){for(const key of ['weightKg','targetWeightKg','age','heightCm','targetOverride'])assert.equal(initial.profile[key],0);assert.equal(initial.profile.name,'');assert.equal(initial.profile.onboarded,false);}
   else {assert.equal(initial.onboarded,false);assert.deepEqual(initial.window,{start:'',end:''});}
   assert.deepEqual(await releases.import(id,envelope),imported);
  }
  await store.write(ids[0],'records',{synthetic:true});assert.deepEqual(await store.read(ids[1],'records'),[]);
 });
}
