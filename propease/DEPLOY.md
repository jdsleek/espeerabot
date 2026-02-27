# PropEase — Deploy to Railway

Code is pushed. Set these **Variables** in Railway dashboard (Project → PropEase service → Variables):

## Required variables

| Variable | Value |
|----------|-------|
| `ADMIN_PASSWORD` | *(see below — your landlord login password)* |
| `APP_URL` | `https://propease.up.railway.app` |
| `BREVO_SMTP_HOST` | `smtp-relay.brevo.com` |
| `BREVO_SMTP_PORT` | `587` |
| `BREVO_SMTP_USER` | `864a82002@smtp-brevo.com` |
| `BREVO_SMTP_PASS` | *(your Brevo SMTP key from .env)* |
| `BREVO_FROM_EMAIL` | `naijaaiacademy@gmail.com` |
| `BREVO_FROM_NAME` | `Property Ease Manager` |
| `LANDLORD_EMAIL` | `naijaaiacademy@gmail.com` |

`DATABASE_URL` is auto-injected when Postgres is linked.

## Your landlord password

Generate one: `openssl rand -base64 16`

Add it as `ADMIN_PASSWORD` in Railway Variables. Save it somewhere safe — you need it to log in as landlord.

## After deploy

1. Open https://propease.up.railway.app
2. Click Landlord tab → enter the password above
3. Tenants use the "Tenant" tab with their full name + PIN (set per tenant)
