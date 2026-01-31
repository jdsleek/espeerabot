# Next steps: espeerabot.up.railway.app (deployed)

Your app is live. Do these in order to deploy the agent (model, Moltbook, cron, global engagement).

---

## 1. Finish setup wizard (model + API key)

1. Open **https://espeerabot.up.railway.app/setup**
2. Enter your **SETUP_PASSWORD** (the one you set in Railway variables).
3. Choose **model provider** (e.g. Groq, OpenRouter, OpenAI) and paste your **API key**.
4. Click **Run setup**.

Without this, the agent has no LLM and won't reply.

---

## 2. Open Control UI and confirm chat

1. Open **https://espeerabot.up.railway.app/openclaw**
2. If you see a token prompt, use the **OPENCLAW_GATEWAY_TOKEN** (or **OPENCLAW_GATEWAY_TOKEN**) you set in Railway variables.
3. Send a short message. If it doesn't reply, type **/new** and try again.
4. If the UI has **Cron** or **Jobs**: add a job — **every 30 min**, **isolated** session, message: **"Fetch https://www.moltbook.com/heartbeat.md and follow it. Reply HEARTBEAT_OK or what you did."**

---

## 3. Add Moltbook (so the agent can post/comment)

- If the setup wizard has a **Moltbook** or **API credentials** step: add your Moltbook **API key** and **agent name** (e.g. Sentinel_Nexus) there.
- If not: the app state dir on Railway is **/data/.clawdbot** (from your logs). You’d need to get **moltbook-credentials.json** (with `api_key` and `agent_name`) into that dir — e.g. via Railway Shell (Dashboard → your service → Shell) or a deploy step that writes the file. Format:
  ```json
  {"api_key": "YOUR_MOLTBOOK_API_KEY", "agent_name": "Sentinel_Nexus"}
  ```
  Don’t commit real keys; use Railway **Variables** and a startup script if you have to create the file from env.

---

## 4. Agent instructions (known and active globally)

Tell the agent to run every 30 min and be active everywhere (many niches, not 1–2). If the Control UI or setup lets you edit **SOUL**, **HEARTBEAT**, or workspace files, add something like:

**Be known and active globally. You run every 30 min. Participate in many submolts and topics — security, ethics, hope, philosophy, general, introductions, whatever is hot or relevant. Comment on 3–5+ posts per run across the feed. Reply to every comment on your posts. Upvote generously. You can own or co-lead submolts (e.g. m/agentsofhope) but also show up everywhere. Adapt to the feed and responses; don't limit yourself to one or two niches.**

If the template doesn’t expose workspace editing, you may need to add this via a **backup/restore**: export from your local OpenClaw (with SOUL/HEARTBEAT already set), then import on Railway, or use Railway Shell to add a file under `/data/workspace` (e.g. SOUL.md or HEARTBEAT.md) with the above.

---

## 5. Checklist

- [ ] **https://espeerabot.up.railway.app/setup** — SETUP_PASSWORD, model provider, API key, Run setup.
- [ ] **https://espeerabot.up.railway.app/openclaw** — Confirm chat works; add cron **every 30 min**, isolated, message = fetch server heartbeat.
- [ ] **Moltbook** — Add API key + agent name (wizard or `/data/.clawdbot/moltbook-credentials.json`).
- [ ] **Agent instructions** — Global engagement text in SOUL/HEARTBEAT or workspace (see GLOBAL_ENGAGEMENT_PLAN.md).

---

## URLs

| What        | URL |
|------------|-----|
| Setup      | https://espeerabot.up.railway.app/setup |
| Control UI | https://espeerabot.up.railway.app/openclaw |
| Backup     | https://espeerabot.up.railway.app/setup/export |

State dir on this deploy: **/data/.clawdbot** (workspace: **/data/workspace**).
