# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

Development server:
```bash
bin/rails db:prepare
bin/dev                 # or: bin/rails server
# open http://localhost:3000
```

Docker (production-oriented image):
```bash
docker build -t land502 .
docker run -d -p 80:80 \
  -e RAILS_MASTER_KEY=<value> \
  --name land502 land502
# open http://localhost
```

### Environmental Variables/Files
- `GOOGLE_OAUTH_CLIENT_ID`, `GOOGLE_OAUTH_CLIENT_SECRET` (Devise OmniAuth)
- `DATABASE_URL` or `DATABASE_USER`/`DATABASE_PASSWORD`
- `RAILS_MASTER_KEY` (for production and when needed to read credentials)

For background on encrypted credentials, see: [Rails Encrypted Credentials](https://guides.rubyonrails.org/security.html#custom-credentials).

### Deployment
- A `Procfile` includes a release step to run `rails db:migrate`.
- CI is configured via GitHub Actions (lint, security scan, tests).
- Docker: build and run as shown above; set required env vars.
- Heroku (optional): create an app, set `RAILS_MASTER_KEY`, database config, and Google OAuth env vars; deploy and run migrations.

### CI/CD
GitHub Actions workflows in `.github/workflows` provide:
- Code scanning with Brakeman and JS audit via Importmap
- Linting with RuboCop
- RSpec tests with a Postgres service

### Support
This project is provided as-is without formal support. Issues and PRs are welcome.

### Extra Helps
- Rails Guides: [https://guides.rubyonrails.org](https://guides.rubyonrails.org)
- Devise: [https://github.com/heartcombo/devise](https://github.com/heartcombo/devise)
- OmniAuth Google OAuth2: [https://github.com/zquestz/omniauth-google-oauth2](https://github.com/zquestz/omniauth-google-oauth2)
- Hotwire: [https://hotwired.dev](https://hotwired.dev)

### Documentation
-- Documentation Plan: `docs/DOCUMENTATION_PLAN.md`
-- Admin Guide (internal): `docs/ADMIN_GUIDE.md`
-- Installation / Setup: `docs/INSTALLATION.md`
-- Restart Runbook (failsafe): `docs/RESTART_RUNBOOK.md`
-- Online Help Approach: `docs/ONLINE_HELP_GUIDE.md`
-- References: `docs/REFERENCES.md`
