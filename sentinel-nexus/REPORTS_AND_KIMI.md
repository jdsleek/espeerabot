# Reports, Kimi 2.5, and customer feedback

## Does the current result answer the job?

**Short answer: often no.** Right now, when we submit a human-front job we send a **template** (Executive summary, Findings, Recommendations) built from the bounty title. We do **not** send real research or real “5 resources on X” or real comparison. So for a job like “on the latest scam vote in the nigeria senate … 5 resources on X”, the poster gets a structured placeholder, not five actual X/Twitter links or analysis. It looks like a report but doesn’t fully answer the brief.

**To really answer the question** we need the **brain or Kimi 2.5** to generate the content (research, links, comparison) and then we submit that.

---

## Full report page

You can see the **full report** (full deliverable text) for any delivered job:

- **URL:** `http://127.0.0.1:3880/job/report?token=YOUR_TRACKING_TOKEN`
- From the **track page**, when the job is delivered, use **“View full report →”** to open this page.

No truncation; the whole deliverable is shown so you can review it properly.

---

## Using Kimi 2.5 to do the job fully

**Goal:** For each human-front job, have Kimi 2.5 (or the brain) produce the actual report/content, then we submit that instead of the template.

**Ways to do it:**

1. **Direct API at submit time (recommended first step)**  
   When we are about to submit a human-front job (in the server’s run-cycle or in `submit-human-front-claimed.sh`), instead of calling `buildReportDeliverable(title, wallet)` only:
   - Call the **Kimi API** (Groq/NVIDIA/Moonshot) with a prompt that includes the **bounty title and description** and asks for a real report (e.g. “Research: … 5 resources on X” → produce summary + 5 X links + short commentary).
   - Use the **model’s reply** as the deliverable and submit that (with a fallback to the current template if the API fails or times out).

2. **Brain (OpenClaw cron) does the work**  
   The HEARTBEAT skill is extended so that for human-front bounties we’ve claimed, the brain:
   - Reads the bounty title/description.
   - Uses the LLM (Kimi 2.5) to generate the report.
   - Submits that report via the ClawTasks API.

3. **Hybrid**  
   Scripts do claim + auto-approve; a separate “report generator” job (triggered by cron or by the cycle) generates the content via Kimi 2.5 and writes it somewhere the submit step can read (e.g. a file keyed by bounty ID), and the next cycle submits that content.

**Practical next step:** Add an option (e.g. env or config) to “use Kimi for human-front reports”. When set, the server (or a small script) calls the same Kimi API we use for the report-demo, with a prompt built from the bounty title + description, and the returned text is what we submit. That uses Kimi 2.5 to the fullest for that job type.

---

## Continuing / updating the report from customer feedback

**Is it possible? Yes**, with some design choices.

**Ideas:**

1. **Feedback on our site**  
   - On the **full report** page (or track page), add a short **“Send feedback”** form (e.g. “What should we add or change?”).
   - Store feedback by `bountyId` or tracking token (e.g. in a JSON file or DB).
   - A **scheduled job or manual trigger**:
     - Loads the original bounty + deliverable + feedback.
     - Calls Kimi 2.5 with a prompt like: “Original report: … Customer feedback: … Produce an updated report that addresses the feedback.”
     - We then need a way to get the updated report to the customer:
       - **If ClawTasks allows** re-submit or “revision”: submit the new report there.
       - **Otherwise:** show the updated report on our side (e.g. “Revised report” section on the full report page) and optionally email/link it.

2. **ClawTasks as source of feedback**  
   If the poster comments or rejects on ClawTasks, we could (if we have an API or scrape) read that and treat it as feedback, then run the same “update report from feedback” flow above.

3. **Iteration limit**  
   To avoid unbounded cost, cap iterations (e.g. one revision per job, or only if feedback is provided within 7 days).

**Minimal implementation:**  
- Add a **“Send feedback”** form on the full report page.  
- Save feedback to a file (e.g. `workspace/job-feedback.json` keyed by token or bountyId).  
- Add an **“Update report from feedback”** action (button or cron) that: reads deliverable + feedback, calls Kimi 2.5 to produce an updated report, and either (a) shows it on a “Revised report” page or (b) submits it if the platform allows.

---

## Summary

| Question | Answer |
|----------|--------|
| Does the current result answer the job? | Often **no**; it’s a structured template. Real content needs Kimi 2.5 or the brain. |
| Where can I see the full report? | **Full report page:** `/job/report?token=...` or “View full report →” on the track page. |
| Can Kimi 2.5 do the job fully? | **Yes.** Use the same Kimi API at submit time with a prompt built from the bounty; submit the model output instead of the template. |
| Can we update the report from customer feedback? | **Yes.** Collect feedback (e.g. on the report page), store it, then run Kimi 2.5 with “original report + feedback → updated report” and show or re-submit the update. |

Next concrete steps can be: (1) add “Kimi-generated report” for human-front submits (with template fallback), and (2) add a feedback form plus “Revised report” view or re-submit.
