# Deploy Sentinel/OpenClaw to Railway

## Security — important

**Do not share Railway (or any) API tokens in chat or commit them to the repo.** If you already shared a token, **revoke it** in Railway (Dashboard → Account/Team → Tokens) and create a new one. Use the new token only in your environment (e.g. `export RAILWAY_TOKEN=...`) or in Railway’s dashboard, never in code or chat.

---

## Option A: One-click deploy (no token in terminal)

1. Open: **https://railway.com/deploy/clawdbot-railway-template** (or search “OpenClaw” in Railway templates).
2. Log in or sign up with Railway (GitHub, etc.).
3. Railway creates a project from the template. In the dashboard:
   - **Volume:** Add a volume, mount path **`/data`**.
   - **Variables:** Add at least **`SETUP_PASSWORD`** (your wizard password). Recommended: `PORT=8080`, `OPENCLAW_STATE_DIR=/data/.openclaw`, `OPENCLAW_WORKSPACE_DIR=/data/workspace`.
   - **Settings → Networking:** Enable **HTTP Proxy**, port **8080**.
4. Copy your public URL (Settings → Domains).
5. Open **`https://<your-url>/setup`** → enter SETUP_PASSWORD → add model + API key → Run setup.
6. Chat at **`https://<your-url>/openclaw`**.

No token needed in chat or scripts.

---

## Option B: Create project with Railway CLI (token only on your machine)

Use this only if you want to create the project from the CLI. **Use a new token** (revoke any you shared).

1. **Install Railway CLI:** https://docs.railway.app/guides/cli  
   e.g. `npm i -g @railway/cli` or `brew install railway`.

2. **Log in with your token (only in your terminal, never commit):**
   ```bash
   export RAILWAY_TOKEN=your_new_token_here
   railway login --browser
   ```
   Or use token auth: https://docs.railway.app/develop/cli#login

3. **Create project from template:**
   - In browser: https://railway.com/new → “Deploy from template” → search “OpenClaw” or “Clawdbot” → use that template.
   - Or via API if your token has project-creation scope: see Railway docs for template deploy.

4. **Configure** (Volume `/data`, variables, HTTP proxy on 8080) in the Railway dashboard as in Option A.

5. **Finish setup** at `https://<your-url>/setup` as in Option A.

---

## After deploy

- **Setup wizard:** `https://<your-railway-url>/setup`
- **Control UI (chat):** `https://<your-railway-url>/openclaw`
- **Backup:** `https://<your-railway-url>/setup/export`

See **DEPLOY_AND_ENGAGEMENT_PLAN.md** for niche + cron + Moltbook setup.
