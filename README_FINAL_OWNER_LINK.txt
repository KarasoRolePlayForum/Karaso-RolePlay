KARASO ROLEPLAY - FINAL OWNER LINK PACKAGE

Changes:
- Restored the public homepage as index.html.
- Added a small "پنل مدیریت" link in the top account area.
- The link is hidden by default and appears only for an authenticated, approved Owner.
- Clicking it opens owner.html.
- Admin and Owner pages remain separate.
- Added KARASO_COMPLETE_SETUP.sql: consolidated base setup + V2 migration.

Install: upload all files in this ZIP to the root of the GitHub Pages repository, replacing matching files.
SQL: use the single KARASO_COMPLETE_SETUP.sql file in Supabase SQL Editor. This script is designed to preserve existing profiles and Owner account, but was not run against your live Supabase project.
