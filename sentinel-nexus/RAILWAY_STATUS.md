# Railway status and setup check

Quick reference for what’s on Railway and how to fix it.

---

## Two different things on Railway

1. **espeerabot repo** (this repo) → **Jobmaster Agency**: landing, dashboard, hub, brain, APIs. Run with: `node sentinel-nexus/admin/server.js`. See **RAILWAY.md** in repo root.
2. **OpenClaw gateway** → Control UI + chat. Deploy from Railway template (clawdbot-railway-template), not from this repo. See **DEPLOY.md** (OpenClaw on Railway checklist).

You can have one Railway project for the agency (this repo) and a separate one for the OpenClaw gateway, each with its own domain.

---

## Live check (espeerabot.up.railway.app)

When checked:

- **`/`** → Memorial static page (wrong if you want the agency here).
- **`/setup`**, **`/openclaw`**, **`/api/agency`** → Not found (404).

So right now the app running at that URL is **not** the Node agency server and **not** the OpenClaw gateway; it’s the static file server (root `index.html` = memorial).

---

## Fix: show Agency at espeerabot.up.railway.app

If this URL should show the **Jobmaster Agency** (landing, dashboard, hub, brain):

1. In **Railway** → your project → **Settings** (or **Deploy**):
   - Set **Start Command** to: **`node sentinel-nexus/admin/server.js`**
   - (Or leave Start Command empty and rely on **railway.json** in the repo; it already sets this.)
2. **Redeploy** (e.g. trigger a new deploy or push to `main`).
3. **Variables:** Don’t set `PORT` (Railway sets it). Optional: add a **volume** at `/data`, then set **`OPENCLAW_WORKSPACE_DIR=/data/workspace`** so agency data persists.

After a successful deploy:

- **`/`** → Agency landing (marketing).
- **`/hub`** → Hub page.
- **`/admin/dashboard`** → Dashboard.
- **`/api/agency`** → JSON (200).

---

## OpenClaw gateway on Railway (separate deploy)

If you want **OpenClaw** (setup, control UI, chat) on Railway:

- Deploy from the **OpenClaw / clawdbot-railway-template** (see **DEPLOY.md**).
- Use the **OpenClaw on Railway — checklist** at the top of **DEPLOY.md**: volume `/data`, variables (SETUP_PASSWORD, PORT=8080, OPENCLAW_STATE_DIR, OPENCLAW_WORKSPACE_DIR), HTTP proxy port 8080, then **trustedProxies** in gateway config so the UI connects without “pairing required”.

That deploy is independent of this repo; it can use the same domain (if you point it there) or a different one.

---

## Summary

| Goal | Action |
|------|--------|
| Agency (dashboard, hub, brain) at espeerabot.up.railway.app | Set Start Command to `node sentinel-nexus/admin/server.js`, redeploy. See **RAILWAY.md**. |
| OpenClaw (setup, /openclaw, chat) on Railway | Deploy from OpenClaw template; follow **DEPLOY.md** checklist (volume, vars, trustedProxies). |
