KARASO STAFF CONTROL CENTER - INSTALLATION

IMPORTANT
- This is a separate staff portal, not the public player website.
- The original pages/assets/scripts are retained in this package. The root index.html now opens the staff portal.
- The previous public homepage is retained as player-site-index-backup.html.
- Supabase browser configuration is in supabase-config.js. It currently points to:
  https://qgochicianbeexiubnub.supabase.co
  Confirm this is the dedicated NEW staff Supabase project before publishing.
- Never put a Supabase service_role/secret key in this website. Only the publishable key belongs in supabase-config.js.

SUPABASE SETUP
1. Open the NEW dedicated Supabase project.
2. Go to SQL Editor > New query.
3. Open KARASO_STAFF_PORTAL_SETUP.sql from this ZIP, copy all its contents, paste into SQL Editor, and Run.
4. If the SQL reports that pg_cron could not be enabled, open Database > Extensions, enable pg_cron, then rerun the final pg_cron DO block from the SQL file.
5. In Authentication > URL Configuration, set Site URL to the deployed staff portal URL.
   Add the deployed staff portal URL and its /password-reset.html URL to Redirect URLs.
6. Open the website and create the account that must be the first Owner using the normal sign-up form.
7. In Supabase SQL Editor run this one-time statement, replacing the email with the exact Owner account email:

   update public.profiles
   set role='owner', status='approved', display_name='OWNER', title='Owner', rank_number=null
   where email='OWNER_EMAIL_HERE';

8. Sign out and sign back in with that Owner account. Owner can now approve new staff signups and set their in-game name, title and rank 1-8.
9. Other people register from the portal. Their profile is automatically created as role=admin, status=pending. They cannot enter staff tools until Owner approves them.

FEATURES
- Staff registration/login and password recovery using Supabase Auth; persistent sessions.
- Pending approval queue. Owner can edit in-game name/title/rank, approve, reject, or remove from team.
- Ranks are limited to 1 through 8; Owner is a separate role.
- Playtime logs and daily reports.
- Automatic missing-daily-report warning job scheduled for 23:59 UTC, if pg_cron is enabled. The job checks database current_date; report dates use the same database date.
- Owner-issued warnings.
- Private team criticism/suggestions/ideas.
- Owner-assigned tasks and staff submissions/review.
- Shift check-in/check-out and leave requests.
- Daily/weekly/monthly staff awards.
- RLS policies and owner-only RPC for member approvals.

NOTES / LIMITATIONS
- The SQL creates the database schema and security policies; it does not migrate existing users from another Supabase project.
- Existing users must register in this dedicated project, unless you separately migrate their Auth accounts.
- The automatic warning scheduler depends on pg_cron being available/enabled in the Supabase project.
- This package has passed JavaScript syntax checks and ZIP integrity checks. It has not been live-tested against your Supabase project because no project access was provided.
