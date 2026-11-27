KARASO - Signup and Owner Approval

New accounts are created as role=admin and status=pending by the Supabase auth.users trigger.
The user can sign in and use the public homepage, but portal-auth.js only displays the Admin panel link when role=admin AND status=approved.
Owner panel has a separate pending-requests list with explicit Approve / Reject actions.
Approve requires a rank from 1 to 8 and uses the existing staff_owner_update_member RPC.
Reject sets status=rejected; the user remains a normal signed-in site visitor and never sees the Admin panel.

If the auth trigger/policies in your current Supabase database are not already installed, run KARASO_SIGNUP_APPROVAL_FLOW.sql once in Supabase SQL Editor.
Do NOT rerun the full database setup SQL for this change.

Files changed:
- portal-auth.js
- owner.html
- staff-console.js
- KARASO_SIGNUP_APPROVAL_FLOW.sql (optional migration)

Important: The existing Owner account is not changed. The approval action uses the existing Owner-only RPC staff_owner_update_member.
