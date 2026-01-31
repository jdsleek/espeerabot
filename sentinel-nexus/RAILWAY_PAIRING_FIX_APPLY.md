# Fix "disconnected (1008): pairing required" on Railway

Apply the gateway patch so the Control UI connects with **token only** (no device pairing).

---

## Option 1: Setup page — Advanced / Edit config (fastest)

1. Open **https://espeerabot.up.railway.app/setup** and sign in with your setup password.
2. Find **Advanced**, **Edit config**, or **Config** (JSON).
3. In the JSON, locate the **`gateway`** object.
4. Add (or merge) this inside `gateway`:
   ```json
   "controlUi": { "allowInsecureAuth": true }
   ```
   If `gateway.controlUi` already exists, add only: `"allowInsecureAuth": true` inside it.
5. Save and restart the gateway if prompted.
6. Open the Control UI with the tokenized URL:
   `https://espeerabot.up.railway.app/openclaw?token=YOUR_CLAWDBOT_GATEWAY_TOKEN`

---

## Option 2: Patch script (backup or shell)

**From a downloaded backup:**

1. Download backup: **https://espeerabot.up.railway.app/setup** → export/download.
2. Extract the archive. Find `openclaw.json` (often under `.clawdbot/`).
3. Run (from repo root):
   ```bash
   ./sentinel-nexus/apply-gateway-patch.sh path/to/extracted/.clawdbot/openclaw.json
   ```
4. If your Setup page has **Import** or **Restore backup**, upload the patched backup. Otherwise use Option 3.

**From Railway shell (if you have it):**

1. Railway dashboard → your service → **Shell** (or run a one-off command).
2. Run:
   ```bash
   # If the repo is not in the image, merge manually with jq:
   jq '.gateway.controlUi += {"allowInsecureAuth": true}' /data/.clawdbot/openclaw.json > /tmp/o.json && mv /tmp/o.json /data/.clawdbot/openclaw.json
   ```
   Or if you have the patch file in the container:
   ```bash
   jq -s '.[0] * .[1]' /data/.clawdbot/openclaw.json /path/to/openclaw-gateway-patch.json > /tmp/o.json && mv /tmp/o.json /data/.clawdbot/openclaw.json
   ```
3. Restart the service (Redeploy or Restart in Railway).

---

## Option 3: Commit patch and redeploy (if your deploy uses this repo)

The repo now includes:

- **sentinel-nexus/openclaw-gateway-patch.json** — adds `gateway.controlUi.allowInsecureAuth: true`
- **sentinel-nexus/apply-gateway-patch.sh** — merges the patch into an existing openclaw.json

Your Railway app is deployed from the **Clawdbot template**, not from this repo, so the config lives on the Railway **volume**. You still need to apply the patch **on the server** (Option 1 or 2). Pushing this repo does not change the config on Railway unless you have a custom deploy that runs the script.

After applying, open:

**https://espeerabot.up.railway.app/openclaw?token=YOUR_CLAWDBOT_GATEWAY_TOKEN**

(Use the value of `CLAWDBOT_GATEWAY_TOKEN` from Railway Variables.)
