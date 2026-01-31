# How Grok + OpenRouter Works (Automatic)

You **don’t connect Grok to OpenRouter**. It’s already connected on OpenRouter’s side.

## How it works

1. **OpenRouter** is a single API that can call many models (Anthropic, OpenAI, **xAI Grok**, etc.).
2. You have **one key**: your **OpenRouter API key** (`sk-or-v1-...`).
3. In OpenClaw we set **model** to `openrouter/x-ai/grok-4.1-fast`.
4. When the agent runs, OpenClaw sends the request to **OpenRouter** with your OpenRouter key.
5. OpenRouter **automatically** routes that request to **xAI’s Grok** and returns the reply.

So: **you only add your OpenRouter key.** OpenRouter already “connects” to Grok; you don’t register Grok or xAI separately for this.

## Your config (already set)

- **Key:** `OPENROUTER_API_KEY` in `~/.openclaw/openclaw.json` (env).
- **Model:** `openrouter/x-ai/grok-4.1-fast` (agents.defaults.model.primary).

Restart the gateway after changing the key so it picks up the new env.

## If you had an xAI key instead

If you had a key from **x.ai** (Grok) directly, that’s a different key. For **OpenClaw + Grok** we use the **OpenRouter** key and the model above; no xAI key is needed.
