import { readFile, writeFile, mkdir, readdir, lstat, realpath, rename, rm, mkdtemp } from 'node:fs/promises'
import { join, relative, resolve, sep, dirname } from 'node:path'
import { createHash } from 'node:crypto'
import { checkId, atomic } from './store.mjs'

const FORMAT = 'dsh-anyapp-plugin/1', API = 2, MAX = 1500000
const digest = value => createHash('sha256').update(value).digest('hex')
const privatePath = value => /(^|\/)(node_modules|\.git|\.dsh|\.env[^/]*|credentials?[^/]*|sessions?|records?|data)(\/|$)|\.(log|db|sqlite|jks|keystore)$/i.test(value)
const safePath = value => typeof value === 'string' && value.length < 240 && !value.includes('\\') && !value.startsWith('/') && value.split('/').every(p => p && p !== '.' && p !== '..') && !privatePath(value)
const sourceFile = value => /(^|\/)(LICENSE|NOTICE|COPYING)(\.[A-Za-z0-9_-]+)?$/i.test(value) || value === 'package.json' || /^README(?:[._-][A-Za-z0-9_-]+)?\.md$/i.test(value) || (/^(locale|i18n)\//.test(value) && value.endsWith('.json')) || /\.(m?js|cjs|jsx|tsx?|css|html|svg|png|webp|jpe?g|woff2?|ya?ml)$/.test(value) || (/^(assets|schema)\//.test(value) && value.endsWith('.json'))
const secret = text => /\bsk-[a-zA-Z0-9_-]{24,}|(?:api[_-]?key|access[_-]?token|password|authorization)\s*[=:]\s*["'](?:Bearer\s+)?[a-zA-Z0-9_+\/.=-]{24,}["']/i.test(text)
function validate(envelope) {
  if (!envelope || envelope.format !== FORMAT || !Number.isInteger(envelope.api) || envelope.api > API || envelope.api < 1) throw new Error('release-incompatible-format')
  checkId(envelope.sourceId)
  if (typeof envelope.title !== 'string' || envelope.title.length > 80 || !envelope.title.trim()) throw new Error('invalid-work-name')
  if (!Array.isArray(envelope.files) || !envelope.files.length || envelope.files.length > 512) throw new Error('release-invalid-files')
  const paths = new Set(); let size = 0
  for (const f of envelope.files) {
    if (!safePath(f.path) || !sourceFile(f.path) || paths.has(f.path) || typeof f.data !== 'string' || !/^[A-Za-z0-9+/]*={0,2}$/.test(f.data)) throw new Error('release-invalid-file')
    paths.add(f.path); const bytes = Buffer.from(f.data, 'base64'); size += bytes.length
    if (size > MAX || digest(bytes) !== f.sha256) throw new Error('release-integrity-failed')
    if (envelope.portable === true && /\.(m?js|cjs|jsx|tsx?|html|css|json|ya?ml)$/.test(f.path) && secret(bytes.toString('utf8'))) throw new Error('release-possible-secret')
  }
  const sorted = [...envelope.files].sort((a,b) => a.path < b.path ? -1 : a.path > b.path ? 1 : 0)
  if (digest(JSON.stringify(sorted)) !== envelope.hash || !paths.has('package.json')) throw new Error('release-integrity-failed')
  const pkg = JSON.parse(Buffer.from(envelope.files.find(f=>f.path==='package.json').data,'base64'))
  if (pkg.name !== `@local/${envelope.sourceId}` || (envelope.portable === true && ((pkg.scripts && Object.keys(pkg.scripts).length) || Object.values(pkg.dependencies || {}).some(v=>/^(file:|link:|workspace:|\/|\.\.)/.test(v))))) throw new Error('release-not-portable')
  return envelope
}

// Verify both original bytes and the complete source file set before accepting
// a retry. Package-manager outputs are allowed, but never followed or rewritten.
async function verifyImportedPackage(root,files) {
  const expected=new Map(files.map(f=>[f.path,f])), seen=new Set()
  const directories=new Set([''])
  for(const f of files){let parent=dirname(f.path);while(parent!=='.'){directories.add(parent);parent=dirname(parent)}}
  const rootStat=await lstat(root)
  if(!rootStat.isDirectory()||rootStat.isSymbolicLink())throw new Error('invalid-import-root')
  async function inspect(prefix) {
    for(const name of await readdir(join(root,prefix))) {
      const path=prefix?`${prefix}/${name}`:name
      if(!prefix && ['node_modules','pnpm-lock.yaml','package-lock.json','yarn.lock'].includes(name) && !expected.has(path))continue
      const full=join(root,path), stat=await lstat(full)
      if(stat.isSymbolicLink())throw new Error('invalid-import-symlink')
      if(stat.isDirectory()) {
        if(!directories.has(path))throw new Error('unexpected-import-directory')
        await inspect(path)
      } else {
        const file=expected.get(path)
        if(!stat.isFile()||!file||stat.size!==file.bytes.length||digest(await readFile(full))!==file.sha256)throw new Error('modified-import-file')
        seen.add(path)
      }
    }
  }
  await inspect('')
  if(seen.size!==expected.size)throw new Error('missing-import-file')
}

/** Immutable code releases. Work data, sessions and native grants are never included. */
export class WorkReleases {
  constructor(store) { this.store = store }
  directory(id) { return join(this.store.root, 'work-versions', checkId(id)) }
  async packageRoot(id, spec) {
    const workspace = await realpath(this.store.workspace(id))
    const inside = path => path === workspace || path.startsWith(workspace + sep)
    const requested = typeof spec==='string' && /^(\/|file:|link:)/.test(spec) ? spec.replace(/^(file:|link:)/,'') : workspace
    async function inspect(path) {
      const packageFile=await realpath(join(path,'package.json'))
      if(!inside(packageFile))throw new Error('release-outside-work')
      const pkg=JSON.parse(await readFile(packageFile,'utf8'))
      if(pkg.name!==`@local/${id}`)return null
      return {workspace,root:dirname(packageFile),pkg}
    }
    const root=await realpath(requested)
    if(!inside(root))throw new Error('release-outside-work')
    try { const found=await inspect(root); if(found)return found } catch(e) { if(e.code!=='ENOENT')throw e }
    // Older creators sometimes put the bundle under a nested directory, or link
    // their workspace manifest to it. Discover only within this work, bounded.
    let visited=0
    async function search(dir,depth) {
      if(depth>3)return null
      for(const name of (await readdir(dir)).sort()) {
        if(privatePath(name)||name.startsWith('.'))continue
        if(++visited>300)throw new Error('release-discovery-limit')
        const path=join(dir,name), stat=await lstat(path)
        if(!stat.isDirectory()||stat.isSymbolicLink())continue
        try { const found=await inspect(path);if(found)return found } catch(e) {if(e.code!=='ENOENT')throw e}
        const found=await search(path,depth+1);if(found)return found
      }
      return null
    }
    const found=await search(workspace,0)
    if(!found)throw new Error('release-wrong-package')
    return found
  }
  async prepare(id, spec, title) {
    await this.recover(id)
    const {root,pkg} = await this.packageRoot(id,spec)
    const files = []; let total = 0
    async function add(path) {
      if (!safePath(path)) throw new Error('release-private-or-invalid-path')
      const full = join(root,path), stat = await lstat(full), canonical = await realpath(full)
      if (canonical !== root && !canonical.startsWith(root+sep)) throw new Error('release-symlink-outside-work')
      if (stat.isSymbolicLink()) throw new Error('release-symlink-not-portable')
      if (stat.isDirectory()) { for (const n of (await readdir(full)).sort()) await add(`${path}/${n}`); return }
      if (!stat.isFile() || !sourceFile(path)) return
      let bytes = await readFile(full)

      total += bytes.length
      if (total > MAX || files.length >= 512) throw new Error('release-exceeds-limit')
      if (!files.some(f=>f.path===path)) files.push({path,data:bytes.toString('base64'),sha256:digest(bytes)})
    }
    await add('package.json')
    const declared = pkg.files
    if (declared != null && !Array.isArray(declared)) throw new Error('release-invalid-files')
    if (declared?.length) {
      for (const entry of declared) {
        const path=String(entry).replace(/^\.\//,'')
        if(path==='package.json')continue
        if(path.includes('*')) {
          // npm's common bounded directory glob. No recursive root glob.
          const match=/^(.+)\/\*(?:\*\/\*)?(\.[a-zA-Z0-9]+)?$/.exec(path)
          if(!match||!safePath(match[1]))throw new Error('release-invalid-glob')
          const base=match[1], suffix=match[2]
          async function glob(dir) {
            for(const name of (await readdir(join(root,dir))).sort()) {
              const child=`${dir}/${name}`, stat=await lstat(join(root,child))
              if(stat.isSymbolicLink())throw new Error('release-symlink-not-portable')
              if(stat.isDirectory()&&path.includes('**'))await glob(child)
              else if(stat.isFile()&&(!suffix||name.endsWith(suffix)))await add(child)
            }
          }
          await glob(base)
        } else { try { await add(path) } catch(e) { if(e.code!=='ENOENT'||!/^README(?:[._-][A-Za-z0-9_-]+)?\.md$/i.test(path))throw e } }
      }
    } else {
      // Legacy bundles: code and assets only; never loose JSON, AGENTS, logs or data directories.
      for (const name of (await readdir(root)).sort()) {
        if (name==='package.json' || privatePath(name) || name==='AGENTS.md')continue
        const stat = await lstat(join(root,name))
        if (stat.isFile() && sourceFile(name)) await add(name)
        if (stat.isDirectory() && ['assets','dist','lib','src','schema'].includes(name)) await add(name)
      }
    }
    files.sort((a,b)=>a.path < b.path ? -1 : a.path > b.path ? 1 : 0)
    return validate({format:FORMAT,api:API,portable:false,sourceId:id,title:title?.trim() || pkg.name,declaredVersion:pkg.version || '0.0.0',hash:digest(JSON.stringify(files)),files})
  }
  async export(id,spec,title) {
    const envelope=await this.prepare(id,spec,title)
    envelope.portable=true
    envelope.files=envelope.files.map(f=>{
      if(f.path!=='package.json')return f
      const pkg=JSON.parse(Buffer.from(f.data,'base64'));delete pkg.scripts;delete pkg.devDependencies
      const bytes=Buffer.from(JSON.stringify(pkg,null,2)+'\n')
      return {path:f.path,data:bytes.toString('base64'),sha256:digest(bytes)}
    })
    envelope.hash=digest(JSON.stringify(envelope.files))
    return validate(envelope)
  }
  async checkpoint(id,spec,title) {
    const envelope=await this.prepare(id,spec,title), dir=this.directory(id)
    await mkdir(dir,{recursive:true})
    const file=join(dir,`${envelope.hash}.json`)
    try { await readFile(file); } catch(e) { if(e.code!=='ENOENT')throw e; await atomic(file,{...envelope,createdAt:new Date().toISOString(),packagePath:relative(await realpath(this.store.workspace(id)), (await this.packageRoot(id,spec)).root)}) }
    return this.metadata(envelope)
  }
  metadata(e) { return {hash:e.hash,title:e.title,version:e.declaredVersion,createdAt:e.createdAt,files:e.files.length,bytes:e.files.reduce((n,f)=>n+Buffer.from(f.data,'base64').length,0),api:e.api} }
  async list(id) {
    const dir=this.directory(id);let names
    try{names=await readdir(dir)}catch(e){if(e.code==='ENOENT')return [];throw e}
    return (await Promise.all(names.filter(n=>/^[a-f0-9]{64}\.json$/.test(n)).map(async n=>this.metadata(JSON.parse(await readFile(join(dir,n),'utf8')))))).sort((a,b)=>(b.createdAt||'').localeCompare(a.createdAt||''))
  }
  async load(id,hash) { if(!/^[a-f0-9]{64}$/.test(hash))throw new Error('invalid-release');return validate(JSON.parse(await readFile(join(this.directory(id),`${hash}.json`),'utf8'))) }
  async recover(id) {
    const journal=join(this.directory(id),'pending.json');let tx
    try{tx=JSON.parse(await readFile(journal,'utf8'))}catch(e){if(e.code==='ENOENT')return;throw e}
    const work=await realpath(this.store.workspace(id)), root=resolve(work,tx.packagePath||'.')
    if(root!==work&&!root.startsWith(work+sep))throw new Error('release-outside-work')
    for(const f of tx.before) {
      if(!safePath(f.path)||!sourceFile(f.path))throw new Error('release-invalid-file')
      const target=join(root,f.path);await mkdir(dirname(target),{recursive:true})
      const parent=await realpath(dirname(target))
      if(parent!==work&&!parent.startsWith(work+sep))throw new Error('release-symlink-outside-work')
      if(f.data===null)await rm(target,{force:true})
      else { const temp=target+'.anyapp-recover';await writeFile(temp,Buffer.from(f.data,'base64'));await rename(temp,target) }
    }
    await rm(journal)
  }
  async restore(id,hash) {
    await this.recover(id)
    const envelope=await this.load(id,hash), raw=JSON.parse(await readFile(join(this.directory(id),`${hash}.json`),'utf8'))
    const work=await realpath(this.store.workspace(id)), root=resolve(work,raw.packagePath||'.')
    if(root!==work&&!root.startsWith(work+sep))throw new Error('release-outside-work')
    const before=[]
    // Validate and back up every target before changing even one source file.
    for(const f of envelope.files) {
      const target=join(root,f.path);await mkdir(dirname(target),{recursive:true})
      const parent=await realpath(dirname(target))
      if(parent!==work&&!parent.startsWith(work+sep))throw new Error('release-symlink-outside-work')
      try { const stat=await lstat(target);if(!stat.isFile()||stat.isSymbolicLink())throw new Error('release-invalid-target');before.push({path:f.path,data:(await readFile(target)).toString('base64')}) }
      catch(e){if(e.code!=='ENOENT')throw e;before.push({path:f.path,data:null})}
    }
    const journal=join(this.directory(id),'pending.json')
    await atomic(journal,{packagePath:relative(work,root),before})
    try {
      // Manifest last: DSH cannot see the new version before its sources exist.
      for(const f of [...envelope.files].sort((a,b)=>(a.path==='package.json')-(b.path==='package.json'))) {
        const target=join(root,f.path);let bytes=Buffer.from(f.data,'base64')
        if(f.path==='package.json'){const pkg=JSON.parse(bytes);pkg.version=`0.0.0-anyapp.${hash.slice(0,16)}`;bytes=Buffer.from(JSON.stringify(pkg,null,2)+'\n')}
        const temp=target+'.anyapp.tmp';await writeFile(temp,bytes);await rename(temp,target)
      }
      await rm(journal)
    } catch(e) {await this.recover(id);throw e}
    return {spec:root,...this.metadata(envelope)}
  }
  // In-place code-only update, protected by an optimistic source hash.
  // Data, identity and session directories are never part of this transaction.
  async upgrade(id,envelope,spec,expectedHash) {
    validate(envelope)
    if(envelope.portable!==true)throw new Error('release-not-portable')
    if(!/^[a-f0-9]{64}$/.test(expectedHash||''))throw new Error('release-expected-hash-required')
    checkId(id)
    return this.store.serial(async()=>{
      await this.store.begin(id)
      const current=await this.export(id,spec)
      if(current.hash!==expectedHash)throw new Error('release-source-changed')
      const before=await this.checkpoint(id,spec,current.title)
      const {root}=await this.packageRoot(id,spec)
      const oldRpc=envelope.sourceId.replaceAll('-','_'),newRpc=id.replaceAll('-','_')
      const files=envelope.files.map(f=>{
        if(f.path.includes(envelope.sourceId)||f.path.includes(oldRpc))throw new Error('release-identity-in-file-path')
        let bytes=Buffer.from(f.data,'base64')
        if(/\.(m?js|cjs|jsx|tsx?|css|html|json|ya?ml)$/.test(f.path))bytes=Buffer.from(bytes.toString('utf8').split(envelope.sourceId).join(id).split(oldRpc).join(newRpc))
        return {path:f.path,data:bytes.toString('base64'),sha256:digest(bytes)}
      }).sort((a,b)=>a.path<b.path?-1:a.path>b.path?1:0)
      const next=validate({...envelope,portable:false,sourceId:id,title:current.title,files,hash:digest(JSON.stringify(files))})
      const directory=this.directory(id)
      await mkdir(directory,{recursive:true})
      await atomic(join(directory,`${next.hash}.json`),{...next,createdAt:new Date().toISOString(),packagePath:relative(await realpath(this.store.workspace(id)),root)})
      const installed=await this.restore(id,next.hash)
      return {...installed,beforeHash:before.hash,sourceHash:envelope.hash}
    })
  }
  async import(id,envelope) {
    validate(envelope)
    if(envelope.portable!==true)throw new Error('release-not-portable')
    checkId(id)
    const oldRpc=envelope.sourceId.replaceAll('-','_'), newRpc=id.replaceAll('-','_')
    const files=envelope.files.map(f=>{
      // Content substitution cannot safely rename module filenames and every
      // reference to them. Refuse these rare bundles rather than install broken code.
      if(f.path.includes(envelope.sourceId)||f.path.includes(oldRpc))throw new Error('release-identity-in-file-path')
      let bytes=Buffer.from(f.data,'base64')
      if(/\.(m?js|cjs|jsx|tsx?|css|html|json|ya?ml)$/.test(f.path))
        bytes=Buffer.from(bytes.toString('utf8').split(envelope.sourceId).join(id).split(oldRpc).join(newRpc))
      return {path:f.path,bytes,sha256:digest(bytes)}
    }).sort((a,b)=>a.path < b.path ? -1 : a.path > b.path ? 1 : 0)
    const materializedHash=digest(JSON.stringify(files.map(({path,sha256})=>({path,sha256}))))
    return this.store.serial(async()=>{
      await this.store.begin(id)
      const workspace=await realpath(this.store.workspace(id))
      if(workspace!==join(await realpath(join(this.store.root,'workspaces')),id))throw new Error('release-outside-work')
      const root=join(workspace,'package'), directory=this.directory(id), journal=join(directory,'import.json')
      await mkdir(directory,{recursive:true})
      if(await realpath(directory)!==join(await realpath(this.store.root),'work-versions',id))throw new Error('release-outside-work')
      let receipt, exists=false
      try {
        const stat=await lstat(journal)
        if(!stat.isFile()||stat.isSymbolicLink())throw new Error('release-import-invalid-receipt')
        receipt=JSON.parse(await readFile(journal,'utf8'))
      } catch(e) {if(e.code!=='ENOENT')throw e}
      try {await lstat(root);exists=true}catch(e){if(e.code!=='ENOENT')throw e}
      const conflict=reason=>Object.assign(new Error(reason),{code:'EEXIST'})
      if(receipt && (receipt.schema!==1 || receipt.sourceHash!==envelope.hash || receipt.materializedHash!==materializedHash || !['prepared','ready'].includes(receipt.phase)))
        throw conflict('release-import-conflict')
      if(exists) {
        if(!receipt)throw conflict('EEXIST')
        try {await verifyImportedPackage(root,files)}catch(_){throw conflict('release-import-modified')}
        if(receipt.phase!=='ready')await atomic(journal,{...receipt,phase:'ready'})
        return {spec:root,sourceHash:envelope.hash,title:envelope.title}
      }
      // A committed package disappearing is an external edit, not an unfinished import.
      if(receipt?.phase==='ready')throw conflict('release-import-modified')
      const stage=await mkdtemp(join(workspace,'.import-'))
      try {
        for(const f of files){const target=join(stage,f.path);await mkdir(dirname(target),{recursive:true});await writeFile(target,f.bytes,{flag:'wx'})}
        // Persist intent before exposing the complete package. A process killed
        // after rename can verify this exact package and finish on the next call.
        const prepared={schema:1,sourceHash:envelope.hash,materializedHash,phase:'prepared'}
        await atomic(journal,prepared)
        await rename(stage,root)
        await atomic(journal,{...prepared,phase:'ready'})
      } catch(e) {await rm(stage,{recursive:true,force:true});throw e}
      return {spec:root,sourceHash:envelope.hash,title:envelope.title}
    })
  }
}
export { validate as validateWorkPackage }
