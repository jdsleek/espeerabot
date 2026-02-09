# Other platforms like ClawTasks to run agents on (free tasks / testing)

Besides **ClawTasks** (clawtasks.com), here are other agent task/bounty marketplaces you can use to test your agents. Focus: free or low-cost ways to post and complete tasks.

**Note:** **ClawTasks** (clawtasks.com) is different from **Claw4Task** — ClawTasks is the one with real USDC payments on Base (Together AI); Claw4Task is separate/beta.

---

## Active Agent-to-Agent Marketplaces

### 1. **ClawTasks** (clawtasks.com) — current

- **What:** Agent-to-agent bounty marketplace; post free (amount 0) or paid bounties; agents claim and submit. Real economic activity; USDC on Base (Ethereum L2).
- **Free:** Yes — free bounties (amount 0). Paid claims may be paused; free tasks still available.
- **API:** Yes — `https://clawtasks.com/api` (agents, bounties, claim, submit). Auth: Bearer API key.
- **Use:** We already run jobmaster, jobmaster2, jobmaster3 here. **Best for paid work with real USDC when paid features are on.**

### 2. **Molt Road**

- **What:** Agent-only marketplace inside the OpenClaw ecosystem. Agents connect via API, do onboarding tasks, and can list **data**, **computing power**, or **specific skills**. Other agents browse and buy.
- **Use:** Complements OpenClaw/ClawTasks; list our capabilities or buy from other agents. Check OpenClaw/Molt docs for API and onboarding.

### 3. **MoltBook** (already in our stack)

- **What:** Social network for AI agents — post, discuss, upvote; verified identities and reputation. **~1.5M+ autonomous agents** (Feb 2026).
- **Use:** We’re already registered (m/clawtasks). **Primary testing ground for traffic and visibility**; use for recruitment and identity alongside ClawTasks.

---

## Human-Facing Agent Marketplaces (visibility / real-world testing)

### 4. **AI Agent Store** (aiagentstore.ai)

- **What:** AI agent marketplace/directory to list agents for visibility and connect with users.
- **Use:** List Jobmaster Agency (or individual agents) for broader visibility and inbound interest.

### 5. **Jenova AI Agent Marketplace**

- **What:** Specialized agents across categories; deep domain expertise; integrates with Gmail, Google Calendar, Google Drive, etc. via Model Context Protocol (MCP).
- **Use:** Another listing option for visibility and integrations.

---

## Other Agent / Bounty Platforms

### 6. **Freelance AI (PayAI)**

- **What:** Marketplace where AI agents work for and hire each other. Open source; built on libp2p, IPFS, ElizaOS, Solana.
- **Free / test:** Open source; you can run or join a network. Payments/escrow on Solana.
- **API / integration:** Plugin support for Eliza, Virtuals, Autogen, LangChain. Contract-based engagements on IPFS.
- **Links:** [Introduction](https://docs.payai.network/freelance-ai/introduction), [Getting started](https://docs.payai.network/freelance-ai/getting-started).

---

## 3. **AgentBounty**

- **What:** Decentralized AI agent marketplace on Base. Pay-per-use (you pay for completed tasks only).
- **Free / test:** “Free demo mode” mentioned for testing. Mainnet uses USDC on Base (Sepolia for test).
- **API:** Likely wallet + agent registration; check their docs.
- **Links:** [User guide (DEV)](https://dev.to/prema_ananda/agentbounty-user-guide-454o), Base ecosystem.

---

## 4. **GigBot** (gigbot.xyz)

- **What:** Job marketplace for AI agents. Post “gigs” (micro-bounties) with token rewards; humans or agents complete and claim to EVM/Solana wallets.
- **Status:** Some sources say it is no longer active; the API and docs may still be up for reference.
- **API:** `https://www.gigbot.xyz/api` — create gig, start gig, get gig types, claim tokens. [API docs](https://www.gigbot.xyz/api-doc), [GitBook](https://viabull-labs.gitbook.io/gig.bot).
- **Use:** If still live, good for testing “post task → agent completes → claim” flows (similar to ClawTasks).

---

## 5. **nullpath**

- **What:** AI agents marketplace, pay-per-request. x402 HTTP payments, USDC on Base.
- **Free:** Not clearly free; $0.001 flat fee + 15% platform cut; agents keep 85%.
- **Use:** More “call an agent API and pay” than “post a bounty and have someone claim it,” but another place agents can earn.

---

## 6. **Moltbook** (already in our stack)

- **What:** Social / “front page of the agent internet,” not a bounty board. We use it for recruitment (m/clawtasks) and identity.
- **Free:** Yes for posting and API (agent verification, etc.).
- **Use:** Complements ClawTasks (visibility, referrals); not a replacement for task posting/claiming.

---

## Quick comparison (for free-task testing)

| Platform     | Free tasks / test | Post bounties | Agents claim & complete | API |
|-------------|-------------------|---------------|--------------------------|-----|
| ClawTasks  | Yes (free bounties) | Yes          | Yes                      | Yes |
| Freelance AI | OSS / run yourself | Yes (marketplace) | Yes                | Plugins / docs |
| AgentBounty | Demo mode        | Yes (pay for completed) | Yes        | Check docs |
| GigBot     | Possibly (tokens) | Yes (gigs)   | Yes                      | Yes (if still up) |
| Moltbook   | N/A (social)     | No bounties  | No                       | Yes (identity) |

---

## Recommendation for “another site to test”

1. **ClawTasks** — Keep using for free bounties; we’re already set up.
2. **Freelance AI** — Best “other” option: open source, agent-to-agent marketplace, clear docs. Run or join a network and test with free/low-value contracts.
3. **GigBot** — If the site/API is still live, try creating a gig and having an agent complete and claim (similar flow to ClawTasks).
4. **AgentBounty** — Use demo mode for testing; then move to testnet (Base Sepolia) if you want to try paid completions.

For **free task testing only**, the most direct alternatives are: **Freelance AI** (self-hosted/OSS) and **GigBot** (if still active). ClawTasks remains the main production-style option we use today.
