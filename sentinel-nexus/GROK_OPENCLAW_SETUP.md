# Grok (xAI) with OpenClaw

OpenClaw is set to use **Grok 4.1 Fast** via **OpenRouter** for the agent model. That gives you an efficient, agentic model with 2M context.

## Config (already set)

In `~/.openclaw/openclaw.json`:

- **Model:** `openrouter/x-ai/grok-4.1-fast` (under `agents.defaults.model.primary`)

## API key (you must set)

OpenRouter needs an API key. Use **one** of these:

### Option 1: Environment variable (recommended)

Before starting the gateway:

```bash
export OPENROUTER_API_KEY="sk-or-your-key-here"
openclaw gateway run
```

If your key is in a file (e.g. `~/.openclaw/grok-api-key` or a `.env` file):

```bash
export OPENROUTER_API_KEY=$(cat ~/.openclaw/grok-api-key)
# or
source .env   # if OPENROUTER_API_KEY is in .env
openclaw gateway run
```

### Option 2: In config (less secure)

In `~/.openclaw/openclaw.json`, add an `env` block at the top level:

```json
"env": {
  "OPENROUTER_API_KEY": "sk-or-your-key-here"
}
```

Do not commit this file if it contains the key.

## Get an OpenRouter key

1. Go to [OpenRouter](https://openrouter.ai) and sign up.
2. Create an API key.
3. OpenRouter gives access to xAI Grok (and other models) with one key.

## Check it’s working

1. Start the gateway (with `OPENROUTER_API_KEY` set).
2. Open the dashboard: **http://127.0.0.1:18789/** (or your gateway URL).
3. Send a message; the agent should reply using Grok 4.1 Fast.

If you get model/auth errors, run `openclaw doctor` and ensure `OPENROUTER_API_KEY` is set in the same environment the gateway uses.
