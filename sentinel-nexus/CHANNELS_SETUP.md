# OpenClaw: Discord and WhatsApp channel setup

If you see an error about **configure** when connecting Discord (or WhatsApp), the gateway is telling you that the **channel is not configured** in `~/.openclaw/openclaw.json`. Add the config below, then start the gateway (Discord) or run the login step (WhatsApp).

---

## 1. Where to configure

- **Config file:** `~/.openclaw/openclaw.json` (or `%USERPROFILE%\.openclaw\openclaw.json` on Windows).
- **Do not** put bot tokens or phone numbers in this repo. Edit the file on your machine only.

---

## 2. Discord — talk to the bot via Discord (recommended to start)

### Cause of “configure” error

Discord appears in the UI but there is no `channels.discord` block (or no token), so OpenClaw asks you to configure it.

### Fix — step by step

**Step 1 – Create a Discord bot**

1. Go to [Discord Developer Portal](https://discord.com/developers/applications) → **Applications** → **New Application** (name it e.g. “OpenClaw”).
2. In your app: **Bot** → **Add Bot**.
3. Copy the **Bot Token** (you’ll put it in config or env).
4. Under **Privileged Gateway Intents**, enable:
   - **Message Content Intent** (required so the bot can read message text).
   - **Server Members Intent** (recommended for allowlists and DMs).

**Step 2 – Invite the bot to your server**

Use this link to add the **openclaw1** bot to a Discord server (choose the server, then Authorize):

**https://discord.com/oauth2/authorize?client_id=1470371209932832892&permissions=52224&integration_type=0&scope=bot+applications.commands**

Or build your own: in your app **OAuth2** → **URL Generator** → Scopes: `bot` + `applications.commands` → set Bot Permissions → copy the generated URL.

**Step 3 – Add Discord to OpenClaw config**

Open `~/.openclaw/openclaw.json` and add a `channels` section (or merge into existing). Minimal:

```json
{
  "channels": {
    "discord": {
      "enabled": true,
      "token": "YOUR_BOT_TOKEN_HERE"
    }
  }
}
```

Replace `YOUR_BOT_TOKEN_HERE` with the token you copied from the Developer Portal.  
**Safer:** use an env var instead of putting the token in the file:

```bash
export DISCORD_BOT_TOKEN=your_token_here
```

Then you can omit `channels.discord.token` (OpenClaw uses `DISCORD_BOT_TOKEN` when the config block has no token).

**Step 4 – Start the gateway**

```bash
openclaw gateway run
```

(or `./sentinel-nexus/run-agency-24-7.sh` if that starts the gateway).

**Step 5 – Talk to the bot**

- **In a server channel:** mention the bot, e.g. `@YourBotName hello`. By default the bot only replies when mentioned in guild channels.
- **In DMs:** open a DM with the bot. First time you get a **pairing code**. Approve it in a terminal:
  ```bash
  openclaw pairing approve discord <code>
  ```
  Then send messages in the DM; they go to the same agent session.

### Optional: restrict to one server and one channel

If you want the bot only in one server and one channel (e.g. `#general`):

1. In Discord: **User Settings** → **Advanced** → enable **Developer Mode**.
2. Right‑click your server name → **Copy Server ID**. Right‑click the channel (e.g. `#general`) → **Copy Channel ID**. Right‑click your user → **Copy User ID**.
3. Add to config (use your real IDs):

```json
{
  "channels": {
    "discord": {
      "enabled": true,
      "token": "YOUR_BOT_TOKEN",
      "dm": { "enabled": false },
      "guilds": {
        "YOUR_GUILD_ID": {
          "users": ["YOUR_USER_ID"],
          "requireMention": true,
          "channels": {
            "general": { "allow": true, "requireMention": true }
          }
        }
      }
    }
  }
}
```

Use the **channel slug** as the key (e.g. `general` for `#general`). Then only that channel is allowed and only when you @mention the bot.

### Troubleshooting

- **“Used disallowed intents”** → Enable **Message Content Intent** (and **Server Members Intent**) in the Developer Portal, then restart the gateway.
- **Bot connects but never replies** → Check Message Content Intent, channel permissions (View/Send/Read History), and that you’re @mentioning the bot if `requireMention` is true.
- **DMs don’t work** → First DM sends a pairing code; run `openclaw pairing approve discord <code>`, then try again.

Full docs: [OpenClaw Discord channel](https://docs.openclaw.ai/channels/discord).

---

## 3. WhatsApp — fix “configure” error

### Cause

WhatsApp has no `channels.whatsapp` block in config, so OpenClaw shows a configure error.

### Fix

**Step 1 – Add WhatsApp to config**

```json
{
  "channels": {
    "whatsapp": {
      "dmPolicy": "allowlist",
      "allowFrom": ["+15551234567"]
    }
  }
}
```

Replace with your phone number in E.164 (e.g. `+2348012345678`). If the bot uses your **personal** number, add `"selfChatMode": true`.

**Step 2 – Log in**

```bash
openclaw channels login
```

Scan the QR with WhatsApp → **Settings → Linked devices → Link a device**.

**Step 3 – Start the gateway**

Use **Node** (not Bun) to run the gateway. Full docs: [OpenClaw WhatsApp channel](https://docs.openclaw.ai/channels/whatsapp).

---

## 4. Quick reference

| Channel  | Config key              | Next step after config                    |
|----------|-------------------------|-------------------------------------------|
| **Discord** | `channels.discord` + token | Invite bot → start gateway → @mention or DM (approve pairing for DMs) |
| WhatsApp | `channels.whatsapp`     | `openclaw channels login` → scan QR → start gateway |

---

## 5. Example file to merge

**`sentinel-nexus/openclaw-channels-example.json`** has sample `channels` for Discord and WhatsApp. Copy the block you need into `~/.openclaw/openclaw.json` (merge into the root; don’t replace the whole file). Replace `YOUR_BOT_TOKEN` and any phone numbers, then start the gateway (and for WhatsApp, run `openclaw channels login`).
