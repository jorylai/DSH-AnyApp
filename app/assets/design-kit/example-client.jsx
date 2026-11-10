// v5 UI fragment for an official DSH React Client plugin. Read STYLE-RADAR/DESIGN/MOTION/ICONS first. Keep its apply/slot registration.
export function WorkView({React}) {
  const [settings,setSettings]=React.useState(false);
  const [autoSave,setAutoSave]=React.useState(true);
  const [saveState,setSaveState]=React.useState('');
  const [busy,setBusy]=React.useState(false);
  const [error,setError]=React.useState('');
  const [messages,setMessages]=React.useState([]);
  const taskHost=React.useRef(null), composerHost=React.useRef(null);
  const state=React.useRef({});state.current={settings,setSettings};
  const submit=React.useRef(null);
  submit.current=async text=>{
    setBusy(true);setError('');
    try{
      const response=await window.dshWish.ai.complete({prompt:text});
      setMessages(old=>[...old,{question:text,text:response.text}]);
    }catch(e){setError(e.message);throw e;}finally{setBusy(false);}
  };
  React.useEffect(()=>{
    let unregister, control, composer, disposed=false;
    async function mount(){
      const w=window.dshWish;if(!w||disposed)return;
      unregister?.();control?.dispose();composer?.dispose();
      unregister=w.ui.registerNavigation({back(){if(state.current.settings){state.current.setSettings(false);return true;}return false;},settings(){state.current.setSettings(true);}});
      if(taskHost.current)control=w.ui.mountTaskControl(taskHost.current);
      if(composerHost.current)composer=w.ui.mountComposer(composerHost.current,{placeholder:'说说想做的事…',onSend:text=>submit.current(text)});
      try{
        await w.work.describe({title:'小助',description:'你的手机助手'});
        const saved=await w.data.read('settings');if(!disposed)setAutoSave(saved?.autoSave!==false);
      }catch(e){if(!disposed)setError(e.message);}
      if(!disposed)await w.ui.ready();
    }
    mount();window.addEventListener('dsh-wish-ready',mount);
    return()=>{disposed=true;unregister?.();control?.dispose();composer?.dispose();window.removeEventListener('dsh-wish-ready',mount);};
  },[]);
  async function toggle(value){
    const old=autoSave;setAutoSave(value);setSaveState('正在保存…');
    try{await window.dshWish.data.write('settings',{autoSave:value});setSaveState('已保存');}
    catch(e){setAutoSave(old);setSaveState(e.message);}
  }
  return <main className="wish-app wish-scaffold"><div className="wish-page">
    <header className="wish-header"><h1>{settings?'作品设置':'小助'}</h1><span className="wish-badge">手机助手</span></header>
    <div className="wish-content wish-stack">
      {settings?<div className="wish-settings"><fieldset><legend>记录</legend><label className="wish-setting"><span className="wish-setting-label">保存结果<small>成功的结果保留在本作品</small></span><input type="checkbox" checked={autoSave} onChange={e=>toggle(e.target.checked)}/></label><div className="wish-save-state" role="status">{saveState}</div></fieldset><button className="wish-button" data-variant="secondary" onClick={()=>setSettings(false)}>完成</button></div>:<>
        {!messages.length&&<section className="wish-hero"><p className="wish-eyebrow">A LITTLE HELP, EVERY DAY</p><h2>把日常的小事，<br/>交给一个懂你的帮手。</h2><p>从下方说一句开始。结果会留在这里。</p></section>}
        {messages.map((m,i)=><article className="wish-card" key={i}><h2>{m.question}</h2><p>{m.text}</p></article>)}
        {busy&&<div className="wish-skeleton" aria-label="正在处理"/>}
      </>}
      {error&&<p className="wish-error" role="alert">{error}</p>}
      <div ref={taskHost}/>
    </div>
    <div ref={composerHost} hidden={settings}/>
  </div></main>;
}
