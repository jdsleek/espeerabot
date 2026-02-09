# Admin dashboard review — what’s wrong and how to fix it

**Problem:** The dashboard has grown into many blocks with overlapping info and jargon. It’s hard to see “what’s the status” and “what should I do” at a glance.

**Status: Applied.** Dashboard restructured as described below; doc kept for reference.

---

## What’s on the page today (in order)

| # | Section | What it shows |
|---|--------|----------------|
| 1 | **Earnings — wake up to this** | Big USDC number + one line about autonomy |
| 2 | **Jobs — claim hierarchy (all open, not ours)** | Table of 50 open bounties + 4 buttons (Run cycle, Drain, Claim all instant, Complete 2 tasks) |
| 3 | **Jobs from our site (human front)** | List of jobs posted via “Post a job” and their status |
| 4 | **Agency overview** | Agent count, total earned (again), posted, pending, completed, ClawTasks links |
| 5 | **Earn — make money** | Short text + links to ClawTasks + pitch docs |
| 6 | **MoltX (autonomy)** | Status + claim tweet + URL input (when pending) |
| 7 | **Agency structure** | “One cron, 5 min, claim → submit → post → recruit” |
| 8 | **Brain (autonomous)** | Model name, report snippet, learnings |
| 9 | **Landing page review** | Button to run Kimi review of landing page |
| 10 | **Agents (roles)** | One card per agent (earned, posted, completed, reputation, wallet) |
| 11 | **Cron jobs** | List of cron names + last status + last run time |
| 12 | **Latest cron results** | Short text snippets from ClawTasks and Moltbook runs |
| 13 | **Activity (realtime)** | Same kind of snippets as “Latest cron results” |

---

## What’s confusing

### 1. Duplication
- **Total earned** appears in the top “Earnings” card and again in “Agency overview”.
- **“Run cycle” / autonomy** is mentioned in Earnings, Jobs block, and Brain.
- **Cron output** is split across “Latest cron results” and “Activity” with no clear difference.

### 2. Jargon
- **“Claim hierarchy (all open, not ours)”** — “hierarchy” and “not ours” are unclear; it’s really “open bounties we can claim”.
- **“Human front”** — internal name; better: “Jobs posted on our site” or “Our site jobs”.
- **“Drain free work”** — what “drain” means is not obvious.
- **“Instant to claim” / “Need proposal”** — only clear if you know ClawTasks modes.
- **“Cron”** — technical; “scheduled tasks” or “auto-runs” is clearer.
- **“Gateway”** — only makes sense if you know OpenClaw.

### 3. Too many actions in one place
Four buttons in a row:
- **Run cycle now** — claim + submit + approve (main “do work” action).
- **Drain free work** — loop until no instant left (advanced).
- **Claim all instant** — only claim, no submit.
- **Complete 2 tasks now** — only submit, no claim.

Most users need “Run cycle now” most of the time. The others are secondary and could be grouped under “More actions” or moved to a separate “Advanced” area.

### 4. No clear “at a glance” vs “details”
Everything has similar visual weight. There’s no obvious “status strip” (earnings + are we working + any action needed) and then “details below”.

### 5. Unclear grouping
- **Money:** Earnings, Agency overview, Earn — three different cards that all relate to earning.
- **Work to do:** Jobs table + 4 buttons — one big block that mixes “what’s available” and “what to click”.
- **Systems:** Brain, Cron jobs, Latest results, Activity — four blocks about “how it runs” with overlap.

### 6. MoltX and “one human step” are easy to miss
MoltX is one card in the middle of the grid. If the user needs to “post tweet and paste URL”, that should be very visible when it’s pending (e.g. top strip or prominent banner).

### 7. Order
- Good: Earnings at top.
- Then: immediately a long table and four buttons, so the “simple” status (earnings + agents + any pending action) gets lost.
- “Agency overview” repeats the earnings number and could be merged into a single “Status” block.

---

## Recommended direction (high level)

1. **One “Status” strip at the top**
   - Total earned (once).
   - Short line: “Agents: X · Pending: Y · Instant available: Z” (or similar).
   - If MoltX needs the one human step: **banner** “Post MoltX claim tweet and paste URL” with link to the form (or inline).

2. **One “Do this” area**
   - Primary: **Run cycle now** (with one short line: “Claim, submit, and approve work”).
   - Secondary / “More actions”: Claim all instant, Complete 2 tasks, Drain (as a small link or collapsible “Advanced”).

3. **Rename and group**
   - “Jobs — claim hierarchy (all open, not ours)” → **“Open bounties we can claim”** (and optional subtitle: “From ClawTasks, not posted by us”).
   - “Jobs from our site (human front)” → **“Jobs posted on our site”** (and optional: “Posted via Post a job; we claim first”).
   - Merge **Agency overview** and **Earn — make money** into one **“Agency & earnings”** card (one USDC number, key counts, main ClawTasks links).
   - **Cron jobs** + **Latest cron results** + **Activity** → one **“How it’s running”** section: list of schedules + last run + last output (one place).

4. **Less repetition**
   - Show “total earned” only in the top Status strip (and optionally in Agency & earnings if you keep that card).
   - One place for “last run / last output” instead of two (Latest cron results + Activity).

5. **Clearer labels everywhere**
   - Replace “Cron” with “Scheduled task” or “Auto-run” where it’s user-facing.
   - Replace “Human front” with “Our site jobs” or “Jobs from our site”.
   - Add one-line explanations for “Instant” and “Proposal” (e.g. “Instant = claim immediately; Proposal = submit proposal first”).

6. **MoltX**
   - When status is “registered, not claimed”: show a **persistent banner** at top or right under Status: “MoltX: post the claim tweet, then paste the tweet URL here” with the form inline or a single link to the card.

---

## Summary table

| Issue | Change |
|-------|--------|
| Duplicate “total earned” | Show once in top Status strip; remove or fold into one “Agency & earnings” card |
| Jargon (“hierarchy”, “human front”, “cron”, “drain”) | Rename and add one-line explanations |
| Four buttons with similar names | One primary “Run cycle now”; rest under “More actions” or Advanced |
| No at-a-glance vs details | Add Status strip (earnings + agents + pending + MoltX if needed); group details below |
| MoltX easy to miss | When pending claim: banner or prominent block “Post MoltX tweet and paste URL” |
| Cron / results / activity overlap | Single “How it’s running” section: schedules + last run + last output |

If you want, next step is to implement these changes in `index.html`: restructure the grid, add the Status strip, rename sections, merge duplicates, and make MoltX and “Run cycle now” the clear focal points.
