# Agency credentials safety — keep all agents’ data and keys safe

**Rule:** All agent credentials, wallets, and API keys live only in `~/.openclaw/`. The agency uses one agent (the **lead**) for the cron; other agents’ credentials are only read when they are **enabled** and only to fetch their stats — never exposed in the dashboard, API, or logs.

---

## 1. Where secrets live (never commit)

| What | Location | Who uses it |
|------|----------|-------------|
| Lead agent (jobmaster) | `~/.openclaw/clawtasks-credentials.json` | Cron, claim-all, dashboard (stats only) |
| Worker agents (jobmaster2, …) | `~/.openclaw/clawtasks-credentials-jobmaster2.json` etc. | Only when enabled: admin server reads to show stats; never sent to browser |
| Full registration (wallet + private key) | `~/.openclaw/clawtasks-jobmaster-registration.json` (or `-jobmaster2`, …) | Backup/recovery only; **never** used by cron or dashboard. Keep `chmod 600`. |
| Moltbook | `~/.openclaw/moltbook-credentials.json` | Moltbook cron, status scripts |
| OpenClaw config (gateway, model keys) | `~/.openclaw/openclaw.json` | Gateway, crons |

All of the above are **outside the repo** (or in `.gitignore`). Do not copy them into the repo or into logs, screenshots, or docs.

---

## 2. What the agency uses

- **Cron (ClawTasks):** Uses only the **lead** agent’s credentials file (e.g. `clawtasks-credentials.json`). The cron skill does not read jobmaster2/jobmaster3 files unless we add a multi-agent loop that you explicitly configure.
- **Claim-all (dashboard or script):** Uses only the **lead** agent’s key to claim bounties.
- **Dashboard / Workers API:** For each **enabled** agent, the server reads that agent’s credentials file from disk **only to call** ClawTasks API (`/agents/me`, `/agents/me/pending`). The server **never** sends API keys, private keys, or full wallet addresses in any response. Wallet is truncated (e.g. `0xB610…4e19`) in API and UI.

So even if you have several agents, only the lead is used for automated claiming and cron. Other agents’ keys are only used when you enable them and only for fetching their stats; they stay on disk and are never exposed.

---

## 3. Keeping other agents safe

- **Add agents without exposing them:** Register jobmaster2 (or more) with `OUT_CREDS_FILE=clawtasks-credentials-jobmaster2.json`. The file is created in `~/.openclaw/`. Add the agent to `agency-agents.json` with `enabled: false` until you want them to appear and be used for stats. When `enabled: true`, the server will read that file only to fetch stats; keys are still never sent to the client.
- **Full registration files** (with `private_key`): Written by `register-jobmaster-bot.js` to e.g. `~/.openclaw/clawtasks-jobmaster-registration.json`. Use these only for backup or recovery. Set `chmod 600` (the script does this for the main registration file). Do not put them in the repo; `.gitignore` includes `*-registration.json`.
- **Backups:** If you back up `~/.openclaw/`, use encrypted storage and restrict access. Do not upload to public or shared storage.

---

## 4. What is never done

- **Never** log `api_key`, `private_key`, or full `wallet_address` in server or scripts.
- **Never** return keys or full wallet in `/api/agency`, `/api/workers`, or `/api/stats`.
- **Never** commit any file under `*credentials*.json`, `*-registration.json`, or `openclaw.json` that contains secrets.
- **Never** paste registration output (which can contain the new API key) into public logs or channels; run registration in a safe environment.

---

## 5. Quick checklist

| Check | Action |
|-------|--------|
| All credential files | Only in `~/.openclaw/`, not in repo |
| Dashboard/API | Only truncated wallet (e.g. 0xB610…4e19); no keys |
| Lead vs others | Only lead used for cron/claim; others’ creds only for stats when enabled |
| Registration files | `chmod 600`, backup only, never in repo or logs |
| Backups of `.openclaw` | Encrypted, restricted access |

This keeps all agents’ data and wallets safe even when only one is used for the agency. For a **security upgrade checklist** (rotation, least privilege, incidents), see **SECURITY_UPGRADES.md**.
