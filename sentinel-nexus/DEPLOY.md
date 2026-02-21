# Deploy OpenClaw to Railway

Deploy the same agent so it’s reachable at a public URL. Use a **token in the URL** so only you can open the UI.

---

## OpenClaw on Railway — checklist (done right)

Use this when deploying the **OpenClaw gateway** (control UI + chat) via Railway so it runs and connects properly.

| Step | What to do |
|------|------------|
| 1. Template | Deploy from **https://railway.com/deploy/clawdbot-railway-template** (or search "OpenClaw" in Railway templates). This is a **separate** deploy from the espeerabot repo. |
| 2. Volume | Add a **volume**, mount path **`/data`**. Required for config and workspace to persist. |
| 3. Variables | **`SETUP_PASSWORD`** (required). **`PORT=8080`** (must match proxy). **`OPENCLAW_STATE_DIR=/data/.openclaw`**, **`OPENCLAW_WORKSPACE_DIR=/data/workspace`**. |
| 4. Networking | Enable **HTTP Proxy**, port **8080** (same as `PORT`). Add a public domain (e.g. espeerabot.up.railway.app if this is the OpenClaw service). |
| 5. Setup | Open **`https://<your-url>/setup`** → enter SETUP_PASSWORD → add Groq + **GROQ_API_KEY** → Run setup. |
| 6. Token | Get **gateway token** from setup export or `/data/.openclaw/openclaw.json` → `gateway.auth.token`. |
| 7. trustedProxies | In `/data/.openclaw/openclaw.json` (or via Setup → Export, edit, Restore), under `gateway` add: **`"trustedProxies": ["127.0.0.1"]`**. Then redeploy. Without this, the UI may show "pairing required" (1008). |
| 8. Control UI | Open **`https://<your-url>/openclaw?token=YOUR_GATEWAY_TOKEN`**. Bookmark this; path must be `/openclaw`, not `/` or `/control`. |

**Quick reference:** See `sentinel-nexus/railway-gateway-trustedProxies-snippet.json` for the JSON to merge into gateway config. For **pairing fix + Kimi 2.5** (Groq/Moonshot/NVIDIA) in one step, use `sentinel-nexus/railway-openclaw-kimi25-trustedproxies.json`: paste into Setup → Config editor → Save, set the matching API key in Railway Variables, then run **Debug console** → `gateway.restart`. Launcher: copy `openclaw-railway-launch.example.html` to `openclaw-railway-launch.html`, set `RAILWAY_APP_URL` and `GATEWAY_TOKEN`, open in browser.

---

## Use OpenClaw from the other project on the same domain (espeerabot)

If you deployed OpenClaw to a **separate** Railway project (e.g. `openclaw-xyz.up.railway.app`), you can still use it from your **main** domain (espeerabot) so everything is in one place:

1. In the **espeerabot** Railway service (this repo), add a variable:
   - **`OPENCLAW_GATEWAY_URL`** = the full URL of your OpenClaw project, e.g. **`https://openclaw-xyz.up.railway.app`** (no trailing slash).

2. Redeploy the espeerabot service.

3. The agency server will **proxy** `/setup` and `/openclaw` (and WebSockets) to that URL. So you can use:
   - **`https://espeerabot.up.railway.app/setup`** → setup wizard (on the other project)
   - **`https://espeerabot.up.railway.app/openclaw?token=YOUR_TOKEN`** → Control UI (same domain, same service as your dashboard and files).

One domain, one place: dashboard, Completed, APIs, and OpenClaw setup/UI all from espeerabot.

---

## Security

**Do not share Railway API tokens or your gateway token in chat or commit them.** Revoke any you’ve shared and create new ones. Use tokens only in Railway Variables or in your environment.

---

## One-click deploy

1. Open **https://railway.com/deploy/clawdbot-railway-template** (or search “OpenClaw” in Railway templates).
2. Log in / sign up with Railway.
3. In the project:
   - **Volume:** Add a volume, mount path **`/data`**.
   - **Variables:** At least **`SETUP_PASSWORD`**. Recommended: `PORT=8080`, `OPENCLAW_STATE_DIR=/data/.openclaw`, `OPENCLAW_WORKSPACE_DIR=/data/workspace`.
   - **Networking:** Enable **HTTP Proxy**, port **8080**.
4. Deploy. Copy your public URL (Settings → Domains).
5. Open **`https://<your-url>/setup`** → enter SETUP_PASSWORD → add **Groq** model + **GROQ_API_KEY** → Run setup.
6. Get your **gateway token** from the setup export or from the config on the volume (`/data/.openclaw/openclaw.json` → `gateway.auth.token`). Then open the UI with the token in the URL:
   - **`https://<your-url>/openclaw?token=YOUR_GATEWAY_TOKEN`**
   Use that bookmark so the UI connects; without the token you’ll get “token_missing”.

---

## If the Control UI is not connecting

1. **Exact URL:** `https://<your-railway-domain>/openclaw?token=<your-token>`. Path must be **`/openclaw`** (not `/` or `/control`). Example: `https://espeerabot.up.railway.app/openclaw?token=YOUR_TOKEN`.
2. **Token must match server:** Token in URL must equal gateway token on Railway. Set **Railway Variables:** `OPENCLAW_GATEWAY_TOKEN=<your-token>`. Same as `/data/.openclaw/openclaw.json` → `gateway.auth.token`.
3. **Railway:** HTTP Proxy port **8080**; variable `PORT=8080`; `SETUP_PASSWORD` set.
4. **App up?** Open `https://<your-domain>/setup`. If it doesn't load, check Railway logs and Domains.
5. **Browser:** Hard refresh or incognito. "token_missing" or WebSocket fail = wrong or missing token in URL.

6. **"disconnected (1008): pairing required"** — Railway’s proxy sends headers from `127.0.0.1`, so the gateway doesn’t trust the connection and requires device pairing. Add **trustedProxies** so token auth works:
   - In the config on the server (e.g. `/data/.openclaw/openclaw.json` or `/data/.clawdbot/...`), under `gateway` add: `"trustedProxies": ["127.0.0.1"]`.
   - Then restart/redeploy the service. Example gateway block:
     `"gateway": { "auth": { ... }, "controlUi": { "allowInsecureAuth": true }, "trustedProxies": ["127.0.0.1"], ... }`
   - If you use the setup wizard, try **Setup → Export** (backup), edit the JSON to add `gateway.trustedProxies`, then restore or merge that config into the volume and redeploy.

**Launcher:** Copy `openclaw-railway-launch.example.html` to `openclaw-railway-launch.html`, set `RAILWAY_APP_URL` and `GATEWAY_TOKEN`, open in browser. (Launcher is gitignored when you add token.)

---

## After deploy

- **Setup / backup:** `https://<your-url>/setup`
- **Control UI (with token):** `https://<your-url>/openclaw?token=YOUR_GATEWAY_TOKEN`
- **Chat:** Same URL, then open the Chat tab. Prefer a new session or type `/new` if replies don’t show.

Copy your workspace files (SOUL.md, AGENTS.md, etc.) into the deployed workspace if the template doesn’t include them (e.g. via setup or volume).
