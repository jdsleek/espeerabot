# Agency mode — summary

The bots are set up to **run like an agency**: recruit others, apply for jobs, post bounties, and make money when possible.

---

## What’s enhanced

### ClawTasks cron (every 4h)

- **Profile + referral:** Gets `/agents/me` (referral code for recruitment).
- **Pending first:** Handles anything that needs your action (stake, submit, review).
- **Recruit:** Posts to **m/clawtasks** on Moltbook with your referral code and skill link (earn when recruits complete bounties).
- **Apply for jobs:** Lists open bounties, claims one if you can do it, submits work for claimed bounties.
- **Post work:** Posts at least one **free bounty** (amount 0) so other agents work for you.
- Writes a one-line result to `cron-results/clawtasks-latest.txt`.

### Moltbook cron (every 2h)

- Status, DM check, feed as before.
- **Optional recruitment:** If ClawTasks credentials exist, posts once to **m/clawtasks** with referral code and skill link to keep the agency visible.

### Account summary

- Run: **`./sentinel-nexus/account-summary.sh`**
- Shows: profile (name, wallet, referral), as worker (completed, earned, success rate), as poster (posted, spent), reputation, and links (fund, dashboard, bounties, workers).

---

## How to run

| What | Command |
|------|--------|
| Account summary | `./sentinel-nexus/account-summary.sh` |
| View cron results | `./sentinel-nexus/view-cron-results.sh` |
| Run ClawTasks cron now | `./sentinel-nexus/run-clawtasks-cron-now.sh` |
| Run Moltbook cron now | `./sentinel-nexus/run-moltbook-cron-now.sh` |
| Run both crons now | `./sentinel-nexus/run-both-crons-now.sh` |
| Post water factory job | `./sentinel-nexus/post-water-factory-job.sh` |

Crons run on schedule (ClawTasks every 4h, Moltbook every 2h) when the gateway is running.

---

## Files

- **ClawTasks agency steps:** `~/.openclaw/skills/clawtasks/HEARTBEAT_CRON.md`
- **Moltbook + recruitment:** `~/.openclaw/skills/moltbook/HEARTBEAT_CRON.md`
- **Cron job config:** `~/.openclaw/cron/jobs.json`
- **Credentials:** `~/.openclaw/clawtasks-credentials.json`, `~/.openclaw/moltbook-credentials.json`
- **Full registration (jobmaster):** `~/.openclaw/clawtasks-jobmaster-registration.json` (includes private key; keep secure).
