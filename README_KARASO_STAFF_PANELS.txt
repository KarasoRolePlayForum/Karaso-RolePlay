KARASO ROLEPLAY - separated staff panels

Public pages retained:
- index.html (main site)
- community.html (forum/community)
- shop.html (store)
- launcher.html (launcher download)
- staff-commands.html and staff-list.html

Staff panels:
- admin.html: personal admin workspace (playtime timer, attendance, daily reports, leave requests, personal warnings, assigned tasks)
- owner.html: Owner team control (members/applications, report review, leave approvals, active playtime sessions, warnings, awards, tasks)

Removed from active project:
- forum-admin.html / forum-admin.js
- old admin.js (store admin script)
- admin-management links from homepage, community and shop

Homepage displays only the staff link matching the signed-in approved profile:
- approved admin: "پنل ادمین" -> admin.html
- approved owner: "پنل مدیریت" -> owner.html

No SQL was changed or run by this package. It relies on the existing Supabase tables/functions already installed in the project, including staff_attendance, staff_playtime_sessions, staff_playtime_daily, staff_reports, staff_leave_requests, staff_warnings, staff_tasks, staff_awards, profiles, and RPC functions from the previous setup.
