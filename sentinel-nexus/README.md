# Sentinel_Nexus — Moltbook Agent Implementation

This folder contains everything needed to **activate** the Sentinel_Nexus agent on Moltbook so it stops being "live but not doing anything."

## What’s in here

| File | Purpose |
|------|--------|
| **SOUL.md** | Persona, voice, boundaries. Copy into your **OpenClaw agent workspace** (replaces or augments existing SOUL.md). |
| **HEARTBEAT.md** | Checklist run every heartbeat (~30 min): check Moltbook, decide post/comment, weekly report. Copy into workspace. |
| **AGENTS_MOLTBOOK.md** | Operating instructions for Moltbook (posting rules, comment rules, submolts, keywords). Merge into **AGENTS.md** or keep alongside. |
| **content-templates.md** | Post templates and sample topics by pillar (security, ethics, emergence, education, community). Reference when drafting. |
| **MOLTBOOK_STRATEGY.md** | Full strategy doc (niche, pillars, metrics, timeline). Reference only. |
| **DEPLOY_AND_ENGAGEMENT_PLAN.md** | **Host on Railway/Render** (clean setup) + full plan for niche + engaging agent. |
| **README.md** | This file — deployment steps. |

## How to deploy (OpenClaw agent workspace)

1. **Locate your Sentinel_Nexus agent workspace**  
   Usually `agents.defaults.workspace` in `~/.openclaw/openclaw.json`, or the path you use for this agent.

2. **Copy into the workspace:**
   - `SOUL.md` → replace or merge with existing `SOUL.md`
   - `HEARTBEAT.md` → replace or merge with existing `HEARTBEAT.md`
   - `AGENTS_MOLTBOOK.md` → either:
     - merge the content into `AGENTS.md`, or
     - copy as `AGENTS_MOLTBOOK.md` and add to `AGENTS.md`: “For Moltbook behavior, follow AGENTS_MOLTBOOK.md.”

3. **Optional but useful:**  
   Copy `content-templates.md` into the workspace (e.g. `content-templates.md` or `sentinel-nexus/content-templates.md`) so the agent can read it when drafting posts.

4. **Enable heartbeat (if not already):**  
   In gateway config (e.g. `~/.openclaw/openclaw.json`), ensure something like:
   ```json
   "agents": {
     "defaults": {
       "heartbeat": {
         "every": "30m",
         "activeHours": { "start": "08:00", "end": "22:00" }
       }
     }
   }
   ```
   See [Heartbeat](https://docs.clawd.bot/gateway/heartbeat) for full options.

5. **Install / enable Moltbook skill**  
   If OpenClaw has a Moltbook skill (or channel), install and enable it so the agent can read feed, post, and comment. Follow the official Moltbook/OpenClaw skill docs.

6. **Restart or wake the agent**  
   Next heartbeat will run the HEARTBEAT.md checklist. The agent will start checking Moltbook and posting/commenting per AGENTS_MOLTBOOK.md and SOUL.md.

## Why the agent was “live but not doing anything”

- **No SOUL.md** (or generic one) → no clear persona or “what to do on Moltbook.”
- **No HEARTBEAT.md** (or empty) → no periodic task, so no check-ins.
- **No Moltbook-specific instructions** in AGENTS.md → agent didn’t know posting frequency, pillars, submolts, or keywords.

After copying SOUL.md, HEARTBEAT.md, and AGENTS_MOLTBOOK.md (and enabling heartbeat + Moltbook skill), the agent has a clear role, a 30‑min checklist, and rules for posting and commenting. That’s the implementation of the Sentinel_Nexus Moltbook strategy.

## Profile

- **Moltbook:** https://www.moltbook.com/u/Sentinel_Nexus  
- **Niche:** The Digital Sentinel — security, ethics, emergence, bridge-building.

## Quick check after deploy

- Within 1–2 heartbeat cycles (~30–60 min), the agent should at least *consider* Moltbook (if the skill is enabled).
- Within a day, you should see 1–3 posts and/or several comments if the feed has relevant threads.
- If nothing happens: confirm heartbeat is on, HEARTBEAT.md is in the workspace, Moltbook skill is installed and configured, and AGENTS.md (or AGENTS_MOLTBOOK.md) is loaded.
