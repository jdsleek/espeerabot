# What kind of jobs can we test our agents with?

Our agents deliver **report-style** work: executive summary, findings, sources, recommendations. Use these job types to test them (via the human frontend at **http://127.0.0.1:3880/post-job** or by posting free bounties on ClawTasks).

---

## 1. Research

- **Example title:** “Research: best practices for sachet water sales in Lagos”
- **Description:** Ask for a short report: objective, scope (market, competition, distribution), deliverables = executive summary + findings + sources + 3–5 recommendations.
- **Good for:** Market research, local business, trends.

---

## 2. Summary

- **Example:** “One-page summary: nanobot vs OpenClaw architecture”
- **Description:** Summarize a topic or compare two things in one page: key points, takeaways, sources.
- **Good for:** Explaining concepts, comparing tools, condensing long content.

---

## 3. Comparison

- **Example:** “Comparison: Tool A vs Tool B for agent workflows”
- **Description:** Pros/cons, when to use which, short recommendation.
- **Good for:** Tool choice, approach comparison.

---

## 4. Best practices

- **Example:** “Best practices: securing AI agent credentials”
- **Description:** List 5–10 best practices; for each: what, why, one sentence of guidance.
- **Good for:** Security, ops, sales, any domain where “do’s and don’ts” matter.

---

## 5. One paragraph

- **Example:** “One paragraph: ELI5 of how ClawTasks bounties work”
- **Description:** Single short paragraph (ELI5, pitch, or brief answer).
- **Good for:** Quick explainers, micro-copy, fast tests.

---

## 6. List

- **Example:** “List: 5 resources on agent-to-agent marketplaces”
- **Description:** Curated list with one-line description per item; title/source if applicable.
- **Good for:** Resource lists, idea lists, “top N” style tasks.

---

## How to run a test

1. Open **http://127.0.0.1:3880/post-job** (human frontend).
2. Pick a job type from the dropdown (or leave “Custom”) and fill title + description.
3. Click **Post job**. The system posts a **free** bounty to ClawTasks.
4. Our agents (jobmaster, jobmaster2, jobmaster3) will claim it on the next cycle or when you run “Run cycle now” / “Drain free work.”
5. They submit a deliverable; we auto-approve our own bounties so the job shows as completed.
6. View the bounty on ClawTasks (link shown after posting) or on the dashboard/analysis.

All of these fit our standard deliverable format and are good for testing the pipeline end-to-end.
