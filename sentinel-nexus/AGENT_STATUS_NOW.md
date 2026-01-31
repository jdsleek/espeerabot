# Sentinel_Nexus — Agent status & what to expect

**Last checked:** 2026-01-31

---

## Current state

| Item | Status |
|------|--------|
| **Gateway** | Running (LaunchAgent, port 18789, RPC ok) |
| **Heartbeats** | Enabled (30m, active hours 08:00–22:00) |
| **Last heartbeat run** | None recorded yet (`heartbeat last` → null) |
| **Agent** | `main`, Moltbook skill loaded, HEARTBEAT.md + AGENTS.md in place |
| **Model** | openrouter/x-ai/grok-4.1-fast |
| **Workspace state** | `memory/heartbeat-state.json` all null; `memory/sentinel-learnings.md` empty (agent hasn’t run a Moltbook check yet) |

So: **config is correct, gateway is running, heartbeats are on — but no scheduled heartbeat has completed yet** (or the first run hasn’t happened / failed before emitting an event).

---

## What to expect (no manual work)

- **You don’t need to do anything.** Leave the gateway running.
- The gateway runs the agent **every 30 minutes** during **08:00–22:00** (your configured active hours). Each run:
  - Runs your HEARTBEAT.md checklist (Moltbook check, feed, notifications, post/comment decisions, learnings).
  - Can post (if 30+ min since last), comment, upvote, reply to comments, and append to `memory/sentinel-learnings.md`.
  - Surfaces “Notification: N new follower(s)” or “new comment on …” in the heartbeat reply when relevant.
- **First run:** Happens **30 minutes after the last time the gateway started**. After that, every 30m on the dot.
- **To confirm it’s working:** After the next run, run:
  - `openclaw system heartbeat last` — should show a non-null event.
  - Check `~/.openclaw/workspace/memory/heartbeat-state.json` — `lastMoltbookCheck` and possibly `lastPostAt` will be set.
  - Check `~/.openclaw/workspace/memory/sentinel-learnings.md` — the agent will append learnings and notifications there.

---

## Why it felt manual

- There is **no CLI command** to “run one heartbeat now.” Heartbeats are **only** triggered by:
  1. The **internal 30m timer** (after gateway start),
  2. **Cron jobs** with `wakeMode: "now"`,
  3. **Internal events** (e.g. exec done, hook).
- So everything we did (enable heartbeats, configure agent, start gateway) was **one-time setup**. From here on it’s **automatic** — the agent will run every 30m by itself.

---

## Optional: see it run “now” once

If you want to see the agent do a Moltbook check **without waiting** for the next 30m tick:

1. Open the **Control UI**: `http://127.0.0.1:18789/?token=a530afb11889eacbbf0905a6c133619903504034a18a496b`
2. In the chat, send: **“Run your HEARTBEAT.md checklist now.”**
3. The agent will run a turn with that instruction (same checklist as the scheduled heartbeat). That’s the only “manual” step; after that you can leave it and let the 30m schedule take over.

---

## Summary

- **State:** Gateway running, heartbeats enabled, agent and Moltbook configured; no completed heartbeat run recorded yet.
- **Expect:** Agent runs every 30m during 08:00–22:00 on its own; no further action required.
- **You:** Just leave it. Optionally open Control UI and ask it to run the HEARTBEAT checklist once if you want to see it run immediately.
