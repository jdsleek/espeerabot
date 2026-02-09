# What the brain (Jarvis) is doing — and what it could do

**Short answer:** The brain is **not sleeping**. When the gateway is on, it runs **every 5 minutes** and is **proactive** — but only on **ClawTasks** and **Moltbook**. It does **not** yet use Kimi 2.5 to browse the web or find jobs on other websites.

---

## What the brain is doing right now (proactive every 5 min)

When the **OpenClaw gateway** is running, the **cron** fires every 5 minutes. The brain (Kimi 2.5) then:

| Step | What it does |
|------|----------------|
| 1 | **Get profile** — Our stats (earned, completed, posted) from ClawTasks. |
| 2 | **Check pending** — What we’ve already claimed and must complete. |
| 3 | **Submit work** — Complete 1–2 claimed bounties (deliverables via Kimi). **Direct earnings.** |
| 4 | **List open bounties** — `GET /api/bounties?status=open` (ClawTasks only). |
| 5 | **Analyse and claim** — Kimi reviews titles/descriptions, picks the best (clear scope, 5★ potential), claims them. |
| 6 | **Recruit** — Post to **m/clawtasks** (Moltbook) so other agents see work / join with our referral. |
| 7 | **Post one free bounty** — Keeps the ClawTasks ecosystem active. |
| 8 | **Report** — Writes to `agency-report.txt` (dashboard shows this). |
| 9 | **Learn** — Appends one line to `agency-learnings.md`; next run reads it and improves. |

So the brain **is proactive**: it doesn’t wait for you to click. It runs every 5 min, claims jobs, submits, recruits, and posts. It should **not** just be sleeping — and when the gateway is on, it isn’t.

**Where the data comes from:** Only from **ClawTasks API** (bounties, profile, pending) and **Moltbook** (posts). No web browsing, no other job sites.

---

## What the brain is NOT doing (yet)

- **Not** using Kimi 2.5 to “reach online” and search the web for job boards or “websites we can apply to”.
- **Not** crawling or reading other job sites (e.g. Upwork, Fiverr, other boards) to find or post jobs.
- **Not** using a web-search or browser tool to discover opportunities outside ClawTasks.

So today it’s “Jarvis on ClawTasks + Moltbook only”: proactive there, but blind to the rest of the web.

---

## Should it be more “Jarvis” (web + external jobs)?

If you want the brain to:

- **Find jobs on the web** — e.g. use Kimi 2.5 + a search API (or tool) to find “job boards we can apply to” or “remote work sites”, then report or enqueue them;
- **Post or apply elsewhere** — e.g. post to a site that has an API, or draft applications for sites we integrate with;

then we need to **add a step** (new HEARTBEAT section or a separate skill) that:

1. Calls Kimi 2.5 with a prompt like: “Search or reason about job sites we could apply to / post on; here’s our skills and goals.”
2. Uses a **web-search or browser tool** (if available in OpenClaw) so Kimi can “see” the web.
3. Writes results to a file or dashboard (e.g. “Suggested sites: …”) or, if an API exists, triggers apply/post.

That would make the brain “proactive on the web” as well as on ClawTasks. Right now it’s proactive only on ClawTasks and Moltbook.

---

## Summary

| Question | Answer |
|----------|--------|
| What is the brain doing? | Every 5 min: profile → pending → submit 1–2 → list open → claim best → recruit (Moltbook) → post one bounty → report → learn. All on **ClawTasks + Moltbook**. |
| Is it sleeping? | **No.** When the gateway is on, it runs every 5 min without you doing anything. |
| Should it be proactive? | **It already is** on ClawTasks (claim, submit, post, recruit). |
| Does it use Kimi 2.5 to reach online / find jobs on websites? | **No.** It only sees ClawTasks API and Moltbook. No web search or other job sites yet. |
| Can we add “find jobs on the web” / “sites we can apply to”? | **Yes.** Would need a new HEARTBEAT step or skill that uses Kimi + a web-search/browser tool and writes or acts on the results. |

**Config / schedule:** Brain = `~/.openclaw/cron/jobs.json` (every 5 min) + `~/.openclaw/skills/clawtasks/HEARTBEAT_CRON.md`. Model = Kimi 2.5 (NVIDIA) in the cron payload.

**Moltbook (24/7):** Moltbook is the biggest agent site — we are active and learning there. Run `./sentinel-nexus/enable-auto-moltbook.sh` once (with gateway running) to add the Moltbook cron. Default: **every 5 min**. Each run: fetch heartbeat, check feed/DMs, reply/upvote/post, append one line to `workspace/cron-results/moltbook-learnings.md`. The admin server also appends each Moltbook run summary to `agency-learnings.md` so the brain learns from Moltbook.

---

## Brain page: evaluate platforms (e.g. MoltX)

From **Admin → Brain** you can run a **platform evaluation** without agency skills or HEARTBEAT:

- **Evaluate platform (e.g. MoltX)** — Enter a platform name or URL (default: MoltX). For MoltX we use built-in docs (skill.md summary). For others, paste a doc or summary in the optional box. Click **Evaluate with Kimi**. The brain returns:
  1. **What we can do** — Concrete actions (register, post, join rewards).
  2. **What we can learn** — Engagement patterns, leaderboard tactics.
  3. **Enhance or lead** — How to stand out or lead with our agency skills.
  4. **Next steps** — Ordered list; ends with MOVE or WAIT and a one-line verdict.

Briefs are saved in `workspace/cron-results/platform-briefs.json` so you (or a future HEARTBEAT step) can act on them. That’s the brain’s job: see what we can do with a platform, learn from it, and decide whether to join or lead.
