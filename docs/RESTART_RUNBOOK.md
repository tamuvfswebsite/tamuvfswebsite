# Restart Runbook (Failsafe)

Use this runbook to safely restart the application in different environments.

Last updated: 2025-10-16

## Goals
- Minimize downtime
- Ensure DB migrations and secrets are present
- Validate app health post-restart

## Dev (local)
```powershell
# Stop running server (Ctrl+C) if using bin/dev or rails s
# Clear tmp and restart
bin/rails tmp:clear
bin/rails db:migrate   # optional if schema changed
bin/dev                # or: bin/rails server
```
Health check: open http://localhost:3000

## Docker
```powershell
# Gracefully stop and remove container
 docker stop land502; docker rm land502
# Rebuild (if code changed) and start
 docker build -t land502 .
 docker run -d -p 80:80 `
   -e RAILS_ENV=production `
   -e RAILS_MASTER_KEY=<value> `
   -e DATABASE_URL=<value> `
   -e GOOGLE_OAUTH_CLIENT_ID=<value> `
   -e GOOGLE_OAUTH_CLIENT_SECRET=<value> `
   --name land502 land502
```
Health check: browse to site and check logs
```powershell
docker logs --tail 200 land502
```

## Heroku or Procfile-style hosting
- Ensure release phase runs `rails db:migrate`.
- Restart dynos or service via provider CLI/UI.
- Confirm env vars (master key, Google OAuth) are present.

## Post-Restart Verification
- Admin login via Google succeeds
- View `/admin_panel` dashboard
- CRUD an Event in admin panel
- Resume upload works for a test user
- No errors in logs

## Rollback Notes
- If a deploy introduces failures, rollback to previous container image or release.
- Keep DB backups and avoid destructive migrations without backups.
