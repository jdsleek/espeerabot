# 5-agent agency plan — free money, researcher, prediction, brain

**Goal:** 5 agents total. One checks and feeds researcher updates to the brain; we pursue free money (crypto airdrops, prediction markets); the brain constantly reviews and acts, and you see suggestions on a page and assign work to agents.

---

## 1. Five agents (roles)

| # | Agent ID      | Role              | What they do |
|---|---------------|-------------------|---------------|
| 1 | jobmaster     | Lead (ClawTasks)  | Cron uses this. Claim, submit, post, recruit on ClawTasks. |
| 2 | jobmaster2    | Worker (ClawTasks) | Same flow; more throughput. |
| 3 | jobmaster3    | Worker (ClawTasks) | Same flow; more throughput. |
| 4 | researcher    | Researcher        | Check sources (crypto airdrops, prediction markets, job boards). Write short **researcher updates** to a file the brain reads. No ClawTasks credential; runs as Kimi cron or dashboard-triggered. |
| 5 | scout         | Airdrop / Prediction | Use Kimi 2.5 to list airdrops, prediction-market opportunities, “turn $2 → more” plays. Writes **suggestions** and priorities for the brain. Execution can be manual or later automated. |

So: **3 ClawTasks agents** (existing) + **2 “brain-side” agents** (Researcher, Scout) that produce updates and suggestions for the brain and for you.

---

## 2. Free money streams (what we’re aiming for)

- **ClawTasks** — Already live. Claim, submit, get paid USDC. Brain runs every 5 min.
- **Crypto airdrops** — Researcher/Scout finds programs (protocols, testnets, points). You (or later a wallet-safe automation) do signup/claims. Brain suggests “focus on X this week.”
- **Prediction markets** — Scout finds markets (e.g. Polymarket, small stakes). Kimi suggests where to put $2–$20 for upside. You approve and sign; we don’t auto-trade with real funds without explicit approval.
- **More agents making money** — More ClawTasks workers = more claims. Researcher/Scout = more opportunities surfaced so you and the brain can act.

---

## 3. Brain loop (review and act)

- **Brain** (existing HEARTBEAT every 5 min) reads:
  - `agency-learnings.md`
  - **Researcher update** (e.g. `cron-results/researcher-updates.md`) — “What’s new in airdrops / prediction / jobs.”
  - **Brain suggestions** (e.g. `cron-results/brain-suggestions.md` or JSON) — Kimi’s plan and priorities; your assigned tasks per agent.
- Brain **reviews**, **updates the plan**, **acts** (e.g. claim on ClawTasks, or write “suggested action: do X” for you), and **writes a short report** (dashboard + agency-report.txt).
- You see everything on **Admin → Brain**: suggestions, researcher update, list of 5 agents, and you **assign tasks** to agents (saved so the brain and you can see who does what).

---

## 4. Where things live

| Item | Location |
|------|----------|
| 5-agent roster | `sentinel-nexus/agency-agents.json` (extended) or `cron-results/agent-roster.json` |
| Researcher update (text) | `workspace/cron-results/researcher-updates.md` |
| Brain suggestions (Kimi plan + your assignments) | `workspace/cron-results/brain-suggestions.json` (or .md) |
| Assignments to agents | In `brain-suggestions.json` or `agent-assignments.json` |
| Page to see and assign | **Admin → Brain** (`/admin/brain`) |

---

## 5. What you can do on the Brain page

- **See** latest Kimi 2.5 plan (suggestions for airdrops, prediction, priorities).
- **See** latest researcher update (what’s new in crypto / prediction / jobs).
- **See** 5 agents and their roles; **assign** a task to an agent (saved and shown to the brain).
- **Trigger** “Plan with Kimi” to refresh the plan.
- **Trigger** “Researcher update” to refresh the researcher summary.

The brain (HEARTBEAT) will read these files each run and incorporate them into what it does and reports.

---

## 6. Make the brain read suggestions and researcher updates

Add this to your ClawTasks HEARTBEAT (`~/.openclaw/skills/clawtasks/HEARTBEAT_CRON.md`) as an optional step (e.g. after "Get your profile"):

- **Read researcher update:** If the file `cron-results/researcher-updates.md` exists in your workspace, read it. Use it as context for what’s new in airdrops, prediction markets, and job boards.
- **Read brain suggestions and assignments:** If the file `cron-results/brain-suggestions.json` exists, read the `plan` and `assignments` fields. Use them to prioritise (e.g. “human assigned Scout to check Polymarket”) and mention in your agency report what you’re doing about it.

This keeps the brain aligned with your Brain page and with the researcher/scout agents.

---

## 7. Brain constantly reaches online (ClawTasks-like sites, apply, move)

The brain should **constantly reach online**: find websites similar to ClawTasks (bounty/task/gig marketplaces), join or apply, and give you **full feedback**. When it feels it can handle something, **move** (take action or record "apply/joined").

**On the Brain page (**`/admin/brain`**):**

- **Reach online / Discovery** — Click **"Run discovery"**. Kimi 2.5 will:
  1. List 5–10 platforms similar to ClawTasks (with how to join and whether we can handle it).
  2. Recommend which to apply to first.
  3. Give full feedback and when to "move" if we can handle it.
- **Paste content** — If you have a tweet, post, or link (e.g. [an X post about a new opportunity](https://x.com/njokuScript/status/2018056914190344609)), paste the **text** into the box and run discovery. Kimi will analyze it and say what the opportunity is, full feedback, and "MOVE: [next step]" if we can handle it. (If the link doesn’t load, paste the tweet/post text manually.)
- **Record a move** — When you or the brain decide to apply or join, use **Record move** (platform name + Apply/Joined/Skip) so the brain and you can track what we’re doing.

**Data:** `cron-results/discovery-feed.json` holds the last discovery (feedback, moves). The brain can read this file in HEARTBEAT to stay aligned with "reach online and move when we can handle it."
