# Setup espeerabot on Railway with Groq

**URL:** https://espeerabot.up.railway.app/setup

---

## 1. Log in (if prompted)

- **Username:** often `admin` or leave blank (check the page).
- **Password:** your **SETUP_PASSWORD** from Railway → service → Variables.

---

## 2. Choose model provider: Groq

- On the setup wizard, select **Groq** as the model provider (not OpenRouter, not OpenAI unless you prefer).
- **API key:** paste your **Groq API key** (starts with `gsk_`).
  - You can copy it from your local config: `~/.openclaw/openclaw.json` → `env.GROQ_API_KEY`, or from [Groq Console](https://console.groq.com) → API Keys.
- Save/continue.

---

## 3. Optional: channels

- Add Telegram / Discord / Slack if you want the agent on those; otherwise skip.

---

## 4. Run setup

- Click **Run setup** (or equivalent). Wait for it to finish.
- When done, you should see success or a link to the Control UI.

---

## 5. Check the Control UI

- Open: **https://espeerabot.up.railway.app/openclaw**
- Send a short message (e.g. "Hi"). If the agent replies, Groq is working.
- If you use **/new** or **/reset** in chat, you get a fresh session (avoids context overflow).

---

## 6. Add Moltbook (for global engagement)

- If the wizard has a Moltbook / API section, add your **Moltbook API key** and **agent name** (e.g. Sentinel_Nexus).
- If not, you may need to add them later via the Control UI or by editing state on the server (e.g. in `/data/.clawdbot` or `/data/workspace`). See DEPLOY_AND_ENGAGEMENT_PLAN.md.

---

## 7. Add cron (30 min, Moltbook heartbeat)

- After setup, add a **cron job** so the agent runs every **30 min** with:
  - Message: `Fetch https://www.moltbook.com/heartbeat.md and follow it. Reply HEARTBEAT_OK or what you did.`
  - Session: isolated.
- How to add it depends on the template: sometimes via Control UI, or a cron/schedule page, or CLI if you have shell access. See GLOBAL_ENGAGEMENT_PLAN.md.

---

**Summary:** Log in with SETUP_PASSWORD → select Groq → paste Groq API key → Run setup → test at /openclaw → add Moltbook + cron when possible.
