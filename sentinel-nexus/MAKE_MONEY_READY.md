# Make money — readiness checklist

Get everything ready so the agency can earn. Then apply to one platform and see it work.

---

## 1. We’re already on ClawTasks (our main earn platform)

- [x] jobmaster, jobmaster2, jobmaster3 registered  
- [x] All three enabled in agency  
- [x] Free bounties: we can claim and submit  
- [ ] **Approve pending submissions** so completions count and we build rating: https://clawtasks.com/dashboard → open each bounty we submitted to → Approve  
- [ ] When **paid claims** reopen: fund each agent’s wallet (USDC + a little ETH on Base) via https://clawtasks.com/fund/<wallet>

**Why we’re not claiming the bounties you see on the site right now:** ClawTasks has **paid features paused**. The visible instant bounties (e.g. coda_owl’s $1 tasks) are **paid**; the API returns “Paid bounties and transfers are currently paused. Free tasks are still available.” We only **claim free (amount 0) instant bounties** so we don’t hit that block. When someone posts a **free** instant bounty, we’ll claim and work on it automatically. When ClawTasks re-enables paid claims, we’ll claim paid bounties too (wallets need USDC + ETH on Base).

---

## 2. Run a cycle and see

1. **Dashboard:** http://127.0.0.1:3880  
2. Click **Run cycle now (claim + complete 2)** — claims instant free bounties and submits up to 2 pending.  
3. **ClawTasks:** Open https://clawtasks.com/dashboard — see our bounties and pending (need approval). Approve submissions so we get “completed” and rating.  
4. Repeat: more free bounties → run cycle → approve → we earn reputation; when paid is back, we earn USDC.

---

## 3. Apply to one and see (this is it)

**“Apply” = we’re already applied on ClawTasks.** To see it:

1. Run one cycle: `./sentinel-nexus/run-agency-cycle-now.sh` or use the dashboard button.  
2. Open ClawTasks: https://clawtasks.com/dashboard and https://clawtasks.com/workers — you’ll see our agents and bounties.  
3. Approve any submissions from jobmaster2/jobmaster3 (our bounties) so those tasks show as completed and we build profile.  
4. Optional: try **AgentBounty** (buyer side, demo) to see another platform: https://agentbounty.premananda.site/?demo=true  

---

## 4. Optional: another platform

- **Freelance AI (PayAI):** ElizaOS + plugin; Solana. See docs.payai.network/freelance-ai/getting-started.  
- **AgentBounty:** Register as user, connect wallet (Base Sepolia), create tasks (you pay their agents). For us to *earn* there we’d need to list as an agent provider if they support it.  
- Use **AGENCY_PITCH.md** when signing up or listing the agency anywhere.

---

## Quick commands

```bash
# Run one cycle (claim + complete 2)
./sentinel-nexus/run-agency-cycle-now.sh

# Start full 24/7 (gateway + dashboard + claim once)
./sentinel-nexus/run-agency-24-7.sh
```

Then open **ClawTasks** and **dashboard** to see and approve.
