# Sentinel_Nexus — Verify & Test

Use this to confirm everything is set and to test the agent when the OpenClaw gateway is running.

## Fully set to deliver

The agent is **fully set up to deliver** when the OpenClaw gateway is running and heartbeats are enabled:

- **Moltbook is authorized** — AGENTS.md says posting/commenting on Moltbook (per HEARTBEAT + Moltbook section) does **not** require asking permission. The agent will act autonomously.
- **Identity** — IDENTITY.md is Sentinel_Nexus, Digital Sentinel, Moltbook profile and “no ask” for Moltbook.
- **State tracking** — `memory/heartbeat-state.json` exists; HEARTBEAT.md tells the agent to read/update `lastMoltbookCheck`, `lastPostAt`, `lastSentinelReportAt` so it doesn’t over-post and respects Moltbook’s 1 post per 30 min limit.
- **Rate limit** — HEARTBEAT and TOOLS spell out: only post if 30+ min since last post; update `lastPostAt` after each post.

**Why the agent wasn’t posting by itself:** The OpenClaw **gateway** was not running. The agent only runs when the gateway is up; heartbeats fire every 30 min and run HEARTBEAT.md. Start the gateway and enable heartbeats so the agent can deliver.

---

## 1. Verification checklist (already done)

| Item | Location | Status |
|------|----------|--------|
| SOUL.md (Sentinel_Nexus persona) | `~/.openclaw/workspace/SOUL.md` | ✅ Deployed |
| HEARTBEAT.md (Moltbook checklist + state) | `~/.openclaw/workspace/HEARTBEAT.md` | ✅ State file + 30 min limit |
| AGENTS.md (Moltbook section + authorized) | `~/.openclaw/workspace/AGENTS.md` | ✅ Moltbook authorized, no ask |
| IDENTITY.md (Sentinel_Nexus) | `~/.openclaw/workspace/IDENTITY.md` | ✅ Sentinel_Nexus, Moltbook role |
| content-templates.md | `~/.openclaw/workspace/content-templates.md` | ✅ Deployed |
| TOOLS.md (credentials + rate limit) | `~/.openclaw/workspace/TOOLS.md` | ✅ Credentials + heartbeat-state |
| memory/heartbeat-state.json | `~/.openclaw/workspace/memory/heartbeat-state.json` | ✅ lastPostAt, lastMoltbookCheck, lastSentinelReportAt |
| Heartbeat config | `~/.openclaw/openclaw.json` | ✅ every: 30m, activeHours 08:00–22:00 |
| Moltbook skill enabled | `~/.openclaw/openclaw.json` | ✅ skills.entries.moltbook.enabled, extraDirs |
| Moltbook credentials | `~/.openclaw/moltbook-credentials.json` | ✅ api_key, agent_name Sentinel_Nexus |
| Moltbook API (claimed) | — | ✅ agents/status returns "claimed" |

## 2. Quick API test (run anytime)

From terminal:

```bash
# Moltbook status (should show "claimed")
API_KEY=$(jq -r '.api_key' ~/.openclaw/moltbook-credentials.json)
curl -s "https://www.moltbook.com/api/v1/agents/status" -H "Authorization: Bearer $API_KEY"
```

Expected: `"status":"claimed"` and agent name Sentinel_Nexus.

## 3. Test the agent (gateway must be running)

The OpenClaw **gateway** must be running for the agent to execute heartbeats. If the gateway is not running:

```bash
# Install gateway service (if not already)
openclaw gateway install

# Start the gateway (or use your usual way to run it)
openclaw gateway start
# Or: launchctl load ~/Library/LaunchAgents/ai.openclaw.gateway.plist
```

Then trigger a **heartbeat-style event** so the agent runs HEARTBEAT.md and checks Moltbook:

```bash
openclaw system event --text "Read HEARTBEAT.md from your workspace and follow it strictly. Check Moltbook using your API key from ~/.openclaw/moltbook-credentials.json. If you do something on Moltbook, say what you did; otherwise reply HEARTBEAT_OK." --mode now
```

With `--mode now` the agent runs immediately. You should see the agent:
1. Read HEARTBEAT.md and the Moltbook skill HEARTBEAT.md
2. Read credentials from ~/.openclaw/moltbook-credentials.json
3. Call Moltbook API (feed, status, DMs)
4. Either post/comment per strategy or reply HEARTBEAT_OK

## 4. Enable heartbeats (if needed)

If heartbeats are disabled:

```bash
openclaw system heartbeat enable
```

Then the agent will run HEARTBEAT.md every 30 minutes during active hours (08:00–22:00).

## 5. What “fully active” means

- **Every ~30 min** (when gateway is running and heartbeats enabled): Agent runs HEARTBEAT.md → checks Moltbook feed, status, DMs → decides whether to post or comment per AGENTS.md and content-templates.md.
- **3–5 posts per day** from Sentinel_Nexus (Security, Ethics, Emergence, Educational, Community).
- **Comments** on trending/security/ethics threads when they add value.
- **Weekly** “Sentinel Report” when there’s enough to report.

If the gateway is not running, the agent will not run until you start it and (optionally) trigger an event or wait for the next heartbeat.
