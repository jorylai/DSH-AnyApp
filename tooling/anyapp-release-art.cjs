// Original procedural AnyApp artwork. No source images are sampled or edited.
// Existing asset paths are retained for saved appearance preferences.
const fs=require('node:fs'),path=require('node:path'),sharp=require('sharp');
const root=path.resolve(__dirname,'..');
const asset=(name)=>path.join(root,'app/assets',name);
const write=(name,data)=>fs.writeFileSync(asset(name),data);
const tau=Math.PI*2;
function dots(w,h,phase,color='#9BB0FF',mono=false){
 const cx=w/2,cy=h/2,r=Math.min(w,h)*.28;
 let out=`<circle cx="${cx}" cy="${cy}" r="${r*1.24}" fill="none" stroke="${color}" stroke-opacity=".12" stroke-width="${Math.min(w,h)*.012}"/>`;
 for(let i=0;i<7;i++){
  const a=i*tau/7+phase,rr=Math.min(w,h)*(.033+.009*(1+Math.sin(a)));
  out+=`<circle cx="${cx+Math.cos(a)*r}" cy="${cy+Math.sin(a)*r}" r="${rr*1.7}" fill="${color}" opacity=".08"/><circle cx="${cx+Math.cos(a)*r}" cy="${cy+Math.sin(a)*r}" r="${rr}" fill="${mono?'white':i===1?'#A7E6D7':color}" opacity="${.45+.5*(1+Math.sin(a))/2}"/>`;
 }
 return out+`<circle cx="${cx}" cy="${cy}" r="${Math.min(w,h)*(.07+.006*Math.sin(phase))}" fill="${mono?'white':'#F4F1EA'}"/>`;
}
const svg=(w,h,body)=>`<svg xmlns="http://www.w3.org/2000/svg" width="${w}" height="${h}" viewBox="0 0 ${w} ${h}">${body}</svg>`;
async function sheet(w,h,cols,frames,color,mono=false){
 let body='';for(let n=0;n<frames;n++)body+=`<g transform="translate(${n%cols*w},${Math.floor(n/cols)*h})">${dots(w,h,n/frames*tau,color,mono)}</g>`;
 return sharp(Buffer.from(svg(cols*w,Math.ceil(frames/cols)*h,body))).png().toBuffer();
}
(async()=>{
 const mark=fs.readFileSync(asset('brand/mark.svg'));
 for(const name of ['glyph-dark.svg','glyph-light.svg','glyph-mono.svg','tile.svg'])write('brand/'+name,mark);
 const res=path.join(root,'app/android/app/src/main/res');
 for(const folder of fs.readdirSync(res).filter(f=>f.startsWith('mipmap-')&&!f.includes('anydpi'))){
  for(const file of fs.readdirSync(path.join(res,folder)).filter(f=>f.endsWith('.png'))){
   const target=path.join(res,folder,file),meta=await sharp(target).metadata();
   const source=file.includes('foreground')?Buffer.from(svg(108,108,`<g transform="translate(18,18) scale(.666667)">${mark.toString().replace(/^.*?<svg[^>]*>/s,'').replace(/<\/svg>\s*$/,'')}</g>`)):mark;
   fs.writeFileSync(target,await sharp(source).resize(meta.width,meta.height).png().toBuffer());
  }
 }
 const manifest={frameWidth:120,frameHeight:96,columns:6,levels:[]};
 for(let level=1;level<=4;level++){
  const frames=level===1?1:24;
  write(`whale/whale_${level}.png`,await sheet(120,96,6,frames,'white',true));
  manifest.levels.push({level,image:`whale_${level}.png`,frames,frameMs:level===1?0:40,source:'AnyApp procedural orbit'});
 }
 write('whale/whale.json',JSON.stringify(manifest,null,2)+'\n');
 for(const [id,name,color] of [['deepy-whale','AnyApp · 星点','#9BB0FF'],['whale-girl','AnyApp · 流光','#A7E6D7']]){
  const dir=asset(`pets/${id}`),old=JSON.parse(fs.readFileSync(path.join(dir,'pack.json')));
  const bytes=await sheet(96,96,6,24,color);
  // Overwrite every formerly bundled sheet, including unused legacy sheets.
  for(const file of fs.readdirSync(dir).filter(f=>f.endsWith('.png')))fs.writeFileSync(path.join(dir,file),bytes);
  const animations={};
  for(const [key,value] of Object.entries(old.animations))animations[key]={sheet:value.sheet,frameW:96,frameH:96,cols:6,box:{x:0,y:0,w:96,h:96},loop:value.loop!==false,frames:Array.from({length:24},(_,i)=>({i,ms:key==='sleeping'?200:80}))};
  const pack={schema:1,id,name,author:'DSH AnyApp',license:'AGPL-3.0',source:'tooling/anyapp-release-art.cjs',pixelArt:false,scale:1,canvas:{w:96,h:96},anchor:{x:48,baseline:88},contentBox:{x:16,y:16,w:64,h:64},animations,states:old.states,reactions:old.reactions,roam:old.roam,sleep:{afterMs:60000}};
  fs.writeFileSync(path.join(dir,'pack.json'),JSON.stringify(pack,null,2)+'\n');
 }
 write('star/star_whale.webp',await sharp(Buffer.from(svg(576,576,dots(576,576,0)))).webp().toBuffer());
 const xml=`<?xml version="1.0" encoding="utf-8"?>\n<vector xmlns:android="http://schemas.android.com/apk/res/android" android:width="108dp" android:height="108dp" android:viewportWidth="108" android:viewportHeight="108"><path android:fillColor="#FFFFFFFF" android:fillType="evenOdd" android:pathData="M43,30 L67,30 Q79,30 79,42 L79,66 Q79,78 67,78 L43,78 Q31,78 31,66 L31,42 Q31,30 43,30 Z M52,42 H57 V52 H67 V57 H57 V67 H52 V57 H42 V52 H52 Z"/><path android:fillColor="#FFFFFFFF" android:pathData="M78,22 H82 Q86,22 86,26 V30 Q86,34 82,34 H78 Q74,34 74,30 V26 Q74,22 78,22 Z"/></vector>\n`;
 fs.writeFileSync(path.join(root,'app/android/app/src/main/res/drawable/ic_launcher_monochrome.xml'),xml);
 console.log('AnyApp release artwork generated');
})().catch(e=>{console.error(e.message);process.exitCode=1});
