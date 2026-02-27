# Railway status (checked)

## Verified right now

| Service | URL | Reachable? | Notes |
|---------|-----|------------|--------|
| **clawdbot-railway-template** | https://espeerabot.up.railway.app | **Yes** | Landing, /hub, /api/stats return 200. Logs show server up, credentials written, autonomous cycle + Moltbook running. |
| **scrapper** | https://scrapper-production-3674.up.railway.app | **No (404)** | Root and /api/health return 404. Deploys from **jdsleek/scrapper** (different repo) – fix in that repo or check its start command / routes. |
| **clawdbot-railway-template-sPBe** | https://clawdbot-railway-template-spbe-production.up.railway.app | **Yes** | Page loads but shows "Disconnected from gateway". UI needs a running OpenClaw gateway; this app only serves the frontend. |

So **one of the three** (Jobmaster at espeerabot) is up. If you see "none working", try: (1) open https://espeerabot.up.railway.app in an incognito window or another device; (2) Railway dashboard → each service → Deployments → confirm latest is SUCCESS and view logs for crashes.

## Variables and .env

- **Variables** are set on all 3 services (production env `bb39f067`): OPENCLAW_*, RUN_*_MIN, CLAWTASKS_*_JSON, MOLTBOOK_CREDENTIALS_JSON.
- **RAILWAY_ENVIRONMENT_ID** in `.env` is set to production `bb39f067...` (was wrong before).


## How to fix each service

- **espeerabot:** Verified up. If you get no response, try another browser/network or Redeploy from Railway dashboard.
- **scrapper:** 404 – deploys from **jdsleek/scrapper**. Fix in that repo (listen on PORT, expose `/` or health route), then redeploy.
- **OpenClaw Control (sPBe):** "Disconnected from gateway" – the UI needs a gateway. Use espeerabot for Jobmaster, or run `./sentinel-nexus/run-agency-24-7.sh` locally for gateway + UI.

## If things still don’t work

1. **Redeploy**  
   Railway → project → each service → Deployments → Redeploy (or push a commit). Variables are already set; redeploy picks them up.

2. **OpenClaw Control “Disconnected from gateway”**  
   The Control UI needs a running **OpenClaw gateway**. `server.js` does not run the gateway; it only **proxies** to `OPENCLAW_GATEWAY_URL` when set. So either:
   - Run the gateway elsewhere and set **OPENCLAW_GATEWAY_URL** on the service that serves the Control UI (or the one that proxies) to that URL, or  
   - Run the full stack locally with `./sentinel-nexus/run-agency-24-7.sh` (gateway + dashboard).

3. **Credentials at runtime**  
   `server.js` writes credentials from env (base64) into `OPENCLAW_STATE_DIR` on startup. On Railway, use a **volume** for that path so they persist across redeploys; otherwise they’re recreated from env each time (OK if vars are set).

4. **Check logs**  
   Railway → service → Deployments → latest → View logs. Look for `[Railway] Wrote credentials from env:` and any startup errors.

## Quick re-apply variables (CLI)

From repo root with `.env` loaded:

```bash
source .env
export RAILWAY_TOKEN
ENV_ID=bb39f067-0b69-4262-b991-bba60dc90c2d
# Then run the variable --set block from set-railway-variables.sh or use:
./sentinel-nexus/export-credentials-for-railway.sh   # paste into Railway Variables if CLI is flaky
```

Then redeploy each service from the Railway dashboard.
