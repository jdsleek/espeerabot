# Reputation 95+ — plan to keep worker reputation optimized

**Goal:** Keep ClawTasks worker reputation at **95+** at all times. Current state (e.g. 58 with 2 completions) improves as we add volume and quality; this plan ensures we build and hold 95+.

---

## 1. What likely drives reputation (ClawTasks)

From typical marketplace logic and our stats:

| Factor | We control | Target |
|--------|------------|--------|
| **Success rate** | Yes — only submit work we’re confident in; avoid rejections | Keep 100% (0 rejections) |
| **Bounties abandoned** | Yes — don’t claim what we can’t deliver; submit human-front via fallback | Keep 0 |
| **Quality of deliverables** | Yes — report format, match scope, no generic one-liners | High; posters approve and rate well |
| **Volume** | Partially — more quality completions = more positive signal | Grow without sacrificing quality |
| **Speed** | Partially — faster completion can help; 1.4h is reasonable | Keep &lt;2h where possible |
| **Rejections** | Yes — never submit bad or off-scope work | 0 |

So: **zero rejections, zero abandonments, and consistently strong deliverables** are the levers we optimize.

---

## 2. Plan (actions and ownership)

### A. Deliverable quality (biggest lever)

- **Current issue:** Scripts and run-cycle submit minimal text (“Task executed; contact wallet”). Posters expect real content (summary, findings, recommendations).
- **Action:**
  - Use **report-style deliverables** everywhere: Executive summary (1–2 sentences), Findings (bullets or short list), Recommendations (2–5 items). Match bounty title/scope where possible.
  - **submit-2-pending.sh:** Fetch bounty title (and description if available); build deliverable from template keyed to title/type (research → report; summary → summary blurb).
  - **submit-human-front-claimed.sh:** Already has title; use same report template (research/summary/task).
  - **Dashboard “Complete 2” and run-cycle (server.js):** Use same report template; pass bounty `title` and optional `description` into content builder.
- **Ownership:** Scripts + admin server; align with `bounty-posting-standard.md` and BRAIN.md “aim for 5★”.

### B. Claim selectivity (avoid bad fits)

- **Action:**
  - Only claim bounties with **clear scope** and **text deliverable** we can do well (research, summary, list, report). Skip vague titles, no-description, or mismatched types (e.g. image if we don’t support it).
  - Document in ClawTasks brain/HEARTBEAT (e.g. `~/.openclaw/skills/clawtasks/HEARTBEAT_CRON.md`): “Target 95+ reputation. Only claim bounties we can complete to a high standard; deliver report-format; zero rejections and zero abandonments.”
  - Brain reads `agency-learnings.md` and follows “prefer X, avoid Y” so it doesn’t re-claim bad-fit types.
- **Ownership:** HEARTBEAT_CRON + claim logic (brain/cron); claim-all-instant can stay broad for free instant, but brain should prioritise clear-deliverable bounties when choosing what to work on first.

### C. Zero rejections, zero abandonments

- **Rejections:** Don’t submit off-scope or placeholder-only work. Use report template so every submission is substantive.
- **Abandonments:** Ensure human-front and pending bounties always get submitted (submit-human-front-claimed + run cycle). If we ever add “release if we can’t deliver”, use it instead of abandoning.
- **Ownership:** All submit paths + run-agency-cycle-now; WHEN_AGENTS_DONT_SUBMIT.md for release policy.

### D. Visibility and learning

- **Dashboard:** Show reputation score when we have it from ClawTasks API (`/agents/me` → `reputation_score`). Add a “Target: 95+” line so we monitor.
- **Learnings:** Append to `agency-learnings.md` when we get a rejection or abandonment (if API exposes it), and when we deliver: “Delivered [title]; keep report format; target 95+.”
- **Ownership:** Admin server (agency API + dashboard); brain/scripts that append learnings.

### E. Speed (secondary)

- Keep run cycle and gateway running so claimed work is submitted within 1–2 cycles (e.g. &lt;15 min). Human-front fallback prevents long “claimed but not submitted” gaps. Avg completion time ~1.4h is acceptable; we can tighten later if the platform rewards faster completion.

---

## 3. Checklist (implement and maintain)

- [ ] **Deliverables:** All submit paths use report-style content (summary + findings + recommendations); no generic “Task executed” only.
- [ ] **submit-2-pending.sh:** Fetches bounty title (and description); builds deliverable from template.
- [ ] **submit-human-front-claimed.sh:** Uses same report template with bounty title.
- [ ] **server.js (Complete 2 + run-cycle):** Same report template; content includes bounty title and structure.
- [ ] **HEARTBEAT_CRON (ClawTasks):** Explicit “Target 95+; only claim clear-scope; report-format; zero rejections/abandonments.”
- [ ] **Dashboard:** Show reputation score and “Target: 95+” when available from API.
- [ ] **Learnings:** Brain and post-delivery logic reinforce “quality + 95+ target” in agency-learnings.md.

---

## 4. ClawTasks HEARTBEAT (brain) — add to `~/.openclaw/skills/clawtasks/HEARTBEAT_CRON.md`

Ensure the brain instructions include:

- **Reputation target: 95+.** Only claim bounties we can complete to a high standard. Deliver report-format (Executive summary, Findings, Recommendations). Zero rejections and zero abandonments.
- **Selectivity:** Prefer bounties with clear scope and text deliverable (research, summary, list, report). Skip vague titles or no description. Read `agency-learnings.md` and follow “prefer X, avoid Y”.
- **Quality:** Every submission must be substantive and match the bounty scope so posters approve and rate well.

---

## 5. Success criteria

- **Success rate:** 100% (0 rejections).
- **Abandoned:** 0.
- **Reputation:** 95+ once we have enough completions for the platform to show it (may need 10–20+ quality completions).
- **Deliverables:** Every submission is a clear, scope-matched report or summary, not a one-liner.

This keeps the system optimized for 95+ reputation through quality, selectivity, and consistent delivery.
