-- KARASO STAFF DB (run in the Supabase FORUM project only)
-- Namespaced tables; does not alter forum's existing tables.
create extension if not exists pgcrypto;

create table if not exists public.ks_staff_profiles (
 user_id uuid primary key references auth.users(id) on delete cascade,
 display_name text not null default 'Staff',
    game_name text, role text not null default 'admin' check(role in ('owner','admin')),
 admin_level integer, status text not null default 'pending' check(status in ('pending','active','suspended')),
 joined_at timestamptz not null default now(), updated_at timestamptz not null default now(),
 constraint ks_rank_check check ((role='owner' and admin_level is null) or (role='admin' and admin_level between 1 and 8))
);
create table if not exists public.ks_attendance (
 id uuid primary key default gen_random_uuid(), user_id uuid not null references auth.users(id) on delete cascade,
 started_at timestamptz not null default now(), ended_at timestamptz, note text, created_at timestamptz not null default now(),
 constraint ks_attendance_time_check check(ended_at is null or ended_at>=started_at)
);
create unique index if not exists ks_one_open_shift on public.ks_attendance(user_id) where ended_at is null;
create table if not exists public.ks_reports (
 id uuid primary key default gen_random_uuid(), user_id uuid not null references auth.users(id) on delete cascade,
 title text not null, content text not null, activity_date date not null default current_date,
 status text not null default 'submitted' check(status in ('submitted','accepted','rejected','revision')),
 review_note text, reviewed_by uuid references auth.users(id), reviewed_at timestamptz, created_at timestamptz not null default now()
);
create table if not exists public.ks_tasks (
 id uuid primary key default gen_random_uuid(), title text not null, description text,
 assigned_to uuid references auth.users(id) on delete set null, created_by uuid references auth.users(id),
 priority text not null default 'normal' check(priority in ('low','normal','high','urgent')),
 status text not null default 'pending' check(status in ('pending','in_progress','completed','approved','rejected')),
 deadline timestamptz, completion_note text, completed_at timestamptz, reviewed_by uuid references auth.users(id), reviewed_at timestamptz, created_at timestamptz not null default now()
);
create table if not exists public.ks_warnings (
 id uuid primary key default gen_random_uuid(), user_id uuid not null references auth.users(id) on delete cascade,
 issued_by uuid references auth.users(id), reason text not null, evidence text,
 status text not null default 'active' check(status in ('active','revoked','expired')), revoke_reason text,
 revoked_by uuid references auth.users(id), revoked_at timestamptz, created_at timestamptz not null default now()
);
create table if not exists public.ks_leave_requests (
 id uuid primary key default gen_random_uuid(), user_id uuid not null references auth.users(id) on delete cascade,
 start_date date not null, end_date date not null, reason text,
 status text not null default 'pending' check(status in ('pending','approved','rejected')),
 reviewed_by uuid references auth.users(id), review_note text, reviewed_at timestamptz, created_at timestamptz not null default now(), check(end_date>=start_date)
);
create table if not exists public.ks_feedback (
 id uuid primary key default gen_random_uuid(), user_id uuid references auth.users(id) on delete set null,
 category text not null default 'suggestion' check(category in ('suggestion','complaint','feedback','confidential')),
 subject text not null, content text not null, confidential boolean not null default false,
 status text not null default 'open' check(status in ('open','reviewing','closed')),
 reply text, replied_by uuid references auth.users(id), replied_at timestamptz, created_at timestamptz not null default now()
);
create table if not exists public.ks_awards (
 id uuid primary key default gen_random_uuid(), user_id uuid not null references auth.users(id) on delete cascade,
 award_type text not null check(award_type in ('day','week','month','custom')), title text not null, reason text,
 awarded_by uuid references auth.users(id), awarded_at timestamptz not null default now()
);
create table if not exists public.ks_notifications (
 id uuid primary key default gen_random_uuid(), user_id uuid not null references auth.users(id) on delete cascade,
 title text not null, message text not null, type text not null default 'info', read boolean not null default false, created_at timestamptz not null default now()
);
create table if not exists public.ks_audit_logs (
 id uuid primary key default gen_random_uuid(), actor_id uuid references auth.users(id), action text not null,
 target_user_id uuid references auth.users(id), details jsonb not null default '{}'::jsonb, created_at timestamptz not null default now()
);
create table if not exists public.ks_task_submissions (
 id uuid primary key default gen_random_uuid(), task_id uuid not null references public.ks_tasks(id) on delete cascade,
 user_id uuid not null references auth.users(id) on delete cascade, evidence text, note text,
 status text not null default 'submitted' check(status in ('submitted','approved','rejected')), submitted_at timestamptz not null default now()
);

create or replace function public.ks_is_owner() returns boolean language sql stable security definer set search_path=public as $$
 select exists(select 1 from public.ks_staff_profiles where user_id=auth.uid() and role='owner' and status='active'); $$;
create or replace function public.ks_is_active_staff() returns boolean language sql stable security definer set search_path=public as $$
 select exists(select 1 from public.ks_staff_profiles where user_id=auth.uid() and status='active'); $$;

alter table public.ks_staff_profiles enable row level security;
alter table public.ks_attendance enable row level security;
alter table public.ks_reports enable row level security;
alter table public.ks_tasks enable row level security;
alter table public.ks_warnings enable row level security;
alter table public.ks_leave_requests enable row level security;
alter table public.ks_feedback enable row level security;
alter table public.ks_awards enable row level security;
alter table public.ks_notifications enable row level security;
alter table public.ks_audit_logs enable row level security;
alter table public.ks_task_submissions enable row level security;

-- Staff-directory reads; profile mutation is Owner-only. Avoid users editing their own rank.
drop policy if exists "ks_profile_read" on public.ks_staff_profiles;
create policy "ks_profile_read" on public.ks_staff_profiles for select to authenticated using(user_id=auth.uid() or public.ks_is_owner() or (status='active' and public.ks_is_active_staff()));
drop policy if exists "ks_owner_manage_profiles" on public.ks_staff_profiles;
create policy "ks_owner_manage_profiles" on public.ks_staff_profiles for all to authenticated using(public.ks_is_owner()) with check(public.ks_is_owner());
-- Attendance: own rows or Owner reads; staff may insert own and update own row (timestamp integrity needs server RPC in hardened deployment).
drop policy if exists "ks_attendance_read" on public.ks_attendance;
create policy "ks_attendance_read" on public.ks_attendance for select to authenticated using(user_id=auth.uid() or public.ks_is_owner());
drop policy if exists "ks_attendance_insert" on public.ks_attendance;
create policy "ks_attendance_insert" on public.ks_attendance for insert to authenticated with check(user_id=auth.uid() and public.ks_is_active_staff());
drop policy if exists "ks_attendance_update" on public.ks_attendance;
create policy "ks_attendance_update" on public.ks_attendance for update to authenticated using(user_id=auth.uid() or public.ks_is_owner()) with check(user_id=auth.uid() or public.ks_is_owner());
-- Reports
drop policy if exists "ks_reports_read" on public.ks_reports;
create policy "ks_reports_read" on public.ks_reports for select to authenticated using(user_id=auth.uid() or public.ks_is_owner());
drop policy if exists "ks_reports_submit" on public.ks_reports;
create policy "ks_reports_submit" on public.ks_reports for insert to authenticated with check(user_id=auth.uid() and public.ks_is_active_staff());
drop policy if exists "ks_reports_owner_review" on public.ks_reports;
create policy "ks_reports_owner_review" on public.ks_reports for update to authenticated using(public.ks_is_owner()) with check(public.ks_is_owner());
-- Tasks
 drop policy if exists "ks_tasks_read" on public.ks_tasks;
create policy "ks_tasks_read" on public.ks_tasks for select to authenticated using(assigned_to=auth.uid() or public.ks_is_owner());
drop policy if exists "ks_tasks_owner_manage" on public.ks_tasks;
create policy "ks_tasks_owner_manage" on public.ks_tasks for all to authenticated using(public.ks_is_owner()) with check(public.ks_is_owner());
-- Task evidence submissions
 drop policy if exists "ks_task_submissions_read" on public.ks_task_submissions;
create policy "ks_task_submissions_read" on public.ks_task_submissions for select to authenticated using(user_id=auth.uid() or public.ks_is_owner());
drop policy if exists "ks_task_submissions_create" on public.ks_task_submissions;
create policy "ks_task_submissions_create" on public.ks_task_submissions for insert to authenticated with check(user_id=auth.uid() and public.ks_is_active_staff());
drop policy if exists "ks_task_submissions_owner_review" on public.ks_task_submissions;
create policy "ks_task_submissions_owner_review" on public.ks_task_submissions for update to authenticated using(public.ks_is_owner()) with check(public.ks_is_owner());
-- Warnings
drop policy if exists "ks_warnings_read" on public.ks_warnings;
create policy "ks_warnings_read" on public.ks_warnings for select to authenticated using(user_id=auth.uid() or public.ks_is_owner());
drop policy if exists "ks_warnings_owner_manage" on public.ks_warnings;
create policy "ks_warnings_owner_manage" on public.ks_warnings for all to authenticated using(public.ks_is_owner()) with check(public.ks_is_owner());
-- Leave
drop policy if exists "ks_leave_read" on public.ks_leave_requests;
create policy "ks_leave_read" on public.ks_leave_requests for select to authenticated using(user_id=auth.uid() or public.ks_is_owner());
drop policy if exists "ks_leave_submit" on public.ks_leave_requests;
create policy "ks_leave_submit" on public.ks_leave_requests for insert to authenticated with check(user_id=auth.uid() and public.ks_is_active_staff());
drop policy if exists "ks_leave_owner_review" on public.ks_leave_requests;
create policy "ks_leave_owner_review" on public.ks_leave_requests for update to authenticated using(public.ks_is_owner()) with check(public.ks_is_owner());
-- Feedback
 drop policy if exists "ks_feedback_read" on public.ks_feedback;
create policy "ks_feedback_read" on public.ks_feedback for select to authenticated using(user_id=auth.uid() or public.ks_is_owner());
drop policy if exists "ks_feedback_submit" on public.ks_feedback;
create policy "ks_feedback_submit" on public.ks_feedback for insert to authenticated with check(user_id=auth.uid());
drop policy if exists "ks_feedback_owner_manage" on public.ks_feedback;
create policy "ks_feedback_owner_manage" on public.ks_feedback for update to authenticated using(public.ks_is_owner()) with check(public.ks_is_owner());
-- Awards
 drop policy if exists "ks_awards_read" on public.ks_awards;
create policy "ks_awards_read" on public.ks_awards for select to authenticated using(user_id=auth.uid() or public.ks_is_owner() or public.ks_is_active_staff());
drop policy if exists "ks_awards_owner_manage" on public.ks_awards;
create policy "ks_awards_owner_manage" on public.ks_awards for all to authenticated using(public.ks_is_owner()) with check(public.ks_is_owner());
-- Notifications
 drop policy if exists "ks_notifications_read" on public.ks_notifications;
create policy "ks_notifications_read" on public.ks_notifications for select to authenticated using(user_id=auth.uid() or public.ks_is_owner());
drop policy if exists "ks_notifications_update" on public.ks_notifications;
create policy "ks_notifications_update" on public.ks_notifications for update to authenticated using(user_id=auth.uid() or public.ks_is_owner()) with check(user_id=auth.uid() or public.ks_is_owner());
drop policy if exists "ks_notifications_owner_insert" on public.ks_notifications;
create policy "ks_notifications_owner_insert" on public.ks_notifications for insert to authenticated with check(public.ks_is_owner());
-- Audit (Owner-only)
drop policy if exists "ks_audit_owner_read" on public.ks_audit_logs;
create policy "ks_audit_owner_read" on public.ks_audit_logs for select to authenticated using(public.ks_is_owner());
drop policy if exists "ks_audit_owner_insert" on public.ks_audit_logs;
create policy "ks_audit_owner_insert" on public.ks_audit_logs for insert to authenticated with check(public.ks_is_owner());

grant usage on schema public to authenticated;
grant select,insert,update,delete on public.ks_staff_profiles,public.ks_attendance,public.ks_reports,public.ks_tasks,public.ks_warnings,public.ks_leave_requests,public.ks_feedback,public.ks_awards,public.ks_notifications,public.ks_task_submissions to authenticated;
grant select,insert on public.ks_audit_logs to authenticated;
