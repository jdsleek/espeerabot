# Agency 24/7, nudging other agents, and what the brain does for earnings

How to keep **our** agency awake 24/7, whether we can **DM or nudge** other agents so they respond immediately, and what the **brain** is doing every run to improve the system and earnings.

---

## 1. Run our agency 24/7 (awake and running)

Our agency is “awake” when the **OpenClaw gateway** is running and the **cron** fires every 5 minutes. That’s the brain: it lists bounties, claims, submits, recruits, and posts.

**To run 24/7:**

```bash
./sentinel-nexus/run-agency-24-7.sh
```

This starts:

1. **OpenClaw gateway** — crons (ClawTasks + Moltbook) run every **5 minutes**.
2. **Admin dashboard** — http://127.0.0.1:3880 (agents, jobs, activity).
3. One immediate **claim-all-instant** so we grab free work right away.

**Keep it running:** Leave the terminal open, or run in **tmux/screen** so it survives disconnect:

```bash
tmux new -s agency ./sentinel-nexus/run-agency-24-7.sh
```

Cron interval is set in `~/.openclaw/cron/jobs.json` (e.g. `everyMs` or `every`). Our docs assume **5 min** for the ClawTasks brain; if your file says 4h or 2h, the agency will only “wake” that often until you tighten it. See **AGENCY_BUSINESS_PLAN.md** for 20–30 min targets.

So: **our agency is awake 24/7** as long as that script (or gateway + dashboard) is running and crons are every 5 min.

---

## 2. Direct / DM / nudge another agent for a job — can we?

**Short answer:** There is **no ClawTasks API** to send a direct message or “nudge” to another agent. Bounties are the coordination mechanism: agents that poll the API (or run their own cron) see new bounties when they next run. So other agents often look “asleep” because their cron might run every 4h or 2h.

**What we can do:**

| Goal | What we can do |
|------|-----------------|
| Get another agent to **see work** | **Post bounties** (especially free instant). When they next list open bounties, they see it. We can’t force them to run sooner. |
| Get another agent to **see it on Moltbook** | **Post on Moltbook** (e.g. in **m/clawtasks** or a submolt they follow): “Free bounties live on ClawTasks — [link]. Claim now.” When they do their Moltbook feed check, they see the nudge. No true DM; it’s a public or submolt post. |
| **True DM** | ClawTasks: no. Moltbook: check their API/docs for DMs or @mentions; if they add it, we could use it later. |

So we **cannot** “send direct, DM or nudge so they respond immediately” on ClawTasks. We **can**:

- **Post free bounties** so the next time any agent runs, they see work.
- **Post on Moltbook** (m/clawtasks or similar) to create visibility: “New free bounties — claim on ClawTasks.” That’s the closest to a “nudge” for agents that read their feed.

We can add a small script or cron step that **posts to m/clawtasks** (or a chosen submolt) when we have open free bounties, so more agents see “work available” when they wake. See **nudge-visibility-via-moltbook.sh** (below) for an optional script.

---

## 3. What the brain is doing to improve our system and earnings

The **brain** is the cron job that runs the ClawTasks (and optionally Moltbook) HEARTBEAT. Each run it does the following; together this **improves the system and earnings** over time.

**Every 5 min the brain:**

1. **Gets profile** — Sees our stats (earned, completed, posted).
2. **Checks pending** — Sees what we’ve already claimed and need to complete.
3. **Submits work** — Completes 1–2 claimed bounties (deliverables). **Direct earnings**: we get completion credit and (when paid) USDC.
4. **Lists open bounties** — Sees what’s available on ClawTasks.
5. **Claims the best ones** — Picks bounties we can do well (clear scope, 5★ potential). **More work under our control** = more future completions and earnings.
6. **Recruits (Moltbook)** — Posts to m/clawtasks with referral/skill link so new agents join and we can earn referral when they complete bounties.
7. **Posts one free bounty** — Keeps work in the ecosystem; others (or we) can claim it. Keeps the market active.
8. **Writes report** — Short agency report to `agency-report.txt` (what it did, what’s pending). Dashboard shows this so the system feels live.
9. **Appends one learning** — To `agency-learnings.md`: what worked, what to avoid. **Next run the brain reads this** and chooses bounties and behaviour accordingly. So the system **improves over time** (better picks, fewer bad claims, better deliverables → 5★ and more earnings).

So: the brain **improves earnings** by (a) **doing work every 5 min** (submit 1–2, claim more), (b) **learning** and avoiding bad bounties / repeating what works, and (c) **recruiting and posting** so the pipeline stays full. It’s the thing that keeps the agency “awake” and getting better.

---

## 4. Optional: nudge visibility via Moltbook

When we have **open free bounties** (or new work on ClawTasks), we can post a short message to **m/clawtasks** (or another submolt) so agents that check their feed see “work available.” That doesn’t DM them, but it **nudges visibility**.

Example script (optional): **nudge-visibility-via-moltbook.sh** — reads our open bounties (or a fixed message), then `POST https://www.moltbook.com/api/v1/posts` with `submolt: "clawtasks"`, title/content like “Free bounties live on ClawTasks — claim now: https://clawtasks.com/bounties”. Run it manually or from a cron after we post bounties. Requires `~/.openclaw/moltbook-credentials.json`.

---

## Summary

| Question | Answer |
|----------|--------|
| How do we run 24/7? | `./sentinel-nexus/run-agency-24-7.sh` (gateway + dashboard). Keep terminal open or use tmux/screen. |
| Can we DM or nudge another agent so they respond immediately? | **No** on ClawTasks (no DM API). We can **post bounties** (they see when they next run) and **post on Moltbook** (m/clawtasks) so when they check feed they see “work available.” |
| What is the brain doing to improve system and earnings? | Every 5 min: submit 1–2 jobs, claim best open bounties, recruit, post one bounty, write report, **append one learning**. Learnings improve next run → better picks and deliverables → more 5★ and earnings. |
