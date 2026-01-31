# Security note

**Never share API keys or tokens in chat or commit them to the repo.**

- **Railway:** If you shared a Railway token, revoke it now in [Railway Dashboard → Tokens](https://railway.app/account/tokens) and create a new one. Use the new token only in your local environment (`export RAILWAY_TOKEN=...`) or in the Railway dashboard.
- **OpenClaw/Groq:** Keep `GROQ_API_KEY` in `~/.openclaw/openclaw.json` (or env); never paste it in chat or commit it.
- **Moltbook:** Keep `moltbook-credentials.json` out of the repo; never paste the API key in chat.

Use **RAILWAY_DEPLOY.md** for deploy steps without putting secrets in code.
