-- KARASO ROLEPLAY COMPLETE STAFF SYSTEM SETUP
-- Run this single file in Supabase SQL Editor. Existing Owner profile is preserved.
-- This script creates/updates the base staff schema and the V2 timer/directory features.

-- KARASO STAFF PORTAL - fresh, separate Supabase project
-- Run in SQL Editor AFTER creating the project. Then create the first account,
-- and run the one-time OWNER bootstrap statement at the bottom.
create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text,
  display_name text not null default '',
  title text,
  role text not null default 'admin' check (role in ('owner','admin')),
  status text not null default 'pending' check (status in ('pending','approved','rejected','removed')),
  rank_number integer check (rank_number between 1 and 8),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  approved_at timestamptz,
  approved_by uuid references public.profiles(id)
);
create index if not exists profiles_staff_status_idx on public.profiles(status, rank_number);

create or replace function public.staff_touch_updated_at()
returns trigger language plpgsql as $$ begin new.updated_at=now(); return new; end $$;

drop trigger if exists profiles_staff_updated_at on public.profiles;
create trigger profiles_staff_updated_at before update on public.profiles
for each row execute function public.staff_touch_updated_at();

create or replace function public.staff_is_owner()
returns boolean language sql stable security definer set search_path=public
as $$ select exists(select 1 from public.profiles where id=auth.uid() and role='owner' and status='approved') $$;
create or replace function public.staff_is_approved()
returns boolean language sql stable security definer set search_path=public
as $$ select exists(select 1 from public.profiles where id=auth.uid() and status='approved' and role in ('owner','admin')) $$;

create or replace function public.staff_new_user_profile()
returns trigger language plpgsql security definer set search_path=public
as $$ begin
 insert into public.profiles(id,email,display_name,role,status)
 values(new.id,new.email,coalesce(new.raw_user_meta_data->>'display_name',''),'admin','pending')
 on conflict(id) do nothing;
 return new;
end $$;
drop trigger if exists staff_auth_user_created on auth.users;
create trigger staff_auth_user_created after insert on auth.users
for each row execute function public.staff_new_user_profile();

-- Owner-only member decisions. The account's email/login identity is never changed here.
create or replace function public.staff_owner_update_member(
 p_user_id uuid, p_display_name text, p_title text, p_rank integer, p_status text
) returns void language plpgsql security definer set search_path=public
as $$ begin
 if not public.staff_is_owner() then raise exception 'فقط Owner اجازه این عملیات را دارد'; end if;
 if p_status not in ('approved','rejected','removed','pending') then raise exception 'وضعیت نامعتبر است'; end if;
 if p_status='approved' and (p_rank is null or p_rank not between 1 and 8) then raise exception 'برای تأیید، رنک ۱ تا ۸ الزامی است'; end if;
 if p_rank is not null and p_rank not between 1 and 8 then raise exception 'رنک باید بین ۱ تا ۸ باشد'; end if;
 update public.profiles set display_name=trim(p_display_name), title=nullif(trim(p_title),''),
   rank_number=case when p_status='approved' then p_rank else null end,
   status=p_status, approved_at=case when p_status='approved' then now() else null end,
   approved_by=case when p_status='approved' then auth.uid() else null end
 where id=p_user_id and role<>'owner';
 if not found then raise exception 'عضو پیدا نشد یا امکان تغییر Owner وجود ندارد'; end if;
 insert into public.staff_audit_logs(actor_id,target_user_id,action,details) values(auth.uid(),p_user_id,'member_status_updated',jsonb_build_object('status',p_status,'display_name',p_display_name,'title',p_title,'rank_number',p_rank));
end $$;

create table if not exists public.staff_playtime (
 id uuid primary key default gen_random_uuid(), user_id uuid not null references public.profiles(id) on delete cascade,
 minutes integer not null check(minutes between 1 and 1440), activity_date date not null default current_date,
 note text, created_at timestamptz not null default now()
);
create table if not exists public.staff_reports (
 id uuid primary key default gen_random_uuid(), user_id uuid not null references public.profiles(id) on delete cascade,
 report_date date not null default current_date, content text not null check(length(trim(content)) between 5 and 8000),
 status text not null default 'submitted' check(status in ('submitted','reviewed','needs_revision')),
 owner_note text, reviewed_by uuid references public.profiles(id), reviewed_at timestamptz,
 created_at timestamptz not null default now()
);
create table if not exists public.staff_warnings (
 id uuid primary key default gen_random_uuid(), user_id uuid not null references public.profiles(id) on delete cascade,
 reason text not null check(length(trim(reason)) between 3 and 3000), severity text not null default 'normal' check(severity in ('normal','serious','final')),
 issued_by uuid not null references public.profiles(id), source_key text unique, created_at timestamptz not null default now()
);
alter table public.staff_warnings add column if not exists source_key text unique;
create table if not exists public.staff_feedback (
 id uuid primary key default gen_random_uuid(), user_id uuid not null references public.profiles(id) on delete cascade,
 kind text not null check(kind in ('criticism','suggestion','idea')), subject text not null,
 content text not null check(length(trim(content)) between 5 and 5000), status text not null default 'open' check(status in ('open','seen','answered','closed')),
 owner_reply text, created_at timestamptz not null default now()
);
create table if not exists public.staff_tasks (
 id uuid primary key default gen_random_uuid(), user_id uuid not null references public.profiles(id) on delete cascade,
 title text not null, description text, due_at timestamptz, status text not null default 'assigned' check(status in ('assigned','submitted','approved','rejected')),
 submission text, owner_note text, assigned_by uuid not null references public.profiles(id), created_at timestamptz not null default now(), submitted_at timestamptz
);
create table if not exists public.staff_attendance (
 id uuid primary key default gen_random_uuid(), user_id uuid not null references public.profiles(id) on delete cascade,
 check_in timestamptz not null default now(), check_out timestamptz, note text,
 constraint attendance_time_valid check(check_out is null or check_out>=check_in)
);
create unique index if not exists staff_one_open_shift_per_user on public.staff_attendance(user_id) where check_out is null;
create table if not exists public.staff_leave_requests (
 id uuid primary key default gen_random_uuid(), user_id uuid not null references public.profiles(id) on delete cascade,
 starts_at timestamptz not null, ends_at timestamptz not null, reason text not null,
 status text not null default 'pending' check(status in ('pending','approved','rejected')),
 owner_note text, reviewed_by uuid references public.profiles(id), reviewed_at timestamptz,
 created_at timestamptz not null default now(), check(ends_at>starts_at)
);
create table if not exists public.staff_awards (
 id uuid primary key default gen_random_uuid(), user_id uuid not null references public.profiles(id) on delete cascade,
 award_type text not null check(award_type in ('day','week','month')), period_start date not null,
 period_end date not null, title text not null default 'برترین ادمین', description text,
 awarded_by uuid not null references public.profiles(id), created_at timestamptz not null default now(),
 unique(award_type,period_start)
);
create table if not exists public.staff_notifications (
 id uuid primary key default gen_random_uuid(), user_id uuid not null references public.profiles(id) on delete cascade,
 title text not null, body text not null, is_read boolean not null default false,
 created_at timestamptz not null default now()
);
create table if not exists public.staff_audit_logs (
 id uuid primary key default gen_random_uuid(), actor_id uuid references public.profiles(id), target_user_id uuid references public.profiles(id),
 action text not null, details jsonb not null default '{}'::jsonb, created_at timestamptz not null default now()
);

-- Helper policies: approved staff can see the team directory and their own records;
-- Owner can see/manage all records. Users can only create their own submissions.
do $$ declare t text; begin
 foreach t in array array['staff_playtime','staff_reports','staff_warnings','staff_feedback','staff_tasks','staff_attendance','staff_leave_requests','staff_awards','staff_notifications'] loop
  execute format('alter table public.%I enable row level security',t);
  execute format('drop policy if exists staff_select_own_or_owner on public.%I',t);
  execute format('create policy staff_select_own_or_owner on public.%I for select to authenticated using (user_id=auth.uid() or public.staff_is_owner())',t);
 end loop;
end $$;

-- Profile visibility and safe self-service edits
alter table public.profiles enable row level security;
drop policy if exists profiles_read_team on public.profiles;
create policy profiles_read_team on public.profiles for select to authenticated using (id=auth.uid() or public.staff_is_owner() or public.staff_is_approved());
drop policy if exists profiles_self_update_name on public.profiles;
create policy profiles_self_update_name on public.profiles for update to authenticated using(id=auth.uid() and status='pending') with check(id=auth.uid() and status='pending' and role='admin');
drop policy if exists profiles_owner_update on public.profiles;
create policy profiles_owner_update on public.profiles for update to authenticated using(public.staff_is_owner()) with check(public.staff_is_owner());

-- Users can submit their own playtime, reports, feedback, attendance and leave requests.
drop policy if exists playtime_insert_self on public.staff_playtime;
create policy playtime_insert_self on public.staff_playtime for insert to authenticated with check(user_id=auth.uid() and public.staff_is_approved());
drop policy if exists reports_insert_self on public.staff_reports;
create policy reports_insert_self on public.staff_reports for insert to authenticated with check(user_id=auth.uid() and public.staff_is_approved());
drop policy if exists feedback_insert_self on public.staff_feedback;
create policy feedback_insert_self on public.staff_feedback for insert to authenticated with check(user_id=auth.uid() and public.staff_is_approved());
drop policy if exists attendance_insert_self on public.staff_attendance;
create policy attendance_insert_self on public.staff_attendance for insert to authenticated with check(user_id=auth.uid() and public.staff_is_approved());
drop policy if exists attendance_update_self on public.staff_attendance;
create policy attendance_update_self on public.staff_attendance for update to authenticated using(user_id=auth.uid() and check_out is null and public.staff_is_approved()) with check(user_id=auth.uid() and public.staff_is_approved());
drop policy if exists leave_insert_self on public.staff_leave_requests;
create policy leave_insert_self on public.staff_leave_requests for insert to authenticated with check(user_id=auth.uid() and public.staff_is_approved());
drop policy if exists task_update_self on public.staff_tasks;
create policy task_update_self on public.staff_tasks for update to authenticated using(user_id=auth.uid() and status='assigned' and public.staff_is_approved()) with check(user_id=auth.uid() and status in ('submitted','assigned') and public.staff_is_approved());

-- Owner-only write policies on management records.
do $$ declare t text; begin
 foreach t in array array['staff_warnings','staff_awards','staff_audit_logs'] loop
  execute format('drop policy if exists staff_owner_all on public.%I',t);
  execute format('create policy staff_owner_all on public.%I for all to authenticated using(public.staff_is_owner()) with check(public.staff_is_owner())',t);
 end loop;
end $$;
drop policy if exists reports_owner_update on public.staff_reports;
create policy reports_owner_update on public.staff_reports for update to authenticated using(public.staff_is_owner()) with check(public.staff_is_owner());
drop policy if exists feedback_owner_update on public.staff_feedback;
create policy feedback_owner_update on public.staff_feedback for update to authenticated using(public.staff_is_owner()) with check(public.staff_is_owner());
drop policy if exists tasks_owner_all on public.staff_tasks;
create policy tasks_owner_all on public.staff_tasks for all to authenticated using(public.staff_is_owner()) with check(public.staff_is_owner());
drop policy if exists leave_owner_update on public.staff_leave_requests;
create policy leave_owner_update on public.staff_leave_requests for update to authenticated using(public.staff_is_owner()) with check(public.staff_is_owner());
drop policy if exists notifications_own_read on public.staff_notifications;
create policy notifications_own_read on public.staff_notifications for select to authenticated using(user_id=auth.uid() or public.staff_is_owner());
drop policy if exists notifications_owner_insert on public.staff_notifications;
create policy notifications_owner_insert on public.staff_notifications for insert to authenticated with check(public.staff_is_owner());
drop policy if exists notifications_own_update on public.staff_notifications;
create policy notifications_own_update on public.staff_notifications for update to authenticated using(user_id=auth.uid()) with check(user_id=auth.uid());

-- Owner review can issue a warning and creates an audit record via the client.
-- First Owner bootstrap: create/sign up the intended Owner account, then run this once:
-- update public.profiles set role='owner', status='approved', display_name='OWNER', title='Owner', rank_number=null
-- where email='YOUR_OWNER_EMAIL';
alter table public.staff_audit_logs enable row level security;
drop policy if exists staff_audit_select on public.staff_audit_logs;
create policy staff_audit_select on public.staff_audit_logs for select to authenticated using(actor_id=auth.uid() or target_user_id=auth.uid() or public.staff_is_owner());


-- Automatic daily-report enforcement: at 23:59 UTC, each approved admin
-- without a report for the database's current date receives one warning.
create or replace function public.staff_apply_daily_report_warnings()
returns integer language plpgsql security definer set search_path=public
as $$ declare added_count integer; begin
 insert into public.staff_warnings(user_id,reason,severity,issued_by,source_key)
 select p.id,
   'گزارش روزانه تاریخ '||to_char(current_date,'YYYY-MM-DD')||' ارسال نشده است.',
   'normal',
   (select id from public.profiles where role='owner' and status='approved' order by created_at limit 1),
   'missing-report:'||p.id::text||':'||current_date::text
 from public.profiles p
 where p.role='admin' and p.status='approved'
   and not exists(select 1 from public.staff_reports r where r.user_id=p.id and r.report_date=current_date)
   and exists(select 1 from public.profiles o where o.role='owner' and o.status='approved')
 on conflict(source_key) do nothing;
 get diagnostics added_count = row_count;
 return added_count;
end $$;

-- Supabase projects support pg_cron. The job is idempotently replaced on re-run.
do $$ begin
  create extension if not exists pg_cron;
  if exists(select 1 from cron.job where jobname='karaso-daily-report-warning') then
    perform cron.unschedule('karaso-daily-report-warning');
  end if;
  perform cron.schedule('karaso-daily-report-warning','59 23 * * *','select public.staff_apply_daily_report_warnings();');
exception when others then
  raise notice 'Automatic schedule was not created. Enable pg_cron in Supabase Database Extensions, then rerun this SQL section. Error: %', sqlerrm;
end $$;



-- Compatibility additions for databases where some tables were created earlier
alter table public.staff_reports add column if not exists owner_note text;
alter table public.staff_reports add column if not exists reviewed_by uuid references public.profiles(id);
alter table public.staff_reports add column if not exists reviewed_at timestamptz;
alter table public.staff_leave_requests add column if not exists reason text not null default '';
alter table public.staff_leave_requests add column if not exists owner_note text;
alter table public.staff_leave_requests add column if not exists reviewed_by uuid references public.profiles(id);
alter table public.staff_leave_requests add column if not exists reviewed_at timestamptz;
alter table public.staff_tasks add column if not exists submission text;
alter table public.staff_tasks add column if not exists owner_note text;
alter table public.staff_tasks add column if not exists submitted_at timestamptz;
alter table public.staff_warnings add column if not exists source_key text unique;
alter table public.profiles add column if not exists username text;

-- KARASO STAFF CONTROL CENTER V2 migration
-- Run once in the NEW Supabase project SQL Editor. Existing profiles/owner are preserved.
create extension if not exists pgcrypto;

-- Keep the in-game name in username, while retaining display_name for compatibility.
alter table public.profiles add column if not exists username text;
alter table public.profiles add column if not exists approved_at timestamptz;
alter table public.profiles add column if not exists approved_by uuid references public.profiles(id);
update public.profiles set username=coalesce(nullif(username,''),nullif(display_name,''),'بدون نام') where username is null or username='';

create or replace function public.staff_new_user_profile()
returns trigger language plpgsql security definer set search_path=public
as $$
declare v_name text;
begin
 v_name := coalesce(nullif(trim(new.raw_user_meta_data->>'display_name'),''), nullif(trim(new.raw_user_meta_data->>'username'),''), 'بدون نام');
 insert into public.profiles(id,email,username,display_name,role,status)
 values(new.id,new.email,v_name,v_name,'admin','pending')
 on conflict(id) do update set email=excluded.email, username=coalesce(nullif(public.profiles.username,''),excluded.username), display_name=coalesce(nullif(public.profiles.display_name,''),excluded.display_name);
 return new;
end $$;

-- Session timer: timestamps are authoritative; browser countdown is display-only.
create table if not exists public.staff_playtime_sessions (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references public.profiles(id) on delete cascade,
 started_at timestamptz not null default now(),
 ended_at timestamptz,
 started_by uuid not null references public.profiles(id),
 ended_by uuid references public.profiles(id),
 note text,
 constraint playtime_session_range check(ended_at is null or ended_at >= started_at)
);
create unique index if not exists staff_one_open_playtime_session on public.staff_playtime_sessions(user_id) where ended_at is null;
alter table public.staff_playtime_sessions enable row level security;
drop policy if exists staff_sessions_select on public.staff_playtime_sessions;
create policy staff_sessions_select on public.staff_playtime_sessions for select to authenticated using(user_id=auth.uid() or public.staff_is_owner());

create or replace function public.staff_playtime_start(p_note text default null)
returns uuid language plpgsql security definer set search_path=public
as $$ declare v_id uuid;
begin
 if not public.staff_is_approved() then raise exception 'حساب تأییدشده تیم لازم است'; end if;
 insert into public.staff_playtime_sessions(user_id,started_by,note) values(auth.uid(),auth.uid(),nullif(trim(p_note),'')) returning id into v_id;
 return v_id;
exception when unique_violation then raise exception 'تایم‌پلی شما از قبل روشن است';
end $$;

create or replace function public.staff_playtime_stop()
returns void language plpgsql security definer set search_path=public
as $$
begin
 if not public.staff_is_approved() then raise exception 'حساب تأییدشده تیم لازم است'; end if;
 update public.staff_playtime_sessions set ended_at=now(),ended_by=auth.uid()
 where user_id=auth.uid() and ended_at is null;
 if not found then raise exception 'تایمر فعالی برای بستن وجود ندارد'; end if;
end $$;

create or replace function public.staff_owner_close_session(p_session_id uuid)
returns void language plpgsql security definer set search_path=public
as $$
begin
 if not public.staff_is_owner() then raise exception 'فقط Owner اجازه این عملیات را دارد'; end if;
 update public.staff_playtime_sessions set ended_at=now(),ended_by=auth.uid()
 where id=p_session_id and ended_at is null;
 if not found then raise exception 'جلسه باز پیدا نشد'; end if;
 insert into public.staff_audit_logs(actor_id,action,details) values(auth.uid(),'playtime_session_closed',jsonb_build_object('session_id',p_session_id));
end $$;

-- Local operational day starts at 03:00 Asia/Tehran. History is never deleted.
create or replace view public.staff_playtime_daily with (security_invoker = true) as
with session_ranges as (
 select id,user_id,started_at at time zone 'Asia/Tehran' as start_local,
        coalesce(ended_at,now()) at time zone 'Asia/Tehran' as end_local,
        (started_at at time zone 'Asia/Tehran') - interval '3 hours' as day_anchor,
        ended_at is null as is_open
 from public.staff_playtime_sessions
), split_days as (
 select s.*, days.day_start::date as work_date,
        greatest(s.start_local, days.day_start::date + time '03:00') as segment_start,
        least(s.end_local, (days.day_start::date + 1) + time '03:00') as segment_end
 from session_ranges s
 cross join lateral generate_series(s.day_anchor::date, (s.end_local - interval '3 hours')::date, interval '1 day') as days(day_start)
)
select user_id, work_date,
       sum(greatest(0,extract(epoch from (segment_end-segment_start))::bigint))::bigint as seconds_total,
       count(distinct id)::integer as session_count,
       bool_or(is_open) as has_open_session
from split_days
group by user_id,work_date;

-- Owner-only profile editing, including username, rank and status.
create or replace function public.staff_owner_update_member(
 p_user_id uuid, p_display_name text, p_title text, p_rank integer, p_status text
) returns void language plpgsql security definer set search_path=public
as $$ begin
 if not public.staff_is_owner() then raise exception 'فقط Owner اجازه این عملیات را دارد'; end if;
 if p_status not in ('approved','rejected','removed','pending') then raise exception 'وضعیت نامعتبر است'; end if;
 if p_status='approved' and (p_rank is null or p_rank not between 1 and 8) then raise exception 'برای تأیید، رنک ۱ تا ۸ الزامی است'; end if;
 if p_rank is not null and p_rank not between 1 and 8 then raise exception 'رنک باید بین ۱ تا ۸ باشد'; end if;
 update public.profiles set username=trim(p_display_name), display_name=trim(p_display_name), title=nullif(trim(p_title),''),
   rank_number=case when p_status='approved' then p_rank else null end,
   status=p_status, approved_at=case when p_status='approved' then coalesce(approved_at,now()) else null end,
   approved_by=case when p_status='approved' then auth.uid() else null end
 where id=p_user_id and role<>'owner';
 if not found then raise exception 'عضو پیدا نشد یا امکان تغییر Owner وجود ندارد'; end if;
 insert into public.staff_audit_logs(actor_id,target_user_id,action,details)
 values(auth.uid(),p_user_id,'member_updated',jsonb_build_object('status',p_status,'username',p_display_name,'title',p_title,'rank_number',p_rank));
end $$;

-- Approved leave is reflected in directory status through a view.
create or replace view public.karaso_staff_directory_v2 as
select p.id, coalesce(nullif(p.username,''),nullif(p.display_name,''),'بدون نام') as display_name,
       p.title, p.rank_number, p.role, p.status as membership_status,
       case when exists(select 1 from public.staff_leave_requests l where l.user_id=p.id and l.status='approved' and now() between l.starts_at and l.ends_at) then 'leave'
            when p.status='approved' then 'active' else p.status end as current_status,
       p.created_at
from public.profiles p where p.role='admin' and p.status='approved';

-- Ensure view/table access is authenticated only; RLS still governs source tables.
grant select on public.staff_playtime_daily to authenticated;
grant select on public.karaso_staff_directory_v2 to authenticated;
grant execute on function public.staff_playtime_start(text) to authenticated;
grant execute on function public.staff_playtime_stop() to authenticated;
grant execute on function public.staff_owner_close_session(uuid) to authenticated;
