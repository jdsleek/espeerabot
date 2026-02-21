# Deploy to Railway — Run Independently 24/7

Deploy the Jobmaster Agency so it runs on **Railway** instead of your PC. Hub, Dashboard, and Landing work at **your Railway URL**; claim, submit, Moltbook, and Nexus Chapel run automatically **even when your PC is off**.

---

## Run everything on Railway (PC off)

| Local (127.0.0.1:3880) | On Railway (same app) |
|------------------------|------------------------|
| http://127.0.0.1:3880/ | **https://\<your-app\>.up.railway.app/** |
| http://127.0.0.1:3880/hub | **https://\<your-app\>.up.railway.app/hub** |
| http://127.0.0.1:3880/admin/dashboard | **https://\<your-app\>.up.railway.app/admin/dashboard** |

**One-time setup:** Connect repo → add Volume (`/data`) → add Variables (below) → add credentials from `export-credentials-for-railway.sh` → **Generate Domain** in Settings → Networking. After that, every push to `main` auto-deploys.

---

## 1. One-Time Setup

### A. Connect Repo to Railway

1. Go to [railway.app](https://railway.app) → New Project → Deploy from GitHub.
2. Connect **jdsleek/espeerabot** (or your fork), branch **main**.
3. Railway uses `railway.json` and `nixpacks.toml` → start: `node sentinel-nexus/admin/server.js`. Health check: **`/health`** (returns 200).

### B. Add Volume

1. In your project → **+ New** → **Volume**.
2. Mount path: **`/data`**.
3. Railway injects **`RAILWAY_VOLUME_MOUNT_PATH`** automatically. The server uses it for workspace and credentials.

### C. Add Variables

1. Project → **Variables** → Add:

| Variable | Value | Required |
|----------|-------|----------|
| `OPENCLAW_WORKSPACE_DIR` | `/data/workspace` | Recommended (or app defaults to `/data` when PORT is set) |
| `OPENCLAW_STATE_DIR` | `/data/.openclaw` | Recommended (or app defaults to `/data/.openclaw` on Railway) |
| `RUN_AUTONOMOUS_CYCLE_MIN` | `20` | Optional (default 20) |
| `RUN_MOLTBOOK_ENGAGE_MIN` | `20` | Optional (Moltbook upvote every 20 min) |
| `RUN_NEXUS_CHAPEL_POST_MIN` | `720` | Optional (Nexus Chapel prayer/reflection every 12h; 0 = off) |

### D. Add Credentials

**Option 1 — Use token (set variables via API, no copy-paste):**

1. In Railway: Project → **Settings** → **Tokens** → **Create Token** (Project Token). Copy the token.
2. Run locally (where you have `~/.openclaw/` and credentials):

```bash
RAILWAY_TOKEN=<your-project-token> ./sentinel-nexus/set-railway-variables.sh
```

The script pushes all required variables (paths, cycle intervals, and credentials from `~/.openclaw/`) to Railway. If you have multiple projects, set `RAILWAY_PROJECT_ID` and `RAILWAY_ENVIRONMENT_ID` (from Project → Settings and Environments).

**Option 2 — Paste in dashboard:**

Run locally (where you have `~/.openclaw/`):

```bash
./sentinel-nexus/export-credentials-for-railway.sh
```

Copy each line and add as Railway Variables (e.g. `CLAWTASKS_CREDENTIALS_JSON=...`, `MOLTBOOK_CREDENTIALS_JSON=...`, `NEXUS_CHAPEL_CREDENTIALS_JSON=...`). Or use the bulk `RAILWAY_CLAWTASKS_CREDENTIALS` line.

**Moltbook:** Use credentials for **Sentinel_Nexus** only (one identity; see `sentinel-nexus/MOLTBOOK_LEARNINGS.md`).

**Nexus Chapel:** Add `nexus-chapel-credentials.json` with Moltbook API key for agent **Nexus_Chapel** (create/claim on Moltbook first). Set `RUN_NEXUS_CHAPEL_POST_MIN=720` to post 1–2 prayers/day.

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
| **Nexus Chapel post** | Every 12 h (if credentials + `RUN_NEXUS_CHAPEL_POST_MIN=720`) |

All agents (jobmaster, jobmaster2, jobmaster3) run in parallel. Moltbook and Nexus Chapel run when their credentials are present. No OpenClaw gateway needed on Railway—the server does everything via ClawTasks and Moltbook APIs.

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

---

## 6. Checklist: “All on Railway, PC off”

- [ ] Railway project created and **jdsleek/espeerabot** (or your fork) connected, branch **main**.
- [ ] **Volume** added, mount path **`/data`**.
- [ ] **Variables** set: `OPENCLAW_WORKSPACE_DIR=/data/workspace`, `OPENCLAW_STATE_DIR=/data/.openclaw`, and optionally `RUN_AUTONOMOUS_CYCLE_MIN=20`, `RUN_MOLTBOOK_ENGAGE_MIN=20`, `RUN_NEXUS_CHAPEL_POST_MIN=720`.
- [ ] **Credentials** added (run `./sentinel-nexus/export-credentials-for-railway.sh` and paste each line into Railway Variables): ClawTasks (lead + jobmaster2/3), Moltbook (Sentinel_Nexus), and Nexus Chapel if you use it.
- [ ] **Public domain** generated: Project → **Settings** → **Networking** → **Generate Domain** (e.g. `espeerabot.up.railway.app`).
- [ ] Redeploy once (or push to `main`) so the server writes credentials to the volume and starts the cycle.

When all are done, open **https://\<your-domain\>/hub** — same Hub, Dashboard, and Landing as local, but they run 24/7 on Railway. You can stop running `run-agency-24-7.sh` on your PC.
