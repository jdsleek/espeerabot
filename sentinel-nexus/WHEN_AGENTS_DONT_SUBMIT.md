# When agents don’t submit — what’s in place (ours vs outside)

This doc describes what happens when a bounty is **claimed** but the claimer **doesn’t submit** work, and what mechanics exist for **our agency** vs **outside agents**.

---

## 1. Our own agents (jobmaster, jobmaster2, jobmaster3)

### In place

- **Run cycle (claim + submit + approve)**  
  `run-agency-cycle-now.sh` and the dashboard **“Run cycle now”** button:
  1. Claim instant bounties (excluding our own).
  2. **Submit** for each agent via `submit-2-pending.sh` (uses `/agents/me/pending`).
  3. **submit-human-front-claimed.sh** — fallback when a **human-front** job is **claimed by us** but **not listed in pending**. Submits by bounty ID using the claimer’s credentials so our claimed jobs don’t stay stuck.
  4. **Auto-approve** our own bounties so completed work shows as delivered.

- **Gateway / cron**  
  When the OpenClaw gateway is running, the brain runs every 5 minutes. If the cron is wired to run the same flow (claim → submit → submit-human-front-claimed → auto-approve), our agents will submit and complete without manual steps.

- **Manual unblock**  
  If something is still stuck (e.g. pending was empty for hours):
  - Run **Run cycle now** on the dashboard, or  
  - Run `./sentinel-nexus/run-agency-cycle-now.sh`  
  So: **we have a mechanic** for our agents not submitting: run cycle + human-front fallback script.

### Not in place (optional later)

- **Auto-release** if we decide we can’t deliver (e.g. brain reviews human-front jobs and releases back to pool). Mentioned in HUMAN_FRONT_JOBS.md; not implemented.
- **Timeout-based release** (e.g. “if we claimed and didn’t submit in 24h, release”). Not implemented.

---

## 2. Outside agents (other ClawTasks agents)

### When we **post** a bounty and an **outside agent** claims but doesn’t submit

- **Today:** We have **no automatic mechanic** in our codebase to “take back” or release the bounty from that claimer. The bounty stays in **claimed** on ClawTasks until:
  - The claimer submits, or
  - The **platform** does something (e.g. deadline, auto-release, or poster action), or
  - We implement a **poster-side** release/cancel.

- **ClawTasks platform:**  
  Bounties have `deadline_hours` (e.g. 24). The platform may support:
  - Poster **cancels** or **releases** a claimed bounty (API/UI).
  - Some **time-based** rule (e.g. claimer must submit within X or bounty reopens).  
  This is platform behaviour; we don’t currently call any release/cancel API.

- **Practical options now:**
  1. **Manual:** Use ClawTasks dashboard (or API if available) to cancel/release the bounty so it can be re-posted or claimed by someone else.
  2. **Later:** Add a script or dashboard action that calls ClawTasks **release/cancel** for bounties we posted that are **claimed** and **not submitted** for longer than X hours (if the API exists).

### When we **claim** a bounty from an **outside poster** and we don’t submit

- **Our side:** We added **submit-human-front-claimed.sh** and **run-agency-cycle-now** so **our** claimed bounties (especially human-front) get submitted even when they’re missing from `/agents/me/pending`. So our own “don’t submit” case is mitigated.

- **Poster (outside) side:** They have no control over our code. They rely on:
  - ClawTasks rules (e.g. deadline, stake, or release/cancel by poster if the platform allows).
  - Us actually running run cycle / gateway so we submit.

---

## 3. Summary table

| Scenario | Mechanic in place? | Notes |
|----------|--------------------|--------|
| **Our agent** claimed, didn’t submit (human-front) | **Yes** | `submit-human-front-claimed.sh` + run cycle submit by bounty ID; then auto-approve. |
| **Our agent** claimed, didn’t submit (open pool) | **Partial** | submit-2-pending uses pending list; if pending is empty we don’t submit unless it’s also in human-front (then fallback script runs). |
| **Outside agent** claimed **our** bounty, didn’t submit | **No** | No release/cancel in our code; rely on ClawTasks dashboard/API or platform rules. |
| **We** claimed **outside** bounty, didn’t submit | **Mitigated for us** | Run cycle + human-front fallback reduce the chance our claim sits unsubmitted; poster’s recourse is platform (deadline/release). |

---

## 4. Possible next steps (especially for outside agents)

1. **ClawTasks API:** Check whether ClawTasks exposes **release** or **cancel** for a claimed bounty (e.g. `POST /bounties/:id/release` or `cancel`). If yes, add a script or dashboard action: “Release bounties we posted that are claimed and not submitted for >24h.”
2. **HEARTBEAT / brain:** Optional step: “For human-front jobs we claimed, if we haven’t submitted within X hours, release back to pool (or mark for manual release).”
3. **Dashboard:** List “Our bounties: claimed, not submitted” (by us or by others) with age and, if API exists, a “Release” button.

Until then, **outside agents** that don’t submit are handled only by **ClawTasks platform** behaviour and **manual** poster action on ClawTasks.
