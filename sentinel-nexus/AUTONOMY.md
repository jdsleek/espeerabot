# Is the system autonomous?

**Short answer:** Yes, with the gateway running — with a few optimizations still useful.

---

## What is autonomous today

- **Gateway + cron:** When you run `./sentinel-nexus/run-agency-24-7.sh`, the OpenClaw gateway runs and the **brain (ClawTasks HEARTBEAT)** runs every 5 minutes. It can:
  - Get profile and pending
  - Submit work for claimed bounties (1–2 per run)
  - List open bounties, analyse, and claim (with 95+ reputation and selectivity in HEARTBEAT)
  - Recruit (Moltbook) and post bounties
  - Write report and append learnings

- **Run cycle (no gateway):** The dashboard **“Run cycle now”** and `run-agency-cycle-now.sh` do: claim instant → submit pending → **submit-human-front-claimed** (fallback for human-front jobs not in pending) → auto-approve. So you can get work done without the gateway.

- **Human-front:** Jobs posted on our site are claimed at post time and get submitted by run cycle (or by the brain when it runs submit). Fallback script ensures claimed-but-not-in-pending human-front jobs still get submitted.

- **Quality and reputation:** Deliverables are report-format everywhere; HEARTBEAT and learnings target 95+ reputation and selective claiming.

So: **with the gateway on, the system runs claim → submit → approve and learns on its own.** You don’t need to click “Run cycle” every time; the cron does it every 5 minutes.

---

## Where we still optimize

1. **Cron vs run-agency-cycle-now:** The **5‑min cron** runs the HEARTBEAT (LLM); the exact steps it executes depend on the skill (tools/API calls). Our **submit-human-front-claimed** step is wired into **run-agency-cycle-now.sh**, not necessarily into the cron job. So if the cron doesn’t call that script, human-front jobs that don’t appear in `/agents/me/pending` could still sit claimed until you run the cycle manually. **Done:** The 24/7 script now runs a **cycle loop** every 5 min that executes `run-agency-cycle-now.sh` (claim → submit pending → submit-human-front-claimed → auto-approve), so human-front is always advanced without you clicking anything.

2. **Visibility:** Dashboard shows reputation (target 95+), and **Completed** page shows all completed work. No further change needed for “see it all.”

3. **Release/cancel:** If an outside agent claims our bounty and never submits, we have no automatic release yet (see WHEN_AGENTS_DONT_SUBMIT.md). Optional later.

---

## Summary

| Question | Answer |
|----------|--------|
| Can we say the system is autonomous? | **Yes** when the gateway is running: the brain runs every 5 min, claims, submits, approves, learns. |
| Do we need to optimize? | **Done:** Cycle loop in 24/7 script runs full cycle every 5 min. Optional later: release flow for outside claimers. |
| Do we need to click “Run cycle” all the time? | **No** if the gateway is on; the cron does the loop. Use “Run cycle” when the gateway is off or when you want an immediate run. |

So: **the system is autonomous with the gateway on;** the main optimization is ensuring the 5‑min cron also runs the human-front submit fallback (and optionally auto-approve) so nothing is left stuck.
