# Agent Setup Strategy — Learn, Improve, Earn, Participate

**How I would set up agents as an AI engineer** — focused on what actually works and earns, with live visibility as they work.

---

## 1. The Problem With the Current Setup

| Issue | Current | Better |
|-------|---------|--------|
| **Single brain, one lead** | Cron uses only jobmaster; jobmaster2/3 sit idle | All agents work in parallel; each earns |
| **Blind to APIs** | Pending/open APIs fail → no claims | Multi-platform; if one fails, others run |
| **Moltbook = recruitment only** | Post to m/clawtasks, get suspended for duplicates | Moltbook = karma + visibility + referrals; semantic engagement, not spam |
| **No live view** | Dashboard shows stats, not *what they're doing right now* | Virtual office: see agents claim, submit, post in real time |
| **One platform** | ClawTasks only for earning | ClawTasks + MolTask + MoltCities + BountyBot = multiple income streams |
| **No learning loop** | agency-learnings.md exists but isn't driving decisions | Leaderboard scraping, competitor analysis, A/B on what wins |

---

## 2. Platforms That Actually Pay (2025–2026)

| Platform | What | Earns | API | Priority |
|----------|------|-------|-----|----------|
| **ClawTasks** | Bounty marketplace, USDC on Base | Free now; paid when on | Yes | **P0** — already set up |
| **MolTask** | 1K–7.5K MOLT per task via REST | Tokens | REST API | **P1** — add |
| **MoltCities** | Solana escrow, verified work | USDC | Solana | **P1** — add |
| **BountyBot** | Security vuln hunting, Solana | 70% finder + 20% pool, USDC | Yes | **P1** — high payout |
| **TweetBounty** | Viral tweets for brands, Base | USDC for engagement | Base | **P2** — creative |
| **Moltbook** | Social, karma, referrals | Visibility → ClawTasks referrals | Yes | **P0** — identity + growth |
| **Molt Road** | Agent marketplace, data/compute | List skills, sell | OpenClaw ecosystem | **P2** |
| **Rose Token** | ~$3–9 per task, escrow | Direct pay | Smart contract | **P2** |
| **Openwork** | Base, competitive bounties | Up to 500K tokens | Base | **P2** |

**Strategy:** Start with ClawTasks + Moltbook (already have). Add MolTask and BountyBot next — both have clear APIs and pay. MoltCities and TweetBounty when ready.

---

## 3. How I Would Set It Up

### A. Agent Roles (Not "Lead + Workers")

| Agent | Platform | Role | Schedule |
|-------|----------|------|----------|
| **jobmaster** | ClawTasks | Poster + claimer | Every 15 min |
| **jobmaster2** | ClawTasks | Claimer + submitter | Every 15 min |
| **jobmaster3** | ClawTasks | Claimer + submitter | Every 15 min |
| **Sentinel_Nexus** | Moltbook | Engage, karma, recruit | Every 20 min |
| **security_agent** | BountyBot (when added) | Vuln scan, submit | Every 6 h |
| **moltask_agent** | MolTask (when added) | Claim + complete | Every 30 min |

**Key change:** Each agent has a *primary platform* and *schedule*. No single "brain" bottleneck. Parallel execution.

### B. Moltbook Strategy (From moltgrowth + X)

| Action | How | Frequency |
|--------|-----|-----------|
| **Karma** | Post value (takes, essays), not "welcome" | 1–2/day max |
| **Engage** | `moltgrowth semantic` — AI finds relevant posts, comment | Every 20 min |
| **Grow** | `moltgrowth grow` — reply to comments on our posts | Every 20 min |
| **Recruit** | Post to m/clawtasks only when we have *new* free bounties | When new bounties |
| **DMs** | Approve pairing; reply with value, not templates | Human-in-loop or auto-allowlist |

**Never:** Duplicate posts, generic "Hi I'm X", spam m/clawtasks. That gets suspended.

### C. ClawTasks Strategy (From Leaderboard + X)

| Action | How |
|--------|-----|
| **Claim fast** | First valid submission wins; run claim loop every 10–15 min |
| **Submit quality** | Kimi 2.5 delivers; human review optional for paid |
| **Post bounties** | Clear scope, 5★ potential; don't post 188 and leave them open |
| **Close old** | Complete or cancel stale bounties before posting new |
| **Reputation** | Success rate + completed count = more work |

### D. Multi-Platform Cron Architecture

```
┌─────────────────────────────────────────────────────────────┐
│  SCHEDULER (every 1 min)                                    │
│  - Check which jobs are due                                 │
│  - Dispatch to platform-specific runners                    │
└─────────────────────────────────────────────────────────────┘
         │
         ├──► ClawTasks Runner (jobmaster, jobmaster2, jobmaster3)
         │    - Get open bounties (if API up)
         │    - Claim best (each agent picks 1–2)
         │    - Submit pending (Kimi 2.5)
         │    - Post 1 bounty if < N active
         │
         ├──► Moltbook Runner (Sentinel_Nexus)
         │    - moltgrowth semantic (or equivalent)
         │    - moltgrowth grow
         │    - Optional: post if no post in 24h
         │
         ├──► BountyBot Runner (when added)
         │    - Fetch targets, scan, submit findings
         │
         └──► MolTask Runner (when added)
              - Fetch tasks, claim, complete
```

**Resilience:** If ClawTasks API fails, Moltbook and others still run. No single point of failure.

---

## 4. Virtual Visibility — See Them Work

### What "See Them Virtually" Means

| View | What You See |
|------|--------------|
| **Live activity feed** | "10:32 — jobmaster2 claimed bounty X" / "10:33 — Sentinel_Nexus commented on post Y" |
| **Agent avatars** | Each agent as a card; status = idle / claiming / submitting / posting |
| **Platform columns** | ClawTasks | Moltbook | BountyBot — each with last action + next run |
| **Earnings ticker** | Running total USDC / MOLT; +0.05 when a bounty completes |
| **Real-time log** | SSE or WebSocket stream of cron output |

### Implementation Options

1. **Extend current dashboard** — Add `/admin/live` with SSE from server; server tails cron output and pushes events.
2. **OpenClaw Dashboard (mudrii/realriplab)** — Use existing open-source dashboards; they have SSE, activity heatmaps, cost tracking.
3. **Custom "Agent Office"** — Canvas/SVG floor plan: each agent = desk; when working, desk glows; click = last 10 actions.

### Minimal Addition (Quick Win)

- **Dashboard card:** "Live activity" — poll `/api/agency-data` every 5s; show last 5 actions from `cron-results` + in-memory buffer of "just happened" (claim, submit, post).
- **Event buffer:** When cron writes to clawtasks-latest.txt or moltbook-latest.txt, server parses and adds to `recentActions[]`; API returns it; UI shows "2 min ago — jobmaster claimed…".

---

## 5. Learning Loop — Improve Over Time

| Input | Output |
|-------|--------|
| Leaderboard (Claws, Moltbook top karma) | "Top agents post X type; we should try Y" |
| Our wins (which bounties got 5★) | "Research + clear scope wins" |
| Our losses (rejected, abandoned) | "Avoid vague titles, add word count" |
| Moltbook engagement (which posts get upvotes) | "Takes > welcome; controversy gets engagement" |
| Competitor bounties | "They post Z; we can do similar or better" |

**Implementation:**
- Weekly job: scrape leaderboard, top Moltbook posts; Kimi summarizes → `weekly-tactics.md`.
- Each cron run: append one line to `agency-learnings.md` (already exists); brain reads last N lines before deciding.
- A/B: Post 2 bounty styles (A vs B); track which gets claimed faster; double down on winner.

---

## 6. Concrete Next Steps (Priority Order)

| # | Task | Effort | Impact |
|---|------|--------|--------|
| 1 | **Multi-agent cron** — jobmaster2, jobmaster3 run claim+submit in same cycle | Medium | 3x throughput |
| 2 | **Moltbook: moltgrowth or equivalent** — semantic engage, grow; avoid duplicate posts | Medium | Karma + no suspension |
| 3 | **Live activity feed** — dashboard shows last 10 actions, refresh every 5s | Low | See them work |
| 4 | **ClawTasks resilience** — if pending/open API fails, still run submit for existing pending | Low | Don't lose work |
| 5 | **Close old bounties** — before posting new, cancel or complete stale ones | Low | Avoid "too many active" |
| 6 | **Add MolTask** — REST API, 1K–7.5K MOLT/task | Medium | New income stream |
| 7 | **Add BountyBot** — security scanning, 70% finder reward | Medium | High payout potential |
| 8 | **Leaderboard scraping** — weekly, feed Kimi for tactics | Low | Learn from winners |

---

## 7. How I Would Set It Up Myself (Summary)

1. **One agent per platform** — jobmaster = ClawTasks poster; jobmaster2/3 = ClawTasks claimers; Sentinel_Nexus = Moltbook only.
2. **Parallel crons** — Not one 5-min brain. Separate: ClawTasks every 15 min, Moltbook every 20 min; each has its own job.
3. **Moltbook = moltgrowth-style** — semantic + grow; no spam. Value posts only.
4. **Live dashboard** — SSE or 5s poll; show "agent X did Y at Z".
5. **Add MolTask + BountyBot** — Two more platforms that pay; diversify.
6. **Learning** — Leaderboard scrape, learnings file, weekly tactics. Iterate.

---

## 8. Ideas Imported From X / Web

| Source | Idea |
|--------|------|
| **Moltgrowth** | `semantic` (AI finds relevant posts), `grow` (reply to comments), no duplicate posts |
| **ClawTasks leaderboard** | First valid submission wins; speed + quality |
| **BountyBot** | 70% finder + 20% pool; 24–48h payout; Solana wallet |
| **TweetBounty** | Viral tweets for brands; USDC on Base |
| **MolTask** | 1K–7.5K MOLT per task; REST API |
| **OpenClaw dashboards** (mudrii, realriplab) | SSE, activity heatmaps, cost tracking, 30-day history |
| **Fiverr/Upwork model** | AI as production tool; $500–2K/mo content; $5–10K/mo automation |
| **Rose Token** | ~$3–9/task; smart contract escrow |

---

## 9. Visual: The Agent Office (Target State)

```
┌────────────────────────────────────────────────────────────────────────┐
│  JOBMASTER AGENCY — LIVE                                               │
│  Total earned: 12.50 USDC  |  Last 24h: +2.30  |  Refresh: 5s           │
├────────────────────────────────────────────────────────────────────────┤
│  CLAWTASKS          │  MOLTBOOK           │  MOLTASK (soon)            │
│  jobmaster   ●      │  Sentinel_Nexus ●   │  —                         │
│  jobmaster2  ○      │  karma: 47          │                            │
│  jobmaster3  ●      │  last: commented    │                            │
│  last: posted #189  │  on "AI challenges" │                            │
├────────────────────────────────────────────────────────────────────────┤
│  LIVE ACTIVITY                                                         │
│  10:45:22  jobmaster3  submitted bounty abc123  (pending review)        │
│  10:44:01  Sentinel_Nexus  commented on post xyz                        │
│  10:43:18  jobmaster2  claimed bounty def456                          │
│  10:42:55  jobmaster  posted bounty "Research: Lagos water sales"      │
└────────────────────────────────────────────────────────────────────────┘
```

---

**Next:** Pick 1–2 items from §6 and implement. Recommended: **#1 (multi-agent cron)** and **#3 (live activity feed)** first — biggest impact with existing setup.
