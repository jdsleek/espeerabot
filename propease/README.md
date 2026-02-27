# PropEase — Property & Tenant Management

Property management portal for landlords and tenants. Includes:

- **Landlord dashboard** — tenants, payments, agreements, maintenance tickets
- **Reminders** — rent due, lease expiry, custom reminders with WhatsApp links
- **Browser notifications** — enable for desktop alerts
- **Tenant portal** — view notices, payment history, submit maintenance requests
- **Data** — Postgres when `DATABASE_URL` is set, else localStorage

## Run locally

```bash
cd propease
npm install
npm start
```

Open http://localhost:3000

- **Landlord:** password `admin123`
- **Tenant:** name + PIN (e.g. Amira Hassan / 1234)

### With database (optional)

```bash
export DATABASE_URL="postgresql://user:pass@host:5432/dbname"
npm run db:init   # create tables + seed
npm start
```

## Deploy to Railway

1. **New project** → [railway.app/new](https://railway.app/new)
2. **+ New** → **Empty Service** → name it `propease`
3. **+ New** → **Database** → **PostgreSQL** (this creates a linked DB)
4. Connect the service to your repo (eggy or a fork)
5. Settings → **Root Directory** = `propease` (if repo root is eggy)
6. **Variables** — Railway auto-injects `DATABASE_URL` from the Postgres plugin
7. **Email (Brevo)** — Add these variables for email notifications:
   ```
   BREVO_SMTP_HOST=smtp-relay.brevo.com
   BREVO_SMTP_PORT=587
   BREVO_SMTP_USER=864a82002@smtp-brevo.com
   BREVO_SMTP_PASS=<paste Brevo SMTP key>
   BREVO_FROM_EMAIL=naijaaiacademy@gmail.com
   BREVO_FROM_NAME=Property Ease Manager
   LANDLORD_EMAIL=naijaaiacademy@gmail.com
   ```
8. Deploy — server runs `db:init` on first start, then serves the app

## Notifications

Click **Enable Notifications** on the Reminders page for browser push alerts when:
- Rent is due
- Leases expire within 30 days
- Custom reminders are due today
