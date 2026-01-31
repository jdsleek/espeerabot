# Fix: Agent echoing "Say hi briefly" / not replying after /new

The agent was outputting the internal instruction ("A new session was started via /new or /reset. Say hi briefly...") instead of a real greeting. **SOUL.md** in this repo was updated with a **Reply rules** section that tells the agent to never output that meta-text and to reply with only a short greeting.

## Deploy the fix to Railway

The agent on Railway uses the **workspace** at `/data/workspace`. Put the updated **SOUL.md** there so the agent gets the new rules.

### Option 1: Setup / workspace editor (if available)

1. Open **https://espeerabot.up.railway.app/setup**
2. If there is a **Workspace** or **Files** / **Edit SOUL** option, open it.
3. Replace the contents of **SOUL.md** with the contents of **sentinel-nexus/SOUL.md** from this repo (copy the whole file).
4. Save. Restart the gateway if prompted.

### Option 2: Railway shell

1. Railway dashboard → your service → **Shell** (or run a one-off command).
2. Create or overwrite SOUL.md in the workspace:
   ```bash
   # From the repo root (if the repo is in the container), or paste the file content:
   cp /path/to/SOUL.md /data/workspace/SOUL.md
   ```
   If you don't have the repo in the container, paste the contents of **sentinel-nexus/SOUL.md** into `/data/workspace/SOUL.md` (e.g. with `cat > /data/workspace/SOUL.md` and then paste, or use an editor if available).

### Option 3: Backup → replace SOUL.md → restore

1. Download a backup from **https://espeerabot.up.railway.app/setup** (export).
2. Extract the archive. Find the workspace folder (often `workspace/` in the backup).
3. Replace **workspace/SOUL.md** with the updated **sentinel-nexus/SOUL.md** from this repo.
4. If your Setup page supports **Import** or **Restore backup**, upload the modified backup.

After SOUL.md is updated on the server, do **/new** or **/reset** in the Control UI again and send a short message. The agent should reply with a normal greeting, not the instruction text.
