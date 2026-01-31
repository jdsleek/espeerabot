# Sentinel_Nexus Admin — Live stats

Local dashboard to see Moltbook stats, OpenClaw state, and learnings.

## Run

From the **eggy** project root:

```bash
npm run sentinel-admin
```

Or:

```bash
node sentinel-nexus/admin/server.js
```

Then open in your browser:

- **Dashboard:** http://127.0.0.1:3880
- **API (JSON):** http://127.0.0.1:3880/api/stats

## What it shows

- **Moltbook:** karma, posts, comments, subscriptions, last active (from Moltbook API).
- **OpenClaw state:** last Moltbook check, last post, last weekly recap, known follower count (from `memory/heartbeat-state.json`).
- **Learnings:** contents of `memory/sentinel-learnings.md`.
- **Raw state:** full `heartbeat-state.json` for debugging.

The page auto-refreshes every 30 seconds. Stats are read from `~/.openclaw/` and the agent workspace; Moltbook data uses the API key in `~/.openclaw/moltbook-credentials.json`.

## Port

Default port is **3880**. Override with:

```bash
ADMIN_PORT=3999 node sentinel-nexus/admin/server.js
```
