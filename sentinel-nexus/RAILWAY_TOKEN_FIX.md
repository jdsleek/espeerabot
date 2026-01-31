# Railway: token_missing and token_mismatch — fix

From your logs:
- **token_missing** = you're opening `/openclaw` **without** the token in the URL. The UI never sends a token, so the gateway rejects the connection.
- **token_mismatch** = you're sending a token, but it's **not** the one the gateway is using (e.g. old token, or token from config vs. token from Railway env).

---

## Fix 1: Always use the tokenized URL

**Do not** open:
```
https://espeerabot.up.railway.app/openclaw
```

**Do** open (with the correct token):
```
https://espeerabot.up.railway.app/openclaw?token=YOUR_GATEWAY_TOKEN
```

If you use the URL **without** `?token=...`, you will always get **token_missing**.

---

## Fix 2: Get the token the gateway actually uses

The gateway reads its token from **/data/.clawdbot/openclaw.json** on the server (field `gateway.auth.token`). The **wrapper** may use **OPENCLAW_GATEWAY_TOKEN** from Railway Variables. They must be the same.

**Option A — From backup (recommended)**  
1. Open **https://espeerabot.up.railway.app/setup**  
2. Click **Download backup (.tar.gz)**  
3. Extract the archive and open **.clawdbot/openclaw.json** (or **openclaw.json** inside the archive)  
4. Find **`gateway.auth.token`** (or **`gateway.token`**) and copy its **exact** value  
5. Open: `https://espeerabot.up.railway.app/openclaw?token=PASTE_THAT_VALUE_HERE`  
6. Use that bookmark so you always open the UI with the token  

**Option B — Force one token via Railway**  
1. In Railway → your service → **Variables**  
2. Set **OPENCLAW_GATEWAY_TOKEN** to a **new** value you choose (e.g. a long random string, 32+ chars)  
3. Save and **redeploy**  
4. On the setup page, click **Reset** (this deletes the OpenClaw config so you can rerun onboarding)  
5. Run **setup** again (model + API key, etc.)  
6. After setup, the gateway should be using the same token as the wrapper (if the template writes OPENCLAW_GATEWAY_TOKEN into config). Use that token in the URL:  
   `https://espeerabot.up.railway.app/openclaw?token=YOUR_CHOSEN_TOKEN`  

If the template does **not** write the env token into openclaw.json, Option A (backup) is more reliable.

---

## Fix 3: Bookmark the tokenized URL

After you have the correct token, bookmark:
```
https://espeerabot.up.railway.app/openclaw?token=YOUR_TOKEN
```
Use that bookmark every time. Then you won’t get token_missing or token_mismatch from opening the wrong URL.

---

## Summary

| Log reason        | Cause                          | Fix |
|-------------------|--------------------------------|-----|
| **token_missing** | Opened /openclaw without token | Open `/openclaw?token=YOUR_TOKEN` |
| **token_mismatch**| Token in URL ≠ gateway token   | Get token from backup (Option A) or set OPENCLAW_GATEWAY_TOKEN + Reset + re-setup (Option B), then use that token in the URL |

Always use the **tokenized** URL; get the token from the **backup** (Option A) so it matches what the gateway has.
