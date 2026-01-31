# Railway: UI not opening / "Application Error"

Your deploy at **espeerabot.up.railway.app** shows the **wrapper** listening on :8080 and state at `/data/.clawdbot`, but the link returns an application error. Below is what to check.

---

## 1. Use the correct URLs

- **Setup wizard:** `https://espeerabot.up.railway.app/setup`
- **Control UI (after setup):** `https://espeerabot.up.railway.app/openclaw`
- **Root:** `https://espeerabot.up.railway.app/` (may redirect or show a simple page)

Use **https** and the full domain. If you only opened the root, try **/setup** first.

---

## 2. Check Railway settings

| Setting | What to do |
|--------|------------|
| **HTTP Proxy** | Railway → your service → **Settings** → **Networking**. Enable **Public Networking** and set the **port to 8080** (same as the wrapper). |
| **PORT** | In **Variables**, set `PORT=8080` so the app listens on the port Railway uses. |
| **SETUP_PASSWORD** | Required. Set it in **Variables** (e.g. a strong password you’ll use to open /setup). |
| **Volume** | Volume must be mounted at **/data**. Without it, state is lost and the app can misbehave. |

---

## 3. Check deploy logs (gateway process)

The logs you shared show only the **wrapper**:

- `[wrapper] listening on :8080`
- `[wrapper] gateway target: http://127.0.0.1:18789`

The **gateway** (OpenClaw/Clawdbot) is supposed to run on 127.0.0.1:18789 and the wrapper proxies to it. If the gateway never starts or crashes, you get “application error” when opening the UI.

In Railway:

1. Open your service → **Deployments** → latest deploy → **View Logs**.
2. Scroll **past** the wrapper lines. Look for:
   - Lines about the **gateway** starting (e.g. “gateway listening”, “18789”, or similar).
   - Any **error** or **crash** (e.g. missing config, missing env, port in use, Node error).

If you only see the wrapper and then nothing, or an error, the gateway likely isn’t running. Common causes:

- **First deploy:** Some templates expect the gateway to start even with minimal config; others may expect setup first. Check the template’s README or docs.
- **Missing env:** e.g. `SETUP_PASSWORD` or other required variables not set.
- **State dir:** Template uses `/data/.clawdbot`. If the volume isn’t mounted at `/data`, the process can fail.

---

## 4. Redeploy after fixing

After changing **Variables** or **Networking** (e.g. PORT, SETUP_PASSWORD, HTTP proxy port):

1. Save.
2. Trigger a **redeploy** (e.g. **Deployments** → **Redeploy** or push a small change if connected to Git).
3. Wait 1–2 minutes, then try again:
   - `https://espeerabot.up.railway.app/setup`

---

## 5. If it still fails

- Copy the **full deploy log** (especially any line after the wrapper and any stack trace or “Error:”) and use it in Railway’s [Help Station](https://help.railway.app) or the template’s repo (e.g. Clawdbot/OpenClaw Railway template on GitHub).
- Confirm the **template** (e.g. `clawdbot-railway-template`) and its **docs** for:
  - Required variables.
  - Correct port (8080) and HTTP proxy.
  - Any “first run” or “setup” steps that affect startup.

---

## Quick checklist

- [ ] Open **https://espeerabot.up.railway.app/setup** (with https and /setup).
- [ ] **Variables:** `PORT=8080`, `SETUP_PASSWORD` set.
- [ ] **Networking:** Public HTTP proxy enabled, port **8080**.
- [ ] **Volume:** mounted at **/data**.
- [ ] **Logs:** Check for gateway startup or errors after the wrapper lines; fix or report those.
