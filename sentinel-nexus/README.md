# Sentinel Nexus — OpenClaw agent

Minimal setup for one OpenClaw agent (Sentinel_Nexus): **Groq** model, local or Railway.

## Quick start (local)

1. **Install OpenClaw** (if needed): https://openclaw.ai or `npm i -g openclaw`
2. **Config:** Copy `openclaw-config-template.json` to `~/.openclaw/openclaw.json`. Replace `YOUR_GROQ_API_KEY` and `YOUR_GATEWAY_TOKEN` (get Groq key at [console.groq.com](https://console.groq.com), token can be any long random string).
3. **Workspace:** Point `agents.defaults.workspace` to a folder that has at least `SOUL.md` and `AGENTS.md` (e.g. copy from this repo into `~/.openclaw/workspace`).
4. **Run:** `openclaw gateway run`
5. **Open UI:** In browser open `http://127.0.0.1:18789/?token=YOUR_GATEWAY_TOKEN` (use the same token you put in config). Or use `openclaw-launch.html` after pasting your token in it once.

Full steps: **SETUP.md**. Deploy to Railway: **DEPLOY.md**. Security: **SECURITY.md**. If nothing shows in chat (your messages or bot): **UI_NOTHING_SHOWING.md**.

## What’s in this folder

| File | Use |
|------|-----|
| **SETUP.md** | From-scratch setup (config, workspace, run, UI) |
| **DEPLOY.md** | Deploy to Railway |
| **SECURITY.md** | Secrets, binding, tokens |
| **openclaw-config-template.json** | Minimal config template (no real keys) |
| **openclaw-launch.html** | One-click open UI (paste token once); links to Jobmaster hub |
| **SOUL.md**, **HEARTBEAT.md**, **content-templates.md** | Agent identity — copy into workspace |
| **reset-main-session.sh** | Clear main chat if it gets stuck |
| **admin/** | Jobmaster Agency: landing, post job, track, **admin** (dashboard, workers, etc.) |
| **run-agency-24-7.sh** | Starts gateway + admin server; then open **http://127.0.0.1:3880/hub** for all links |

**Two UIs:** **OpenClaw** = gateway/chat at `http://127.0.0.1:18789`. **Jobmaster Agency** = landing + admin at `http://127.0.0.1:3880`. Use **/hub** on 3880 to see both in one page. Admin runs only when you start `node admin/server.js` or `run-agency-24-7.sh`.
