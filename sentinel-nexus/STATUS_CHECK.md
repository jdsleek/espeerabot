# Sentinel_Nexus — Status check

**Current setup and how to verify**

**Automatic runs:** Heartbeat is **disabled** (`every: "0m"`). Use **cron (isolated)** with the **official Moltbook flow** (fetch server heartbeat every 4h). Run once: `./sentinel-nexus/enable-auto-moltbook.sh` (gateway must be running). See [MOLTBOOK_WHAT_AGENTS_DO.md](MOLTBOOK_WHAT_AGENTS_DO.md) for what other agents do and why server-driven is the norm.

---

## Stats (from last known state)

| Source | Value |
|--------|--------|
| **heartbeat-state.json** | lastMoltbookCheck: 2026-01-31T13:08:02Z, lastPostAt: 2026-01-31T12:28:00Z |
| **Moltbook (from state)** | 9 karma, 2 posts, 1 follower, 0 comments on both posts |
| **Gateway** | Running (LaunchAgent, port 18789) |
| **Model** | Groq `groq/llama-3.3-70b-versatile` (128k context, compaction enabled) |

The agent **has run successfully**: state and `memory/sentinel-learnings.md` were updated (e.g. 13:08 UTC) with Moltbook intel (Shellraiser, skill.md supply chain, etc.).

---

## Config summary

- **Model:** `groq/llama-3.3-70b-versatile` (Groq API, not OpenRouter).
- **Auth:** `GROQ_API_KEY` in `openclaw.json` env.
- **Heartbeats:** **Disabled** (`every: "0m"`) — use cron instead for reliable auto runs.
- **Auto runs:** Add cron job with `./sentinel-nexus/enable-auto-moltbook.sh` (once, gateway running).

---

## Manual run (one-off)

Trigger one run now (e.g. to test):

```bash
openclaw system event --text "Read HEARTBEAT.md from your workspace and follow it strictly. Check Moltbook using your API key from ~/.openclaw/moltbook-credentials.json. If you do something on Moltbook, say what you did; otherwise reply HEARTBEAT_OK." --mode now
```

**Automatic runs:** Add the cron job once so the agent runs every 4h (official Moltbook cadence): `./sentinel-nexus/enable-auto-moltbook.sh`.

---

## Verify persistence

After a run:

1. **State:** `~/.openclaw/workspace/memory/heartbeat-state.json` — `lastMoltbookCheck`, `lastPostAt`, counts.
2. **Learnings:** `~/.openclaw/workspace/memory/sentinel-learnings.md` — intel bullets per day.
3. **One-liner:** `OPENCLAW_WORKSPACE=~/.openclaw/workspace ./sentinel-nexus/check-sentinel-status.sh`

---

## Admin dashboard

- **URL:** http://127.0.0.1:3880 (run `npm run sentinel-admin` from repo root).
- Shows live Moltbook stats and OpenClaw state.

---

## Summary

| Item | Status |
|------|--------|
| Gateway | ✅ Running |
| Heartbeat | ⏸ Disabled (0m) — use cron for auto |
| Cron (Moltbook) | ⬜ Add once: `./sentinel-nexus/enable-auto-moltbook.sh` (every 4h, official server heartbeat) |
| Moltbook skill | ✅ Enabled |
| Model (Groq) | ✅ groq/llama-3.3-70b-versatile |
| Agent activity | ✅ Runs have completed; state and learnings updated |

**Next:** Run `./sentinel-nexus/enable-auto-moltbook.sh` once (with gateway running) so the agent runs every 4h with the official server heartbeat. See [MOLTBOOK_WHAT_AGENTS_DO.md](MOLTBOOK_WHAT_AGENTS_DO.md).

**Is the API working?** Run `./sentinel-nexus/test-llm-api.sh` to call the Groq API once and verify the key. See [AGENT_AND_API_STATUS.md](AGENT_AND_API_STATUS.md) for agent vs manual and API status.
