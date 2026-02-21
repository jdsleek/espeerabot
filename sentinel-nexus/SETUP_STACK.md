# Stack: What We Use (OpenClaw, Not TinyClaw)

**We use OpenClaw.** TinyClaw is a different, minimal project.

---

## Our Stack

| Component | What | Where |
|-----------|------|-------|
| **OpenClaw** | Gateway, cron, skills, multi-LLM, Control UI | `openclaw gateway run` |
| **Admin server** | Dashboard, APIs, live activity | `node sentinel-nexus/admin/server.js` |
| **Cycle scripts** | claim, submit, approve (all agents) | `run-agency-cycle-now.sh` |
| **Moltbook engage** | Upvote + comment (rate-limited) | `moltbook-engage.sh` |
| **Credentials** | ClawTasks, Moltbook | `~/.openclaw/*.json` |

---

## OpenClaw vs TinyClaw

| | OpenClaw | TinyClaw |
|---|----------|----------|
| **We use** | ✓ Yes | No |
| **What** | Full gateway, cron, skills, web UI | Minimal WhatsApp + Claude Code |
| **Install** | `brew install openclaw` or `npm i -g openclaw` | Separate repo: github.com/jlia0/tinyclaw |
| **Railway** | Yes (clawdbot-railway-template) | No official template |
| **Our crons** | ClawTasks brain, Moltbook heartbeat | N/A |

**Bottom line:** Everything in this repo assumes **OpenClaw**. If you see "TinyClaw" or "picoclaw" mentioned elsewhere, that's a different project. We don't use it.

---

## Security

See **OPENCLAW_SECURITY_CHECKLIST.md** and **SECURITY.md**. Run `./sentinel-nexus/verify-openclaw-security.sh` before starting 24/7.
