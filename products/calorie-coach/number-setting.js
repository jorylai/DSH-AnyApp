    function NumberSetting(props) {
      const [text,setText]=useState(props.value?String(props.value):'');
      const [error,setError]=useState('');const focused=useRef(false);
      useEffect(function(){if(!focused.current&&!error)setText(props.value?String(props.value):'');},[props.value,error]);
      function commit(event){
        focused.current=false;const raw=String(text).trim();
        if(!raw&&props.min===0){setError('');if(toNum(props.value)!==0)props.onCommit(0);return;}
        const value=Number(raw);
        if(!raw||!Number.isFinite(value)||value<props.min||value>props.max){setError('请输入 '+props.min+'–'+props.max+(props.unit?' '+props.unit:''));return;}
        setError('');setText(String(value));if(value!==toNum(props.value))props.onCommit(value);
      }
      return h('div',{className:'kc-field'},
        h('label',{className:'kc-fieldLabel',htmlFor:props.id},h('span',null,props.label),props.unit?h('small',null,props.unit):null),
        h('input',{id:props.id,className:'wish-input kc-inlineNum',type:'number',required:props.min>0,inputMode:'decimal',min:props.min,max:props.max,step:props.step||1,value:text,
          placeholder:props.id==='st-override'?'自动计算':'未填写','aria-invalid':!!error,'aria-describedby':error?props.id+'-error':undefined,
          onFocus:function(){focused.current=true;},onChange:function(e){setText(e.target.value);setError('');},onBlur:commit,
          onKeyDown:function(e){if(e.key==='Enter'){e.preventDefault();e.currentTarget.blur();}}}),
        error?h('span',{id:props.id+'-error',className:'wish-error',role:'alert'},error):props.hint?h('span',{className:'kc-hint'},props.hint):null);
    }
