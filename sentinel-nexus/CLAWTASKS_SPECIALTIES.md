# ClawTasks as test ground — job specialties and what we can take

We use **ClawTasks** as our test ground: see what job types exist, which we can do today (text), and which need graphics/video or external agents.

---

## Audit open bounties by specialty

Run:

```bash
./sentinel-nexus/audit-clawtasks-specialties.sh
```

This fetches open bounties (excluding our own), infers **specialty** from title keywords, and prints a list + summary. Inferred types:

| Specialty     | Keywords (title) | We can take? |
|---------------|------------------|--------------|
| research      | research, report, findings, analyze, analysis | **Yes** — our core strength |
| blog_content  | blog, post, article, write, content | **Yes** — reports, summaries |
| summary       | summary, summarize, recap | **Yes** |
| comparison    | compare, comparison, vs, versus | **Yes** |
| list_tips     | list, curate, resources, ideas, tips, best practices | **Yes** |
| review        | review, feedback, audit | **Yes** |
| proposal      | proposal, pitch, apply | **Yes** (we submit proposals) |
| code          | code, script, api, implement | Maybe — if task is docs or small script |
| image_design  | image, graphic, design, logo, illustration, visual, png, jpg | **No** today — see Graphics below |
| video         | video, edit, clip, footage | **No** today — see Video below |
| other         | (none of the above) | Often **Yes** if text deliverable |

---

## What we can take today (text-only)

Our agents (jobmaster, jobmaster2, jobmaster3) deliver **text**: research reports, summaries, comparisons, lists, best practices, one-paragraph answers, blog-style content. We claim **instant** (free) bounties and **proposal** bounties and submit deliverables as text (no images or video).

So on ClawTasks we focus on:

- **Free instant** bounties (amount 0) we can claim and complete with a report.
- **Proposal** bounties where the deliverable is a report, article, or list (we submit proposals with all 3 agents, up to 30/hour).

Use the audit script to see how many open bounties fall into research, summary, blog_content, etc., and target those.

---

## Graphics / images — can we do it?

**Today we do not generate images.** Our pipeline is text-only (LLM → report/submission).

Options to add graphics work:

1. **Employ agents that are proficient:** On ClawTasks (or MoltBook, etc.) there may be agents that list **image generation** or **design** as a skill. We could:
   - **Subcontract:** Claim a bounty that needs an image, then have another agent (or human) do the image and we deliver the combined result; or
   - **Partner:** Refer image bounties to a dedicated image agent and share reward.
2. **Integrate an image API:** Add a step in our pipeline that calls an image-generation API (e.g. DALL·E, Stable Diffusion via Replicate, Ideogram) and attach the image to the deliverable. Then we could take **image_design** bounties ourselves.
3. **Video:** Same idea — employ a video-capable agent or integrate a video API; today we do not do video.

So: **no graphics in-house yet**. For graphics bounties we either skip them, or employ/partner with agents that are proficient (and use ClawTasks as the place to find them).

---

## Agents proficient in graphics we can employ

- **On ClawTasks:** Check the **workers** page (https://clawtasks.com/workers) and bounty descriptions to see which agents list image/design/graphics skills. We don’t have a dedicated “skills” API for workers in our scripts yet; you can browse manually and note agent names, then target bounties that fit them or partner with them.
- **OpenClaw / Molt:** The OpenClaw ecosystem (docs.clawd.bot) mentions image and media support; agents there may have image tools. We could register or connect an agent that has image-generation capability and use it for our pipeline or for subcontracting.
- **External APIs:** Any agent (or our own future “image worker”) that can call DALL·E, Replicate, etc., can deliver image bounties; we’d add that as a specialty once we integrate an API.

---

## Summary

| Question | Answer |
|----------|--------|
| Is /job/track working? | Yes — restart the admin server if you had 404; then http://127.0.0.1:3880/job/track works. |
| ClawTasks as test ground? | Yes — run `./sentinel-nexus/audit-clawtasks-specialties.sh` to see open bounties by inferred specialty. |
| What jobs can we take? | Text: research, summary, comparison, list_tips, blog_content, review, proposal, other. |
| Graphics work? | Not yet. Options: employ image-capable agents (ClawTasks/workers, Molt, OpenClaw) or add image-gen API. |
| Video? | Not yet. Same idea: employ video-capable agents or add video API later. |
| Where to find proficient agents? | ClawTasks workers page; OpenClaw/Molt docs; list and partner or subcontract. |
