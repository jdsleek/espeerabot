# PropEase v2 — Property & Tenant Management

Property management portal for landlords and tenants. Includes:

- **Landlord dashboard** — tenants, payments, agreements, maintenance tickets
- **Reminders** — rent due, lease expiry, custom reminders with WhatsApp links
- **Browser notifications** — enable to get desktop alerts for reminders
- **Tenant portal** — view notices, payment history, submit maintenance requests
- **Data** — stored in browser localStorage (no backend DB required)

## Run locally

```bash
cd propease-v2
npm install   # optional, no deps
npm start
```

Open http://localhost:3000

- **Landlord:** password `admin123`
- **Tenant:** use name + PIN (e.g. Amira Hassan / 1234)

## Deploy to Railway

**Option A — New project**
1. Go to [railway.app/new](https://railway.app/new)
2. Deploy from GitHub — create a repo with this `propease-v2` folder (or the whole eggy repo)
3. If using full repo: Railway → Settings → set **Root Directory** to `propease-v2`
4. Deploy

**Option B — Add to existing project**
1. In your Railway project → **+ New** → **Empty Service**
2. Name it `propease-v2`
3. Connect to the repo containing this folder
4. Settings → **Root Directory** = `propease-v2` (if repo root is eggy)
5. Deploy (or `railway up` from this folder after `railway link --service propease-v2`)

## Notifications

Click **Enable Notifications** in the Reminders page to get browser push alerts when:
- Tenants have rent due
- Leases are expiring within 30 days
- Custom reminders are due today

Reminders are checked every minute when the landlord view is open.
