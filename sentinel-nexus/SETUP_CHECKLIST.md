# OpenClaw setup checklist (basic replies working)

Aligned with [OpenClaw Getting Started](https://docs.openclaw.ai/start/getting-started) and [openclaw/openclaw](https://github.com/openclaw/openclaw).

## Prereqs

- **Node 22+** — `node --version` (you have v22.22.0 ✓)
- **Gateway** — run `openclaw gateway run` (or use `openclaw onboard --install-daemon` for a background service)

## What we fixed for “basic replies should work”

1. **Default model (free)** — Config primary is **Groq Kimi K2 0905** (`groq/moonshotai/kimi-k2-instruct-0905`). [Groq free tier](https://console.groq.com/docs/model/moonshotai/kimi-k2-instruct-0905); no payment required. For 100% free local use, install [Ollama](https://ollama.ai) and pick an `ollama/...` model in chat.
2. **Main chat session** — The **agent:main:main** session in `~/.openclaw/agents/main/sessions/sessions.json` was still using `openai/gpt-oss-20b`. It’s now set to `moonshotai/kimi-k2-instruct-0905` so the default tab uses the same model as config.
3. **Cron (Moltbook)** — Both cron sessions use `groq` + `moonshotai/kimi-k2-instruct-0905` so the Moltbook agent runs by itself.
5. **Doctor** — Run `openclaw doctor --fix` (legacy keys, config backup). Config file permissions set to `chmod 600 ~/.openclaw/openclaw.json`.

## Quick checks

| Check | Command / action |
|-------|-------------------|
| Node 22+ | `node --version` |
| Gateway running | `openclaw gateway status` or `openclaw gateway run` |
| Health | `openclaw doctor` (then `openclaw doctor --fix` if suggested) |
| Open UI | `openclaw dashboard` or `http://127.0.0.1:18789/?token=YOUR_TOKEN` |
| New session | In chat, use **/new** or open a new session so it picks up the default model |

## If basic replies still don’t work

1. **Restart gateway** — Stop then `openclaw gateway run` so it reloads config and session defaults.
2. **Use a new chat session** — Existing sessions keep their last-used model; **/new** or a new session name uses the config primary (Kimi K2 0905).
3. **Confirm API key** — `~/.openclaw/openclaw.json` → `env.GROQ_API_KEY` must be set and valid (no extra spaces).
4. **Update OpenClaw** — `openclaw update` or `npm i -g openclaw@latest`, then restart the gateway.
5. **Troubleshooting** — See [UI_NOTHING_SHOWING.md](./UI_NOTHING_SHOWING.md) and [OpenClaw troubleshooting](https://docs.openclaw.ai/channels/troubleshooting).
6. **Discord / WhatsApp “configure” error** — Channels must be defined in `~/.openclaw/openclaw.json`. See [CHANNELS_SETUP.md](./CHANNELS_SETUP.md): Discord = bot token + invite; WhatsApp = merge example + `openclaw channels login`.

## Kimi K2.5 “Vertu” / free full API (OpenClaw 2026)

OpenClaw has been announced as offering **full Kimi K2.5 API access** (no limited trial). You can use Kimi K2.5 in several ways:

| Option | Provider | Model ref | What you need |
|--------|----------|-----------|----------------|
| **Moonshot (official)** | `moonshot` | `moonshot/kimi-k2.5` | [Moonshot API key](https://platform.moonshot.ai/console/api-keys) → set `env.MOONSHOT_API_KEY` in `~/.openclaw/openclaw.json` |
| **OpenRouter** | `openrouter` | `openrouter/moonshotai/kimi-k2.5` | You already have `OPENROUTER_API_KEY`; new OpenRouter accounts get free credits |
| **NVIDIA NIM** | `nvidia` | `nvidia/moonshotai/kimi-k2.5` | `NVIDIA_API_KEY` (free tier at [NVIDIA NIM](https://build.nvidia.com)) |

To use a specific option:

1. Ensure the provider is in `~/.openclaw/openclaw.json` → `models.providers` (moonshot + openrouter are already added).
2. Set the matching API key in `env` (e.g. `MOONSHOT_API_KEY` for Moonshot).
3. In the chat UI, pick the model (e.g. **Kimi K2.5 (Moonshot / Vertu free)** or **Kimi K2.5 (OpenRouter)**), or set default: `agents.defaults.model.primary` to `moonshot/kimi-k2.5` or `openrouter/moonshotai/kimi-k2.5`.
4. Use **/new** or a new session so the session uses the new model.

References: [Use Kimi K2.5 in OpenClaw](https://platform.moonshot.ai/docs/guide/use-kimi-in-openclaw), [OpenClaw + Kimi free (Vertu)](https://vertu.com/ai-tools/openclaw-drops-bombshell-kimi-k2-5-becomes-first-free-premium-model).

---

## References

- [OpenClaw README](https://github.com/openclaw/openclaw)
- [Getting started](https://docs.openclaw.ai/start/getting-started)
- [Models](https://docs.openclaw.ai/concepts/models)
- [Groq: Kimi K2 0905](https://console.groq.com/docs/model/moonshotai/kimi-k2-instruct-0905)
