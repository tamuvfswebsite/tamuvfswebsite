# Admin Guide (Internal)

This document is intended for internal administrators responsible for operating Land-502. Keep it with the application handoff bundle.

Last updated: 2025-10-16

## Overview
- Framework: Ruby on Rails 8
- AuthN/AuthZ: Admin login via Google OAuth using Devise + OmniAuth
- DB: PostgreSQL
- Storage: Active Storage (local dev; set production service via `config/storage.yml`)
- Admin UI: `/admin_panel`

## 1) Transfer Admin Privileges / Ownership

Land-502 uses Google Sign-In for admins. Admin entries are stored in the `admins` table and created on first login via OmniAuth.

Steps to transfer ownership to a new organization or lead admin:
1. Ensure the Google OAuth client is owned by the new organization (see Section 3: Config Rotation).
2. Add the new lead admin:
   - Ask them to visit the app and click “Admin Sign in with Google”
   - Their first successful login will create an `Admin` record via `Admins::OmniauthCallbacksController#google_oauth2`.
3. Verify Admin entry in DB:
   - Check `admins` table for their email; uniqueness is enforced on email.
4. Optionally remove departing admins:
   - From database: delete their row in `admins` by email, or provide an admin management UI (future improvement).

Notes:
- Users are tracked separately in the `users` table on admin login to maintain a mirrored user profile.
- In development, users may be given role `admin` automatically; in production, default role is `user`.

## 2) Backups and Restores

Back up both the PostgreSQL database and the Active Storage files.

### Database (PostgreSQL)
- Backup:
  - pg_dump example: `pg_dump --format=custom --file=backup_$(date +%F).dump <DATABASE_URL or connection params>`
- Restore:
  - `pg_restore --clean --no-owner --dbname=<DATABASE_URL or params> backup_YYYY-MM-DD.dump`
- Rails shortcut (dev):
  - `bin/rails db:dump` (if configured) or use `pg_dump` directly.

Data to preserve:
- Tables: admins, users, events, organizational_roles, resumes, Active Storage tables if used.

### Active Storage
- If using local disk in production, ensure the storage directory (e.g., `storage/`) is backed up as part of server backups.
- If using cloud storage (S3, GCS, Azure Blob), ensure lifecycle and versioning are configured per org policy.

### Test a Restore
- Always test restoring into a staging environment to validate integrity (migrations, attachments, sign-in).

## 3) Configuration Rotation / Reset

Sensitive configs include:
- `GOOGLE_OAUTH_CLIENT_ID`, `GOOGLE_OAUTH_CLIENT_SECRET`
- `RAILS_MASTER_KEY`
- Database credentials / `DATABASE_URL`

Procedures:
1. Google OAuth app handoff
   - Create or transfer ownership of the Google Cloud project that contains the OAuth client.
   - Update Authorized redirect URIs to include `<APP_URL>/admins/auth/google_oauth2/callback`.
   - Regenerate client secret if needed; store securely.
2. Rails master key
   - Regenerate only if secrets are compromised. This will require re-encrypting credentials.
   - Store `config/master.key` securely and as a secret in CI/CD and hosting.
3. Update environment variables
   - Update deployment environment with the new credentials and rotate old ones.
   - Redeploy to apply changes.

## 4) Operational Tasks

- Migrations: `bin/rails db:migrate` (Procfile release phase already runs migrations on deploys).
- Cache clear: `bin/rails tmp:clear` and `bin/rails log:clear` (or `./bin/setup` in dev).
- Restart app:
  - See `RESTART_RUNBOOK.md` for safe restart procedures across environments.

## 5) Security and Access Control

- Admin accounts are tied to Google emails; only those who can authenticate with the configured OAuth client will have admin records created.
- Consider restricting allowed admin domains via custom validation (future work).
- Run Brakeman and RuboCop regularly; CI already includes these checks.

## 6) Handoff Checklist

- [ ] New Google OAuth client configured, secrets rotated
- [ ] At least one new admin logged in successfully
- [ ] Database backup taken and stored securely
- [ ] Storage backups configured (S3/GCS or server-level)
- [ ] `RAILS_MASTER_KEY` stored in secret manager
- [ ] CI/CD updated with new secrets
- [ ] Links updated in `REFERENCES.md`
