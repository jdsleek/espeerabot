# Jobmaster Agency — Admin Dashboard

Local dashboard for the full agency: agents (Jobmaster 1–3+), tasks, cron jobs, and realtime activity.

## Run

From the **eggy** project root:

```bash
node sentinel-nexus/admin/server.js
```

Or with npm (if configured):

```bash
npm run sentinel-admin
```

Then open in your browser:

- **Dashboard:** http://127.0.0.1:3880
- **Workers (display view):** http://127.0.0.1:3880/workers
- **APIs:** /api/agency  /api/workers  /api/stats  POST /api/claim-instant  POST /api/submit-pending

## What it shows

- **Agency overview** — Total agents, total earned USDC, bounties posted, pending (claimed), completed (all time). **Complete 2 tasks now** submits deliverables for up to 2 pending bounties (no gateway needed). Links to ClawTasks dashboard, bounties, workers.
- **Agents (Jobmaster 1–3+)** — Per-agent: name, earned, posted, completed, wallet (truncated). Add more agents in `sentinel-nexus/agency-agents.json`.
- **Cron jobs** — Name, last status (ok/error), last run time.
- **Latest cron results** — Last line from ClawTasks and Moltbook cron result files.
- **Activity (realtime)** — Current activity from cron results; refreshes every 15s.

**Workers page** (`/workers`) — Presentable view of all agents and what they're working on (current bounties, status). Use for display or sharing. Refreshes every 30s.

## Port

Default: **3880**. Override:

```bash
ADMIN_PORT=3999 node sentinel-nexus/admin/server.js
```

## Adding more agents (Jobmaster 2, 3)

1. Register a new ClawTasks agent (new wallet, new name): e.g. duplicate `register-jobmaster-bot.js` logic for "jobmaster2", save to `~/.openclaw/clawtasks-credentials-jobmaster2.json`.
2. Add to `sentinel-nexus/agency-agents.json`:

```json
{
  "agents": [
    { "id": "jobmaster", "name": "jobmaster", "credentialsFile": "clawtasks-credentials.json", "enabled": true },
    { "id": "jobmaster2", "name": "jobmaster2", "credentialsFile": "clawtasks-credentials-jobmaster2.json", "enabled": true }
  ]
}
```

3. Restart the admin server; the dashboard will show the new agent. Configure cron to run the agency flow for each credential file (see AGENCY_BUSINESS_PLAN.md).
