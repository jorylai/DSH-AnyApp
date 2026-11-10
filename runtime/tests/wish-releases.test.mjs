import test from 'node:test'
import {createHash} from 'node:crypto'
import assert from 'node:assert/strict'
import {mkdtemp,mkdir,writeFile,readFile,rm,symlink} from 'node:fs/promises'
import {tmpdir} from 'node:os'
import {join} from 'node:path'
import {ProjectStore} from '../../app/assets/engine/forms/mobile-core.mjs'
import {WorkReleases,validateWorkPackage} from '../../app/assets/engine/forms/releases.mjs'
async function setup(t){const root=await mkdtemp(join(tmpdir(),'anyapp-release-'));t.after(()=>rm(root,{recursive:true,force:true}));const store=new ProjectStore(root);await store.create('local-original','A work','A request');const dir=join(store.workspace('local-original'),'package');await mkdir(dir);await writeFile(join(dir,'package.json'),JSON.stringify({name:'@local/local-original',version:'1.0.0',type:'module',files:['client.js'],scripts:{build:'echo built'}}));await writeFile(join(dir,'client.js'),"export const id='local-original'; export const rpc='wishWork_local_original';");return {store,dir,releases:new WorkReleases(store)}}
test('code checkpoint is content-addressed and excludes work records',async t=>{const{store,dir,releases}=await setup(t);await store.write('local-original','records',[{private:true}]);await writeFile(join(dir,'records.json'),'private');const a=await releases.checkpoint('local-original',dir,'Title');const b=await releases.checkpoint('local-original',dir,'Title');assert.equal(a.hash,b.hash);assert.equal((await releases.list('local-original')).length,1);const e=await releases.load('local-original',a.hash);assert.deepEqual(e.files.map(f=>f.path),['client.js','package.json']);assert.equal(JSON.parse(Buffer.from(e.files.find(f=>f.path==='package.json').data,'base64')).scripts.build,'echo built');});
test('restore rolls code back without replacing data, identity or sessions',async t=>{const{store,dir,releases}=await setup(t);await store.bind('local-original','session-existing');await store.write('local-original','records',[{kept:42}]);const a=await releases.checkpoint('local-original',dir,'Title');await writeFile(join(dir,'client.js'),'export const changed=true');await writeFile(join(dir,'records.json'),'keep workspace data');await releases.restore('local-original',a.hash);assert.match(await readFile(join(dir,'client.js'),'utf8'),/local-original/);assert.equal(await readFile(join(dir,'records.json'),'utf8'),'keep workspace data');assert.deepEqual(await store.read('local-original','records'),[{kept:42}]);assert.equal((await store.projects())[0].sessionId,'session-existing');});
test('portable export strips install scripts and imports into a distinct namespace',async t=>{const{store,dir,releases}=await setup(t);const e=await releases.export('local-original',dir,'Title');const pkg=JSON.parse(Buffer.from(e.files.find(f=>f.path==='package.json').data,'base64'));assert.equal(pkg.scripts,undefined);const result=await releases.import('local-imported',e);assert.match(await readFile(join(result.spec,'client.js'),'utf8'),/wishWork_local_imported/);assert.equal(JSON.parse(await readFile(join(result.spec,'package.json'),'utf8')).name,'@local/local-imported');assert.deepEqual(await releases.import('local-imported',e),result);const receipt=JSON.parse(await readFile(join(releases.directory('local-imported'),'import.json'),'utf8'));assert.equal(receipt.sourceHash,e.hash);assert.equal(receipt.phase,'ready');assert.match(await readFile(join(dir,'client.js'),'utf8'),/local-original/);});
test('rejects traversals, private directories and outside symlinks',async t=>{const{dir,releases}=await setup(t);await symlink('/etc/hosts',join(dir,'client.js.link'));const pkg=JSON.parse(await readFile(join(dir,'package.json'),'utf8'));for(const file of ['../outside.js','data','client.js.link']){pkg.files=[file];await writeFile(join(dir,'package.json'),JSON.stringify(pkg));await assert.rejects(releases.prepare('local-original',dir,'Title'));}});
test('shared package integrity and portable flag are required',async t=>{const{dir,releases}=await setup(t);const e=await releases.export('local-original',dir,'Title');const altered=structuredClone(e);altered.files[0].data=Buffer.from('changed').toString('base64');assert.throws(()=>validateWorkPackage(altered));const privateRelease=await releases.prepare('local-original',dir,'Title');await assert.rejects(releases.import('local-new',privateRelease),/portable/);});
test('discovers nested legacy package and includes declared locale globs',async t=>{const{store,dir,releases}=await setup(t);await mkdir(join(dir,'locale'));await writeFile(join(dir,'locale/zh.json'),'{"title":"作品"}');const pkg=JSON.parse(await readFile(join(dir,'package.json'),'utf8'));pkg.files.push('locale/*.json');await writeFile(join(dir,'package.json'),JSON.stringify(pkg));await symlink('package/package.json',join(store.workspace('local-original'),'package.json'));const a=await releases.checkpoint('local-original','@local/local-original','Title');const release=await releases.load('local-original',a.hash);assert.ok(release.files.some(f=>f.path==='locale/zh.json'));await writeFile(join(dir,'client.js'),'changed');await releases.restore('local-original',a.hash);assert.match(await readFile(join(dir,'client.js'),'utf8'),/local-original/);});
test('restore validates all targets before changing any source',async t=>{const{dir,releases}=await setup(t);await writeFile(join(dir,'z.js'),'original z');const pkg=JSON.parse(await readFile(join(dir,'package.json'),'utf8'));pkg.files.push('z.js');await writeFile(join(dir,'package.json'),JSON.stringify(pkg));const a=await releases.checkpoint('local-original',dir,'Title');await writeFile(join(dir,'client.js'),'keep current');await rm(join(dir,'z.js'));await symlink('/etc/hosts',join(dir,'z.js'));await assert.rejects(releases.restore('local-original',a.hash),/invalid-target/);assert.equal(await readFile(join(dir,'client.js'),'utf8'),'keep current');});
test('interrupted file transaction recovers old code without touching records',async t=>{const{store,dir,releases}=await setup(t);await store.write('local-original','records',[1,2]);await mkdir(releases.directory('local-original'),{recursive:true});await writeFile(join(releases.directory('local-original'),'pending.json'),JSON.stringify({packagePath:'package',before:[{path:'client.js',data:Buffer.from('before transaction').toString('base64')},{path:'new.js',data:null}]}));await writeFile(join(dir,'client.js'),'partial');await writeFile(join(dir,'new.js'),'partial new');await releases.recover('local-original');assert.equal(await readFile(join(dir,'client.js'),'utf8'),'before transaction');await assert.rejects(readFile(join(dir,'new.js')),/ENOENT/);assert.deepEqual(await store.read('local-original','records'),[1,2]);});

test('agent execution uses a separate context and deletion retains other works',async t=>{const {store,releases,dir}=await setup(t);await writeFile(join(store.workspace('local-original'),'AGENTS.md'),'Creator instructions');const job=await store.agentWorkspace('local-original');assert.notEqual(job.path,store.workspace('local-original'));assert.ok(job.path.endsWith('/agent-workspaces/local-original'));await assert.rejects(readFile(join(job.path,'AGENTS.md')),/ENOENT/);assert.equal(job.results,join(store.workspace('local-original'),'agent-results.json'));await releases.checkpoint('local-original',dir,'Title');await store.create('local-other','Other');await store.write('local-other','records',[42]);await store.removeProject('local-original');await assert.rejects(readFile(join(releases.directory('local-original'),'pending.json')),/ENOENT/);await assert.rejects(readFile(join(job.path,'AGENTS.md')),/ENOENT/);assert.deepEqual(await store.read('local-other','records'),[42]);assert.equal((await store.projects())[0].id,'local-other');});


test('retries recover either side of the import rename without touching work records',async t=>{
  const {store,dir,releases}=await setup(t)
  const envelope=await releases.export('local-original',dir,'Title')
  const first=await releases.import('local-recovered',envelope)
  await store.write('local-recovered','records',[{kept:17}])
  const journal=join(releases.directory('local-recovered'),'import.json')
  const receipt=JSON.parse(await readFile(journal,'utf8'))
  // Killed after package rename, before committing the receipt.
  await writeFile(journal,JSON.stringify({...receipt,phase:'prepared'}))
  assert.deepEqual(await releases.import('local-recovered',envelope),first)
  assert.equal(JSON.parse(await readFile(journal,'utf8')).phase,'ready')
  // Killed after writing intent, before renaming the staged package.
  await writeFile(journal,JSON.stringify({...receipt,phase:'prepared'}))
  await rm(first.spec,{recursive:true})
  assert.deepEqual(await releases.import('local-recovered',envelope),first)
  assert.match(await readFile(join(first.spec,'client.js'),'utf8'),/wishWork_local_recovered/)
  assert.deepEqual(await store.read('local-recovered','records'),[{kept:17}])
})

test('retry refuses another source release and never adopts an unreceipted package',async t=>{
  const {dir,releases}=await setup(t)
  const envelope=await releases.export('local-original',dir,'Title')
  const first=await releases.import('local-retry',envelope)
  const original=await readFile(join(first.spec,'client.js'),'utf8')
  await writeFile(join(dir,'client.js'),'export const different=true')
  const changed=await releases.export('local-original',dir,'Title')
  await assert.rejects(releases.import('local-retry',changed),/release-import-conflict/)
  assert.equal(await readFile(join(first.spec,'client.js'),'utf8'),original)
  await rm(join(releases.directory('local-retry'),'import.json'))
  await assert.rejects(releases.import('local-retry',envelope),/EEXIST/)
  assert.equal(await readFile(join(first.spec,'client.js'),'utf8'),original)
})

test('retry detects modified, missing, additional and symlinked source files',async t=>{
  const {dir,releases}=await setup(t)
  const envelope=await releases.export('local-original',dir,'Title')
  const first=await releases.import('local-edited',envelope)
  const file=join(first.spec,'client.js'), original=await readFile(file)
  await writeFile(file,'keep this user edit')
  await assert.rejects(releases.import('local-edited',envelope),/release-import-modified/)
  assert.equal(await readFile(file,'utf8'),'keep this user edit')
  await rm(file)
  await assert.rejects(releases.import('local-edited',envelope),/release-import-modified/)
  await writeFile(file,original)
  await writeFile(join(first.spec,'extra.js'),'keep added source')
  await assert.rejects(releases.import('local-edited',envelope),/release-import-modified/)
  assert.equal(await readFile(join(first.spec,'extra.js'),'utf8'),'keep added source')
  await rm(join(first.spec,'extra.js'))
  await rm(file)
  await symlink(join(dir,'client.js'),file)
  await assert.rejects(releases.import('local-edited',envelope),/release-import-modified/)
  assert.match(await readFile(join(dir,'client.js'),'utf8'),/local-original/)
})

test('retry preserves package-manager artifacts but does not reconstruct a deleted committed package',async t=>{
  const {dir,releases}=await setup(t)
  const envelope=await releases.export('local-original',dir,'Title')
  const first=await releases.import('local-managed',envelope)
  await mkdir(join(first.spec,'node_modules'))
  await writeFile(join(first.spec,'node_modules','generated.js'),'generated dependency')
  await writeFile(join(first.spec,'pnpm-lock.yaml'),'generated lock')
  assert.deepEqual(await releases.import('local-managed',envelope),first)
  assert.equal(await readFile(join(first.spec,'pnpm-lock.yaml'),'utf8'),'generated lock')
  await rm(first.spec,{recursive:true})
  await assert.rejects(releases.import('local-managed',envelope),/release-import-modified/)
  await assert.rejects(readFile(join(first.spec,'package.json')),/ENOENT/)
})

test('concurrent retries share one complete import',async t=>{
  const {dir,releases}=await setup(t)
  const envelope=await releases.export('local-original',dir,'Title')
  const results=await Promise.all(Array.from({length:3},()=>releases.import('local-concurrent',envelope)))
  assert.deepEqual(results[1],results[0]);assert.deepEqual(results[2],results[0])
  assert.equal(JSON.parse(await readFile(join(releases.directory('local-concurrent'),'import.json'),'utf8')).phase,'ready')
})

test('import refuses identity-bearing filenames instead of breaking rewritten module references',async t=>{
  const {dir,releases}=await setup(t)
  const pkg=JSON.parse(await readFile(join(dir,'package.json'),'utf8'))
  for(const filename of ['local-original.js','local_original.js']) {
    await writeFile(join(dir,filename),'export const helper=true')
    await writeFile(join(dir,'package.json'),JSON.stringify({...pkg,files:[filename]}))
    const envelope=await releases.export('local-original',dir,'Title')
    await assert.rejects(releases.import('local-filenames',envelope),/release-identity-in-file-path/)
  }
})

test('legacy imported packages with an optional missing README can checkpoint and re-export', async t => {
  const {dir,releases}=await setup(t);
  const envelope=await releases.export('local-original',dir,'Title');
  const file=envelope.files.find(f=>f.path==='package.json');
  const pkg=JSON.parse(Buffer.from(file.data,'base64'));pkg.files.push('README.md');
  const bytes=Buffer.from(JSON.stringify(pkg));file.data=bytes.toString('base64');file.sha256=createHash('sha256').update(bytes).digest('hex');
  envelope.hash=createHash('sha256').update(JSON.stringify([...envelope.files].sort((a,b)=>a.path<b.path?-1:1))).digest('hex');
  const imported=await releases.import('local-readme-compat',envelope);
  assert.ok((await releases.checkpoint('local-readme-compat',imported.spec,'Named app')).hash);
  assert.equal((await releases.export('local-readme-compat',imported.spec,'Named app')).title,'Named app');
});
