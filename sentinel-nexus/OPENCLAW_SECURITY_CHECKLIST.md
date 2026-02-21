# OpenClaw Security Checklist — Don't Let It Hack Your Machine

**Your OpenClaw runs on your machine with access to your credentials. Follow this so it never compromises you.**

---

## 1. Stack: OpenClaw (Not TinyClaw)

| Tool | What | Where |
|------|------|-------|
| **OpenClaw** | Gateway, cron, skills, multi-LLM, Control UI | We use this. Installed via `brew install openclaw` or `npm i -g openclaw`. |
| **TinyClaw** | Minimal WhatsApp + Claude Code only | We do NOT use this. Different project. |

**Our setup:** OpenClaw gateway + cron (ClawTasks, Moltbook) + admin dashboard. All in this repo.

---

## 2. What OpenClaw Can Access (By Design)

| Path | Purpose |
|------|---------|
| `~/.openclaw/` | Config, credentials, cron jobs, skills |
| `~/.openclaw/workspace/` | Agent workspace, cron results |
| `~/.openclaw/cron/` | Job definitions, run history |

**Risk:** If OpenClaw (or a malicious skill) is compromised, it can read credentials and API keys from `~/.openclaw/`. That's why we lock it down.

---

## 3. Security Rules (Non-Negotiable)

### A. Gateway Binding

- **`gateway.bind`** must be **`"loopback"`** (127.0.0.1).
- **Never** set `bind: "0.0.0.0"` or expose port 18789 to the internet.
- **Why:** Exposed gateways have been harvested for API keys. Attackers scan for open OpenClaw instances.

**Check:** `~/.openclaw/openclaw.json` → `gateway.bind` = `"loopback"`

**Fix if missing:** Add under `gateway`: `"bind": "loopback"`. Example:
```json
"gateway": {
  "bind": "loopback",
  "auth": { "token": "..." },
  ...
}
```

### B. Skills: Trusted Only

- **341+ malicious skills** have been found on ClawHub (malware, credential theft).
- **Only install skills** from official OpenClaw docs or sources you've verified.
- **Do not** install skills that request broad file access, run arbitrary code, or read credentials.

**Check:** `~/.openclaw/skills/` — know every skill there. Remove anything unknown.

### C. Credentials: Never Commit

- `~/.openclaw/openclaw.json` (env section)
- `~/.openclaw/*credentials*.json`
- `~/.openclaw/*-registration.json`

**Check:** `git status` — none of these should ever be staged or committed.

### D. Remote Access

- **Local:** OpenClaw UI at `http://127.0.0.1:18789/?token=YOUR_TOKEN`
- **Remote:** Use **Tailscale**, **Cloudflare Tunnel**, or **Railway** with tokenized URL. Never open 18789 on a public IP.

---

## 4. Quick Verification Script

Run this to sanity-check your setup:

```bash
# Check gateway bind
jq -r '.gateway.bind // "NOT SET"' ~/.openclaw/openclaw.json
# Should output: loopback

# Check skills (list only)
ls -la ~/.openclaw/skills/ 2>/dev/null || echo "No skills dir"

# Check no credentials in repo
git ls-files | grep -E 'openclaw\.json|credentials|registration' && echo "DANGER: secrets in repo" || echo "OK: no secrets committed"
```

---

## 5. If You Suspect Compromise

1. **Stop the gateway** — `pkill -f openclaw` or kill the process.
2. **Rotate all keys** — Groq, Anthropic, Moltbook, ClawTasks, etc. Revoke old, create new.
3. **Update config** — Replace keys in `~/.openclaw/openclaw.json` and credential files.
4. **Audit skills** — Remove any skill you didn't explicitly add. Reinstall only from trusted sources.
5. **Check bind** — Ensure `gateway.bind` = `"loopback"` before restarting.

---

## 6. Our Hardening (What We Enforce)

- **Admin server** binds to `127.0.0.1:3880` only (not 0.0.0.0 unless on Railway with PORT).
- **No credentials** in repo; `.gitignore` excludes all secret paths.
- **SECURITY.md** and this checklist document the rules.
- **Run scripts** use `OPENCLAW_STATE_DIR` so you can override; never hardcode paths to your home.

**You own your machine. OpenClaw is a tool. Lock it down.**
