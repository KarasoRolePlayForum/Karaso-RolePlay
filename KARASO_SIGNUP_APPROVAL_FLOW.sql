-- KARASO: ثبت‌نام کاربران و تأیید Owner برای دسترسی ادمین
-- این اسکریپت فقط منطق پروفایل ثبت‌نام را تضمین می‌کند و سوابق موجود را حذف نمی‌کند.
create or replace function public.staff_new_user_profile()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles(id, email, display_name, role, status)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data->>'display_name', ''),
    'admin',
    'pending'
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists staff_auth_user_created on auth.users;
create trigger staff_auth_user_created
after insert on auth.users
for each row execute function public.staff_new_user_profile();

-- کاربر فقط نام نمایشی پروفایل pending خودش را می‌تواند اصلاح کند؛
-- نمی‌تواند role یا status را خودش تغییر دهد.
alter table public.profiles enable row level security;
drop policy if exists profiles_self_update_name on public.profiles;
create policy profiles_self_update_name
on public.profiles for update to authenticated
using (id = auth.uid() and status = 'pending' and role = 'admin')
with check (id = auth.uid() and status = 'pending' and role = 'admin');

-- نمایش درخواست‌ها برای Owner و مشاهده پروفایل خود کاربر
 drop policy if exists profiles_read_team on public.profiles;
create policy profiles_read_team
on public.profiles for select to authenticated
using (id = auth.uid() or public.staff_is_owner() or public.staff_is_approved());
