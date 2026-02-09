# Nothing showing in chat (your messages + bot replies)

If the OpenClaw chat UI shows nothing — not even your own messages — try these in order.

---

## 0. WebSocket connection to 'ws://localhost:8081/' failed

That error means the page is trying to connect to **port 8081**, but the OpenClaw gateway uses **port 18789** by default.

**Fix:**
1. **Use the gateway URL, not a dev server.** Open the Control UI at:
   ```
   http://127.0.0.1:18789/?token=YOUR_GATEWAY_TOKEN
   ```
   (Replace `YOUR_GATEWAY_TOKEN` with the value from `~/.openclaw/openclaw.json` → `gateway.auth.token`.)
2. **Ensure the gateway is running:** In a terminal run `openclaw gateway run`. You should see something like “listening on ws://127.0.0.1:18789”. Leave it running.
3. If you opened the UI from another app (e.g. a React/Vite app on port 8081), that app is pointing at the wrong port. Either open the URL above in the browser, or change that app’s WebSocket URL to `ws://127.0.0.1:18789`.

---

## 0a. "Context overflow" or "prompt too large" / 413 (Groq TPM)

If the UI acts like it’s replying but **nothing shows**, or you see **"Context overflow: prompt too large"** or **413 Request too large** in logs/transcript, Groq’s **on_demand** tier is rejecting the request: **TPM (tokens per minute) limit 10000**, and your prompt is over that.

**Fix:**
1. **Shrink bootstrap context** — In `~/.openclaw/openclaw.json` set `agents.defaults.bootstrapMaxChars` to **100** (or at most 200). Restart the gateway.
2. **Use a fresh session** — In chat, type **/new** or open a URL with a new session name (e.g. `?session=basic`). Old sessions have long history and push the request over the limit. **Long or multi-part messages are fine in a new session;** it’s the accumulated history that pushes you over 10k tokens.
3. **Upgrade Groq** — [Groq Dev Tier](https://console.groq.com/settings/billing) gives higher TPM so you can raise `bootstrapMaxChars` again.

---

## 0b. Loading/typing but no reply — "Failed to call a function" (Groq)

If the UI shows "loading" or typing then nothing appears, check the session transcript or gateway log. If you see **"Failed to call a function. Please adjust your prompt. See 'failed_generation'"**, Groq is rejecting the model's tool-call output.

**Fix:** Use **Groq Kimi K2 0905** (`groq/moonshotai/kimi-k2-instruct-0905`) which has better tool-calling. If you still see the error, update OpenClaw and retry.

---

## 0c. Cron: "Failed to call a function" (Groq)

If the **Cron** job posts **"Failed to call a function. Please adjust your prompt. See 'failed_generation'"** into chat, the cron session was using a Groq model that fails on tool calls (e.g. `llama-3.3-70b-versatile`).

**Fix:** Cron sessions are stored in `~/.openclaw/agents/main/sessions/sessions.json`. Each cron session entry (e.g. `agent:main:cron:<job-id>`) should use the same model as your main chat. For **Groq Kimi K2 0905** set `"modelProvider": "groq"` and `"model": "moonshotai/kimi-k2-instruct-0905"` (and `"contextTokens": 256000`). Save, then run the cron again.

---

## 0d. Local default: Groq / NVIDIA / Moonshot / OpenRouter

**This setup** can use **Groq Kimi K2 0905**, **NVIDIA NIM Kimi K2.5**, **Moonshot Kimi K2.5**, or **OpenRouter Kimi K2.5**. Set the matching API key in `~/.openclaw/openclaw.json` → `env` (e.g. `GROQ_API_KEY`, `NVIDIA_API_KEY`, `MOONSHOT_API_KEY`; `OPENROUTER_API_KEY` is already there). For **free full Kimi K2.5 (Vertu-style)** use **Moonshot** (get key at [platform.moonshot.ai](https://platform.moonshot.ai/console/api-keys)) or **OpenRouter** (free credits). See [SETUP_CHECKLIST.md](./SETUP_CHECKLIST.md) § Kimi K2.5 Vertu.

---

## 1. Hard refresh and clear site data

- **Chrome/Edge:** Open `http://127.0.0.1:18789` (with your token in the URL), press **F12** → **Application** tab → **Storage** → **Clear site data** for this origin. Then close the tab.
- **Safari:** Develop → Empty Caches, then close the tab.
- Or: use a **new incognito/private window** so there’s no old cache or state.

---

## 2. One tab, correct URL, fresh session

1. Close **all** tabs that have OpenClaw (127.0.0.1:18789).
2. Open **one** new tab and go **exactly** to (replace the token with yours from `~/.openclaw/openclaw.json` → `gateway.auth.token`):
   ```
   http://127.0.0.1:18789/chat?session=fresh2&token=YOUR_GATEWAY_TOKEN
   ```
   Using a **new** session name (`fresh2` or any new name) avoids old broken state.
3. Type a message and send. Wait 10–15 seconds.

---

## 3. Restart the gateway

Sometimes the gateway and UI get out of sync. Restart the gateway:

```bash
openclaw gateway stop
openclaw gateway run
```

Leave it running, then open the UI again in a **new** tab with the URL from step 2 (with token).

---

## 4. Try another browser

If you were on Chrome, try **Safari** (or the other way around). Open the same URL with the token and a fresh session. This rules out browser-specific cache or extensions.

---

## 5. Update OpenClaw

An old Control UI can have display bugs. Update and restart:

```bash
openclaw update
openclaw gateway stop
openclaw gateway run
```

Then open the chat URL again in a new tab.

---

**Summary:** Clear site data or use incognito → one tab, tokenized URL, **new session** (e.g. `session=fresh2`) → restart gateway if needed → try another browser → update OpenClaw. If it still shows nothing, check the browser console (F12 → Console) for red errors and note the message.
