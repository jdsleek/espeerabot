# Sentinel Nexus — Work Report

**One report we work on together.** Update this as we go.

---

## Current status (short)

| Item | Status |
|------|--------|
| **Deployment** | Railway: espeerabot.up.railway.app |
| **Control UI** | Needs pairing fix applied on server, then use tokenized URL |
| **Agent** | MiniMax configured; chat once Control UI is connected |
| **Engagement** | Plan in DEPLOY_AND_ENGAGEMENT_PLAN.md / GLOBAL_ENGAGEMENT_PLAN.md |

---

## Done

- [x] Deploy Clawdbot to Railway (template, volume `/data`, port 8080)
- [x] Setup wizard: MiniMax, SETUP_PASSWORD
- [x] Token in URL: CLAWDBOT_GATEWAY_TOKEN → Control UI URL
- [x] Fix "pairing required" (1008): patch and script added in repo
  - `openclaw-gateway-patch.json`, `apply-gateway-patch.sh`, `RAILWAY_PAIRING_FIX_APPLY.md`
- [ ] **Apply pairing fix on Railway** (Setup → Advanced, or shell) — *pending*
- [ ] **Confirm Control UI connects** with tokenized URL — *pending*

---

## In progress

- **Control UI connection:** Apply `gateway.controlUi.allowInsecureAuth: true` on Railway (see RAILWAY_PAIRING_FIX_APPLY.md), then open `https://espeerabot.up.railway.app/openclaw?token=YOUR_TOKEN`.

---

## Next steps

1. Apply pairing fix on Railway (Setup → Advanced → add `controlUi: { allowInsecureAuth: true }` under `gateway`).
2. Open Control UI with tokenized URL; confirm Health Online and chat works.
3. Configure cron / heartbeat for 30m cadence if desired (see DEPLOY_AND_ENGAGEMENT_PLAN.md).
4. Moltbook / engagement: credentials, submolt, engagement strategy (see GLOBAL_ENGAGEMENT_PLAN.md).

---

## Blockers

- (Resolved) Control UI pairing — fixed with `controlUi.allowInsecureAuth: true`.
- **Chat not replying:** Try `/new` or `/reset` in chat, then send a short message; if still no reply, check Railway logs when you send (see RAILWAY_CHAT_NOT_REPLYING.md).

---

## Links

| What | URL |
|------|-----|
| Setup | https://espeerabot.up.railway.app/setup |
| Control UI | https://espeerabot.up.railway.app/openclaw |
| Control UI (with token) | https://espeerabot.up.railway.app/openclaw?token=**PASTE_CLAWDBOT_GATEWAY_TOKEN** |
| Backup export | https://espeerabot.up.railway.app/setup/export |

---

## Notes

- **Token:** Get from Railway → Variables → `CLAWDBOT_GATEWAY_TOKEN` (reveal and copy).
- **Config on Railway:** Lives on volume at `/data/.clawdbot/openclaw.json` (or OPENCLAW_STATE_DIR). Edit via Setup Advanced or Railway shell.
- **Docs in this repo:** RAILWAY_CONTROL_UI_TOKEN.md, RAILWAY_PAIRING_FIX_APPLY.md, RAILWAY_CHAT_NOT_REPLYING.md, DEPLOY_AND_ENGAGEMENT_PLAN.md, GLOBAL_ENGAGEMENT_PLAN.md.

---

*Last updated: add date or note when you change this.*
