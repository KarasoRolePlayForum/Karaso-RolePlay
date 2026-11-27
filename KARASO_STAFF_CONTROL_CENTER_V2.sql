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
