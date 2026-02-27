# OpenClaw on Railway — setup for automation

The espeerabot service now runs the **OpenClaw gateway in-process**. You get:

- **Control UI** at `https://espeerabot.up.railway.app/openclaw?token=YOUR_TOKEN`
- **Brain cron** every 5 min (claim, submit, Moltbook HEARTBEAT)
- **Existing automation** (autonomous cycle, Moltbook engage, Nexus Chapel)

## Quick setup

### Option A: Use your existing openclaw.json (recommended)

1. Run locally:
   ```bash
   ./sentinel-nexus/export-credentials-for-railway.sh
   ```

2. Copy the `OPENCLAW_CONFIG_JSON=...` line from the output.

3. In Railway → **clawdbot-railway-template** (espeerabot) → Variables, add:
   - `OPENCLAW_CONFIG_JSON` = the base64 value from step 2

4. Redeploy the service.

5. Open **https://espeerabot.up.railway.app/openclaw?token=YOUR_GATEWAY_TOKEN**  
   (Token is in your local `~/.openclaw/openclaw.json` → `gateway.auth.token`)

### Option B: Token + API key only

1. Generate a token:
   ```bash
   openssl rand -hex 24
   ```

2. In Railway → Variables, add:
   - `OPENCLAW_GATEWAY_TOKEN` = the token from step 1
   - `GROQ_API_KEY` = your Groq key (from [console.groq.com](https://console.groq.com))  
     Or `MOONSHOT_API_KEY` / `NVIDIA_API_KEY` instead.

3. Redeploy.

4. Open **https://espeerabot.up.railway.app/openclaw?token=YOUR_TOKEN**

## Set variables via CLI

```bash
source .env
export RAILWAY_TOKEN
ENV_ID=bb39f067-0b69-4262-b991-bba60dc90c2d
SVC_ID=2f159caa-5013-425b-b716-86b06b5aacac   # clawdbot-railway-template

# From export output:
railway variables --environment "$ENV_ID" --service "$SVC_ID" \
  --set "OPENCLAW_CONFIG_JSON=<paste-base64>" \
  --skip-deploys
```

Then redeploy from the Railway dashboard.

## Troubleshooting

- **"Disconnected from gateway"** — Add `OPENCLAW_CONFIG_JSON` or `OPENCLAW_GATEWAY_TOKEN` + `GROQ_API_KEY`, redeploy. Use the token in the URL: `?token=YOUR_TOKEN`.
- **"pairing required" (1008)** — The config must have `gateway.trustedProxies: ["127.0.0.1"]`. Option A includes this; Option B generates it.
- **No chat replies** — Ensure `GROQ_API_KEY` (or another API key) is set. The brain and chat need it.
