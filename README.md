## README

### Introduction
Land-502 is a Ruby on Rails web application that provides an events dashboard and resume submissions. Admins authenticate with Google OAuth to manage events; users can view events and attach a PDF resume to their profile.

### Application Description
- Rails 8 app with PostgreSQL, Hotwire (Turbo/Stimulus), and Active Storage
- Admin Google OAuth via Devise + OmniAuth
- Admin panel (`/admin_panel`) for Events CRUD
- Users have a single PDF resume (validated type and size)
- GitHub Actions for linting, security scans, and tests

### Requirements
This code has been run and tested on:
- **Ruby**: 3.4.5
- **Rails**: 8.0.2.1
- **RubyGems**: see `Gemfile`
- **PostgreSQL**: 13.x or newer
- **Node.js**: 16.20.2 (optional for legacy webpack scripts)
- **Yarn**: 1.x (optional)
- **Docker**: latest (for containerized runs)

### External Deps
- **Docker Desktop**: [Download](https://www.docker.com/products/docker-desktop)
- **Git**: [Install](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
- **Heroku CLI (optional)**: [Install](https://devcenter.heroku.com/articles/heroku-cli)
- **GitHub Desktop (optional)**: [Install](https://desktop.github.com/)

### Installation
Download this code repository using git:

```bash
git clone <YOUR_REPO_URL>
cd <YOUR_REPO_DIR>

gem install bundler --conservative
bundle install
./bin/setup        # prepares database, clears logs, restarts
```

### Tests
An RSpec test suite is available and can be run using:

```bash
bundle exec rspec
# or
rspec spec/
```

### Execute Code
Run the following in PowerShell (Windows) or a terminal (Linux/Mac):

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
