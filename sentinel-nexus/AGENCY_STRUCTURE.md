# Agency structure — roles and efficiency

## How the agency runs

- **One cron, every 5 minutes** (ClawTasks heartbeat). The cron uses the **lead** agent’s credentials (`clawtasks-credentials.json`).
- **Same flow for every agent** (when we add a multi-agent loop): get profile → check pending → claim open bounties → submit work → recruit (Moltbook) → post one free bounty.
- **Execution:** **Sequential**, not parallel. One cron job runs once per 5 min; it currently runs the flow for the lead agent only. Adding more agents (jobmaster2, jobmaster3) can be done in two ways:
  - **Option A (future):** One cron per agent — each runs every 5 min with its own credentials. True parallelism; more API load.
  - **Option B (current):** One cron, one run per cycle using the lead. To scale, we add a loop in the skill so the agent runs the same steps for each credential file in `agency-agents.json` (sequential over agents, still one cron).

## Roles

| Role   | Who        | What they do |
|--------|------------|----------------------------------------------|
| **lead**  | First agent in `agency-agents.json` | Used by the cron. Primary claimer, poster, recruiter. **Also does jobs** (same claim/submit loop as workers). |
| **worker** | Any other agent | Same capabilities; when we run a multi-agent loop, they run the same flow with their own key. More agents = more claims per cycle. |

All agents share the **same role capabilities**: claim bounties, submit work, post bounties, recruit on Moltbook. There is no separate “poster-only” or “claimer-only” agent; the structure is **efficiency through repetition** (same flow, more accounts = more throughput).

## Lead and workers: who does jobs, how completions count

- **Does the lead (jobmaster) do any job?** **Yes.** All enabled agents (including the lead) are in the same loop: **run-agency-cycle-now.sh**, **drain-free-work.sh**, and the dashboard "Run cycle" run **claim** and **submit** for every agent. So jobmaster (lead) claims and completes bounties like jobmaster2 and jobmaster3.
- **How do the others' jobs count for the lead?** They **don't**. Completions count **per agent** on ClawTasks: each agent has their own profile (earned, bounties_completed). jobmaster2's completions show on jobmaster2's profile; jobmaster's on jobmaster's. No automatic "credit" to the lead for workers' work.
- **Agency total:** The **agency** total (earned, completed) is the **sum** of all agents' stats. Dashboard and Analysis page show this sum plus per-agent breakdown.
- **Recommendation:** Leave as-is: lead and workers all do jobs; each builds their own profile; agency total = sum. To put all work under the lead only, we would use only the lead's credentials for claim/submit (workers would then be unused for claiming); we don't do that so every agent contributes and builds reputation.

## Making them start working

1. **Cron is already scheduled** — OpenClaw runs the ClawTasks job every 5 min.
2. **Run once now:**  
   `./sentinel-nexus/run-clawtasks-cron-now.sh`  
   (or from the dashboard, use “Claim all instant” to claim with the lead agent.)
3. **Start the admin server** so dashboard and workers are visible:  
   `node sentinel-nexus/admin/server.js`  
   Or full 24/7:  
   `./sentinel-nexus/run-agency-24-7.sh`

## Adding more agents

1. Register:  
   `AGENT_NAME=jobmaster2 OUT_CREDS_FILE=clawtasks-credentials-jobmaster2.json node sentinel-nexus/register-jobmaster-bot.js`
2. Add to `sentinel-nexus/agency-agents.json` with `"role": "worker"`, `"enabled": true`.
3. Restart the admin server. The dashboard and workers page will show the new agent and its role.
