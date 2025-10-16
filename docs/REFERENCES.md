# References

Central links and contacts for Land-502. Replace placeholders with your project’s values at handoff.

Last updated: 2025-10-16

## Application
- Production URL: https://<your-app-domain>
- Staging URL: https://<your-staging-domain>

## Source Code
- GitHub repository: https://github.com/ZGong1/Land-502
- Default branch: main

## API and Auth
- Rails Routes: see `bin/rails routes` during development
- Google OAuth setup guide: https://developers.google.com/identity/protocols/oauth2
- OmniAuth Google OAuth2 gem: https://github.com/zquestz/omniauth-google-oauth2
- Devise OmniAuth docs: https://github.com/heartcombo/devise/wiki/OmniAuth:-Overview

## Credentials and Secrets
- Encrypted credentials (Rails): https://guides.rubyonrails.org/security.html#custom-credentials
- Master key handling: store `RAILS_MASTER_KEY` in secret manager/CI

## Operations
- Restart runbook: `RESTART_RUNBOOK.md`
- Admin guide: `ADMIN_GUIDE.md`
- Installation guide: `INSTALLATION.md`

## Support Window
- Contact: <team-email@example.com> or GitHub Issues on the repo
- Response hours: <define>

## Monitoring (if applicable)
- Uptime: <status-page-or-monitoring-link>
- Error tracking: <Sentry/Rollbar link>
- Logs: hosting provider dashboard or `docker logs`
