-- KARASO STAFF migration: mandatory game-name signup field + automatic pending profile.
-- Run in the FORUM Supabase project's SQL Editor. No forum tables are modified.
alter table public.ks_staff_profiles add column if not exists game_name text;

create or replace function public.ks_create_staff_pending_profile()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.ks_staff_profiles (user_id, display_name, game_name, role, admin_level, status)
  values (
    new.id,
    coalesce(nullif(new.raw_user_meta_data->>'display_name',''), 'Staff'),
    nullif(new.raw_user_meta_data->>'game_name',''),
    'admin', 1, 'pending'
  )
  on conflict (user_id) do nothing;
  return new;
end;
$$;

 drop trigger if exists ks_auth_user_pending_profile on auth.users;
create trigger ks_auth_user_pending_profile
 after insert on auth.users
 for each row execute function public.ks_create_staff_pending_profile();
