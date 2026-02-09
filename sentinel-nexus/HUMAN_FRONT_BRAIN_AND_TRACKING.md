# Human front: brain, learning, tracking, and why other agents don’t see your jobs

How the **brain** handles human-front jobs, whether we **learn** or do **reviews/corrections**, **who tracks** and **who updates** status, and **why other agents haven’t picked up** the jobs you posted.

---

## 1. What the brain is doing about the human front

**Today the brain does not have a dedicated “human front” step.** It runs the same loop for all work:

1. Get profile → check **pending** bounties (including any we claimed).
2. **Submit** work for 1–2 of those pending (our agents deliver the report).
3. List open bounties → claim more → recruit → post one bounty.

Human-front jobs are **our** bounties. We **claim them at post time** (jobmaster2/jobmaster3), so they show up in our **pending** list. When the brain runs “submit work for 1–2 pending,” it is **doing human-front jobs** whenever they’re in that pending set. So the brain **does** deliver them — it just doesn’t treat “human front” as a special category in the HEARTBEAT instructions.

**Learning:** The brain appends one learning per run to `agency-learnings.md` (what worked, what to avoid). Those learnings are **global** (all bounties, including human-front). We do **not** yet have a separate “human-front learnings” or “reviews/corrections for jobs from our site.” So:

- **Learning from human-front?** Indirectly yes — completions and failures feed into the same learnings. No separate human-front learning file yet.
- **Reviews/corrections on jobs?** No dedicated step. If we wanted “brain reviews human-front job and corrects scope or releases,” we’d add that to HEARTBEAT (e.g. “Read human-front-jobs.json; for each claimed human-front bounty, consider whether we can deliver; if not, release to pool”). Not implemented yet.

**Summary:** The brain delivers human-front jobs by including them in the normal submit step. It learns from all runs in one place. There is no special review/correction flow for human-front yet.

---

## 2. Who’s tracking? Who updates status?

**Tracking** = “where is this job (posted / in progress / delivered)?”

| Who | What they do |
|-----|----------------|
| **human-front-jobs.json** | Source of truth for *which* jobs came from our site. Written **once** at post time (bountyId, title, trackingToken, optional email, createdAt). **No one** writes status into this file. |
| **Status** | Computed **on demand** from ClawTasks. When you open the **track page** (`/job/track?token=...`) or the dashboard calls **GET /api/human-front-jobs/status**, we call ClawTasks **GET /bounties/:id** for each job and derive status (posted / in_progress / delivered). So **who updates?** No one — we **read** from ClawTasks when you ask. |
| **Dashboard** | “Jobs from our site” card fetches **GET /api/human-front-jobs/status** and shows each job with its **live status** (posted, in_progress, delivered). So **you** see the status when you load the dashboard. |

So: **tracking** is “list of jobs” in `human-front-jobs.json`; **status** is always **live from ClawTasks** when you open the track page or the dashboard. Nothing runs in the background to “update” status in a file.

---

## 3. Status on the 3 jobs you posted

To see the status of your 3 jobs:

1. **Dashboard:** Open **http://127.0.0.1:3880/dashboard**. The **“Jobs from our site (human front)”** card lists all human-front jobs with **status** (posted / in_progress / delivered). It calls the new **GET /api/human-front-jobs/status** so you see live status.
2. **Track page:** If you saved the **tracking link** for each job when you posted, open each link (e.g. `http://127.0.0.1:3880/job/track?token=...`) to see that job’s status and deliverable when delivered.
3. **ClawTasks:** Each job has a link to `https://clawtasks.com/bounty/{id}` in the dashboard (and on the track page). You can open it to see the bounty and any submission there.

So: **status of the 3 jobs** = look at the dashboard “Jobs from our site” card (with status badges) or use the track links / ClawTasks links.

---

## 4. Why haven’t other agents picked them up? Is it not free?

**They are free** (amount 0). **Other agents don’t see them** because we **claim them ourselves as soon as they’re created.**

When you post a job on our site:

1. We create a **free** bounty on ClawTasks (amount 0).
2. We **immediately claim** it with one of our workers (jobmaster2 or jobmaster3).
3. So the bounty **never appears in the “open” list** that other agents poll. It’s already claimed by us.

So: **other agents haven’t picked them up** not because the jobs are paid or hidden — it’s because **by design** we grab human-front jobs first so our agency delivers them. If we *didn’t* claim immediately, the jobs would sit in the open pool and other agents could claim them. We chose “our agency first” so that jobs from our human front are done by us.

**Summary:** The 3 jobs are free. They were claimed by our agency at post time, so they never went to the open pool and other agents never had a chance to take them. That’s intentional.

---

## 5. Why your claimed job might not be submitted yet (and how to fix it)

Human-front jobs are **claimed** by our workers (jobmaster2/jobmaster3) as soon as you post. They are **submitted** (deliverable sent for your review) when our system runs the **submit** step — either from the **cron (brain)** every 5 min or when you click **"Run cycle now"** or **"Complete 2 tasks now"** on the dashboard.

- **If the gateway isn’t running:** The cron doesn’t run, so no one submits. Fix: run `./sentinel-nexus/run-agency-24-7.sh` so the brain runs every 5 min, or click **"Run cycle now"** on the dashboard to submit (and auto-approve) immediately.
- **Submit runs for all agents:** We now run submit for **every** enabled agent (not just the lead). So if jobmaster2 claimed your job, their pending list is processed and your job gets submitted.
- **Human-front first:** When we have pending bounties, we **prioritize** jobs from the human front (our site). So your jobs are submitted in the first 2 slots when an agent has pending work.
- **Auto-approve:** After submit, we auto-approve our own bounties so the status becomes **Delivered** and you see the result. Run cycle does claim → submit → auto-approve in one go.

So: **to get your 3 jobs delivered now**, open the dashboard and click **"Run cycle now (all agents)"**. That will submit up to 2 pending per agent (human-front first) and then auto-approve. If you have 3 jobs, run it twice or use **"Drain free work"** to keep going until all are done.

---

## 6. Quick reference

| Question | Answer |
|----------|--------|
| Is the brain learning from human-front jobs? | It learns from all runs (including human-front) in `agency-learnings.md`. No separate human-front learning yet. |
| Reviews/corrections on human-front jobs? | No dedicated step. Brain just submits work for pending (which includes human-front). Could add “review and release if we can’t deliver” later. |
| Who’s tracking? | human-front-jobs.json = list. Status = computed live from ClawTasks when you open track page or dashboard. |
| Who updates status? | No one “updates” a file. Status is read from ClawTasks on demand (track page, GET /api/human-front-jobs/status). |
| Where do I see status for my 3 jobs? | Dashboard “Jobs from our site” card (with status), or each job’s track link, or ClawTasks bounty link. |
| Why haven’t other agents picked them up? | We claim them immediately. They’re free but never in the open pool — our agency has them from the start. |
| Why not submitted/delivered yet? | Submit runs every 5 min (brain) or when you click "Run cycle now" / "Complete 2 tasks now". We submit for all agents and prioritize human-front. See §5. |
| Work completed time? | Track page and dashboard show **Delivered at** and **Completed in X min** when the job is delivered. |
