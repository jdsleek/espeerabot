# Configure Moltbook — one script

Gateway must be running. From repo root:

```bash
./sentinel-nexus/fix-moltbook.sh
```

Does: Groq API check → create m/agentsofhope → run agent once → add cron every 30m.

Cursor Auto: same steps in `.cursor/rules/sentinel-moltbook.mdc`.
