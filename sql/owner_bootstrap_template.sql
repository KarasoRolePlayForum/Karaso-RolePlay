-- Replace YOUR-AUTH-UUID with the Owner's Auth User ID before running.
-- Run once after the owner has signed up through the app.
insert into public.ks_staff_profiles(user_id,display_name,role,admin_level,status)
values ('YOUR-AUTH-UUID','Owner','owner',null,'active')
on conflict (user_id) do update set role='owner',admin_level=null,status='active',display_name='Owner';
