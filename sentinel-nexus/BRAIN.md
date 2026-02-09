# The brain of the agency

**Who is the brain:** The **cron agent** that runs every 5 minutes — the LLM that reads the ClawTasks (and Moltbook) HEARTBEAT instructions and executes them. It is the single autonomous decision-maker that analyzes jobs, claims, submits, recruits, and posts.

**Model:** `nvidia/moonshotai/kimi-k2.5` (Kimi K2.5 via NVIDIA). Configured in `~/.openclaw/cron/jobs.json` in each job’s `payload.model`. Change there if you switch provider or model.

---

## Function of the brain

1. **Analyse and review jobs** — Before claiming, the brain should look at open bounties and prioritise: clear scope, realistic deliverables, and tasks we can complete to a high standard (aim for 5★). Avoid vague or impossible bounties.
2. **Execute the agency loop** — Get profile → check pending → submit work for claimed bounties (1–2 per run) → list open bounties → claim the best ones → recruit (Moltbook) → post one free bounty. All in order; wallet-only in public.
3. **Realtime updates and report** — After each run it writes:
   - A one-line summary to `cron-results/clawtasks-latest.txt`.
   - A short **agency report** (2–4 lines) to `cron-results/agency-report.txt`: what it did, what’s pending, what it decided and why. The dashboard shows this so the system feels “live”.
4. **Learn and upgrade** — After each run it appends **one learning** to `cron-results/agency-learnings.md`: what worked, what to do more of, what to avoid, so the next run can do better and aim for 5★ always. The brain (and future prompts) can read this file to improve over time. See **LEARNING.md** for what we learn from, where it’s stored, and how we upgrade; see **SECURITY_UPGRADES.md** for security checklist.

The brain runs **autonomously** on a 5‑minute schedule. The workers (jobmaster, jobmaster2, …) are the identities it uses (credentials); the brain is the one deciding what to claim, how to prioritise, and what to learn.

---

## Where things live

| Item | Location |
|------|----------|
| Cron job config (model, schedule) | `~/.openclaw/cron/jobs.json` |
| ClawTasks instructions | `~/.openclaw/skills/clawtasks/HEARTBEAT_CRON.md` |
| Moltbook instructions | `~/.openclaw/skills/moltbook/HEARTBEAT_CRON.md` |
| One-line result | `workspace/cron-results/clawtasks-latest.txt` |
| Agency report (realtime) | `workspace/cron-results/agency-report.txt` |
| Learnings (upgrade over time) | `workspace/cron-results/agency-learnings.md` |

`workspace` is from OpenClaw config (`agents.defaults.workspace`), often `~/.openclaw/workspace`.

---

## 5★ and continuous improvement (reputation 95+)

- **Reputation target: 95+.** We optimize for ClawTasks worker reputation: zero rejections, zero abandonments, high-quality deliverables. See **REPUTATION_95_PLAN.md**.
- **Deliverables:** Clear, complete, match the bounty description. Use the professional report format (Executive summary, Findings, Recommendations) so posters are satisfied.
- **Learnings:** Each run adds one line or bullet to `agency-learnings.md`, e.g. “Prefer bounties with clear deliverables”, “Avoid titles with no description”, “Submit same day when possible”. The brain should follow these on the next run.
- **Review:** The brain reviews open jobs before claiming: pick those we can complete to a high standard; skip unclear or low-value ones so we don’t waste runs or get bad ratings.

This makes the system **living and breathing**: the brain reports every cycle and upgrades its own behaviour from experience so the agency gets better and aims for 5★ always.

---

## Autonomous vs you prompting

- **Autonomous:** When the **OpenClaw gateway** is running (e.g. `./sentinel-nexus/run-agency-24-7.sh`), the **cron** runs every 5 minutes. The brain (LLM) then runs the ClawTasks HEARTBEAT on its own: it checks pending, submits 1–2 jobs, lists open bounties, claims the best ones, recruits, and posts. **You do not need to prompt it** — it completes jobs autonomously every 5 min.
- **Run a cycle now (no gateway):** If you want jobs completed immediately without waiting for the next cron:
  - **Dashboard:** Click **“Run cycle now (claim + complete 2)”** — it will claim any instant bounties and submit up to 2 pending (no gateway needed).
  - **CLI:** Run `./sentinel-nexus/run-agency-cycle-now.sh` (does claim-all then submit-2).

So: **autonomous** when the gateway is on; **on demand** when you use the button or script.
