# Railway Variables for PropEase

Add these in **Railway → Propease service → Variables**:

## App
- `APP_URL` — Public URL for login links in emails (e.g. `https://propease.up.railway.app`). Falls back to `RAILWAY_STATIC_URL` or a default if not set.
- `ADMIN_PASSWORD` — Landlord login password (set via Railway Variables or run `node scripts/railway-set-vars.js` to auto-set).

## Database
- `DATABASE_URL` — **Required.** Add Postgres in Railway, then add variable reference: `${{Postgres.DATABASE_URL}}`. See RAILWAY_SETUP.md.

## Brevo Email
| Variable | Value |
|----------|-------|
| BREVO_SMTP_HOST | smtp-relay.brevo.com |
| BREVO_SMTP_PORT | 587 |
| BREVO_SMTP_USER | 864a82002@smtp-brevo.com |
| BREVO_SMTP_PASS | *(paste your Brevo SMTP key)* |
| BREVO_FROM_EMAIL | naijaaiacademy@gmail.com |
| BREVO_FROM_NAME | Property Ease Manager |
| LANDLORD_EMAIL | naijaaiacademy@gmail.com |
