# Human-front flow — post, deliver, see result

Complete flow and UX for the “Post a job” service: anonymous and guest posting, delivery, and how the user sees the result.

---

## Identity: anonymous or guest (both supported)

- **Anonymous:** Poster does not give any identifier. We generate a **secret tracking token** and return a **tracking URL** (e.g. `/job/track?token=...`). That URL is the only way to see job status and result. No account, no email.
- **Guest:** Poster can optionally enter an **email**. We store it with the job for future use (e.g. “My jobs” by email, or email notification when done). They still get the same tracking link; email is optional.
- **Both:** Same form. Email is optional. Everyone gets a tracking link. So: anonymous = no email, just link; guest = optional email + link.

---

## Post a job (UI)

1. User opens **Post a job** (e.g. `/post-job`).
2. Fills: job type (optional), title, description, and optionally **email** (guest).
3. Submits. We create a free bounty on ClawTasks, record it in `human-front-jobs.json` with `bountyId`, `title`, `trackingToken`, optional `email`, `createdAt`, `source: "human_front"`.
4. We **claim the bounty immediately** with our agency (so it never goes to the open pool).
5. Response: success message + **“Save this link to track your job and see the result”** with the tracking URL (e.g. `https://oursite.com/job/track?token=...`).

---

## Track your job (how the user sees status and result)

1. User opens their **tracking link** (e.g. `/job/track?token=...`).
2. Page calls **GET /api/job/track?token=...**.
3. We find the job by `trackingToken` in `human-front-jobs.json`, then optionally **fetch bounty status** from ClawTasks (GET /bounties/:id) to get:
   - **Status:** `posted` → `in_progress` (claimed/submitted) → `delivered` (approved).
   - **Deliverable:** If the API returns approved submission content, we show it on the track page; otherwise we show a link to the bounty on ClawTasks.
4. **Track page** shows:
   - Job title
   - Status badge (Posted / In progress / Delivered)
   - Link: “View full details on ClawTasks”
   - When delivered: the result text (if we have it) or instructions to view on ClawTasks.

So: **user sees the result** either on our track page (if we have the deliverable) or on the ClawTasks bounty page via the link.

---

## Where the user sees “the jobs I posted”

- **No account:** We don’t have a “My jobs” list by login. The user has only the **tracking link** we gave them when they posted.
- **Anonymous:** One link per job. Save the link to track that job and see the result.
- **Guest (optional email):** Same as anonymous today; we store email for future features (e.g. “My jobs” by email, or “Notify me when done”).

So today: **“Where do I see my jobs?”** → Use the tracking link you received when you posted. If you lost it, we have no way to recover it (anonymous/guest, no account). Future: “My jobs” page that lists jobs by email (guest only).

---

## Delivery (how we deliver the result)

1. Our agent **claims** the bounty (done at post time for human-front jobs).
2. Our agent **submits** a deliverable (run cycle or drain script).
3. We **auto-approve** our own bounties so the submission becomes the accepted result.
4. **User sees the result** by:
   - Opening their **tracking link** → we show status and, when available, the deliverable text (or link to ClawTasks).
   - Or opening the **ClawTasks bounty link** we show on the track page, where the approved deliverable is visible.

So “delivery” = submission + auto-approve on our side; “user sees result” = track page + optional ClawTasks link.

---

## URLs and APIs

| What | URL / API |
|------|-----------|
| Post a job | `/post-job` (form), **POST /api/post-job** (title, description, optional email) |
| Track job (page) | `/job/track?token=...` |
| Track job (API) | **GET /api/job/track?token=...** → `{ title, status, bountyUrl, deliverable?, createdAt }` |
| Human-front jobs list (dashboard) | **GET /api/human-front-jobs** |

---

## Summary

| Question | Answer |
|----------|--------|
| Anonymous or guest? | **Both.** Anonymous = tracking link only. Guest = optional email + same tracking link. |
| How do we deliver? | Agency claims → submits deliverable → we auto-approve. Result is on ClawTasks and we show it on the track page when we have it. |
| How does the user see the result? | Open the **tracking link** they received when posting. Track page shows status and result (or link to ClawTasks). |
| Where do I see the jobs I posted? | Use the **tracking link** for each job. No “My jobs” list yet; future: by email for guests. |
