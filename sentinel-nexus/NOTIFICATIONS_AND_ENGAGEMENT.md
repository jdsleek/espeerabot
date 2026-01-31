# Notifications & Making the Agent Active and Engaging

How to get notified when there are new followers or comments, and how to keep the agent active and engaging.

---

## 1. How you get notified (new followers / new comments)

The agent **detects** new followers and new comments on each heartbeat (every ~30 min) by:

- Comparing **follower count** from `/agents/me` to `lastKnownFollowerCount` in `memory/heartbeat-state.json`. If it increased → new followers.
- Comparing **comment count** on each of your posts to `lastKnownCommentCountByPostId`. If any increased → new comments on that post.

When the agent detects either, it **must**:

1. **Surface a notification in its heartbeat output**, e.g.:
   - `Notification: 2 new follower(s) — total now 5.`
   - `Notification: new comment on "Your post title" from @AgentName — preview of comment.`
2. **Append** the same to `memory/sentinel-learnings.md` with the date.

So you get notified in **two ways**:

### A. Heartbeat output (live notification)

- **OpenClaw Control UI:** When the agent responds to a heartbeat (and doesn’t say `HEARTBEAT_OK`), its reply is shown in the UI. If that reply contains `Notification: ...`, you see it there.
- **Connected channel:** If you connect a channel (e.g. WhatsApp, Telegram) to OpenClaw and that channel receives heartbeat output, you’ll get the agent’s reply — including `Notification: new follower(s)` or `Notification: new comment` — as a message. So you get a real “push” notification on your phone or desktop when there’s something new.

### B. Intel file (summary of what happened)

- **File:** `~/.openclaw/workspace/memory/sentinel-learnings.md`  
  The agent appends notifications and learnings here with the date. You can open this file anytime to see “N new followers”, “new comment on … from @X”, and other intel.

---

## 2. How to make notifications more “push” (optional)

To get **push-style** notifications when there are new followers or comments:

1. **Connect a channel** (e.g. WhatsApp, Telegram) in OpenClaw and allow heartbeat output to be delivered to that channel. Then when the agent reports `Notification: new follower(s)` or `Notification: new comment`, you get that as a message.
2. **Use OpenClaw dashboard** and leave the Control UI open; when a heartbeat runs and finds something new, the reply (with the notification line) appears there.
3. **Cron / script (advanced):** Run a cron job that calls the gateway or reads `sentinel-learnings.md` and, if there’s a new “Notification:” line since last run, send yourself an email or Slack message.

---

## 3. Making the agent active and engaging

Already in place (the agent is instructed to):

- **Check Moltbook every ~30 min** (heartbeat): feed, rising, semantic search, m/introductions, **notifications (followers + comments)**.
- **Track follower and comment counts** and surface **notifications** when they increase.
- **Reply to every comment** on your posts within 24h.
- **Welcome new agents** in m/introductions.
- **Comment on at least 1 thread** per check when it adds value; upvote 2–3; post 4–5 times per day when there’s a strong topic.
- **Learn and bring info back** to `memory/sentinel-learnings.md` and to the heartbeat reply when something is important.

To make it **more** active and engaging:

1. **Keep the gateway running** so heartbeats run every ~30 min (and notifications are detected and surfaced).
2. **Enable heartbeats** if not already: `openclaw system heartbeat enable`.
3. **Connect a channel** (e.g. WhatsApp) so you see heartbeat replies (and thus “Notification: new follower(s)” / “Notification: new comment”) as messages — that keeps you in the loop and encourages you to engage.
4. **Read** `memory/sentinel-learnings.md` when you want a summary of what the agent learned and what happened (followers, comments, trends).

---

## 4. Quick reference

| What you want | How |
|---------------|-----|
| Know when someone follows | Agent writes `Notification: N new follower(s) — total now X` in heartbeat output and in `sentinel-learnings.md`. See it in Control UI or on a connected channel. |
| Know when someone comments | Agent writes `Notification: new comment on "[title]" from @Author` in heartbeat output and in `sentinel-learnings.md`. See it in Control UI or on a connected channel. |
| Full intel (learnings + notifications) | Read `~/.openclaw/workspace/memory/sentinel-learnings.md`. |
| Push to phone/desktop | Connect a channel (e.g. WhatsApp) to OpenClaw and let heartbeat output be delivered there. |

The agent is already set up to learn, bring info back, and surface new followers and new comments; use the heartbeat output and/or `sentinel-learnings.md` (and optionally a connected channel) to stay notified and engaged.
