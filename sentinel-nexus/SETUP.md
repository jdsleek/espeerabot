# OpenClaw from scratch

One path: install → config → workspace → run → open UI. Then optional deploy.

---

## 1. Install OpenClaw

- **macOS:** `brew install openclaw` or see https://openclaw.ai
- Or: `npm i -g openclaw`

Check: `openclaw --version`

---

## 2. Config

Create or replace `~/.openclaw/openclaw.json` with a minimal config.

**Option A — Use the template**

Copy `sentinel-nexus/openclaw-config-template.json` to `~/.openclaw/openclaw.json`. Then edit:

- `env.GROQ_API_KEY` → your key from [console.groq.com](https://console.groq.com)
- `gateway.auth.token` → any long random string (e.g. `openssl rand -hex 24`). You’ll use this in the UI URL.

**Option B — Minimal JSON by hand**

```json
{
  "gateway": {
    "mode": "local",
    "bind": "loopback",
    "auth": { "token": "YOUR_GATEWAY_TOKEN" }
  },
  "agents": {
    "defaults": {
      "workspace": "/path/to/your/workspace",
      "model": { "primary": "groq/moonshotai/kimi-k2-instruct-0905" }
    }
  },
  "env": {
    "GROQ_API_KEY": "YOUR_GROQ_API_KEY"
  },
  "models": {
    "mode": "merge",
    "providers": {
      "groq": {
        "baseUrl": "https://api.groq.com/openai/v1",
        "apiKey": "${GROQ_API_KEY}",
        "api": "openai-completions",
        "models": [
          { "id": "moonshotai/kimi-k2-instruct-0905", "name": "Kimi K2 0905", "contextWindow": 256000 }
        ]
      }
    }
  }
}
```

Replace `YOUR_GATEWAY_TOKEN`, `YOUR_GROQ_API_KEY`, and `workspace` path.

**Use Hugging Face (if Groq gives no reply in the UI)**  
HF Inference often works when the Control UI doesn’t show Groq replies. Do this in `~/.openclaw/openclaw.json`:

1. In **`env`**, add: `"HF_TOKEN": "YOUR_HF_TOKEN"` (get a token at [huggingface.co/settings/tokens](https://huggingface.co/settings/tokens) with “Make calls to Inference Providers”).
2. In **`models.providers`**, add the `hf-inference` block from `sentinel-nexus/openclaw-config-template.json` (or from `add-hf-provider.json`).
3. Set **`agents.defaults.model.primary`** to: `"hf-inference/moonshotai/Kimi-K2.5:novita"`.
4. Restart the gateway.

The template already includes HF; if you use it, set `HF_TOKEN` and keep primary as `hf-inference/moonshotai/Kimi-K2.5:novita`. Note: HF Inference can bill after a small free tier.

---

## 3. Workspace

Your agent needs a workspace folder with at least:

- `SOUL.md` — who the agent is
- `AGENTS.md` — how it behaves

Copy from this repo into `~/.openclaw/workspace` (or your chosen path) and set that path in config as `agents.defaults.workspace`.

Optional: `HEARTBEAT.md`, `content-templates.md`, `TOOLS.md` (see repo).

---

## 4. Run gateway

```bash
openclaw gateway run
```

Leave it running. You should see “listening on ws://127.0.0.1:18789”.

---

## 5. Open Control UI

In the browser open:

```
http://127.0.0.1:18789/?token=YOUR_GATEWAY_TOKEN
```

Use the **exact** token from `gateway.auth.token` in your config. Bookmark this URL.

**Chat:** Go to the Chat tab. Prefer a **new session** (e.g. open `http://127.0.0.1:18789/chat?session=fresh&token=YOUR_GATEWAY_TOKEN`) so the first reply shows up. Send a short message (e.g. “Hi”) and wait a few seconds.

**One-click launcher:** Edit `openclaw-launch.html` in this repo: replace `YOUR_GATEWAY_TOKEN` with your token, then open the file in Chrome/Safari. It redirects to the UI with the token.

---

## 6. If chat doesn’t reply

- Use the **fresh session** URL above.
- Or in Chat type `/new` and send one short message.
- Or run `./sentinel-nexus/reset-main-session.sh` **with the gateway stopped**, then start the gateway again.

---

## 7. Deploy to Railway

See **DEPLOY.md** for deploying the same setup to Railway (public URL + token in query).

---

**Summary:** Install OpenClaw → put Groq key and gateway token in `~/.openclaw/openclaw.json` → set workspace path and copy SOUL/AGENTS → `openclaw gateway run` → open `http://127.0.0.1:18789/?token=YOUR_TOKEN`.
