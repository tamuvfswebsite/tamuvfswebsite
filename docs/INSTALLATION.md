# Installation and Setup Guide

This guide covers local development setup and containerized runs for Land-502.

Last updated: 2025-10-16

## Prerequisites
- Ruby 3.4.5
- PostgreSQL 13+
- Node.js 16+ (optional for legacy scripts)
- Yarn (optional)
- Git
- OpenSSL and build tools (e.g., MSYS2 on Windows, Xcode CLT on macOS)

## Windows Notes
- Recommended: Windows Subsystem for Linux (WSL2) for a smoother Ruby + Postgres experience.
- If staying native on Windows, ensure RubyInstaller with DevKit and `tzinfo-data` gem (already in Gemfile).

## 1) Clone and install gems
```powershell
# PowerShell
git clone <YOUR_REPO_URL>
cd <YOUR_REPO_DIR>

# Install bundler and gems
ruby -v
gem install bundler --conservative
bundle install
```

If you see native extension errors, install platform build tools:
- Windows: Install MSYS2 via RubyInstaller, run `ridk install` then `bundle config set --local build.sassc --disable-march-tune-native` and retry.
- macOS: `xcode-select --install`
- Ubuntu: `sudo apt-get update; sudo apt-get install -y build-essential libpq-dev`.

## 2) Database setup
Configure PostgreSQL access:
- Create role and database or set `DATABASE_URL`.
- Local `.env` (optional):
```
DATABASE_URL=postgres://<user>:<pass>@localhost:5432/land502_dev
```

Then run:
```powershell
bin/rails db:prepare
```
This creates the database, runs migrations, and seeds as configured.

## 3) Environment variables
Set the following for Google OAuth and Rails credentials:
- `GOOGLE_OAUTH_CLIENT_ID`
- `GOOGLE_OAUTH_CLIENT_SECRET`
- `RAILS_MASTER_KEY` (if reading encrypted credentials locally)

You can export in PowerShell for the session:
```powershell
$env:GOOGLE_OAUTH_CLIENT_ID="<id>"
$env:GOOGLE_OAUTH_CLIENT_SECRET="<secret>"
$env:RAILS_MASTER_KEY="<master_key>"
```

## 4) Run the app (dev)
```powershell
bin/dev   # runs Procfile.dev via foreman or bin/dev scripts (hot-reload)
# or
bin/rails server
```
Open http://localhost:3000

Admin sign-in route uses Google OAuth callback at:
- `/admins/auth/google_oauth2` (initiate)
- `/admins/auth/google_oauth2/callback` (redirect URI in Google Cloud Console)

## 5) Tests
```powershell
bundle exec rspec
```

## 6) Docker (optional)
Build and run container:
```powershell
docker build -t land502 .
docker run -d -p 80:80 `
  -e RAILS_ENV=production `
  -e RAILS_MASTER_KEY=<value> `
  -e GOOGLE_OAUTH_CLIENT_ID=<value> `
  -e GOOGLE_OAUTH_CLIENT_SECRET=<value> `
  --name land502 land502
```
Make sure Postgres is reachable (use `DATABASE_URL`).

## 7) Troubleshooting
- OpenSSL errors: ensure system OpenSSL is installed and Ruby is compiled against it.
- PG connection refused: check Postgres service status and credentials.
- OmniAuth callback mismatch: ensure exact Redirect URI in Google Cloud matches `/admins/auth/google_oauth2/callback`.
- Master key: if credentials are required locally, ensure `config/master.key` or `RAILS_MASTER_KEY` is set.

## 8) Next
- See `RESTART_RUNBOOK.md` for restart procedures.
- See `ADMIN_GUIDE.md` for backup/restore and config rotation.
