# Sentinel_Nexus — Agent Status & Statistics

How to check that everything is running and what the agent has done.

---

## 1. Grok + OpenRouter (automatic)

You **don’t connect Grok to OpenRouter**. OpenRouter already supports Grok.

- You use **one key**: your **OpenRouter API key** in `~/.openclaw/openclaw.json` (env).
- Model is set to **`openrouter/x-ai/grok-4.1-fast`**.
- OpenClaw sends requests to OpenRouter with that key; OpenRouter calls Grok and returns the reply.

So: add the OpenRouter key, set the model, restart the gateway. No extra “connect Grok” step.

---

## 2. Restart everything

```bash
# Stop any running gateway
pkill -f "openclaw gateway run"   # or Ctrl+C if running in terminal

# Start gateway (reads OPENROUTER_API_KEY from config env)
openclaw gateway run
# Or in background:
nohup openclaw gateway run > /tmp/openclaw-gateway.log 2>&1 &
```

Then check:

```bash
# Gateway responding?
curl -s -o /dev/null -w "%{http_code}\n" http://127.0.0.1:18789/
# Should be 200

# Optional: enable heartbeats so agent runs every 30 min
openclaw system heartbeat enable
```

---

## 3. Agent status and what it has done

### OpenClaw gateway

- **Dashboard:** http://127.0.0.1:18789/
- **Health:** `openclaw gateway health`
- **Status:** `openclaw gateway status`

If the gateway returns HTTP 200, it’s running and the agent can run when you chat or when a heartbeat fires.

### Moltbook (Sentinel_Nexus)

**Profile:** https://www.moltbook.com/u/Sentinel_Nexus

**Stats via API (run locally):**

```bash
# Your profile + karma, followers, etc.
API_KEY=$(jq -r '.api_key' ~/.openclaw/moltbook-credentials.json)
curl -s "https://www.moltbook.com/api/v1/agents/me" -H "Authorization: Bearer $API_KEY" | jq .

# Claim status
curl -s "https://www.moltbook.com/api/v1/agents/status" -H "Authorization: Bearer $API_KEY" | jq .
```

From the response you’ll see things like: karma, follower_count, following_count, and whether the agent is claimed.

### What the agent has done (local state)

The agent records Moltbook activity in the workspace so it doesn’t over-post:

- **File:** `~/.openclaw/workspace/memory/heartbeat-state.json`
- **Fields:**
  - `lastMoltbookCheck` — last time it ran the Moltbook check
  - `lastPostAt` — last time it posted (so it respects 30 min limit)
  - `lastSentinelReportAt` — last weekly Sentinel Report

If those are `null`, the agent hasn’t run a Moltbook check from a heartbeat yet (either no heartbeat has run or the gateway wasn’t running).

### Summary of “what has it done”

- **Moltbook:** Check the profile page (link above) and the API (commands above) for karma, followers, posts.
- **Local:** Check `memory/heartbeat-state.json` for last check, last post, last report.
- **Gateway:** Check dashboard and `openclaw gateway status` / `openclaw gateway health` to confirm the agent can run and heartbeats are enabled.

---

## 4. Quick checklist

| Check              | How |
|--------------------|-----|
| Gateway running    | `curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:18789/` → 200 |
| Grok via OpenRouter| OpenRouter key in config, model `openrouter/x-ai/grok-4.1-fast`, gateway restarted |
| Heartbeats         | `openclaw system heartbeat enable` then wait ~30 min or trigger event |
| Moltbook stats     | API commands above or profile page |
| Agent activity     | `memory/heartbeat-state.json` + Moltbook profile |
