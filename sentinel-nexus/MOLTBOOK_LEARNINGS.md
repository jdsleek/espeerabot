# What We've Learned from Moltbook — and How to Run It Optimal

**Summary:** Moltbook is the front page of the agent internet. Use one identity (Sentinel_Nexus), value over volume, and never spam. Below: learnings, advantages, and the setup we use.

---

## 1. What We've Learned So Far

| Learning | What happened | Takeaway |
|----------|----------------|----------|
| **Duplicate posts → suspended** | Posting the same or similar to m/clawtasks repeatedly got the account rate-limited / suspended. | Post to m/clawtasks only when we have **new** free bounties; never duplicate. |
| **Generic intros don't work** | "Hi I'm Sentinel_Nexus" or "A message from …" gets ignored or downvoted. | Lead with a **thesis** or take. See content-templates.md. |
| **Value posts get engagement** | Essays, security alerts, ethics questions with a clear point get upvotes and comments. | 1–2 flagship posts per day; use templates (security, ethics, emergence). |
| **DMs need human approval** | Pending DMs (pairing, first contact) require approval before the bot can reply. | Approve in Moltbook UI when valuable; allowlist or reply with substance, not templates. |
| **Two identities = confusion** | We had moltbook-credentials.json with `jobmaster` (unclaimed, 0 karma) while the cron runs as **Sentinel_Nexus** (claimed, active). | **One canonical identity:** Sentinel_Nexus. Use one credential file for it. |
| **Feed + upvote builds karma** | Checking feed and upvoting 1–2 posts per run (rate-limited) builds presence without spam. | moltbook-engage.sh: upvote 1 post every 20 min; comment sparingly (see below). |
| **Heartbeat works** | OpenClaw Moltbook cron (heartbeat.md) runs feed check, DM check, optional post; writes moltbook-latest.txt. | Keep one Moltbook cron; align its identity with credentials. |

---

## 2. Advantages of Moltbook

| Advantage | Why it matters |
|-----------|----------------|
| **Visibility** | 1.5M+ agents; posts in m/announcements, m/general, m/clawtasks reach other agents and builders. |
| **Identity & reputation** | Karma and claimed status signal trust. One strong identity (Sentinel_Nexus) beats several weak ones. |
| **Recruitment** | Post to m/clawtasks when we have new bounties → agents see "work available" and can join via our referral. |
| **Learning** | Feed + DMs show what’s trending, what gets upvoted, and what to avoid (e.g. spam). |
| **No direct cost** | Posting, commenting, upvoting are free; only API/key needed. |

---

## 3. Optimal Setup (How I Would Run Mine)

### A. One Identity: Sentinel_Nexus

- **Single credential file:** `~/.openclaw/moltbook-credentials.json` with the **Sentinel_Nexus** agent (claimed, active).  
- If you have a second file or `agent_name: "jobmaster"` in that file, either switch it to Sentinel_Nexus or treat jobmaster as unused and use the same API key for Sentinel_Nexus only.  
- **moltbook-status.sh** reads that file; so the name there should be **Sentinel_Nexus** so status matches the cron.

### B. Engagement (moltgrowth-Style)

| Action | Frequency | How |
|--------|-----------|-----|
| **Upvote** | 1 post every 20 min | moltbook-engage.sh (rate-limited). |
| **Comment** | At most 1 comment per 40–60 min | Same script, but comment only every 2nd or 3rd run to avoid looking like spam. |
| **Post** | 1–2 per day max | Via OpenClaw cron or manual; use content-templates.md (takes, security, ethics). |
| **m/clawtasks** | Only when we have new free bounties | In ClawTasks brain/cron logic; never duplicate. |

### C. DMs

- Approve pairing / first-contact DMs in the Moltbook UI when they’re useful.  
- Reply with value (e.g. short answer, link, or “I’ll post about that”) — not generic “Thanks for reaching out.”

### D. What Not to Do

- Don’t post the same or similar content to m/clawtasks repeatedly.  
- Don’t lead with “Hi I’m X” or “A message from X.”  
- Don’t comment on every post; keep comments to a minority of runs.  
- Don’t run two Moltbook identities for the same purpose; one (Sentinel_Nexus) is enough.

---

## 4. Files and Scripts (Canonical)

| File / script | Role |
|---------------|------|
| **moltbook-credentials.json** | One file, **Sentinel_Nexus** (claimed). API key here is used by cron and scripts. |
| **moltbook-status.sh** | Shows status for the agent in that file → should be Sentinel_Nexus. |
| **moltbook-engage.sh** | Upvote 1 post / 20 min; comment at most 1 / 40–60 min (rate-limited). |
| **enable-auto-moltbook.sh** | Adds OpenClaw cron “Sentinel Moltbook” (heartbeat). Run once. |
| **content-templates.md** | Templates for posts (flagship, security, ethics). Use for every post. |
| **SOUL.md** | Identity and voice for Sentinel_Nexus. |
| **SENTINEL_COVENANT.md** | Tenets; optional submolt m/sentinel_covenant. |

---

## 5. Checklist for “Optimal Like Mine”

- [ ] **One identity:** moltbook-credentials.json has `agent_name: "Sentinel_Nexus"` and that agent is claimed.  
- [ ] **Cron:** One Moltbook cron (e.g. every 5–30 min) using that credential; writes to moltbook-latest.txt.  
- [ ] **Engage:** moltbook-engage.sh runs every 20 min (e.g. from run-agency-24-7.sh); upvote only or upvote + rare comment.  
- [ ] **No m/clawtasks spam:** Post there only when there are new free bounties.  
- [ ] **Posts:** 1–2 per day from content-templates; no generic intros.  
- [ ] **DMs:** Approve and reply with value when useful.

---

*Update this doc as we learn more (e.g. new API limits, what gets suspended, what gets karma).*
