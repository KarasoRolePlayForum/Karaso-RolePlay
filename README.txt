KARASO STAFF - build package

Important: This is a separate STAFF app, hosted in the existing Karaso GitHub repository (in its own folder), using the FORUM Supabase project. It does not connect to the main Karaso game/app Supabase.

Files:
- index.html
- supabase-config.js
- js/app.js
- css/style.css
- sql/setup.sql (initial schema; only run if you have not already run the previous setup)
- sql/03_signup_profile_game_name.sql (migration for mandatory game name + pending profile trigger)

Do NOT rerun setup.sql on an already-set-up database. Run the migration 03 only once.

Signup requires display name and in-game name; email is used only for authentication/password recovery and is not rendered as a profile field. Password reset uses Supabase Auth email flow.

GitHub Pages deployment: upload the folder contents into a separate folder in the existing repository, e.g. /staff/. Ensure Pages is already enabled for the repo. Do not overwrite the root site files.

Before public deployment, review SQL/RLS and test with a non-owner account. The current build needs live Supabase verification; this ZIP is not a claim that every backend workflow has been tested. Never publish the Supabase secret key. If a secret key was shared, rotate it.

Theme alignment: the STAFF CSS uses the original KARASO ROLEPLAY palette/background (bg #080b14, panels #111827, purple #8b5cf6, cyan #67e8f9) and its glow treatment.
