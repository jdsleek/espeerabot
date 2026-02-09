# Deploy espeerabot (Jobmaster Agency) to Railway

This repo is set up so **espeerabot.up.railway.app** (or your Railway domain) shows the **Jobmaster Agency** (landing, dashboard, hub, brain), not the static memorial site.

## What runs on Railway

- **Start command:** `node sentinel-nexus/admin/server.js` (set in `railway.json` and `package.json` "start").
- **Root URL `/`** serves the agency marketing/landing page; `/admin/dashboard`, `/hub`, `/admin/brain`, etc. work as usual.

## Environment variables (Railway dashboard → Variables)

| Variable | Required | Description |
|----------|----------|-------------|
| `PORT` | **Set by Railway** | Railway injects this; the server uses it automatically. Do not set manually unless overriding. |
| `OPENCLAW_WORKSPACE_DIR` | Optional | Persistent workspace path. If you add a **volume** and mount it at `/data`, set to `/data/workspace` so agency data (discovery-feed, MoltX state, etc.) persists across deploys. |
| `OPENCLAW_STATE_DIR` | Optional | Default (no config) is `~/.openclaw` which may not exist on Railway. If using a volume at `/data`, set to `/data/.openclaw` and ensure `openclaw.json` exists there if you need workspace from config. |
| `ADMIN_PORT` | Optional | Only if you are **not** using Railway’s `PORT` (e.g. local override). Normally leave unset. |
| `REPORT_MAX_TOKENS` | Optional | Max tokens for report generation (default 8192). |
| API keys (Kimi, etc.) | As needed | Any keys used by the server (e.g. report generation) must be set in Railway Variables; the server reads `process.env`. |

## Checklist

1. **Railway project** is connected to this repo (e.g. `jdsleek/espeerabot`), branch `main`.
2. **Start command** is either not set (so `railway.json` / `npm start` is used) or set to: `node sentinel-nexus/admin/server.js`.
3. **PORT** is provided by Railway; do not set it yourself unless you have a reason.
4. **Optional:** Add a volume, mount at `/data`, and set:
   - `OPENCLAW_WORKSPACE_DIR=/data/workspace`
   - (Optional) `OPENCLAW_STATE_DIR=/data/.openclaw` if you use openclaw config there.
5. **HTTP proxy / public domain:** Enable in Railway so you get a URL like `espeerabot.up.railway.app`.
6. Redeploy after changing variables or the start command.

## After deploy

- **Landing:** `https://espeerabot.up.railway.app/`
- **Hub (all links):** `https://espeerabot.up.railway.app/hub`
- **Dashboard:** `https://espeerabot.up.railway.app/admin/dashboard`
- **Brain:** `https://espeerabot.up.railway.app/admin/brain`

If the index still shows the wrong content (e.g. memorial page), Railway is likely still running an old start command (e.g. `npx serve .`). Set the start command to `node sentinel-nexus/admin/server.js` in the Railway dashboard (or rely on `railway.json` and redeploy).

## Memorial static site (optional)

To run the **memorial** static site locally: `npm run start:site` or `npx serve .`. Do not use this as the Railway start command if you want the agency on espeerabot.
