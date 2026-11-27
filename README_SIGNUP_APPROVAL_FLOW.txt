KARASO ROLEPLAY - Signup and Owner Approval

The database approval SQL has already been run by the site owner.
This package now connects the homepage and Owner panel to public.staff_admin_requests.

Flow:
- Signup creates a normal profile through the original handle_new_user() trigger.
- The second trigger creates a row in staff_admin_requests.
- The public homepage does not show the Admin panel unless profiles.role=admin AND profiles.status=approved.
- Owner sees pending requests in Owner > اعضا و درخواست‌ها.
- Approve asks for rank 1-8 and title, calls approve_staff_admin_request(), then updates rank/title with staff_owner_update_member().
- Reject calls reject_staff_admin_request(); the profile remains a normal user.

After uploading these website files, run KARASO_REQUEST_STATUS_POLICY.sql once in Supabase SQL Editor.
This grants each user read access only to their own request status. Owner's existing request-reading policy remains.
Do not rerun the full database setup SQL or the earlier approval SQL.

Upload/replace the files in the repository root. Keep supabase-config.js unchanged unless the Supabase project itself changes.
This package was checked for JavaScript syntax and ZIP integrity, but not live-tested against the remote Supabase project.
