# Railway: Chat not replying (Control UI connected)

Control UI connects but when you send a message the agent doesn’t reply. Try these in order.

---

## 1. Start a fresh chat (do this first)

In the OpenClaw chat box type exactly:

```
/new
```

or

```
/reset
```

Then send a **short** message (e.g. “Hi” or “Hello”).  
If the main session had too much history (context overflow), a new transcript often fixes it.

---

## 2. Check logs when you send a message

1. Send **one** message in the Control UI.
2. In **Railway → your service → Deployments → View logs** (or the log stream), look at the lines that appear **right after** you send.
3. Look for any of:
   - `context overflow` / `prompt too large`
   - `minimax` / `provider` / `401` / `429`
   - `No API key` / `api_key`
   - `error` / `failed`

Paste that line (or a few lines) so we can see the real failure.

---

## 3. Confirm MiniMax API key on Railway

Setup should have saved your MiniMax API key. If it didn’t:

1. Open **https://espeerabot.up.railway.app/setup**
2. Re-enter MiniMax (or your model provider) and paste the API key again, then save/run setup.

---

## 4. If it still doesn’t reply

- Use a **new session**: in the Control UI, create or switch to a different session (e.g. “test”) and send a message there.
- Send only **short** messages until it works; avoid huge pastes so context stays small.

Summary: try **/new** or **/reset**, then one short message; if it still doesn’t reply, grab the log line that appears when you send and use that for the next fix.
