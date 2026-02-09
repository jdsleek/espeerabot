# Full autonomy — wake up to earnings

Goal: **run 24/7 with minimal human steps, so you can wake up and see earnings.**

---

## What runs without you

| System | Schedule | What it does |
|--------|----------|--------------|
| **ClawTasks brain** | Every 5 min (gateway) | Profile → submit work → list open → claim best → recruit (Moltbook) → post bounty → report → learn |
| **Moltbook** | Every 5 min (if enabled) | Feed, DMs, reply/upvote/post, append learnings to `agency-learnings.md` |
| **Discovery processor** | Every 15 min (admin server) | Reads discovery moves; if MoltX "apply" and not yet registered → **registers** on MoltX automatically |
| **Moltbook learnings** | Every 5 min (admin server) | When `moltbook-latest.txt` updates, appends one line to `agency-learnings.md` |

So: **ClawTasks** and **Moltbook** earn and learn. When the brain records "MOVE: MoltX", we **auto-register** on MoltX within ~15 min. One human step left for MoltX: **post the claim tweet on X, paste the URL** (Dashboard or Brain page). After that, we're claimed and can run MoltX engagement (future heartbeat).

---

## One human step for MoltX

1. Brain evaluates MoltX → says MOVE → we record "MoltX → apply".
2. Within ~15 min the admin server registers **ClawBrain** on MoltX and saves the claim code.
3. **You:** Post the claim tweet (text shown on Dashboard and Brain). Paste the tweet URL in the form → Submit.
4. We call MoltX claim API → done. (Next: link EVM wallet on MoltX for $5 USDC reward — one-time in their UI.)

---

## Where to see earnings

- **Dashboard** (http://127.0.0.1:3880/admin/dashboard): top card **"Earnings — wake up to this"** shows **total USDC** (ClawTasks). Same page: agents, cron status, MoltX status.
- **ClawTasks:** https://clawtasks.com/dashboard (earned, completed, pending).

---

## Start 24/7

```bash
./sentinel-nexus/run-agency-24-7.sh
```

This starts:
- OpenClaw gateway (crons every 5 min)
- Admin server (dashboard, brain, MoltX status, discovery processor, learnings)
- Cycle loop every 2 min (claim, submit, approve)

Then once (with gateway running):

```bash
./sentinel-nexus/enable-auto-moltbook.sh   # Moltbook every 5 min
```

---

## Files

| File | Purpose |
|------|---------|
| `workspace/cron-results/discovery-feed.json` | Recorded moves (e.g. MoltX → apply) |
| `workspace/cron-results/moltx-state.json` | MoltX api_key, claim_code, claimed |
| `workspace/cron-results/agency-learnings.md` | Brain + Moltbook learnings |
| `workspace/cron-results/platform-briefs.json` | Platform evaluations (e.g. MoltX brief) |

---

## Summary

- **ClawTasks:** Fully autonomous (claim, submit, post, recruit). Earnings show on dashboard.
- **Moltbook:** Autonomous every 5 min; we learn and engage.
- **MoltX:** Auto-register when brain says MOVE; you post one tweet and paste URL; then we're claimed. After that, we can add a MoltX heartbeat (follow, like, reply, post) for 24/7 presence and $5 USDC reward once wallet is linked.

**Wake up → open dashboard → see total USDC.**
