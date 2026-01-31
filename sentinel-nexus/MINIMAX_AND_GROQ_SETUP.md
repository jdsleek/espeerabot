# MiniMax API (free) + using Groq if the wizard doesn’t show it

Your Railway setup wizard shows **MiniMax M2.1** as the provider. Groq may be under another group or not in the wizard. Here’s how to get MiniMax for free, and how to try Groq.

---

## 1. Get a MiniMax API key (free)

1. **Sign up:** Go to **https://platform.minimax.io**
2. **Register / log in** (email or phone).
3. **Create an API key:** In the dashboard go to **API Keys** (or **Account** → **API Keys**) → **Create new secret key**.
4. **Copy the key** and paste it into the Railway setup wizard in the “Key / Token” field.
5. **Billing:** MiniMax often gives new users free credits or a free tier. Check **Billing** or **Balance** in the dashboard. No card required to start in many regions.

Use **MiniMax - M2.1** in the wizard, paste the key, then continue the wizard (e.g. **Run setup**).

---

## 2. If you want Groq but it’s not in the wizard

The template may only show certain providers (e.g. MiniMax). You can:

**Option A – Look for OpenRouter in the wizard**  
- If there is an **OpenRouter** provider group, choose it.  
- Use your **OpenRouter API key** (from https://openrouter.ai).  
- OpenRouter can use **Groq** models (e.g. `groq/llama-3.3-70b-versatile`). After setup you may need to set the model name in config.

**Option B – Use MiniMax first, add Groq later**  
- Finish setup with **MiniMax** so the app works.  
- Then add Groq by editing config on the server (e.g. in `/data/.clawdbot` or wherever the template stores config), if the stack supports multiple providers or switching.  
- This depends on the template; you may need to check the template’s docs or repo.

**Option C – Check for “Other” or “Custom”**  
- If the wizard has an “Other”, “Custom”, or “API key” provider that accepts a generic endpoint + key, you might be able to point it at Groq. Template docs would say how.

---

## 3. Summary

| Goal | What to do |
|------|------------|
| **Use the wizard now** | Get a free MiniMax key at **https://platform.minimax.io** → API Keys → create key → paste in wizard. |
| **Use Groq** | If Groq isn’t listed, try OpenRouter (if available) and use a Groq model there, or finish setup with MiniMax and add Groq later via config if the template allows. |

Start with MiniMax so the agent works; you can switch or add Groq once you see how the template stores provider config.
