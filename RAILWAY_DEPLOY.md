# Deploy to Railway — Run Independently 24/7

Deploy the Jobmaster Agency so it runs on Railway without your local machine. Agents claim, submit, and engage automatically.

---

## 1. One-Time Setup

### A. Connect Repo to Railway

1. Go to [railway.app](https://railway.app) → New Project → Deploy from GitHub.
2. Connect this repo (e.g. `jdsleek/espeerabot` or your fork), branch `main`.
3. Railway will use `railway.json` → start command: `node sentinel-nexus/admin/server.js`.

### B. Add Volume

1. In your project → **+ New** → **Volume**.
2. Mount path: **`/data`**.
3. Railway injects **`RAILWAY_VOLUME_MOUNT_PATH`** automatically. The server uses it for workspace and credentials.

### C. Add Variables

1. Project → **Variables** → Add:

| Variable | Value | Required |
|----------|-------|----------|
| `OPENCLAW_WORKSPACE_DIR` | `/data/workspace` | Yes (with volume) |
| `OPENCLAW_STATE_DIR` | `/data/.openclaw` | Yes (with volume) |
| `RUN_AUTONOMOUS_CYCLE_MIN` | `20` | Optional (default 20) |
| `RUN_MOLTBOOK_ENGAGE_MIN` | `20` | Optional (Moltbook upvote every 20 min) |

### D. Add Credentials

Run locally (where you have `~/.openclaw/`):

```bash
./sentinel-nexus/export-credentials-for-railway.sh
```

Copy each line and add as Railway Variables (e.g. `CLAWTASKS_CREDENTIALS_JSON=...`, `MOLTBOOK_CREDENTIALS_JSON=...`). Or use the bulk `RAILWAY_CLAWTASKS_CREDENTIALS` line.

On first deploy, the server writes these to the volume under `/data/.openclaw/`.

### E. Public Domain

1. Project → **Settings** → **Networking** → **Generate Domain**.
2. You get a URL like `espeerabot.up.railway.app`.

---

## 2. What Runs on Railway

| Task | When |
|------|------|
| **Claim** | Every 20 min (instant bounties) |
| **Submit** | Every 20 min (up to 2 pending per agent) |
| **Approve** | Every 20 min (our bounties) |
| **Moltbook upvote** | Every 20 min (if credentials set) |

All agents (jobmaster, jobmaster2, jobmaster3) run in parallel. No OpenClaw gateway needed on Railway—the server does everything via ClawTasks and Moltbook APIs.

---

## 3. After Deploy

- **Landing:** `https://<your-domain>/`
- **Dashboard:** `https://<your-domain>/admin/dashboard`
- **Hub:** `https://<your-domain>/hub`

The dashboard shows Live activity, agents, and Run cycle. The cycle runs automatically every 20 min.

---

## 4. Optional: OpenClaw on Same Domain

If you want the OpenClaw Control UI on the same domain:

1. Deploy **OpenClaw** separately from [clawdbot-railway-template](https://railway.com/deploy/clawdbot-railway-template).
2. In this project, add variable: **`OPENCLAW_GATEWAY_URL`** = your OpenClaw URL (e.g. `https://clawdbot-xyz.up.railway.app`).
3. Redeploy. Then `/setup` and `/openclaw` on this domain proxy to OpenClaw.

---

## 5. Quick Deploy (Already Set Up)

If the repo is already connected to Railway:

1. **Volume** — Add if missing; mount `/data`.
2. **Variables** — Set `OPENCLAW_WORKSPACE_DIR`, `OPENCLAW_STATE_DIR`, credentials.
3. **Deploy** — Push to `main` or click Redeploy in Railway.

```bash
git add .
git commit -m "Deploy to Railway"
git push origin main
```

Railway auto-deploys on push. Check logs for `Autonomous cycle every 20 min (Railway).`
