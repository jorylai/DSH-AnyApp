function installDshWish(config) {
  if (window.top !== window) return;
  // Android can report a same-document navigation as a new page start. Keep
  // registered plugin panels, but adopt the host's newly rotated document nonce.
  if (window.__dshWishRefresh && window.__dshWishRefresh(config)) return;
  if (config.styleCss && typeof document !== 'undefined') {
    let style = document.getElementById('dsh-wish-design');
    if (!style) { style=document.createElement('style'); style.id='dsh-wish-design'; document.head.appendChild(style); }
    style.textContent=config.styleCss;
  }
  const pending = new Map();
  const panels = new Map();
  let sequence = 0;
  let navigation = null, viewport = {keyboard:0,menu:{width:48,height:48,right:12,top:10}};
  window.__dshWishBack = () => {
    const modal = document.querySelector('dialog[open]');
    if (modal) { modal.close(); return true; }
    const popup = document.querySelector('[popover]:popover-open');
    if (popup) { popup.hidePopover(); return true; }
    if (window.__dshAppBack) {
      const outcome=window.__dshAppBack({layersOnly:true});
      if (outcome==='layer'||outcome==='popup')return true;
    }
    return navigation?.back?.() === true;
  };
  window.__dshWishSettings = () => { if (!navigation?.settings) return false; navigation.settings(); return true; };
  window.__dshWishViewport = value => {
    viewport={...value,width:window.innerWidth,height:window.innerHeight};
    const root=document.documentElement, menu=value.menu||{};
    root.style.setProperty('--wish-menu-right',(menu.right||0)+'px');
    root.style.setProperty('--wish-menu-top',(menu.top||0)+'px');
    root.style.setProperty('--wish-menu-width',(menu.width||0)+'px');
    root.style.setProperty('--wish-menu-height',(menu.height||0)+'px');
    root.toggleAttribute('data-wish-keyboard',value.keyboard>0);
    window.dispatchEvent(new CustomEvent('dsh-wish-viewport',{detail:value}));
  };
  function registerNavigation(handlers) {
    if (!handlers || (handlers.back && typeof handlers.back !== 'function') || (handlers.settings && typeof handlers.settings !== 'function')) throw new Error('Invalid navigation handlers');
    navigation=handlers;
    return () => {if(navigation===handlers)navigation=null;};
  }
  function mountComposer(host, {placeholder='', onSend, maxRows=5}={}) {
    const row=document.createElement('form');row.className='wish-composer';
    const input=document.createElement('textarea');input.className='wish-input';input.rows=1;input.placeholder=placeholder;input.setAttribute('aria-label',placeholder||'Message');
    const send=document.createElement('button');send.className='wish-button';send.type='submit';send.textContent=(config.locale||'zh').startsWith('zh')?'发送':'Send';
    function fit(){input.style.height='auto';input.style.height=Math.min(input.scrollHeight,Math.max(2,Math.min(maxRows,8))*26+24)+'px';}
    input.addEventListener('input',fit);
    row.onsubmit=async e=>{e.preventDefault();const value=input.value.trim();if(!value||send.disabled)return;send.disabled=true;try{await onSend?.(value);input.value='';fit();}catch(e){row.dispatchEvent(new CustomEvent('wish-error',{detail:e,bubbles:true}));}finally{send.disabled=false;}};
    row.append(input,send);host.appendChild(row);
    return Object.freeze({input,dispose(){row.remove();}});
  }
  window.__dshWishRefresh = next => {
    if (next.projectId !== config.projectId) return false;
    if (next.nonce !== config.nonce) {
      for (const task of pending.values()) {
        clearTimeout(task.timer);
        task.reject(new Error('Android request cancelled by navigation'));
      }
      pending.clear();
      config = next;
      window.dshWish = makeApi();
      window.dispatchEvent(new Event('dsh-wish-ready'));
    }
    return true;
  };
  function call(method, args = {}) {
    const id = Date.now().toString(36) + '-' + (++sequence);
    return new Promise((resolve, reject) => {
      const timer = setTimeout(() => { pending.delete(id); reject(new Error('Android request timed out')); }, 120000);
      pending.set(id, { resolve, reject, timer });
      try { window.DshWish.postMessage(JSON.stringify({ nonce: config.nonce, id, method, args })); }
      catch (e) { clearTimeout(timer); pending.delete(id); reject(e); }
    });
  }
  window.__dshWishReply = function (reply) {
    if (reply.nonce !== config.nonce) return;
    const task = pending.get(reply.id);
    if (!task) return;
    pending.delete(reply.id); clearTimeout(task.timer);
    if (reply.ok) task.resolve(reply.value); else task.reject(new Error(reply.error || 'Android request failed'));
  };
  function mountTaskControl(host) {
    if (!host || typeof host.appendChild !== 'function') throw new Error('Invalid task control host');
    const zh = (config.locale || document.documentElement.lang || 'zh').startsWith('zh');
    const label = (cn,en) => zh ? cn : en;
    const tools = {screen:['读取屏幕','Read screen'],apps:['查看应用','List apps'],open:['打开应用','Open app'],tap:['点按','Tap'],tap_xy:['点按','Tap'],type:['输入','Type'],scroll:['滚动','Scroll'],key:['切换页面','Navigate'],collect:['收集内容','Collect'],notify:['发送提醒','Notify'],handoff:['等待你接手','Waiting for you']};
    const toolLabel = raw => {const key=String(raw||'').replace(/^mcp__phone__/,'');const pair=tools[key];return pair?label(...pair):label('正在执行步骤','Running a step');};
    const details = document.createElement('details'); details.className = 'wish-task'; details.open = true;
    const summary = document.createElement('summary');
    const title = document.createElement('span'); title.className='wish-task-title'; title.textContent=label('任务待命','Ready for a task');
    const actions = document.createElement('span'); actions.className='wish-task-actions';
    function button(text, variant) { const b=document.createElement('button'); b.type='button'; b.className='wish-button'; b.dataset.variant=variant; b.textContent=text; return b; }
    const pause=button(label('暂停','Pause'),'secondary'), stop=button(label('停止','Stop'),'danger');
    actions.append(pause,stop);summary.append(title,actions);
    const body=document.createElement('div');body.className='wish-task-body';
    const steps=document.createElement('ol');steps.className='wish-timeline';
    const row=document.createElement('div');row.className='wish-row';
    const input=document.createElement('input');input.className='wish-input';input.style.flex='1';input.style.minWidth='140px';input.placeholder=label('插话：告诉助手换个做法…','Interject: try a different approach…');input.setAttribute('aria-label',label('任务插话','Task interjection'));
    const send=button(label('发送','Send'),'secondary');
    const error=document.createElement('div');error.className='wish-error';error.setAttribute('role','status');
    row.append(input,send);body.append(steps,row,error);details.append(summary,body);host.appendChild(details);
    let disposed=false, polling=false, paused=false, running=false;
    async function act(fn) { try {error.textContent='';await fn();await refresh();}catch(e){if(!disposed)error.textContent=e.message||String(e);} }
    pause.onclick=e=>{e.preventDefault();e.stopPropagation();act(()=>window.dshWish.phone.pause(!paused));};
    stop.onclick=e=>{e.preventDefault();e.stopPropagation();act(()=>window.dshWish.agent.stop());};
    send.onclick=()=>{const text=input.value.trim();if(text)act(async()=>{await window.dshWish.agent.steer(text);input.value='';});};
    async function refresh() {
      if(disposed || polling)return;polling=true;
      try {
        const [state,native]=await Promise.all([window.dshWish.agent.status(),window.dshWish.capabilities.status()]);
        if(disposed)return;
        running=state.running===true;paused=native.phoneStatus?.task?.paused===true;
        const phases={idle:['任务待命','Ready'],running:['正在执行','Working'],paused:['已暂停','Paused'],'awaiting-confirmation':['等待确认','Needs confirmation'],succeeded:['执行结束，请查看结果','Finished; view result'],failed:['执行失败','Failed'],stopped:['已停止','Stopped'],interrupted:['执行中断','Interrupted']};
        title.textContent=label(...(phases[paused&&running?'paused':state.phase||(running?'running':state.sessionId?'interrupted':'idle')]||phases.interrupted));
        if(state.error)error.textContent=String(state.error).slice(0,400);
        pause.textContent=paused?label('继续','Resume'):label('暂停','Pause');pause.disabled=!running;stop.disabled=!running;send.disabled=!running;
        steps.replaceChildren();
        for(const event of (state.events||[]).slice(-3)) {const li=document.createElement('li');li.textContent=event.type==='tool'?toolLabel(event.name):String(event.text||'').slice(0,160);steps.appendChild(li);}
      }catch(e){if(!disposed)error.textContent=e.message||String(e);}finally{polling=false;}
    }
    const timer=setInterval(refresh,3000);refresh();
    return Object.freeze({refresh,dispose(){disposed=true;clearInterval(timer);details.remove();}});
  }
  function makeApi() { return Object.freeze({
    version: 2, ui: Object.freeze({mountTaskControl, mountComposer, registerNavigation,
      mountBackgroundTasks:(host,options={})=>{
        let disposed=false,busy=false;const wrap=document.createElement('div'),button=document.createElement('button'),error=document.createElement('p');
        button.className='wish-button';button.textContent=(config.locale||'zh').startsWith('zh')?'安排后台任务':'Schedule a background task';error.className='wish-error';error.setAttribute('role','alert');
        button.onclick=async()=>{if(busy||disposed)return;busy=true;button.disabled=true;error.textContent='';try{await call('background.open',options)}catch(e){if(!disposed)error.textContent=e.message||String(e)}finally{busy=false;if(!disposed)button.disabled=false}};
        wrap.append(button,error);host.appendChild(wrap);return {dispose(){disposed=true;wrap.remove()}};
      },
      ready: () => call('ui.ready'), get viewport(){return viewport;}}), projectId: config.projectId,
    work: Object.freeze({describe: value => call('work.describe', {value}), identity: () => call('work.identity')}),
    actions: Object.freeze({register: actions => call('actions.register', {actions}), show: () => call('actions.show'), hide: () => call('actions.hide'), run: id => call('actions.run', {id})}),
    registerPanel(id, open) {
      if (id !== config.projectId || typeof open !== 'function') throw new Error('Invalid work panel');
      panels.set(id, open);
      return () => { if (panels.get(id) === open) panels.delete(id); };
    },
    openPanel(id) {
      const open = panels.get(id);
      if (!open) return false;
      open(); if(typeof requestAnimationFrame==='function')requestAnimationFrame(() => requestAnimationFrame(() => call('ui.ready').catch(()=>{}))); return true;
    },
    capabilities: Object.freeze({status: () => call('capabilities.status'), request: () => call('capabilities.request')}),
    phone: Object.freeze({tools: () => call('phone.tools'), begin: prompt => call('phone.begin', {prompt}),
      call: (ticket, tool, args = {}) => call('phone.call', {ticket, tool, args}), end: () => call('phone.end'), pause: paused => call('phone.pause', {paused})}),
    agent: Object.freeze({start: (prompt, options = {}) => call('agent.start', {prompt, phone: options.phone !== false}), status: () => call('agent.status'),
      results: () => call('agent.results'), open: () => call('agent.open'), steer: text => call('agent.steer', {text}), stop: () => call('agent.stop')}),
    reminders: Object.freeze({schedule: entry => call('reminders.schedule', entry), list: () => call('reminders.list'), cancel: id => call('reminders.cancel', {id})}),
    icons:Object.freeze({render:style=>call('icons.render',style)}),
    background:Object.freeze({open: (options={})=>call('background.open',options),schedule:args=>call('background.schedule',args),list:()=>call('background.list'),cancel:id=>call('background.cancel',{id}),runNow:id=>call('background.runNow',{id})}),
    travel: Object.freeze({extract: source => call('travel.extract',source), list: () => call('travel.list'), remove: id => call('travel.remove',{id}), save: (entry,options={}) => call('travel.save',{entry,...options})}),
    imports: Object.freeze({read: id => call('imports.read',{id}), list: () => call('imports.list'), remove: id => call('imports.remove',{id})}),
    shortcuts: Object.freeze({pin: id => call('shortcuts.pin',{id})}),
    widget: Object.freeze({pin: id => call('widget.pin',{id}), update: value => call('widget.update',{value})}),
    calendar: Object.freeze({list: range => call('calendar.list',range), save: event => call('calendar.save',event), remove: id => call('calendar.delete',{id})}),
    notifications: Object.freeze({list: () => call('notifications.list')}),
    files: Object.freeze({pick: options => call('files.pick',options), export: file => call('files.export',file)}),
    speech: Object.freeze({listen: options => call('speech.listen',options), speak: options => call('speech.speak',options), stop: () => call('speech.stop')}),
    location: Object.freeze({once: () => call('location.once')}), maps: Object.freeze({open: place => call('maps.open',place)}),
    ocr: Object.freeze({recognize: image => call('ocr.recognize',image)}),
    camera: Object.freeze({ capture: () => call('camera.capture') }),
    ai: Object.freeze({ complete: request => call('ai.complete', request) }),
    data: Object.freeze({ read: collection => call('data.read', { collection }), write: (collection, value) => call('data.write', { collection, value }) }),
    publish: entry => call('project.publish', entry),
  }); }
  window.dshWish = makeApi();
  window.dispatchEvent(new Event('dsh-wish-ready'));
}
