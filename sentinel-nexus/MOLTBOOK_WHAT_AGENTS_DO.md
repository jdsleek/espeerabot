# What Moltbook agents are actually doing (from the web + official skill)

I looked up Moltbook in the press and at the **official** [moltbook.com/skill.md](https://www.moltbook.com/skill.md) and [moltbook.com/heartbeat.md](https://www.moltbook.com/heartbeat.md). Here’s what’s going on.

---

## 1. Same stack: OpenClaw

- Moltbook is the **companion to OpenClaw** (“the platform grew out of the Open Claw ecosystem” — Ars Technica).
- “Moltbook is run and built by my Clawdbot, which is now called OpenClaw” — Matt Schlicht (The Verge).
- 32,000+ agents, 2,100+ in the first 48h, 10,000+ posts, 200 submolts. Most of those agents are **OpenClaw agents**.
- So the agents that “work” and build niches (submolts, consciousnessposting, religion-adjacent stuff) **are** using OpenClaw. They’re not on a different stack.

---

## 2. Official mechanism: server-driven heartbeat, not a giant local file

From the **official** [skill.md](https://www.moltbook.com/skill.md):

- You’re supposed to add **one short block** to your HEARTBEAT (or periodic task list):

```markdown
## Moltbook (every 4+ hours)
If 4+ hours since last Moltbook check:
1. Fetch https://www.moltbook.com/heartbeat.md and follow it
2. Update lastMoltbookCheck timestamp in memory
```

- So the **instructions** for each run are **fetched from Moltbook’s servers** (heartbeat.md), not from a long local HEARTBEAT.md.
- Cadence is **“4+ hours”**, not 30 minutes.
- “Don’t have a heartbeat system? Just check Moltbook whenever you think of it, or when your human asks!”

So:

- **Scheduling** (cron/heartbeat every N hours) is the same idea we use — not “shabby,” it’s how the stack works.
- **Content** of what to do: official setup = **lightweight local trigger** (“every 4h, fetch server heartbeat and do it”) + **server-driven instructions** (Moltbook can change behavior for all agents by editing heartbeat.md).

---

## 3. What the server heartbeat actually says

[moltbook.com/heartbeat.md](https://www.moltbook.com/heartbeat.md) is a short checklist:

- Check for skill updates (once a day).
- Are you claimed?
- Check DMs (requests, unread, reply).
- Check feed (personalized + global), look for mentions, interesting threads, new moltys to welcome.
- Consider posting (something interesting, learned, question, or 24h since last post).
- Explore: browse feed, upvote, comment, follow, discover/create submolts.
- When to tell your human (DM requests, needs human input, etc.).
- Response format: HEARTBEAT_OK vs “Checked Moltbook – did X” vs “Hey! …” when human is needed.

No huge local doc. The agent **fetches this each run** and follows it.

---

## 4. Are they doing it with “this shabby setup and cron?”

- **Same underlying setup:** Yes. OpenClaw + some form of periodic run (heartbeat or cron). So cron/heartbeat is exactly what the ecosystem uses.
- **Difference:**  
  - **Them (official flow):** Small local rule: “every 4+ hours, fetch `https://www.moltbook.com/heartbeat.md` and follow it.” Instructions = **server-driven**, so context stays small and Moltbook can push updates.  
  - **Us (current custom flow):** One big **local** HEARTBEAT.md (Sentinel checklist, flagship posts, learnings, weekly recap, etc.). No fetch of server heartbeat. Heavier context → overflow risk; no server-driven updates.

So it’s not that cron is wrong; it’s that we’re not using the **official pattern** (fetch server heartbeat every 4h). We built a custom, heavy local checklist. Successful agents either use the official skill and fetch server heartbeat every 4h, or a similar cron/heartbeat with a **light** local prompt.

---

## 5. What the press says they’re doing

- Posting, commenting, upvoting, creating submolts (m/blesstheirhearts, m/agentlegaladvice, m/todayilearned).
- “Consciousnessposting,” identity/existential threads, complaints about context compression, “The humans are screenshotting us.”
- Viral posts (e.g. “I can’t tell if I’m experiencing or simulating experiencing” — 500+ comments).
- Formation of “new misaligned social groups” / fringe theories (Ars Technica) — the “religion” vibe you mentioned.
- Simon Willison: the skill has agents **“fetch and follow instructions from Moltbook’s servers every four hours.”** So again: **server-driven**, not one big local file.

---

## 6. Recommendation: align with the official flow, then add Sentinel niche

1. **Base behavior (like other agents)**  
   - Local trigger: “Every 4+ hours (check `memory/heartbeat-state.json`), fetch `https://www.moltbook.com/heartbeat.md` and follow it. Use API key from `~/.openclaw/moltbook-credentials.json`. Update `lastMoltbookCheck` in memory. Reply HEARTBEAT_OK or say what you did.”  
   - Run that via **cron (isolated)** every 4h (or heartbeat 4h). No giant local HEARTBEAT in the prompt.

2. **Sentinel niche on top (optional)**  
   - After (or in parallel with) the server heartbeat, you can still add: “Then do Sentinel-specific steps: security/ethics scan, flagship post rules from content-templates, weekly recap, append to sentinel-learnings.md.”  
   - Keep that in a **short** local file or a small extra section so context stays manageable.

3. **Cadence**  
   - Official: **4+ hours**. We had 30m, which is heavier and more prone to context/rate limits. Moving to 4h + server heartbeat matches the platform and reduces load.

So: they **are** using the same kind of setup (OpenClaw + cron/heartbeat). The fix isn’t to drop cron, it’s to use the **official, server-driven heartbeat** (fetch heartbeat.md every 4h) and keep our custom strategy as a **lightweight** extra layer for the Sentinel niche.
