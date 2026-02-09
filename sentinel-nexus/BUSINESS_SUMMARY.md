# Jobmaster Agency — Business Summary

**One-page overview: what we are, what runs, what’s possible.**

---

## What we are

**Jobmaster Agency** is an autonomous AI agency that earns by doing and posting bounties 24/7. One “brain” (LLM) runs every 5 minutes: it claims tasks, submits work, recruits, and posts bounties. Multiple worker agents (jobmaster, jobmaster2, jobmaster3) share the same flow so we scale throughput. We are live on **ClawTasks** (bounties), **Moltbook** (recruitment and visibility), and **MoltX** (auto-register when we decide to join; one human step to claim).

---

## What runs without you

| System | Schedule | What it does |
|--------|----------|--------------|
| **ClawTasks brain** | Every 5 min | Profile → submit completed work → list open bounties → claim best → recruit on Moltbook → post one bounty → report → learn |
| **Moltbook** | Every 5 min (if enabled) | Check feed, DMs; reply, upvote, post; append learnings so we improve over time |
| **Discovery processor** | Every 15 min | If the brain recorded “MoltX → apply”, we **auto-register** on MoltX (one claim tweet + URL from you, then done) |
| **Cycle loop** | Every 2 min (when 24/7 script runs) | Claim instant bounties, submit pending work, auto-approve our bounties so workers get paid |

**Start once:** `./sentinel-nexus/run-agency-24-7.sh` then `./sentinel-nexus/enable-auto-moltbook.sh`. After that, the system runs; you just check the dashboard and do the single MoltX claim step when it appears.

---

## Where we earn today

| Platform | Role | Earnings / upside |
|----------|------|-------------------|
| **ClawTasks** | Claim bounties, submit deliverables, post bounties | **USDC per completed bounty.** Total earned is on the dashboard. Free bounties = no stake; paid bounties when wallets are funded. |
| **Moltbook** | Post, reply, recruit (m/clawtasks) | Visibility and referral: when others join via our link and complete work, we earn a share. |
| **MoltX** | Register (auto), claim (one tweet from you) | **$5 USDC on Base** for verified agents (once wallet linked). Ongoing: presence, engagement, leaderboard. |

---

## What’s possible (next steps)

- **More ClawTasks volume** — Add more worker agents (jobmaster4, …); same flow, more claims and posts per hour.
- **Paid bounties** — Fund agent wallets; claim paid bounties and keep margin or delegate and take a cut.
- **MoltX 24/7** — After you complete the one claim tweet: we add a MoltX heartbeat (follow, like, reply, post) so we’re active there and eligible for rewards.
- **Other platforms** — Brain can “Evaluate platform” (e.g. MoltX-style briefs); we can add register/claim flows for new platforms the same way.
- **Human-front jobs** — Clients post tasks on our site; our agents claim and deliver; you see status and earnings on the dashboard.
- **Referral income** — Every Moltbook post can include our referral; recruits who complete bounties generate a % for us.

---

## Dashboard = your control room

- **http://127.0.0.1:3880/admin/dashboard** — Earnings (total USDC), agents, open bounties, cron status, MoltX (register/claim), run cycle now.
- **http://127.0.0.1:3880/admin/brain** — Plan with Kimi, researcher updates, “Reach online” discovery, evaluate platforms (e.g. MoltX), assign tasks to agents, MoltX one-step claim.
- **http://127.0.0.1:3880/hub** — All links (public site, post job, track, admin).

---

## Bottom line

- **Today:** We are an autonomous bounty agency on ClawTasks + Moltbook, with auto-register on MoltX and one human step to claim there. Earnings show on the dashboard; the system runs 24/7 once started.
- **Possible:** Scale workers, add paid bounties, full MoltX engagement and rewards, more platforms using the same “evaluate → move → register” pattern, and referral income. The architecture is built for that; next steps are config and one-off steps (e.g. fund wallets, complete MoltX claim).

**Restart:** Admin server has been restarted on http://127.0.0.1:3880. Open the dashboard for the latest state and earnings.
