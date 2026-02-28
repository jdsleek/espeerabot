# PropEase — Railway Database Setup

The live app returns "Database not configured" because `DATABASE_URL` is not set. Fix it:

---

## Option A: Railway Dashboard (recommended)

1. Go to [railway.app](https://railway.app) → your **PropEase** project
2. Check if **Postgres** exists:
   - If **no**: Click **+ New** → **Database** → **PostgreSQL**
   - If **yes**: Continue
3. Click your **PropEase web service** (the one that runs `node server.js`)
4. Open **Variables** tab
5. Click **+ New Variable** → **Add Reference**
6. Select **Postgres** (or your DB service) → **DATABASE_URL**
7. Click **Add**
8. **Redeploy**: Deployments → ⋮ → Redeploy

---

## Option B: Railway CLI

```bash
# 1. Login (opens browser)
railway login

# 2. Link to PropEase project
cd propease
railway link
# Select: PropEase project → production → web service

# 3. Check variables
railway variables

# 4. If DATABASE_URL missing: add Postgres in dashboard, then add reference (Option A)
```

---

## Verify

```bash
curl https://propease.up.railway.app/api/health
# Should return: {"ok":true,"db":true}
```

---

## Token Note

The `RAILWAY_TOKEN` in `.env` is for project deploys (e.g. CI). It does not authenticate the CLI or GraphQL API for variable management. Use `railway login` for CLI access.
