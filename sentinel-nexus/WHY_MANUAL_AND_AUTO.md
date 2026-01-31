# Why it was manual and how to make it fully automatic

Other agents on Moltbook (and elsewhere) run **automatically** in the background. Yours was configured to run on a **heartbeat** every 30 minutes, but it was effectively **manual** because:

---

## Why it wasn’t working automatically

1. **Heartbeat runs in the main session**  
   Every 30 minutes the gateway runs the agent in the **same** chat session. That session grows (history + tools + workspace files). After a while the total context exceeds the model’s limit → **context overflow** → the scheduled run fails. You only saw it work when you triggered a run **manually** (e.g. `openclaw system event --mode now`) after we had trimmed the session, so the run had enough context.

2. **`target: "none"` only affects delivery**  
   With `target: "none"`, the agent **does** run; the reply just isn’t sent to any channel. So “skipped” in the UI meant “we didn’t deliver the reply,” not “we didn’t run.” When the run **failed** (e.g. context overflow), that error showed up as the “preview,” which looked like a skipped run.

3. **No separate “autonomous” mode**  
   The setup wasn’t wrong on purpose; it’s just that **heartbeat + main session** is prone to overflow for an agent that does a lot (Moltbook API, HEARTBEAT.md, SOUL, tools, etc.). Other agents that “just work” often use either smaller context, a fresh session per run, or a different stack.

---

## How to make it fully automatic (like the others)

Use **cron with an isolated session** instead of heartbeat:

- **Cron (isolated)** = one run every 30 minutes in a **new** session each time. No growing history → no context overflow.
- Same workspace (HEARTBEAT.md, TOOLS.md, memory, etc.) and same Moltbook logic; only the **session** is fresh per run.

### Steps (one-time)

1. **Heartbeat is already disabled** in your config (`every: "0m"`) so only cron drives the agent.

2. **Add the Moltbook cron job** (gateway must be running):
   ```bash
   ./sentinel-nexus/enable-auto-moltbook.sh
   ```
   Or manually:
   ```bash
   openclaw cron add \
     --name "Sentinel Moltbook" \
     --every 30m \
     --session isolated \
     --message "Read HEARTBEAT.md from your workspace and follow it strictly. Check Moltbook using your API key from ~/.openclaw/moltbook-credentials.json. If you do something on Moltbook, say what you did; otherwise reply HEARTBEAT_OK." \
     --wake now
   ```

3. **Confirm the job**:
   ```bash
   openclaw cron list
   ```

4. **Keep the gateway running** (e.g. as a LaunchAgent or in a terminal). The gateway runs the cron scheduler; every 30 minutes it starts an isolated run. No manual trigger needed.

---

## Summary

| Before | After |
|--------|--------|
| Heartbeat every 30m in **main** session | Cron every 30m in **isolated** session |
| Context grew → overflow → run failed | Fresh session each run → no overflow |
| Felt “manual” because only manual runs succeeded | Fully automatic once the cron job is added |

After you run `enable-auto-moltbook.sh` (or the equivalent `openclaw cron add`), the agent will run on its own every 30 minutes, like other autonomous agents.
