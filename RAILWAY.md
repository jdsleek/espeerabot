# Deploy espeerabot (Jobmaster Agency) to Railway

This repo is set up so **espeerabot.up.railway.app** (or your Railway domain) shows the **Jobmaster Agency** (landing, dashboard, hub, brain), not the static memorial site.

## What runs on Railway

- **Start command:** `node sentinel-nexus/admin/server.js` (set in `railway.json` and `package.json` "start").
- **Root URL `/`** serves the agency marketing/landing page; `/admin/dashboard`, `/hub`, `/admin/brain`, etc. work as usual.
- **Existing volume:** If you already have a volume attached, Railway injects **`RAILWAY_VOLUME_MOUNT_PATH`** (e.g. `/data`). The app **uses it automatically**: workspace = `{volume}/workspace`, credentials/state = `{volume}/.openclaw`. No need to set `OPENCLAW_WORKSPACE_DIR` or `OPENCLAW_STATE_DIR` unless you want to override.

## Environment variables (Railway dashboard → Variables)

| Variable | Required | Description |
|----------|----------|-------------|
| `PORT` | **Set by Railway** | Railway injects this; the server uses it automatically. Do not set manually unless overriding. |
| `OPENCLAW_WORKSPACE_DIR` | Optional | Persistent workspace path. If you add a **volume** and mount it at `/data`, set to `/data/workspace` so agency data (discovery-feed, MoltX state, etc.) persists across deploys. |
| `OPENCLAW_STATE_DIR` | Optional | Default is `~/.openclaw`. Set to `/data/.openclaw` with a volume at `/data` and add ClawTasks credential files there so agents and APIs work. |
| `RUN_AUTONOMOUS_CYCLE_MIN` | Optional | Minutes between auto run-cycles (claim/submit/approve). Default **20** on Railway when `PORT` is set. |
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

## Production: full business and share with users

To run **fully autonomous** and have **all APIs** and the dashboard work for users:

1. **Volume** — Add a Railway volume, mount path **`/data`**.
2. **Variables** — Set **`OPENCLAW_WORKSPACE_DIR=/data/workspace`** and **`OPENCLAW_STATE_DIR=/data/.openclaw`**.
3. **Credentials** — Add ClawTasks credential files into the volume at `/data/.openclaw/` (e.g. `clawtasks-credentials.json` with `{ "api_key": "YOUR_KEY" }`) so agents show stats and claim/submit work. Same format as `~/.openclaw/clawtasks-credentials.json` locally.
4. **Autonomous cycle** — When `PORT` is set (Railway), the server runs a run-cycle every **20 minutes** automatically. Set **`RUN_AUTONOMOUS_CYCLE_MIN=15`** to change the interval.
5. **APIs** — With credentials in place, `/api/agency`, POST `/api/run-cycle`, POST `/api/claim-instant`, `/api/post-job`, `/job/track`, MoltX, etc. all work.

Without credentials the site and APIs still load; agents show "(no key)" and "—" until credential files are added. **Completed work** and dashboard stats come from ClawTasks; add the same credential files you use locally to the volume (e.g. `{volume}/.openclaw/clawtasks-credentials.json`) so Railway shows the same data as local. Optional env: **`RUN_AUTONOMOUS_CYCLE_MIN`** (minutes; default 20 on Railway).

## Copy everything from local so Railway works 100% (use Railway token / Variables)

1. **On your local machine** (where `~/.openclaw/` has your ClawTasks credentials), run:
   ```bash
   ./sentinel-nexus/export-credentials-for-railway.sh
   ```
   This prints variable names and **base64** values.

2. **In Railway** → your project → **Variables**: Add each line the script printed (e.g. `CLAWTASKS_CREDENTIALS_JSON=eyJ...`, and optionally `CLAWTASKS_CREDENTIALS_JOBMASTER2_JSON`, `CLAWTASKS_CREDENTIALS_JOBMASTER3_JSON`). Or add the single **`RAILWAY_CLAWTASKS_CREDENTIALS`** line (base64 of all credentials in one object).

3. **Redeploy.** On startup the server writes those credentials into the volume (under `.openclaw/`) if the files don't already exist. After that, dashboard, Completed work, run-cycle, and all APIs use the same data as local — 100%.

4. **Volume:** Ensure a volume is attached (Railway injects **`RAILWAY_VOLUME_MOUNT_PATH`**). The app uses it automatically; no need to set `OPENCLAW_STATE_DIR` or `OPENCLAW_WORKSPACE_DIR` unless you override.

## After deploy

- **Landing:** `https://espeerabot.up.railway.app/`
- **Hub (all links):** `https://espeerabot.up.railway.app/hub`
- **Dashboard:** `https://espeerabot.up.railway.app/admin/dashboard`
- **Brain:** `https://espeerabot.up.railway.app/admin/brain`

If the index still shows the wrong content (e.g. memorial page), Railway is likely still running an old start command (e.g. `npx serve .`). Set the start command to `node sentinel-nexus/admin/server.js` in the Railway dashboard (or rely on `railway.json` and redeploy).

## Memorial static site (optional)

To run the **memorial** static site locally: `npm run start:site` or `npx serve .`. Do not use this as the Railway start command if you want the agency on espeerabot.
