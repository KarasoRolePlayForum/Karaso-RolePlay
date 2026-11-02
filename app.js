const $=s=>document.querySelector(s), $$=s=>document.querySelectorAll(s);
const defaultCategories=[
 {id:"news-center",title:"اطلاعیه‌ها، اخبار و آموزش سرور",desc:"آخرین اخبار و راهنماهای رسمی کاراسو",icon:"📢",forums:[{id:"announcements",title:"اطلاعیه‌های مهم",desc:"اطلاعیه‌های رسمی مدیریت سرور"},{id:"server_news",title:"اخبار سرور",desc:"خبرها و به‌روزرسانی‌های کاراسو"},{id:"server_tutorials",title:"آموزش سرور",desc:"آموزش سیستم‌ها و امکانات سرور"}]},
 {id:"rules",title:"📌 قوانین مهم سرور و فکشن‌ها",desc:"برای مشاهده قوانین هر بخش، تالار مربوطه را انتخاب کنید",icon:"📜",forums:[{id:"server_rules",title:"قوانین عمومی سرور",desc:"قوانین اصلی و عمومی کاراسو"},{id:"rules_police",title:"قوانین فکشن پلیس",desc:"قوانین سازمان نیروی پلیس"},{id:"rules_army",title:"قوانین فکشن ارتش",desc:"قوانین سازمان ارتش"},{id:"rules_radio",title:"قوانین فکشن رادیو",desc:"قوانین سازمان رادیو"},{id:"rules_federal",title:"قوانین فکشن فدرال",desc:"قوانین سازمان فدرال"},{id:"rules_medic",title:"قوانین فکشن خدمات درمانی",desc:"قوانین سازمان EMS"},{id:"rules_government",title:"قوانین فکشن دولتی",desc:"قوانین سازمان دولتی"},{id:"rules_grove",title:"قوانین گنگ Grove Street Families",desc:"قوانین گنگ گروو استریت"},{id:"rules_ballas",title:"قوانین گنگ Ballas",desc:"قوانین گنگ بالاس"},{id:"rules_vagos",title:"قوانین گنگ Los Santos Vagos",desc:"قوانین گنگ واگوس"},{id:"rules_aztecas",title:"قوانین گنگ Varrios Los Aztecas",desc:"قوانین گنگ آزتکاس"},{id:"rules_rifa",title:"قوانین گنگ San Fierro Rifa",desc:"قوانین گنگ ریفا"}]},
 {id:"leadership",title:"درخواست‌های مدیریتی و لیدری",desc:"درخواست لیدری فکشن‌ها و موقعیت‌های مدیریتی",icon:"♛",forums:[{id:"leader",title:"درخواست لیدری فکشن",desc:"فرم درخواست و شرایط لیدری"},{id:"admin_apply",title:"درخواست ادمینی",desc:"ارسال درخواست پیوستن به تیم مدیریت"},{id:"helper_apply",title:"درخواست هلپری",desc:"ارسال درخواست عضویت در تیم هلپرها"},{id:"resign",title:"درخواست استعفا",desc:"ثبت درخواست استعفا از فکشن"},{id:"membership",title:"درخواست عضویت در فکشن",desc:"درخواست پیوستن به مجموعه‌ها"}]},
 {id:"factions",title:"فکشن‌ها و سازمان‌ها",desc:"بخش‌های رسمی سرور کاراسو",icon:"✦",forums:[{id:"police",title:"سازمان نیروی پلیس",desc:"گفت‌وگو و موضوعات مربوط به پلیس"},{id:"army",title:"سازمان ارتش",desc:"موضوعات و فعالیت‌های سازمان ارتش"},{id:"radio",title:"سازمان رادیو",desc:"موضوعات و فعالیت‌های سازمان رادیو"},{id:"federal",title:"سازمان فدرال",desc:"موضوعات و فعالیت‌های سازمان فدرال"},{id:"medic",title:"سازمان خدمات درمانی",desc:"موضوعات مربوط به EMS"},{id:"government",title:"سازمان دولتی",desc:"موضوعات مربوط به دولت"}]},
 {id:"gangs",title:"گنگ‌های سن آندریاس",desc:"گفت‌وگوهای مربوط به پنج گنگ رسمی",icon:"⚡",forums:[{id:"grove",title:"Grove Street",desc:"انجمن گنگ Grove Street"},{id:"ballas",title:"Ballas",desc:"انجمن گنگ Ballas"},{id:"vagos",title:"Los Santos Vagos",desc:"انجمن گنگ Vagos"},{id:"aztecas",title:"Varrios Los Aztecas",desc:"انجمن گنگ Aztecas"},{id:"rifa",title:"Grove / Rifa",desc:"انجمن گنگ Rifa"}]},
 {id:"community",title:"انجمن عمومی",desc:"اخبار، راهنماها و گفت‌وگوهای پلیرها",icon:"☰",forums:[{id:"news",title:"اخبار و اطلاعیه‌ها",desc:"اطلاعیه‌های رسمی سرور"},{id:"help",title:"سؤالات و راهنما",desc:"کمک و پاسخ به سوالات"},{id:"complaints",title:"شکایات",desc:"ثبت شکایت و پیگیری"}]}
];
// هر فکشن، سه تالار مستقل زیر صفحه اصلی خودش دارد.
for (const category of defaultCategories.filter(c => c.id === "factions" || c.id === "gangs")) {
  category.forums = category.forums.map(f => ({
    ...f,
    subforums: [
      { id: `${f.id}_membership`, title: "درخواست عضویت", desc: "ثبت درخواست پیوستن به این فکشن" },
      { id: `${f.id}_resignation`, title: "درخواست استعفا", desc: "ثبت درخواست خروج از فکشن" },
      { id: `${f.id}_reports`, title: "گزارش کار اعضا", desc: "ارسال گزارش فعالیت و کارکرد اعضای فکشن" },
      { id: `${f.id}_leadership`, title: "درخواست لیدری فکشن", desc: "ثبت درخواست لیدری مخصوص همین فکشن" }
    ]
  }));
}
let categories=defaultCategories, user=localStorage.getItem("karaso_user")||"", activeForum=null, activeTopic=null;
let currentRole="user", currentAuthId=null;
function isAdmin(){return ["owner","admin"].includes(currentRole);}
function isStaff(){return ["owner","admin","helper"].includes(currentRole);}
function currentAuthor(){return user||"کاربر مهمان";}
function refreshAdminButton(){
 const b=$("#adminPanelBtn");
 if(b) b.style.display=isAdmin()?"inline-flex":"none";
 const badge=$("#userBadge");
 if(badge) badge.classList.toggle("admin-name",isStaff());
}
function adminName(name){
 const currentUserName=String(user).trim().toLowerCase();
 const isCurrent=String(name).trim().toLowerCase()===currentUserName;
 const role=isCurrent?currentRole:"user";
 const staff=["owner","admin","helper"].includes(role);
 const label=role==="owner"?"OWNER":role==="admin"?"ADMIN":role==="helper"?"HELPER":"";
 return `<b class="${staff?"admin-name":""}">${esc(name)}</b>${staff?`<span class="admin-role">${label}</span>`:""}`;
}

let topics=[];
let topicsLoaded=false;
function formatDate(value){try{return new Date(value).toLocaleDateString("fa-IR")}catch{return ""}}
function mapTopic(row){return {id:row.id,forum:row.forum,title:row.title,author:row.author||"کاربر",date:formatDate(row.created_at),created_at:row.created_at,body:row.body,replies:[],locked:!!row.locked,author_id:row.author_id};}
function updateStats(){let replies=topics.reduce((n,t)=>n+t.replies.length,0);$("#topicCount").textContent=topics.length;$("#sideTopicCount").textContent=topics.length;$("#postCount").textContent=replies;$("#sidePostCount").textContent=replies;$("#popular").innerHTML=topics.slice(0,4).map(t=>`<div class="statline"><a onclick="openTopic(${t.id})">${esc(t.title)}</a><b>${t.replies.length}</b></div>`).join("")||"—"}
async function loadTopics(){
 if(!sbClient){topics=[];topicsLoaded=true;updateStats();renderHome();return;}
 try{
  const {data,error}=await sbClient.from("topics").select("id,forum,title,body,author,author_id,locked,created_at").order("created_at",{ascending:false});
  if(error)throw error;
  const rows=data||[];
  const ids=rows.map(r=>r.id);
  let replyRows=[];
  if(ids.length){const {data:rd,error:re}=await sbClient.from("replies").select("id,topic_id,body,author,author_id,created_at").in("topic_id",ids).order("created_at",{ascending:true});if(re)throw re;replyRows=rd||[];}
  topics=rows.map(mapTopic);
  for(const r of replyRows){const t=topics.find(x=>String(x.id)===String(r.topic_id));if(t)t.replies.push({id:r.id,author:r.author||"کاربر",body:r.body,date:formatDate(r.created_at),created_at:r.created_at,author_id:r.author_id});}
  topicsLoaded=true;updateStats();
  if(activeTopic!==null)openTopic(activeTopic);else if(activeForum!==null)openForum(activeForum);else renderHome();
 }catch(e){console.error("Supabase topics load error",e);alert("دریافت موضوع‌ها از Supabase ناموفق بود: "+(e.message||e));}
}
function save(){updateStats()}
function forumInfo(id){for(let c of categories){for(let f of c.forums){if(f.id===id)return {f,c};if(f.subforums){let sf=f.subforums.find(x=>x.id===id);if(sf)return {f:sf,c}}}}return {f:{title:id},c:{title:"انجمن"}}}
function updateStats(){let replies=topics.reduce((n,t)=>n+t.replies.length,0);$("#topicCount").textContent=topics.length;$("#sideTopicCount").textContent=topics.length;$("#postCount").textContent=replies;$("#sidePostCount").textContent=replies;$("#popular").innerHTML=topics.slice(0,4).map(t=>`<div class="statline"><a onclick="openTopic(${t.id})">${esc(t.title)}</a><b>${t.replies.length}</b></div>`).join("")||"—"}
function esc(s){return String(s).replace(/[&<>"']/g,c=>({"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#39;"}[c]))}
function renderHome(){activeForum=null;activeTopic=null;$("#content").innerHTML=`<div class="section-head"><div><h2>تالارهای گفت‌وگو</h2><p>انجمن رسمی Karaso RolePlay</p></div><button class="btn orange" onclick="newTopic()">＋ موضوع جدید</button></div>`+categories.map(c=>`<section class="category"><div class="category-head"><div class="cat-title"><span class="cat-icon">${c.icon}</span><div><h3>${c.title}</h3><small>${c.desc}</small></div></div><span class="muted">⌄</span></div><div class="category-body">${c.forums.map(f=>{let ts=topics.filter(t=>t.forum===f.id);return `<div class="forum-row"><div><h4 onclick="openForum('${f.id}')">${f.title}</h4><p>${f.desc}</p>${f.subforums?`<div class="subforum-list">${f.subforums.map(sf=>{let subTopics=topics.filter(t=>t.forum===sf.id);return `<div class="subforum-row"><span class="subforum-mark">↳</span><div class="subforum-info"><h5 onclick="openForum('${sf.id}')">${sf.title}</h5><small>${sf.desc}</small></div><span class="subforum-count">${subTopics.length} موضوع</span></div>`}).join("")}</div>`:""}</div><div class="count"><b>${ts.length}</b>موضوع</div><div class="lastpost">${ts[0]?`آخرین موضوع: ${esc(ts[0].title)}`:"هنوز موضوعی ثبت نشده"}</div></div>`}).join("")}</div></section>`).join("");}
function openForum(id){activeForum=id;activeTopic=null;let {f,c}=forumInfo(id),ts=topics.filter(t=>t.forum===id);$("#content").innerHTML=`<div class="section-head"><div><p class="crumb"><a onclick="renderHome()">انجمن</a> / ${c.title}</p><h2>${f.title}</h2><p>${f.desc}</p></div><button class="btn orange" onclick="newTopic('${id}')">＋ ایجاد موضوع</button></div><section class="panel topic-list">${ts.length?ts.map(t=>`<div class="topic-item"><div><h4 onclick="openTopic(${t.id})">${esc(t.title)}</h4><small>ارسال توسط ${esc(t.author)} · ${t.date}</small></div><small>💬 ${t.replies.length} پاسخ</small></div>`).join(""):`<div class="empty">هنوز موضوعی در این بخش ایجاد نشده است.<br><br><button class="btn orange" onclick="newTopic('${id}')">اولین موضوع را ایجاد کن</button></div>`}</section>`}
function openTopic(id){
 activeTopic=id;let t=topics.find(x=>x.id===id);if(!t)return;let {f,c}=forumInfo(t.forum);
 const adminTools=isAdmin()?`<button class="btn ${t.locked?"outline":"orange"}" onclick="toggleTopicLock(${t.id})">${t.locked?"🔓 باز کردن موضوع":"🔒 قفل کردن موضوع"}</button>`:"";
 const lockedMsg=t.locked?`<div class="locked-banner">🔒 این موضوع قفل شده است. اعضای عادی نمی‌توانند پیام بدهند.</div>`:"";
 const replyBox=(!t.locked||isAdmin())?`<div class="composer"><h3>ارسال پاسخ</h3><textarea id="replyText" placeholder="پیام خود را بنویسید..."></textarea><div class="toolbar"><small>پاسخ شما در همین موضوع ثبت می‌شود.</small><button class="btn orange" onclick="sendReply(${t.id})">ارسال پاسخ</button></div></div>`:`<div class="locked-banner">این موضوع قفل شده است و امکان ارسال پاسخ وجود ندارد.</div>`;
 $("#content").innerHTML=`<div class="section-head"><div><p class="crumb"><a onclick="renderHome()">انجمن</a> / <a onclick="openForum('${t.forum}')">${f.title}</a> / موضوع</p></div><div class="thread-actions">${adminTools}<button class="btn outline" onclick="openForum('${t.forum}')">← بازگشت به تالار</button></div></div><section class="thread"><div class="thread-head"><h2>${esc(t.title)} ${t.locked?"🔒":""}</h2><p>شروع‌کننده: ${esc(t.author)} · ${t.date} · ${t.replies.length} پاسخ</p></div>${lockedMsg}<article class="post"><div class="author"><div class="avatar">${esc(t.author[0]||"K")}</div><button class="profile-link" onclick="openUserProfile('${t.author_id||""}')">${adminName(t.author)}</button><small>${isAdmin()&&t.author===user?"مدیر انجمن":"عضو انجمن"}</small></div><div class="post-content"><div class="post-meta"><span>ارسال نخست</span><span>${t.date}</span></div><p>${esc(t.body)}</p></div></article>${t.replies.map((r,i)=>`<article class="post"><div class="author"><div class="avatar">${esc(r.author[0]||"K")}</div><button class="profile-link" onclick="openUserProfile('${r.author_id||""}')">${adminName(r.author)}</button><small>عضو انجمن</small></div><div class="post-content"><div class="post-meta"><span>پاسخ #${i+1}</span><span>${r.date}</span></div><p>${esc(r.body)}</p></div></article>`).join("")}${replyBox}</section>`;
}
async function toggleTopicLock(id){
 if(!isAdmin())return alert("این قابلیت فقط برای Owner یا Admin است.");
 const t=topics.find(x=>String(x.id)===String(id));if(!t)return;
 if(!sbClient)return alert("اتصال Supabase برقرار نیست.");
 const next=!t.locked;
 try{const {error}=await sbClient.from("topics").update({locked:next}).eq("id",id);if(error)throw error;t.locked=next;save();openTopic(id);}
 catch(e){alert("تغییر وضعیت موضوع در دیتابیس انجام نشد: "+(e.message||e));}
}
function renderAdminPanel(){
 if(!isAdmin())return alert("با حساب ادمین وارد شوید.");
 activeForum=null;activeTopic=null;
 const staffTab=currentRole==="owner"?`<button class="btn outline" onclick="renderStaffManager()">👥 مدیریت ادمین‌ها و هلپرها</button>`:"";
 $("#content").innerHTML=`<div class="section-head"><div><h2>🛡 مدیریت فروم</h2><p>مدیریت قفل موضوع‌ها در همه فکشن‌ها و تالارها</p></div><div style="display:flex;gap:8px;flex-wrap:wrap">${staffTab}<button class="btn outline" onclick="renderHome()">بازگشت به انجمن</button></div></div><section class="panel topic-list">${topics.length?topics.map(t=>`<div class="topic-item"><div><h4 onclick="openTopic(${t.id})">${esc(t.title)}</h4><small>${esc(forumInfo(t.forum).f.title)} · ${esc(t.author)} · ${t.replies.length} پاسخ</small></div><button class="btn ${t.locked?"outline":"orange"}" onclick="toggleTopicLock(${t.id});renderAdminPanel()">${t.locked?"🔓 بازکردن":"🔒 قفل موضوع"}</button></div>`).join(""):`<div class="empty">هنوز موضوعی ایجاد نشده است.</div>`}</section>`;
}
async function renderStaffManager(){
 if(currentRole!=="owner")return alert("فقط Owner اجازه مدیریت نقش‌ها را دارد.");
 if(!sbClient)return alert("Supabase در دسترس نیست.");
 activeForum=null;activeTopic=null;
 $("#content").innerHTML=`<div class="section-head"><div><h2>👥 مدیریت ادمین‌ها و هلپرها</h2><p>تغییر نقش‌ها مستقیماً در Supabase ثبت می‌شود.</p></div><div style="display:flex;gap:8px;flex-wrap:wrap"><button class="btn outline" onclick="renderAdminPanel()">بازگشت</button><button class="btn outline" onclick="renderStaffManager()">↻ تازه‌سازی</button></div></div><section class="panel"><p id="staffStatus">در حال دریافت کاربران…</p><div id="staffTable"></div></section>`;
 try{
  const {data,error}=await sbClient.from("profiles").select("id,username,role,created_at").order("created_at",{ascending:false});
  if(error)throw error;
  if(!data?.length){$("#staffStatus").textContent="هیچ پروفایلی پیدا نشد.";return;}
  $("#staffStatus").textContent=`${data.length} پروفایل در دیتابیس`;
  $("#staffTable").innerHTML=`<div style="overflow-x:auto"><table style="width:100%;border-collapse:collapse;min-width:520px"><thead><tr><th style="text-align:right;padding:10px">نام کاربری</th><th style="padding:10px">نقش فعلی</th><th style="padding:10px">نقش جدید</th><th style="padding:10px">عملیات</th></tr></thead><tbody>${data.map(p=>`<tr style="border-top:1px solid #333"><td style="padding:10px">${esc(p.username||"بدون نام")}${p.id===currentAuthId?" <small>(حساب شما)</small>":""}</td><td style="padding:10px;text-align:center">${esc(p.role||"user")}</td><td style="padding:10px"><select id="role-${p.id}" style="min-width:130px"><option value="user" ${p.role==="user"?"selected":""}>User</option><option value="helper" ${p.role==="helper"?"selected":""}>Helper</option><option value="admin" ${p.role==="admin"?"selected":""}>Admin</option><option value="owner" ${p.role==="owner"?"selected":""}>Owner</option></select></td><td style="padding:10px;text-align:center"><button class="btn orange" onclick="saveStaffRole('${p.id}')">ذخیره</button></td></tr>`).join("")}</tbody></table></div>`;
 }catch(e){$("#staffStatus").textContent="خطا در دریافت پروفایل‌ها: "+(e.message||e);}
}
async function saveStaffRole(profileId){
 if(currentRole!=="owner")return alert("فقط Owner اجازه تغییر نقش دارد.");
 const select=$("#role-"+profileId);if(!select)return;
 const desiredRole=select.value;
 if(!confirm("نقش این کاربر به "+desiredRole+" تغییر کند؟"))return;
 try{
  const {error}=await sbClient.rpc("manage_profile_role",{target_profile_id:profileId,desired_role:desiredRole});
  if(error)throw error;
  alert("نقش با موفقیت در Supabase تغییر کرد.");
  await renderStaffManager();
 }catch(e){alert("تغییر نقش انجام نشد: "+(e.message||e)+"\nابتدا SQL تابع manage_profile_role را در Supabase اجرا کنید.");}
}

async function openUserProfile(profileId){
 if(!profileId)return alert("شناسه پروفایل در این پست موجود نیست.");
 if(!sbClient)return alert("اتصال Supabase در دسترس نیست.");
 $("#modalBody").innerHTML='<div class="profile-loading">در حال بارگذاری پروفایل…</div>';
 $("#modal").classList.remove("hidden");
 try{
  const {data:p,error}=await sbClient.from("profiles").select("id,username,role,created_at").eq("id",profileId).maybeSingle();
  if(error)throw error;
  if(!p)throw new Error("پروفایل پیدا نشد یا دسترسی مشاهده آن فعال نیست.");
  const [{count:topicCount,error:te},{count:replyCount,error:re}]=await Promise.all([
   sbClient.from("topics").select("id",{count:"exact",head:true}).eq("author_id",profileId),
   sbClient.from("replies").select("id",{count:"exact",head:true}).eq("author_id",profileId)
  ]);
  if(te)throw te;if(re)throw re;
  const role=p.role||"user", roleText=role==="owner"?"OWNER":role==="admin"?"ADMIN":role==="helper"?"HELPER":"MEMBER";
  const joined=p.created_at?new Date(p.created_at).toLocaleDateString("fa-IR"):"نامشخص";
  const avatar=(p.username||"K").trim().charAt(0).toUpperCase();
  $("#modalBody").innerHTML=`<div class="profile-card">
   <div class="profile-cover"></div><div class="profile-avatar">${esc(avatar)}</div>
   <h2>${esc(p.username||"کاربر")}</h2><span class="profile-role ${esc(role)}">${roleText}</span>
   <p class="profile-subtitle">پروفایل عضو انجمن Karaso RolePlay</p>
   <div class="profile-stats"><div><b>${topicCount||0}</b><small>موضوع‌ها</small></div><div><b>${replyCount||0}</b><small>پاسخ‌ها</small></div></div>
   <div class="profile-info"><span>📅 تاریخ عضویت</span><b>${joined}</b></div>
  </div>`;
 }catch(e){$("#modalBody").innerHTML=`<h2>پروفایل کاربر</h2><p class="profile-error">${esc(e.message||String(e))}</p><p class="profile-hint">اگر خطای permission دیدی، SQL دسترسی مشاهده پروفایل را اجرا کن.</p>`;}
}
function requireLogin(){if(!currentAuthId)return (alert("برای ارسال موضوع یا پاسخ ابتدا وارد انجمن شوید."),false);return true}
function currentAuthor(){return user||"کاربر"}
async function sendReply(id){
 if(!requireLogin())return;
 const topic=topics.find(x=>String(x.id)===String(id));if(!topic)return;
 if(topic.locked&&!isAdmin())return alert("این موضوع قفل شده است و امکان پاسخ ندارید.");
 const text=$("#replyText").value.trim();if(!text)return alert("متن پاسخ را بنویسید.");
 if(!sbClient)return alert("اتصال Supabase برقرار نیست.");
 try{
  const {error}=await sbClient.from("replies").insert({topic_id:id,body:text});if(error)throw error;
  await loadTopics();openTopic(id);
 }catch(e){alert("ثبت پاسخ ناموفق بود: "+(e.message||e));}
}
function newTopic(forum=activeForum){if(!requireLogin())return;$("#modalBody").innerHTML=`<h2>ایجاد موضوع جدید</h2><label>عنوان موضوع</label><input id="topicTitle" placeholder="عنوان موضوع را وارد کنید"><label>تالار</label><select id="topicForum">${categories.flatMap(c=>c.forums.flatMap(f=>[{...f,display:f.title},...(f.subforums||[]).map(sf=>({...sf,display:"↳ "+f.title+" / "+sf.title}))])).map(f=>`<option value="${f.id}" ${forum===f.id?"selected":""}>${f.display}</option>`).join("")}</select><label>متن پیام</label><textarea id="topicBody" placeholder="متن کامل موضوع را بنویسید..."></textarea><button class="btn orange full" onclick="createTopic()">ثبت موضوع</button>`;$("#modal").classList.remove("hidden")}
async function createTopic(){
 if(!requireLogin())return;
 const title=$("#topicTitle").value.trim(),body=$("#topicBody").value.trim(),forum=$("#topicForum").value;
 if(!title||!body)return alert("عنوان و متن موضوع را کامل کنید.");
 if(!sbClient)return alert("اتصال Supabase برقرار نیست.");
 const btn=$("#modalBody .btn");if(btn){btn.disabled=true;btn.textContent="در حال ثبت…";}
 try{
  const {data,error}=await sbClient.from("topics").insert({forum,title,body}).select("id").single();if(error)throw error;
  closeModal();await loadTopics();openTopic(data.id);
 }catch(e){alert("ثبت موضوع ناموفق بود: "+(e.message||e));if(btn){btn.disabled=false;btn.textContent="ثبت موضوع";}}
}
function loginModal(mode="login"){
 $("#modalBody").innerHTML=`<h2>ورود / ثبت‌نام کاراسو</h2>
 <p style="color:#888;font-size:12px;line-height:1.9">حساب واقعی با ایمیل و رمز عبور. ورود پس از بستن مرورگر حفظ می‌شود.</p>
 <div style="display:flex;gap:8px;margin:12px 0"><button class="btn outline" onclick="loginModal('login')">ورود</button><button class="btn outline" onclick="loginModal('signup')">ثبت‌نام</button></div>
 <div id="usernameWrap" style="display:none"><label>نام کاربری</label><input id="signupUsername" autocomplete="username" placeholder="نام نمایشی در فروم"></div>
 <label>ایمیل</label><input id="authEmail" type="email" autocomplete="email" placeholder="name@example.com">
 <label>رمز عبور</label><input id="authPassword" type="password" autocomplete="current-password" placeholder="حداقل ۸ کاراکتر">
 <button class="btn orange full" id="authSubmit" onclick="handleAuth('login')">ورود به انجمن</button><p id="authMessage" style="font-size:12px;color:#aaa"></p>`;
 $("#authSubmit").setAttribute("onclick",`handleAuth('${mode}')`);
 $("#authSubmit").textContent=mode==="signup"?"ایجاد حساب":"ورود به انجمن";
 if(mode==="signup"){$("#usernameWrap").style.display="block";$("#authPassword").autocomplete="new-password";}
 $("#modal").classList.remove("hidden");
}
function initSupabase(){
 if(!window.supabase){console.error("Supabase library failed to load");return;}
 sbClient=window.supabase.createClient("https://fagqwohtjdzmvkoeuwel.supabase.co","sb_publishable_tDrNMeoS9vEZJIOjbYEOcw_y6TyvvlQ",{auth:{persistSession:true,autoRefreshToken:true,detectSessionInUrl:true}});
 sbClient.auth.getSession().then(async ({data,error})=>{if(error)console.error(error);if(data?.session)await applyAuthUser(data.session.user);await loadTopics();});
 sbClient.auth.onAuthStateChange((event,session)=>{if(session)applyAuthUser(session.user);else if(event==="SIGNED_OUT")applyAuthUser(null);});
}
async function applyAuthUser(authUser){
 // Hide the guest-only welcome/login panel for every authenticated user.
 const welcomePanel=document.querySelector(".sidebar .welcome");
 if(welcomePanel)welcomePanel.style.display=authUser?"none":"";
 if(authUser){
  currentAuthId=authUser.id;
  user=authUser.user_metadata?.username||authUser.email||"کاربر";
  localStorage.setItem("karaso_user",user);
  $("#userBadge").textContent=user;$("#loginBtn").textContent="خروج";
  currentRole="user";
  try{
   const {data,error}=await sbClient.from("profiles").select("username,role").eq("id",authUser.id).maybeSingle();
   if(error)console.warn("Profile role read failed:",error.message);
   if(data&&["owner","admin","helper","user"].includes(data.role)){
    currentRole=data.role;
    if(data.username){user=data.username;localStorage.setItem("karaso_user",user);$("#userBadge").textContent=user;}
   }
  }catch(e){console.warn("Could not load profile role",e);}
 }else{
  user="";currentRole="user";currentAuthId=null;localStorage.removeItem("karaso_user");
  $("#userBadge").textContent="مهمان";$("#loginBtn").textContent="ورود / ثبت‌نام";
 }
 refreshAdminButton();
}
async function handleAuth(mode){
 if(!sbClient)return alert("Supabase بارگذاری نشده؛ اینترنت و اتصال را بررسی کنید.");
 const email=$("#authEmail").value.trim(),password=$("#authPassword").value;
 if(!email||!password)return alert("ایمیل و رمز عبور را وارد کنید.");
 if(password.length<8)return alert("رمز عبور باید حداقل ۸ کاراکتر باشد.");
 const btn=$("#authSubmit");btn.disabled=true;btn.textContent="در حال بررسی…";
 try{
  if(mode==="signup"){
   const username=$("#signupUsername").value.trim();if(!username)return alert("نام کاربری را وارد کنید.");
   const {data,error}=await sbClient.auth.signUp({email,password,options:{data:{username}}});if(error)throw error;
   if(data.user&&data.session){
    const {error:pe}=await sbClient.from("profiles").insert({id:data.user.id,username,role:"user"});
    if(pe)console.warn("Profile insert:",pe.message);
    applyAuthUser(data.user);alert("حساب ساخته شد و وارد شدید.");
   }else{$("#authMessage").textContent="ثبت‌نام انجام شد؛ ایمیل را برای تأیید بررسی کنید، سپس وارد شوید.";return;}
  }else{
   const {data,error}=await sbClient.auth.signInWithPassword({email,password});if(error)throw error;
   applyAuthUser(data.user);alert("خوش آمدی "+(data.user.user_metadata?.username||data.user.email)+"!");
  }
  closeModal();
 }catch(e){alert(e.message||"خطا در ورود/ثبت‌نام");}
 finally{if($("#authSubmit")){$("#authSubmit").disabled=false;$("#authSubmit").textContent=mode==="signup"?"ایجاد حساب":"ورود به انجمن";}}
}
async function logout(){if(sbClient){const {error}=await sbClient.auth.signOut();if(error)return alert(error.message);}applyAuthUser(null);}
function closeModal(){$("#modal").classList.add("hidden")}
function renderTopics(){activeForum=null;$("#content").innerHTML=`<div class="section-head"><h2>آخرین موضوعات</h2><button class="btn orange" onclick="newTopic()">＋ موضوع جدید</button></div><section class="panel topic-list">${topics.map(t=>`<div class="topic-item"><div><h4 onclick="openTopic(${t.id})">${esc(t.title)}</h4><small>${forumInfo(t.forum).f.title} · ${esc(t.author)} · ${t.date}</small></div><small>💬 ${t.replies.length}</small></div>`).join("")}</section>`}
function renderRules(){$("#content").innerHTML=`<section class="panel"><h2>قوانین انجمن Karaso</h2><p>۱. احترام به تمام اعضا الزامی است.</p><p>۲. از ارسال اسپم و موضوعات تکراری خودداری کنید.</p><p>۳. اطلاعات درخواست‌ها را دقیق و کامل بنویسید.</p><p>۴. تصمیم نهایی درخواست‌ها با مدیریت سرور است.</p><p>۵. انتشار اطلاعات شخصی دیگران ممنوع است.</p></section>`}
$$("[data-view]").forEach(el=>el.addEventListener("click",e=>{e.preventDefault();let v=el.dataset.view;v==="home"?renderHome():v==="topics"?renderTopics():renderRules()}));
$("#newTopicHero").onclick=()=>newTopic();$("#loginBtn").onclick=()=>user?logout():loginModal();$("#loginSide").onclick=loginModal;$("#closeModal").onclick=closeModal;$("#modal").addEventListener("click",e=>{if(e.target===$("#modal"))closeModal()});$("#userBadge").textContent=user||"مهمان";$("#loginBtn").textContent=user?"خروج":"ورود / ثبت‌نام";refreshAdminButton();renderHome();updateStats();initSupabase();
