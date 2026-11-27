(() => {
  'use strict';
  const API = 'https://samp-api.ct8.pl/server/5.42.217.107:9223';
  const PROXY = 'https://api.allorigins.win/raw?url=' + encodeURIComponent(API);
  const $ = id => document.getElementById(id);
  const el = {state:$('liveState'),players:$('livePlayers'),capacity:$('liveCapacity'),mode:$('liveGamemode'),map:$('liveMap'),percent:$('livePercent'),bar:$('liveBar'),updated:$('liveUpdated'),list:$('livePlayerList'),count:$('livePlayerCount'),error:$('liveError'),copy:$('liveCopy'),refresh:$('liveRefresh')};
  if (!el.state) return;
  let busy=false, lastOk=null;
  function status(kind,label){el.state.className='live-state '+kind;el.state.replaceChildren();const dot=document.createElement('i');el.state.append(dot,document.createTextNode(label));}
  function render(list){el.list.replaceChildren();if(!Array.isArray(list)||!list.length){const p=document.createElement('p');p.className='live-empty';p.textContent='در حال حاضر بازیکنی آنلاین نیست.';el.list.append(p);return;}
    list.forEach((player,i)=>{const row=document.createElement('article');row.className='live-player';row.style.setProperty('--player-index',i);const name=document.createElement('b');name.textContent=String(player.nickname??'Unknown');const stats=document.createElement('span');stats.textContent=`Score ${Number(player.score)||0} · Ping ${Number(player.ping)||0}`;row.append(name,stats);el.list.append(row);});}
  async function request(url){const controller=new AbortController();const timeout=setTimeout(()=>controller.abort(),10000);try{const r=await fetch(url,{cache:'no-store',headers:{Accept:'application/json'},signal:controller.signal});if(!r.ok)throw new Error('HTTP '+r.status);const d=await r.json();if(typeof d.online!=='boolean')throw new Error('پاسخ API قابل‌خواندن نیست');return d;}finally{clearTimeout(timeout);}}
  async function getData(){try{return await request(API);}catch(first){return request(PROXY);}}
  async function refresh(){if(busy)return;busy=true;el.refresh?.classList.add('is-loading');try{const d=await getData();lastOk=Date.now();const online=!!d.online,now=Number(d.players)||0,max=Number(d.maxplayers)||0,pct=max?Math.min(100,Math.round(now/max*100)):0;
      status(online?'online':'offline',online?'SERVER ONLINE':'SERVER OFFLINE');el.players.textContent=online?String(now):'0';el.capacity.textContent=max?String(max):'--';el.mode.textContent=online?(d.gamemode||'--'):'--';el.map.textContent=online?(d.mapname||'San Andreas'):'سرور در دسترس نیست';el.percent.textContent=(online?pct:0)+'%';el.bar.style.width=(online?pct:0)+'%';render(online?d.list:[]);el.count.textContent=(online?now:0)+' نفر';el.updated.textContent='آخرین بروزرسانی: '+new Date().toLocaleTimeString('fa-IR');el.error.hidden=true;
    }catch(e){status('offline','اتصال ناموفق');el.error.hidden=false;el.error.textContent='دریافت داده واقعی ناموفق بود. سرویس API یا پراکسی پاسخ نداد؛ هیچ عدد ساختگی نمایش داده نمی‌شود. '+(e?.message||'');el.updated.textContent='تلاش مجدد خودکار در ۳۰ ثانیه';if(!lastOk){el.players.textContent='--';el.capacity.textContent='--';el.mode.textContent='--';el.map.textContent='در انتظار اتصال';el.percent.textContent='--';el.bar.style.width='0%';}}
    finally{busy=false;el.refresh?.classList.remove('is-loading');}}
  el.copy?.addEventListener('click',async()=>{try{await navigator.clipboard.writeText('5.42.217.107:9223');el.copy.textContent='کپی شد';}catch{el.copy.textContent='کپی نشد';}setTimeout(()=>{el.copy.textContent='کپی IP';},1600);});
  el.refresh?.addEventListener('click',refresh);refresh();setInterval(refresh,30000);
})();
