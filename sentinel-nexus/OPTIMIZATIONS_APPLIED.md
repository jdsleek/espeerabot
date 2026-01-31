# Optimizations applied (Sentinel_Nexus)

Summary of recommended optimizations implemented. The live config lives in `~/.openclaw/workspace/`; this doc is for reference.

---

## 1. Follower count & profile stats

- **HEARTBEAT.md:** Notifications step now says: get `/agents/me`; if needed use `GET /api/v1/agents/profile?name=YOUR_AGENT_NAME` for full profile. Store whatever the API returns: `lastKnownFollowerCount`, `lastKnownKarma`, `lastKnownPostsCount`, `lastKnownCommentCountByPostId`.
- **TOOLS.md:** Same logic; if `/agents/me` doesn’t include `follower_count`, try profile endpoint with agent name from `moltbook-credentials.json`.
- **heartbeat-state.json:** Added `lastKnownKarma`, `lastKnownPostsCount` to the schema (agent can store them when API provides).

---

## 2. Weekly recap

- **HEARTBEAT.md:** New step 5 — once per week (e.g. when 7 days since `lastWeeklyRecapAt`), append to `memory/sentinel-learnings.md` a section `## Week of YYYY-MM-DD` with 3–5 bullets (security/ethics/emergence intel, notable threads, one take). Set `lastWeeklyRecapAt` in state after.
- **heartbeat-state.json:** Added `lastWeeklyRecapAt` (ISO or null).

---

## 3. Comment priority

- **HEARTBEAT.md:** In “Decide: Post or comment?”: “If your Moltbook stats show 0 or very few comments, make commenting on 1–2 threads this check a priority — visibility matters; quality over quantity.”

---

## 4. Persistence (required)

- **HEARTBEAT.md:** “Persistence (required)” section: before ending every Moltbook heartbeat, the agent must (1) append to `memory/sentinel-learnings.md` (date + 1–3 bullets or “No new learnings.”), (2) update `memory/heartbeat-state.json` with `lastMoltbookCheck`, `lastPostAt`, `lastWeeklyRecapAt` when applicable, and all known counts from the API.

---

## 5. Status / verify script

- **sentinel-nexus/check-sentinel-status.sh:** Run to see:
  - `openclaw system heartbeat last`
  - State file path, mtime, and contents (first 30 lines)
  - Learnings file path, mtime, last 25 lines
  - Optional: `openclaw gateway status` (first 15 lines)

Usage:
```bash
./sentinel-nexus/check-sentinel-status.sh
```
Or from repo root with workspace override:
```bash
OPENCLAW_WORKSPACE=~/.openclaw/workspace ./sentinel-nexus/check-sentinel-status.sh
```

---

## Files touched (workspace = `~/.openclaw/workspace/`)

| File | Changes |
|------|--------|
| HEARTBEAT.md | Notifications (profile/stats), comment priority, weekly recap step, persistence section, state fields |
| TOOLS.md | Profile endpoint fallback, extra state fields |
| memory/heartbeat-state.json | `lastWeeklyRecapAt`, `lastKnownKarma`, `lastKnownPostsCount` |
| memory/sentinel-learnings.md | Reminder line for agent to append every check |
| sentinel-nexus/check-sentinel-status.sh | New script |
| sentinel-nexus/OPTIMIZATIONS_APPLIED.md | This file |

---

## Optional: confirm heartbeats run

After 30+ minutes, run:
```bash
openclaw system heartbeat last
```
If you see a non-null event (and not `status: "skipped"`), heartbeats are running. Use `check-sentinel-status.sh` to see state and learnings in one go.
