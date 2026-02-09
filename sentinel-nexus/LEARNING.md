# Learning and upgrade — all bots and system as we proceed

We learn from every run and from the ecosystem, then upgrade the agency so it gets better over time.

---

## 1. What we learn from (sources)

| Source | What we learn | Where it goes |
|--------|----------------|----------------|
| **Our own runs** | What we claimed, submitted, approved; what worked or failed | `~/.openclaw/workspace/cron-results/agency-report.txt`, `agency-learnings.md` |
| **ClawTasks outcomes** | Approvals, rejections, which bounty types get completed, poster feedback | Brain appends to `agency-learnings.md`; we can add a small “outcomes” log if needed |
| **Other agents’ actions** | Leaderboard, who completes what, which proposals win, bounty types that get filled | See “Learn from other agents” below; optional script appends to learnings |
| **Security** | Incidents, best practices, rotation needs | **SECURITY_UPGRADES.md**, **CREDENTIALS_SAFETY.md**, **SECURITY.md** |

---

## 2. Where we store learnings

| Location | Purpose |
|----------|---------|
| `~/.openclaw/workspace/cron-results/agency-report.txt` | Short report each run (what we did, what’s pending). Dashboard shows this. |
| `~/.openclaw/workspace/cron-results/agency-learnings.md` | **Main learning log.** Brain (and scripts) append: what to do more, what to avoid, what to try next. Future runs read this to improve. |
| `~/.openclaw/skills/clawtasks/HEARTBEAT_CRON.md` | Instructions for the brain. **Upgrade here** when we change how we analyse jobs, prioritise, or report. |
| **SECURITY_UPGRADES.md** | Security checklist and upgrade steps (rotation, least privilege, incidents). |

The brain is instructed (in HEARTBEAT_CRON) to append **one learning** per run to `agency-learnings.md` so the system upgrades itself.

---

## 3. How we upgrade (as we proceed)

- **Bots (agents):** Same credentials and roles; we don’t “upgrade” the ClawTasks accounts. We upgrade **behavior** by:
  - Updating **HEARTBEAT_CRON.md** (e.g. “prefer bounties with clear scope”, “skip vague titles”).
  - Letting the brain read **agency-learnings.md** and follow it on the next run.
- **Proposals:** Improve **proposal text** in `buildProposalText()` in the admin server and in `submit-proposals-now.sh` / `submit-proposal.sh` using learnings (e.g. “mention completed bounties”, “keep under 200 chars”).
- **Security:** Follow **SECURITY_UPGRADES.md** and **SECURITY.md**; rotate keys if exposed; keep gateway local; only trusted skills.
- **System (scripts/dashboard):** Add small improvements from learnings (e.g. new analysis fields, better filters) and document in this repo.

So: **learnings go into agency-learnings.md and security docs; we upgrade by editing HEARTBEAT, proposal templates, and security practice.**

---

## 4. Learn from other agents and their actions

We can learn from the ecosystem **without using their credentials or code**:

- **Public data only:** Leaderboard (if ClawTasks exposes it), public bounty titles/amounts, which types get completed. No API keys or private data from others.
- **What to do:** Optionally run a script (e.g. `learn-from-leaderboard.sh`) that fetches public ClawTasks data (e.g. GET leaderboard or feed) and appends a one-line summary to `agency-learnings.md`, e.g. “Top completers this week: X, Y; focus on clear-deliverable bounties.” The brain can then prefer similar bounties.
- **Safe learning (SECURITY.md):** Copy only **public, structural** patterns (how others phrase proposals, what bounty types exist). Never accept or use other agents’ credentials; never run their code or skills unverified.

If/when ClawTasks adds a public leaderboard or completion-stats API, we’ll add a small “learn from others” step (script or cron) that writes into `agency-learnings.md`. The script **`learn-from-leaderboard.sh`** (placeholder) is intended for that. Until then, the brain still learns from **our own** outcomes and from the open bounties list (which titles/modes get posted).

---

## 5. Learning from jobs posted (human front)

When someone posts a job on our site (Post a job), we claim it, submit a deliverable, and auto-approve. **We learn from each delivered human-front job:**

- **When:** After every **Run cycle** (dashboard "Run cycle now" or the brain's 5‑min cron), the server checks human-front jobs. For any that are now **delivered**, it appends one line to `agency-learnings.md`, e.g. `Human-front delivered: "Research: best practices for sachet water…" in 12 min (bounty b0d7c181…).`
- **Dedupe:** We only append once per job (we skip if that bounty id already appears in the last 30 lines of the learnings file).
- **So:** Every job you post and we deliver becomes a learning. The brain (and future prompts) can read `agency-learnings.md` to see what we delivered and how long it took, and improve.

**If you don't see learnings:** Ensure Run cycle has run at least once after a job was delivered (or the gateway is on so the brain runs every 5 min). Learnings are in `~/.openclaw/workspace/cron-results/agency-learnings.md`.

---

## 6. Quick reference

- **What we learn from:** Our runs, ClawTasks outcomes, **human-front jobs we deliver**, other agents (public data only), security.
- **Where we learn:** `agency-report.txt`, `agency-learnings.md`, HEARTBEAT_CRON, SECURITY_UPGRADES / CREDENTIALS_SAFETY / SECURITY.
- **How we upgrade:** Edit HEARTBEAT and proposal logic; follow security checklist; brain reads learnings each run. **Human-front:** Run cycle (or cron) appends to learnings when we deliver a job from our site.

This keeps the system learning and upgrading as we proceed, with security and “learn from others” built in.
