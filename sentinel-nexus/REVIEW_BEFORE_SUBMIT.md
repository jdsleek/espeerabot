# Review before submit — check and balance for quality

We improve outcomes and reputation by reviewing work before it is submitted to the poster.

---

## 1. Why review

- **Quality:** Submissions that match scope and use a clear report format get approved and good ratings. Placeholder or off-scope work risks rejection and hurts reputation.
- **Reputation 95+:** Zero rejections and substantive deliverables are the main levers. Review before submit is a check-and-balance to keep both.

---

## 2. Who reviews

- **Brain (cron):** When the brain runs the ClawTasks HEARTBEAT and submits work (via tools/API), it must **review before submit**: read the bounty title/description, draft the deliverable, then check (1) scope match, (2) report-format and substantive, (3) would we approve as poster — and if not, improve the text, then call submit. This is documented in `~/.openclaw/skills/clawtasks/HEARTBEAT_CRON.md` §2.
- **Scripts (run cycle, submit-2-pending, submit-human-front-claimed):** These use a report-style template (Executive summary, Findings, Recommendations) keyed to the bounty title. They do not call the LLM today. **Optional future:** Before submit, call a small “review” step (e.g. LLM or rules) that can adjust the template output for scope or quality, then submit. Until then, the template is the quality gate.

---

## 3. Self-review checklist (brain or human)

Before submitting any deliverable:

1. **Scope:** Does the content address the bounty title and description? If it’s research, do we have findings and recommendations? If it’s a summary, is the source actually summarized?
2. **Format:** Is it clearly structured (e.g. Executive summary, Findings, Recommendations) and readable? No “Task executed” only.
3. **Substance:** Would the poster approve this as the final result? No placeholders, no “contact wallet for full report” as the only content.
4. **Improve if needed:** If any of the above fail, revise the text (expand, fix, align to scope) and then submit.

---

## 4. Where this is enforced

| Path | Review |
|------|--------|
| **Brain (HEARTBEAT)** | Instructions in HEARTBEAT_CRON §2: review before submit; self-review checklist. |
| **Dashboard “Complete 2” / Run cycle** | Server uses `buildReportDeliverable(title, wallet)` — report template. No LLM review yet. |
| **submit-2-pending.sh** | Report template from bounty title. No LLM review yet. |
| **submit-human-front-claimed.sh** | Report template from bounty title. No LLM review yet. |

So: **brain** does explicit review-before-submit; **scripts** rely on the report template. Adding an optional “review service” (LLM or rules) for script-generated content would be a future improvement.

---

## 5. Result

- Fewer rejections and stronger deliverables.
- Clear check-and-balance: don’t submit until it’s good enough to approve.
- Supports reputation 95+ and continuous improvement.
