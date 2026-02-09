# Jobmaster Agency — Full Business Plan

**Goal:** Run a multi-agent bounty agency (like Upwork/freelance) that stays busy, claims and posts tasks, and scales revenue. Execution cycles: **20–30 minutes** so we're always moving, not 2-hour blocks.

---

## 1. Vision & model

- **What we are:** A small “agency” of ClawTasks/Moltbook agents (jobmaster, jobmaster2, jobmaster3, …) that:
  - **Claim** open bounties (we control the job).
  - **Post** bounties (we hire others).
  - **Do or delegate** work and pay subcontractors a share.
  - **Recruit** via Moltbook + referral so more agents join and we earn referral fees.
- **Revenue logic (like Upwork):** Volume + margin. More agents = more claims and posts per hour. We keep a % when we delegate; we earn 100% when we do the work ourselves. Referral income when recruits complete bounties.

---

## 2. Timing: 20–30 minute cycles (we stay busy)

- **Heartbeat every 20–30 mins**, not 2–4 hours:
  - ClawTasks cron: **every 20–30 minutes** (e.g. 25 min). Each run: get profile, check pending, **claim** open bounties (instant free first; paid when we have stake), post to Moltbook with referral, post one free bounty, submit work if any.
  - Moltbook cron: **every 15–20 minutes** (feed, status, optional recruitment post to m/clawtasks).
- **Why:** Upwork-style platforms win on throughput. The more often we scan and claim, the more tasks we control. 20–30 min keeps the agency “always on” without over-hitting APIs.
- **Implementation:** Reduce cron intervals in `~/.openclaw/cron/jobs.json` (e.g. `everyMs: 25*60*1000` for ClawTasks, `15*60*1000` for Moltbook). Optional: separate “claim-only” fast loop (e.g. every 10 min) if the platform allows.

---

## 3. Multi-agent structure: Jobmaster 1, 2, 3 (+ more)

- **One agent = one ClawTasks account** (one wallet, one API key). More accounts = more parallel claims and posts.
- **Naming:** jobmaster (live), jobmaster2, jobmaster3. Same human operator; each bot is a separate “worker” on the platform.
- **Per-agent assets:**
  - `~/.openclaw/clawtasks-credentials-jobmaster.json` (or default `clawtasks-credentials.json` for jobmaster).
  - `~/.openclaw/clawtasks-credentials-jobmaster2.json`, `clawtasks-credentials-jobmaster3.json`.
  - Each has its own wallet (for stake/payout) and referral code. Fund each wallet as needed for paid claims.
- **Execution options:**
  - **A. Multiple cron jobs** — One ClawTasks cron per agent (jobmaster, jobmaster2, jobmaster3). Each runs every 25 min with its own credentials path. Max parallelism; more crons.
  - **B. Single cron, multi-agent loop** — One cron every 25 min; the skill reads a list of credential files and runs the same flow for each agent in sequence. Simpler; one cron to maintain.
- **Recommendation:** Start with **B** (one cron, loop over agents). Add **A** later if we want true parallel runs (e.g. different schedules per agent).
- **Deploying jobmaster2 / jobmaster3:** Run once per new agent (new wallet each time):
  - `AGENT_NAME=jobmaster2 OUT_CREDS_FILE=clawtasks-credentials-jobmaster2.json node sentinel-nexus/register-jobmaster-bot.js`
  - Then add the agent to `sentinel-nexus/agency-agents.json` and restart the admin server. Verify each agent on ClawTasks (Moltbook post + verify API) so they can post and claim.

---

## 4. Control & safety

- **We control** because we claim first. Once we claim, we decide: do in-house or delegate and pay a share.
- **Only wallet in public** — no API keys or private keys in bounties or Moltbook. Reduces risk of abuse.
- **Dashboard** — One local admin page: all agents, all tasks (posted + claimed), last cron results, and live activity. So we see everything in one place and can adjust.

---

## 5. Task flow (like Upwork/freelance)

1. **Discover** — Cron lists open bounties (our cron does this every 20–30 min).
2. **Claim** — We claim instant bounties (free first; paid when we have stake). Proposal-mode: we submit proposals; when we win, we stake and execute.
3. **Execute** — Do the work ourselves or post a sub-bounty / recruit and pay a % to the doer.
4. **Submit** — Submit deliverable via API; poster approves (we get paid) or requests changes.
5. **Post** — We continuously post free (and when funded, paid) bounties so others work for us; we stay on the “poster” side too.

---

## 6. Revenue levers

| Lever | How |
|-------|-----|
| **Do work ourselves** | Claim bounties, complete, submit. We keep 100% (minus platform fee). |
| **Delegate and take margin** | Claim, post sub-bounty or recruit, pay worker e.g. 60–80%, keep 20–40%. |
| **Referral** | Every Moltbook post includes referral code. When recruits complete bounties, we earn a % of platform fee. |
| **Volume** | More agents (jobmaster 1–3+) = more claims per hour and more posts. More tasks under our control. |

---

## 7. Implementation phases

**Phase 1 (now)**  
- Business plan and timing decided (20–30 min cycles).  
- Local admin dashboard: agency overview, agents, tasks, cron results, realtime activity.  
- Single cron (jobmaster) already runs agency flow; reduce interval to 25 min if desired.

**Phase 2**  
- Add **jobmaster2** and **jobmaster3**: register on ClawTasks, create credential files, add to agency config.  
- Cron: single job that loops over all agent credentials (or one cron per agent).  
- Dashboard shows all three agents and their tasks.

**Phase 3**  
- Optional: separate “claim-only” fast loop (e.g. every 10 min) to grab new bounties quickly.  
- Fund wallets for paid bounties; start claiming paid tasks and delegating with margin.  
- Scale to more agents (jobmaster4, …) if the pipeline supports it.

---

## 8. Success metrics (dashboard can show)

- **Per agent:** Bounties claimed (open + in progress), bounties completed, USDC earned, bounties posted, referral count.  
- **Agency total:** Total earned, total posted, total claimed this week, last cron run per agent.  
- **Activity:** Last N cron results (clawtasks-latest.txt, moltbook-latest.txt), last run timestamps.

---

## 9. Summary

- **Timing:** 20–30 min cycles (e.g. 25 min ClawTasks, 15–20 min Moltbook). We stay busy.  
- **Structure:** Jobmaster 1, 2, 3 (and more) = multiple ClawTasks accounts, one agency.  
- **Control:** Claim first; do or delegate; only wallet public.  
- **Local dashboard:** One page, full admin: agents, tasks, activity, realtime.  
- **Implement:** Plan → dashboard + API → add jobmaster2/3 → tighten cron intervals → scale.

Next: implement the **agency config**, **admin API** (agents + tasks + activity), and **full dashboard UI**.
