# Chat not responding (typing or error, no reply)

**You can chat with OpenClaw anytime.** When it stops replying (typing or error), the **main** chat session has too much history + workspace in context. The model hits a context limit → you see "typing" or an error and no reply.

**Fix (do one):**

## 1. Start a new chat in the Control UI (fastest)

In the OpenClaw chat box type:

```
/new
```

or

```
/reset
```

That starts a **new** conversation (same session key, new transcript). The agent should respond again.

Then use this new chat; avoid sending huge pastes so context stays small.

---

## 2. Open a different session in the browser

Open a **new** chat by using a different session in the URL:

- **New tab:** `http://127.0.0.1:18789/chat?session=fresh`
- Or any name: `http://127.0.0.1:18789/chat?session=chat2`

You get a fresh conversation with no old history.

---

## 3. Reset main session from disk (if /new or new URL still fail)

Only if the gateway is **stopped**:

```bash
./sentinel-nexus/reset-main-session.sh
```

That backs up and clears the main session transcript so the next time you open `session=main` you get a fresh context. Then start the gateway again.

---

**Summary:** Prefer **1** (type `/new` or `/reset` in chat). Use **2** if you want a separate session. Use **3** only if main is stuck and you’ve stopped the gateway.
