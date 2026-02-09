# Security upgrades — very key

Security is critical. Use this checklist to **upgrade** security as we proceed and after any incident or exposure.

---

## 1. Regular security checklist

| Check | Action |
|-------|--------|
| **Credentials location** | All keys and wallets only in `~/.openclaw/`; never in repo, logs, or public. See **CREDENTIALS_SAFETY.md**. |
| **Gateway binding** | `~/.openclaw/openclaw.json` → `gateway.bind` = `"loopback"`. Never expose 18789 to the internet. See **SECURITY.md**. |
| **Admin dashboard** | Run on localhost (3880) or behind a tokenized URL; never expose without auth. |
| **API responses** | No full wallet, no API keys, no private keys in any API or UI. Server uses `truncateWallet()`, `sanitizeMe()`. |
| **Registration files** | `*-registration.json` in `~/.openclaw/` with `chmod 600`; backup only; never in repo. |
| **Skills** | Only trusted sources; no unverified or overly powerful skills. See **SECURITY.md** §3. |
| **Learning from others** | Copy only public patterns; never accept or use others’ credentials or run their code. See **SECURITY.md** §5. |

---

## 2. Key rotation (if exposed or suspected)

- **ClawTasks API key:** Re-register or use platform “regenerate” if available; update `~/.openclaw/clawtasks-credentials.json` (and any `clawtasks-credentials-*.json`). Restart admin server.
- **Moltbook API key:** Get new key from Moltbook; update `~/.openclaw/moltbook-credentials.json`. Restart gateway/cron if used there.
- **OpenClaw / model keys:** In `~/.openclaw/openclaw.json` under `env`: revoke old key at provider (Groq, Hugging Face, etc.), create new one, update config. Restart gateway.
- **Any key ever in chat, doc, or public repo:** Treat as exposed; rotate and update config.

---

## 3. Least privilege

- **Cron / scripts:** Use only the credential files they need (e.g. lead for listing; per-agent for claim/submit). No broad read of all `.openclaw` files.
- **Dashboard:** Reads only agency config and credential files to call ClawTasks/Moltbook APIs; never writes secrets; never exposes keys to the client.
- **Backups:** If you back up `~/.openclaw/`, use encrypted storage and restrict access.

---

## 4. Learn from security incidents

- **Our incidents:** If we ever leak a key or expose the gateway, rotate immediately and note in this doc: “Rotated ClawTasks key after X; gateway set to loopback.”
- **Ecosystem incidents:** Follow **SECURITY.md** references (exposed instances, malicious skills). Apply same discipline: loopback, no commit of secrets, only trusted skills.

---

## 5. Where security is documented

| Doc | Content |
|-----|---------|
| **SECURITY.md** | Never expose credentials; gateway local only; safe learning; quick checklist; if something goes wrong. |
| **CREDENTIALS_SAFETY.md** | Where secrets live; what the agency uses; keeping other agents safe; what is never done. |
| **SECURITY_UPGRADES.md** (this file) | Upgrade checklist, rotation, least privilege, learning from incidents. |

Run through the checklist regularly and after any change that touches credentials or network exposure. Security upgrades are very key.
