import {readFile,writeFile,readdir} from 'node:fs/promises';
import {createHash} from 'node:crypto';
import {dirname,join,resolve} from 'node:path';
import {fileURLToPath} from 'node:url';
import {validateWorkPackage} from '../../app/assets/engine/forms/releases.mjs';

const root=dirname(fileURLToPath(import.meta.url));
const sha=bytes=>createHash('sha256').update(bytes).digest('hex');

// The author's exported package is the release source of truth. Keep its
// code, locale metadata and icon byte-for-byte; only wrap the portable files.
export async function buildRadar(output=resolve(root,'../../app/assets/presets/radar.anyapp')) {
 const files=[];
 async function collect(prefix='') {
  for(const entry of await readdir(join(root,'package',prefix),{withFileTypes:true})) {
   const path=prefix?`${prefix}/${entry.name}`:entry.name;
   if(entry.isDirectory())await collect(path);
   else if(entry.isFile()) {
    const bytes=await readFile(join(root,'package',path));
    files.push({path,data:bytes.toString('base64'),sha256:sha(bytes)});
   } else throw new Error('radar-source-must-not-contain-links');
  }
 }
 await collect();files.sort((a,b)=>a.path<b.path?-1:a.path>b.path?1:0);
 const pkg=JSON.parse(await readFile(join(root,'package/package.json'),'utf8'));
 const envelope=validateWorkPackage({format:'dsh-anyapp-plugin/1',api:2,portable:true,
  sourceId:pkg.name.slice('@local/'.length),title:'比价雷达',declaredVersion:pkg.version,
  hash:sha(JSON.stringify(files)),files});
 await writeFile(output,JSON.stringify(envelope));
 return envelope;
}
if(process.argv[1]&&resolve(process.argv[1])===fileURLToPath(import.meta.url)) {
 const value=await buildRadar();console.log(`radar ${value.declaredVersion} ${value.hash}`);
}
