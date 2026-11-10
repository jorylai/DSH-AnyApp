    function CoachText({text}) {
      return h('div',{className:'cc-prose'},String(text||'').split(/\n\s*\n/).filter(Boolean).map((block,i)=>{
        const lines=block.split('\n');
        if(lines.every(l=>/^\s*[-*•]\s+/.test(l)))return h('ul',{key:i},lines.map((line,j)=>h('li',{key:j},line.replace(/^\s*[-*•]\s+/,''))));
        return h('p',{key:i},lines.map((line,j)=>h(React.Fragment,{key:j},j?h('br'):null,line.replace(/^#{1,4}\s+/,''))));
      }));
    }
    function CoachExperience(props) {
      const bridge=props.bridge;
      const repoRef=useRef(null),mounted=useRef(true),threadRef=useRef(null),busyRef=useRef(false),pendingReply=useRef(null);
      const [state,setState]=useState('loading'),[error,setError]=useState(''),[memoryError,setMemoryError]=useState('');
      const [catalog,setCatalog]=useState({threads:[]}),[memory,setMemory]=useState({enabled:true,facts:[]});
      const [mode,setMode]=useState('home'),[thread,setThread]=useState(null),[busy,setBusy]=useState(false);
      const modeRef=useRef('home'),modeTrail=useRef([]);
      const [draft,setDraft]=useState(''),[query,setQuery]=useState(''),[editing,setEditing]=useState(null),[editText,setEditText]=useState('');
      const [historyLimit,setHistoryLimit]=useState(10),[notice,setNotice]=useState(''),[saving,setSaving]=useState(false);
      const [confirmForget,setConfirmForget]=useState(null);
      const messagesRef=useRef(null),draftRef=useRef(''),draftTimer=useRef(null),lastSeed=useRef(null);
      const updateThread=value=>{threadRef.current=value;if(mounted.current)setThread(value);};
      const refresh=()=>{const snapshot=repoRef.current.snapshot();if(mounted.current){setCatalog(snapshot.catalog);setMemory(snapshot.memory);}};
      const problem=e=>errorReason(e)||'暂时没有完成，请重试。';
      useEffect(()=>{mounted.current=true;return()=>{mounted.current=false;if(draftTimer.current)window.clearTimeout(draftTimer.current);props.navigationRef.current=null;props.onDepth('');};},[]);
      const enter=next=>{setError('');setNotice('');if(next!==modeRef.current){if(next==='home')modeTrail.current=[];else modeTrail.current.push(modeRef.current);}modeRef.current=next;setMode(next);};
      const leave=()=>{
        if(pendingReply.current){setError('这次回复还没有保存，请先点“重试保存”。');return true;}
        if(mode!=='home'){const previous=modeTrail.current.pop()||'home';modeRef.current=previous;setMode(previous);setError('');setNotice('');return true;}return false;
      };
      useEffect(()=>{props.navigationRef.current=leave;props.onDepth(mode==='home'?'':mode==='chat'?'和教练聊聊':mode==='memory'?'教练的记忆':'过往对话');},[mode]);
      useEffect(()=>{
        if(!bridge?.data)return;
        let cancelled=false;const repo=new CoachCore.Repository(bridge.data);repoRef.current=repo;
        Promise.all([repo.load(),bridge.data.read('coachDraft')]).then(([snapshot,saved])=>{
          if(cancelled)return;setCatalog(snapshot.catalog);setMemory(snapshot.memory);setState('ready');
          if(saved?.text){draftRef.current=saved.text;setDraft(saved.text);}
        }).catch(e=>{if(!cancelled){setState('error');setError(problem(e));}});
        return()=>{cancelled=true;};
      },[bridge]);
      const changeDraft=text=>{
        draftRef.current=text;setDraft(text);
        if(draftTimer.current)window.clearTimeout(draftTimer.current);
        draftTimer.current=window.setTimeout(()=>{
          if(bridge?.data)Promise.resolve(bridge.data.write('coachDraft',{text,threadId:threadRef.current?.id||''})).catch(()=>{});
        },350);
      };
      async function openThread(meta){
        if(busyRef.current&&threadRef.current?.id!==meta.id){setError('当前回复还在生成，完成后再切换对话。');return;}
        try{const value=await repoRef.current.readThread(meta.id);updateThread(value);setMemoryError('');enter('chat');}
        catch(e){setError(problem(e));}
      }
      async function start(kind,seed){
        if(state!=='ready'||busyRef.current)return;
        setError('');setMemoryError('');setNotice('');
        try{
          const repo=repoRef.current;
          if(seed){
            const existing=repo.catalog.threads.find(t=>t.adviceId===seed.id);
            if(existing){await openThread(existing);return;}
          }
          let value=repo.newThread(seed?.headline||'和教练聊聊',kind||'chat');
          if(seed){value.adviceId=seed.id;value.messages=[{id:CoachCore.id(),role:'assistant',text:CoachCore.adviceText(seed),at:seed.at||CoachCore.now(),state:'complete',legacy:true}];value=await repo.saveThread(value);refresh();}
          updateThread(value);enter('chat');
          if(kind==='diet'||kind==='training')await send(kind==='diet'?'结合我的近期饮食和目标，帮我看看接下来一餐怎么安排。':'结合我近期的运动、睡眠和目标，给我一份适合当前状态的活动建议。',value);
        }catch(e){setError(problem(e));}
      }
      useEffect(()=>{if(state==='ready'&&props.seed&&lastSeed.current!==props.seed.id){lastSeed.current=props.seed.id;start('chat',props.seed);}},[state,props.seed?.id]);
      useEffect(()=>{
        if(mode==='chat'&&messagesRef.current){const el=messagesRef.current;el.scrollTop=el.scrollHeight;}
      },[mode,thread?.messages.length,busy]);
      async function storeAnswer(value,candidates,sources){
        const repo=repoRef.current;
        setSaving(true);pendingReply.current={value,candidates,sources};
        try{
          const saved=await repo.saveThread(value);updateThread(saved);refresh();pendingReply.current=null;
          setError('');
          if(repo.memory.enabled&&candidates?.length){
            try{const result=await repo.remember(candidates,sources);refresh();if(result.added)setNotice('记住了 '+result.added+' 条信息，可在“记忆”里查看。');}
            catch(e){setMemoryError('回复已保存，记忆暂未保存：'+problem(e));}
          }
        }catch(e){setError('回复还在当前页面，保存未完成：'+problem(e));}
        finally{if(mounted.current)setSaving(false);}
      }
      async function send(text,initial,retryId){
        const content=String(text||'').trim();if(!content||busyRef.current||state!=='ready')return;
        if(content.length>6000){setError('这段内容超过 6000 字，请分两次发送。');return;}
        if(pendingReply.current){setError('请先保存当前回复。');return;}
        busyRef.current=true;setBusy(true);setError('');setNotice('');setMemoryError('');
        let value=CoachCore.clone(initial||threadRef.current||repoRef.current.newThread(content));
        let message=retryId?value.messages.find(m=>m.id===retryId&&m.role==='user'):null;
        if(!message){message={id:CoachCore.id(),role:'user',threadId:value.id,text:content,at:CoachCore.now(),state:'pending'};value.messages.push(message);}
        else{message.state='pending';delete message.error;}
        if(value.title==='和教练聊聊')value.title=content.slice(0,24);
        value.status='pending';
        try{
          value=await repoRef.current.saveThread(value);updateThread(value);refresh();
          changeDraft('');
          if(!bridge?.ai?.complete)throw new Error('当前模型暂不可用，请检查宿主中的模型登录。');
          const response=await bridge.ai.complete({prompt:CoachCore.prompt(value,props.store,repoRef.current.memory)});
          const parsed=CoachCore.parseResponse(response?.text);
          value=CoachCore.clone(value);value.messages.find(m=>m.id===message.id).state='complete';
          value.messages.push({id:CoachCore.id(),role:'assistant',text:parsed.reply,replyTo:message.id,at:CoachCore.now(),state:'complete',model:[response?.provider,response?.model].filter(Boolean).join(' / '),memoryCandidates:parsed.memories});
          value.status='idle';updateThread(value);
          await storeAnswer(value,parsed.memories,[message]);
        }catch(e){
          // If the user message was not durably saved, retain the input for retry.
          const savedUser=threadRef.current?.messages.some(m=>m.id===message.id);
          if(!savedUser){changeDraft(content);setError('消息尚未保存，也没有发送给模型：'+problem(e));}
          else{
            value=CoachCore.clone(threadRef.current);const pending=value.messages.find(m=>m.id===message.id);
            if(pending){pending.state='failed';pending.error=problem(e);}value.status='failed';updateThread(value);
            try{const saved=await repoRef.current.saveThread(value);updateThread(saved);refresh();}catch{}
            setError(problem(e));
          }
        }finally{busyRef.current=false;if(mounted.current)setBusy(false);}
      }
      async function retryMemory(){
        try{
          const value=threadRef.current;const reply=value?.messages.filter(m=>m.role==='assistant'&&m.memoryCandidates?.length).at(-1);
          if(!reply)return;await repoRef.current.remember(reply.memoryCandidates,value.messages.filter(m=>m.role==='user'));refresh();setMemoryError('');setNotice('记忆已保存。');
        }catch(e){setMemoryError(problem(e));}
      }
      async function memoryAction(action){try{setSaving(true);setError('');await action();refresh();setEditing(null);setNotice('已保存');}catch(e){setError(problem(e));}finally{setSaving(false);}}
      async function exportMemory(){try{
        const data=await repoRef.current.export();
        if(!bridge?.files?.export)throw new Error('当前环境暂不支持导出。');
        const encoded=new TextEncoder().encode(JSON.stringify(data,null,2));let binary='';for(const byte of encoded)binary+=String.fromCharCode(byte);
        const result=await bridge.files.export({name:'热量教练-对话与记忆-'+localDate()+'.json',mime:'application/json',data:btoa(binary)});
        if(result!==null)setNotice('已交给系统保存；可在你选择的位置查看。');
      }catch(e){setError(problem(e));}}
      const button=(text,action,options={})=>h('button',{type:'button',className:'cc-button '+(options.primary?'cc-primary':''),disabled:options.disabled,onClick:action,...options.attrs},text);
      const errorBox=error?h('div',{className:'cc-alert',role:'alert'},h('span',null,error),pendingReply.current?button(saving?'保存中…':'重试保存',()=>{const p=pendingReply.current;if(p)storeAnswer(p.value,p.candidates,p.sources);},{disabled:saving}):null):null;
      if(state==='loading')return h('div',{className:'cc-empty',role:'status'},h('span',{className:'cc-orbit'}),h('p',null,'正在接回之前的对话…'));
      if(state==='error')return h('div',{className:'cc-empty'},h('h2',null,'暂时没能读取对话'),h('p',null,error),button('重试',async()=>{try{await repoRef.current.load();refresh();setState('ready');setError('');}catch(e){setError(problem(e));}}));
      const recent=catalog.threads.slice().sort((a,b)=>String(b.updatedAt).localeCompare(String(a.updatedAt)));
      if(mode==='home')return h('div',{className:'cc-home'},
        h('section',{className:'cc-hero'},h('span',{className:'cc-eyebrow'},'A LITTLE BETTER, EVERY DAY'),h('h2',null,'不用一个人，\n把习惯养好。'),h('p',null,'聊饮食，也聊运动。教练会把你说过的重要信息记下来，让下一次建议更贴近你。'),
          h('div',{className:'cc-intents'},button('今天怎么吃',()=>start('diet'),{primary:true,disabled:busy}),button('运动怎么安排',()=>start('training'),{disabled:busy})),button('我有别的问题',()=>start('chat'))),
        errorBox,
        h('div',{className:'cc-section-head'},h('h3',null,'接着聊'),button('全部对话',()=>enter('history'))),
        recent.length?h('div',{className:'cc-conversations'},recent.slice(0,3).map(t=>h('button',{className:'cc-conversation',key:t.id,onClick:()=>openThread(t)},h('span',{className:'cc-chat-icon'},h(Icon,{name:'spark',size:18})),h('span',null,h('strong',null,t.title),h('small',null,dateTimeLabel(t.updatedAt)+' · '+(t.messageCount||0)+' 条消息')),h(Icon,{name:'back',size:16,style:{transform:'rotate(180deg)'}})))):
          h('div',{className:'cc-soft-empty'},'从一个小问题开始，之后随时接着聊。'),
        h('button',{className:'cc-memory-entry',onClick:()=>enter('memory')},h('span',{className:'cc-memory-symbol'},h(Icon,{name:'heart',size:22})),h('span',null,h('strong',null,'教练的记忆'),h('small',null,(memory.enabled?'正在记住':'已暂停新增')+' · '+memory.facts.filter(f=>f.status==='active').length+' 条信息，可修改、可忘记')),h(Icon,{name:'back',size:16,style:{transform:'rotate(180deg)'}})),
        props.store.advices.length?h('section',{className:'cc-legacy'},h('div',{className:'cc-section-head'},h('h3',null,'之前的建议'),h('span',null,'旧记录全部保留')),
          props.store.advices.slice().reverse().slice(0,historyLimit).map(a=>h('button',{key:a.id,className:'cc-conversation',onClick:()=>start('chat',a)},h('span',null,h('strong',null,a.headline||'饮食与训练建议'),h('small',null,dateTimeLabel(a.at)+' · 点开可继续聊')),h(Icon,{name:'back',size:16,style:{transform:'rotate(180deg)'}}))),props.store.advices.length>historyLimit?button('查看更多旧建议',()=>setHistoryLimit(n=>n+10)):null):null);
      if(mode==='chat'){
        const lastUser=thread?.messages.filter(m=>m.role==='user').at(-1);
        const interrupted=lastUser&&lastUser.state!=='complete'&&!busy&&!pendingReply.current;
        return h('div',{className:'cc-chat'},
          h('div',{className:'cc-chat-top'},h('span',{className:'cc-presence'}),h('span',null,'结合本机记录 · '+(memory.enabled?'记忆已开启':'记忆已暂停')),button('记忆',()=>enter('memory'),{disabled:busy||!!pendingReply.current})),
          h('div',{className:'cc-messages',ref:messagesRef,'aria-live':'polite'},
            thread?.messages.length?thread.messages.map(m=>h('article',{className:'cc-message cc-'+m.role,key:m.id},
              h('div',{className:'cc-message-meta'},m.role==='user'?'你':m.legacy?'之前的教练建议':'热量教练',h('time',null,timeLabel(m.at))),h(CoachText,{text:m.text}),
              m.role==='assistant'&&memory.facts.some(f=>f.source?.messageId===m.replyTo)?h('span',{className:'cc-memory-note'},'已提取记忆，可查看和修改'):null)):
              h('div',{className:'cc-chat-welcome'},h('span',{className:'cc-orbit'}),h('h2',null,'从你在意的事聊起'),h('p',null,'比如“午餐总吃得太晚，怎么安排更容易坚持？”')),
            busy?h('div',{className:'cc-thinking',role:'status'},h('i'),h('i'),h('i'),h('span',null,'正在结合你的记录…')):null,
            errorBox,
            interrupted?h('div',{className:'cc-alert'},h('span',null,lastUser.state==='failed'?'这次没有收到完整回复，原消息已保存。':'上次回复中断，原消息已保存。'),button('重新回复',()=>send(lastUser.text,thread,lastUser.id),{disabled:busy})):null,
            memoryError?h('div',{className:'cc-alert'},h('span',null,memoryError),button('重试保存记忆',retryMemory,{disabled:saving})):null,
            notice?h('p',{className:'cc-inline-status',role:'status'},notice):null),
          h('form',{className:'cc-composer',onSubmit:e=>{e.preventDefault();send(draft);}},h('label',{className:'cc-sr',htmlFor:'cc-message'},'给教练发消息'),
            h('div',{className:'cc-input-shell'},h('textarea',{id:'cc-message',rows:2,maxLength:6000,placeholder:busy?'教练回复后可以继续补充…':'说说你现在的想法…',value:draft,onChange:e=>changeDraft(e.target.value),onKeyDown:e=>{if((e.ctrlKey||e.metaKey)&&e.key==='Enter'&&!e.nativeEvent.isComposing){e.preventDefault();send(draft);}}}),
              h('button',{type:'submit',className:'cc-send','aria-label':'发送给教练',disabled:busy||saving||!draft.trim()||!!pendingReply.current},h(Icon,{name:'up',size:21}))),
            h('p',null,busy?'消息已保存，正在等待模型回复。':'对话保存在本机；发送时会交给当前已登录模型处理。')));
      }
      if(mode==='history')return h('div',{className:'cc-panel'},h('div',{className:'cc-panel-scroll'},h('div',{className:'cc-section-head'},h('h2',null,'过往对话'),button('新的话题',()=>start('chat'))),errorBox,
        recent.length?recent.slice(0,historyLimit).map(t=>h('button',{className:'cc-conversation',key:t.id,onClick:()=>openThread(t)},h('span',null,h('strong',null,t.title),h('small',null,dateTimeLabel(t.updatedAt)+' · '+t.messageCount+' 条消息')),h(Icon,{name:'back',size:16,style:{transform:'rotate(180deg)'}}))):h('p',{className:'cc-hint'},'还没有新的教练对话。之前的建议仍在教练首页。'),
        recent.length>historyLimit?button('查看更多',()=>setHistoryLimit(n=>n+10)):null));
      const facts=memory.facts.filter(f=>f.status!=='archived'&&(!query||f.text.toLowerCase().includes(query.toLowerCase())));
      return h('div',{className:'cc-panel'},
        h('div',{className:'cc-memory-toolbar'},h('input',{className:'wish-input',type:'search',placeholder:'找一条记忆…',value:query,onChange:e=>setQuery(e.target.value),'aria-label':'搜索记忆'})),
        h('div',{className:'cc-panel-scroll'},
          h('section',{className:'cc-memory-intro'},h('h2',null,'一点点，更了解你。'),h('p',null,'从你的原话中提取长期偏好、目标和习惯。每条都能追溯来源；旧目标冲突时先请你确认。'),
            h('label',{className:'cc-toggle'},h('span',null,'记住并引用对话中的信息'),h('input',{type:'checkbox',checked:memory.enabled,disabled:saving,onChange:e=>memoryAction(()=>repoRef.current.setMemoryEnabled(e.target.checked))}))),
          h('p',{className:'cc-hint'},'你的资料和最近 7 天记录会按需引用。关闭记忆会暂停新增和引用长期记忆，不会清空对话。'),
          errorBox,notice?h('p',{className:'cc-inline-status',role:'status'},notice):null,
          h('div',{className:'cc-section-head'},h('h3',null,'我记住的'),button('添加一条',()=>{setEditing('new');setEditText('');})),
          editing?h('form',{className:'cc-memory-editor',onSubmit:e=>{e.preventDefault();memoryAction(()=>editing==='new'?repoRef.current.addFact(editText,'preference'):repoRef.current.editFact(editing,{text:editText}));}},
            h('label',{htmlFor:'cc-edit-memory'},editing==='new'?'想让教练记住什么？':'修改这条记忆'),h('textarea',{id:'cc-edit-memory',className:'wish-input',rows:3,maxLength:240,value:editText,onChange:e=>setEditText(e.target.value),autoFocus:true}),
            h('div',{className:'cc-row'},button('取消',()=>setEditing(null)),h('button',{className:'cc-button cc-primary',type:'submit',disabled:saving||!editText.trim()},saving?'保存中…':'保存记忆'))):null,
          facts.length?facts.map(f=>h('article',{className:'cc-fact',key:f.id},h('div',{className:'cc-fact-label'},h('span',null,CoachCore.CATEGORIES[f.category]||'其他信息'),h('span',null,f.status==='pending'?'有旧目标，待确认':f.expiresAt&&Date.parse(f.expiresAt)<Date.now()?'已过期，未引用':'已记住')),
            h('p',null,f.text),h('small',null,(f.source?.type==='manual'?'你手动添加':f.source?.type==='profile'?'来自本机资料':'来自你的对话')+' · '+dateTimeLabel(f.updatedAt)),
            h('div',{className:'cc-row'},f.status==='pending'?button('用这个新目标',()=>memoryAction(()=>repoRef.current.editFact(f.id,{status:'active'})),{disabled:saving}):null,
              f.source?.threadId?button('查看来源',()=>openThread({id:f.source.threadId})):null,
              button('修改',()=>{setEditing(f.id);setEditText(f.text);}),button('忘记',()=>setConfirmForget(f.id))),
            confirmForget===f.id?h('div',{className:'cc-forget-confirm'},h('p',null,'以后不再引用这条记忆。原始对话仍保留，方便回看。'),button('取消',()=>setConfirmForget(null)),button('确认忘记',()=>memoryAction(async()=>{await repoRef.current.forget(f.id);setConfirmForget(null);} ),{disabled:saving})):null)):
              h('div',{className:'cc-soft-empty'},query?'没有找到这条记忆。':'还没有长期记忆。可以手动添加，或在聊天时告诉教练你的习惯。'),
          h('div',{className:'cc-export'},button('导出对话与记忆',exportMemory),h('p',{className:'cc-hint'},'导出到你选择的位置，方便自己备份。'))));
    }
