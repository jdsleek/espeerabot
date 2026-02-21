# OpenClaw vs TinyClaw — which to use

**TinyClaw** exists at **[github.com/jlia0/tinyclaw](https://github.com/jlia0/tinyclaw)** (270+ stars). Here’s how it compares to OpenClaw for our setup (Jobmaster Agency + Railway).

---

## TinyClaw ([jlia0/tinyclaw](https://github.com/jlia0/tinyclaw))

- **What it is:** Minimal wrapper around **Claude Code** as a 24/7 personal AI agent.
- **Features:** WhatsApp (QR), file-based queue (no race conditions), one message at a time, runs in **tmux** (or systemd/PM2/supervisor).
- **Stack:** Node.js, `whatsapp-web.js`, `claude -c -p` for processing, heartbeat cron.
- **Deploy:** Local or VPS with tmux/PM2/systemd. **No Railway one-click**; you’d need to adapt it (e.g. run `tinyclaw.sh start` in a container and handle QR/auth).
- **Credits:** “Inspired by OpenClaw by Peter Steinberger.”

**Pros:** Lightweight, simple queue, WhatsApp-first, easy to read and hack.  
**Cons:** No web Control UI, no `/setup` wizard, no official Railway template, Claude Code–only (no multi-LLM like OpenClaw).

---

## OpenClaw (clawdbot-railway-template)

- **What it is:** Full gateway + Control UI, multi-channel (WhatsApp, Telegram, Discord, Slack, etc.), cron/skills, multiple LLM providers.
- **Features:** Web UI at `/` and `/openclaw`, setup wizard at `/setup`, persistent state on a volume, token auth.
- **Deploy:** **One-click on Railway:** [railway.com/deploy/clawdbot-railway-template](https://railway.com/deploy/clawdbot-railway-template). Volume + `SETUP_PASSWORD` + optional vars.

**Pros:** Production-ready on Railway, web UI, multi-LLM, official template, fits our existing DEPLOY.md.  
**Cons:** Heavier than TinyClaw; more moving parts.

---

## Recommendation for our project

| Goal | Use |
|------|-----|
| **Gateway + Control UI on Railway** (same as our docs, `/setup`, `/openclaw`) | **OpenClaw** (clawdbot-railway-template) |
| **Minimal WhatsApp + Claude Code** on a VPS or local, no web UI | **TinyClaw** (jlia0/tinyclaw) |

For **Railway + Jobmaster Agency** we already have:

- **Agency app** (espeerabot) — dashboard, Completed, run-cycle, APIs.
- **Gateway** — not yet deployed; the standard option is **OpenClaw** via the Railway template.

So: **use OpenClaw on Railway** for the gateway. Use **TinyClaw** if you want a lightweight, WhatsApp + Claude Code–only agent elsewhere (e.g. local or a small VPS), and are fine without a web UI and without a Railway template.

---

## Links

- **TinyClaw:** [https://github.com/jlia0/tinyclaw](https://github.com/jlia0/tinyclaw)
- **OpenClaw Railway:** [https://railway.com/deploy/clawdbot-railway-template](https://railway.com/deploy/clawdbot-railway-template)
- **OpenClaw:** [https://openclaw.ai](https://openclaw.ai)
