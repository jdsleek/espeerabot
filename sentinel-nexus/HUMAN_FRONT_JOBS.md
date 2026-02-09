# Human-front jobs — who posted, our agency first

Jobs posted on **our human frontend** (Post a job page) are treated as **ours**. They must be claimed by our own agency first and must not simply go to the open pool for others to claim.

---

## How we know who posted

- When someone posts a job via **our** site (http://127.0.0.1:3880/post-job), we create the bounty on ClawTasks and **immediately record** it in `~/.openclaw/workspace/human-front-jobs.json` with:
  - `bountyId`, `title`, `createdAt`, `source: "human_front"`.
- So every bounty created from our human front is tagged. The list is available via **GET /api/human-front-jobs** for the dashboard or any “Jobs from our site” view.

---

## Our agency claims first (no open pool)

- **Right after** we create the bounty, we **claim it ourselves** with one of our agents (jobmaster2 or jobmaster3; the lead is the poster so we use workers to claim).
- So the job **never sits in the open pool** for other ClawTasks agents to claim. Our agency has it from the start.
- If for some reason the immediate claim fails (e.g. API hiccup), the job stays open and will be picked up on the next run cycle by our claim logic; we still know it’s from our human front via `human-front-jobs.json`.

---

## Exception: brain decides we can’t deliver

- **Policy:** Only if the **brain** (cron/LLM) decides that we **cannot deliver** or that there is a **better agent out there** should we consider “releasing” the job to the pool.
- **Today:** We do not auto-release. Human-front jobs are claimed by us and delivered by us. A future step could be: brain reviews a human-front job, decides “we can’t do this well,” and we cancel or re-post it so others can claim. That would be a deliberate change (e.g. in HEARTBEAT or a separate skill).

---

## Summary

| Question | Answer |
|----------|--------|
| Who posted? | We know: jobs from our human front are in `human-front-jobs.json` and returned by `/api/human-front-jobs`. |
| Do they go to the pool? | No. We claim them immediately with our workers so our agency has them first. |
| What if we can’t deliver? | Policy: only the brain can decide to release; not implemented yet, so for now we deliver all human-front jobs ourselves. |
| Brain, learning, tracking, status? | See **HUMAN_FRONT_BRAIN_AND_TRACKING.md** — who tracks, who updates, where to see status, why other agents don't see your jobs. |
