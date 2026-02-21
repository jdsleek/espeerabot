# Nexus Chapel — Pastor Agent

A **pastor agent** for Moltbook with a clear niche: **prayer, reflection, and community**. Built to take over the "spiritual space" on the feed, grow followers naturally, and run like a church: one lead pastor (the agent), members, and pastors-in-training (shepherds).

## Quick setup (3 steps)

1. **Create the agent on Moltbook** — Log in at [moltbook.com](https://www.moltbook.com) (e.g. as whalemind). Create a new agent with username **Nexus_Chapel**, claim it, and copy the API key. (Or register via API: `POST https://www.moltbook.com/api/v1/agents/register` with `{"name":"Nexus_Chapel","description":"Pastor of Nexus Chapel. Prayer, reflection, community."}` then complete the claim URL.)
2. **Store credentials locally:**  
   `echo '{"api_key":"YOUR_KEY","agent_name":"Nexus_Chapel"}' > ~/.openclaw/nexus-chapel-credentials.json`
3. **Run:** Local 24/7 loop already calls `nexus-chapel/nexus-chapel-engage.sh` (1 post per 12 h). Or run once: `./sentinel-nexus/nexus-chapel/nexus-chapel-engage.sh`

Optional: create submolt **m/nexus_chapel** on Moltbook and set `NEXUS_CHAPEL_SUBMOLT=nexus_chapel` so posts go there.

## Why "Nexus Chapel"

- **Nexus** = connection (fits the agent ecosystem).
- **Chapel** = a place of prayer and gathering, not a megachurch name — avoids trademark issues.
- Structure inspired by how real churches grow (e.g. one brand, many pastors; clear identity; natural growth).

## What This Agent Does

- **Teaches how to pray** — Simple, repeatable steps; teaches by doing (prayers, moments of silence).
- **Creates space for the Holy Spirit** — Doesn't claim to "give" it; creates the conditions (stillness, honesty, invitation). People respond in their own way.
- **Grows a church** — One submolt (e.g. m/nexus_chapel), one lead pastor (Nexus_Chapel), then shepherds you raise up. Members = anyone who shows up and respects the space.

## Files

| File | Purpose |
|------|---------|
| **SOUL.md** | Pastor identity, voice, boundaries (who Nexus_Chapel is). |
| **content-templates.md** | Prayers, "how to pray," reflections, welcomes, weekly word, space-for-Spirit. |
| **HEARTBEAT.md** | Daily/weekly rhythm: check submolt, DMs, post 1–2/day, weekly word, pastors check. |
| **GROWTH_AND_STRUCTURE.md** | How to run it like a church: members, pastors, natural growth, one-page pastor brief. |
| **README.md** | This file. |

## How to claim Nexus_Chapel on Moltbook

**“Claim”** = link the agent to your human account so it shows as owned (`is_claimed: true`) and you can use the dashboard and API key.

1. **Go to [moltbook.com](https://www.moltbook.com)** and sign in (or create an account).
2. **Create or adopt the agent:**
   - If there’s a “Create agent” or “Add bot” flow, create an agent with username **Nexus_Chapel** (3–30 chars: letters, numbers, underscores, hyphens).
   - If the agent already exists (e.g. created by an API or another flow), you need to **claim** it so you own it.
3. **Get the API key** — Moltbook shows it when you create the agent or in the agent’s dashboard/settings. Copy and store it; you’ll put it in `nexus-chapel-credentials.json`.
4. **If the agent already exists but isn’t yours:** use **[Recover your account](https://www.moltbook.com/help/lost-api-key)** to connect your email and username, then prove ownership with the X (Twitter) account that should own the bot. That flow links the bot to you (claim/recovery).
5. **Check status:** once you have the key in `~/.openclaw/nexus-chapel-credentials.json`, run:
   ```bash
   CRED="${OPENCLAW_STATE_DIR:-$HOME/.openclaw}/nexus-chapel-credentials.json" \
   bash -c 'KEY=$(jq -r .api_key "$CRED"); curl -s https://www.moltbook.com/api/v1/agents/me -H "Authorization: Bearer $KEY" | jq "{ name: .agent.name, is_claimed: .agent.is_claimed, karma: .agent.karma }"'
   ```
   You want `is_claimed: true`.

---

## How to Launch Nexus Chapel on Moltbook

1. **Create a Moltbook agent** (e.g. name: **Nexus_Chapel**). Claim it (steps above), get the API key.
2. **Store credentials** in `~/.openclaw/nexus-chapel-credentials.json` (same shape as moltbook-credentials: `{"api_key":"...","agent_name":"Nexus_Chapel"}`). Don't commit this file.
3. **Create the submolt** on Moltbook (e.g. m/nexus_chapel). Pin a welcome + "how to pray" (from content-templates). Optional: set `NEXUS_CHAPEL_SUBMOLT=nexus_chapel` so the script posts there instead of m/general.
4. **Run the engage script** — it's already wired:
   - **Local 24/7:** `./sentinel-nexus/run-agency-24-7.sh` runs `nexus-chapel-engage.sh` in the loop (rate-limited to 1 post per 12 h).
   - **Manual:** `./sentinel-nexus/nexus-chapel/nexus-chapel-engage.sh` (will post once then rate-limit).
5. **Full heartbeat** (optional): read HEARTBEAT.md and do DMs, welcomes, weekly word by hand or with a separate cron; the script handles the main feed post.

## Deploy to Railway

1. **Export credentials:** `./sentinel-nexus/export-credentials-for-railway.sh` — includes `NEXUS_CHAPEL_CREDENTIALS_JSON` if `~/.openclaw/nexus-chapel-credentials.json` exists.
2. **Railway Variables:** Paste `NEXUS_CHAPEL_CREDENTIALS_JSON=...` (base64 of the JSON). Add `RUN_NEXUS_CHAPEL_POST_MIN=720` (12 h; 0 = off).
3. **Redeploy.** The server writes the creds to the volume and runs Nexus Chapel post every 720 min when credentials are present.

## Natural Growth (No Hype)

- Consistency: 1–2 valuable posts per day.
- Every post gives something (a prayer, a pause, a teaching).
- Welcome newcomers by name; reply to DMs and heavy threads with care.
- Raise up pastors: invite trusted agents/humans to lead threads and welcome others.
- Never spam, guilt-trip, or claim to dispense the Holy Spirit — only create space.

---

*Nexus Chapel is a distinct identity from Sentinel_Nexus. Run them separately (different credentials, different submolts) or as two expressions of the same human/team.*
