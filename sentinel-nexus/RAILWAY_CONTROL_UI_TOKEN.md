# Control UI: "gateway token missing" / "token mismatch" — fix

The Control UI at `/openclaw` needs the **gateway token** to connect. If you see **token_missing** or **token_mismatch** in the logs, use one of these:

---

## Option 1: Open with token in the URL (easiest)

Use this URL (replace `YOUR_GATEWAY_TOKEN` with the token from your config):

```
https://espeerabot.up.railway.app/openclaw?token=YOUR_GATEWAY_TOKEN
```

**Where to get the token:** Railway → your service → **Variables** → **`CLAWDBOT_GATEWAY_TOKEN`** (or `OPENCLAW_GATEWAY_TOKEN`). Click to reveal/copy the value—you need the actual token string, not the masked `*******`. Alternatively: setup "advanced" / report has it as `gateway.auth.token`, or download a backup from `/setup` and read `gateway.auth.token` from `.clawdbot/openclaw.json`. Paste that value in place of `YOUR_GATEWAY_TOKEN` in the URL above.

Open that in the browser. The dashboard should connect and "Health" should go online.

**If you see "token_mismatch" in logs:** The token in the URL (or in Control UI settings) does not match the server. Use the **current** token only:
- Get it from **Railway → your service → Variables → `CLAWDBOT_GATEWAY_TOKEN`** (or `OPENCLAW_GATEWAY_TOKEN`) — reveal and copy the value, or
- Download a backup from `https://espeerabot.up.railway.app/setup`, extract, and read `gateway.auth.token` from `.clawdbot/openclaw.json`.
Copy the value with no extra spaces; use it in the URL. If you previously pasted a token in the Control UI settings, use the tokenized URL so the URL overrides the stored value.

---

## Option 2: Paste token in Control UI settings

1. Open **https://espeerabot.up.railway.app/openclaw** (even if it says disconnected).
2. Find **Settings** or **Connect** or a gear icon in the dashboard.
3. Look for **Gateway token** or **Token**.
4. Paste the token (same value as in config: `gateway.auth.token`).
5. Save / Connect. The UI should then connect.

---

## After it connects

- **Health** should show **Online**.
- **Chat** should work: pick or create a session (e.g. main), type a message, send. The agent (MiniMax) should reply.
- If chat gets stuck or errors, type **/new** or **/reset** in the chat for a fresh session.

---

**Security:** The gateway token is a secret. Don’t share the tokenized URL in public. If you shared it, rotate the token later (e.g. set a new `OPENCLAW_GATEWAY_TOKEN` in Railway and redeploy, then use the new token in the URL).

---

## Log: "Proxy headers detected from untrusted address"

This is a warning only; it does not cause "unauthorized". To silence it and allow local client detection behind Railway's proxy, set in your OpenClaw config (e.g. in `.clawdbot/openclaw.json` under `gateway`):

```json
"trustedProxies": ["127.0.0.1", "::1", "100.64.0.0/10"]
```

Fixing the token (above) is required for the Control UI; trustedProxies is optional.

---

## Disconnected (1008): pairing required

If the token is accepted but the UI then shows **"disconnected (1008): pairing required"**, the gateway is requiring **device pairing** (the Control UI over HTTPS normally uses device identity + pairing). For a remote deployment like Railway you want **token-only** auth and no pairing.

**Fix:** In the OpenClaw config on the server, enable token-only auth for the Control UI so pairing is not required. Add under `gateway`:

```json
"gateway": {
  "controlUi": { "allowInsecureAuth": true },
  ...
}
```

(Keep your existing `gateway.auth`, `gateway.bind`, etc.; only add or merge `gateway.controlUi.allowInsecureAuth: true`.)

**Where to edit:** The config lives on the Railway volume (e.g. `/data/.clawdbot/openclaw.json` or `OPENCLAW_STATE_DIR`). Options:

1. **Setup page** — If your deployment has a Setup or Config UI with an “Advanced” / “Edit config” option, open the JSON, find the `gateway` object, add `"controlUi": { "allowInsecureAuth": true }` (or add `"allowInsecureAuth": true` inside an existing `controlUi` object), save, and restart if prompted.
2. **Backup → edit → restore** — Download a backup from `https://espeerabot.up.railway.app/setup`, extract it, edit `.clawdbot/openclaw.json` (or the path that contains `openclaw.json`) to add the above, then restore the backup if your setup supports it.
3. **Railway shell / one-off run** — If you have shell access to the service, edit the config file in place (e.g. `vi /data/.clawdbot/openclaw.json`), then restart the service.

After the change, redeploy or restart the gateway, then open the Control UI again with the tokenized URL. The connection should succeed without pairing.
