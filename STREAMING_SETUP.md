# Free Streaming Platform Setup Guide

## Recommended Platforms (All Free)

### 1. **YouTube Live** ⭐ (Easiest & Most Reliable)
**Best for:** Memorial services, professional streams

**Setup Steps:**
1. Go to [YouTube Studio](https://studio.youtube.com)
2. Click "Go Live" in the top right
3. Set up your stream (you may need to verify your account first)
4. Start streaming
5. Copy the video ID from your stream URL: `https://www.youtube.com/watch?v=VIDEO_ID`
6. Open `script.js` and find the YouTube Live section
7. Uncomment the code and replace `YOUR_VIDEO_ID_HERE` with your actual video ID

**Pros:**
- Free and reliable
- Easy to embed
- Works on all devices
- Can be saved as a recording after

**Cons:**
- Requires YouTube account verification (usually instant)

---

### 2. **Twitch** (Great for Live Streaming)
**Best for:** Interactive streams with chat

**Setup Steps:**
1. Create a free account at [twitch.tv](https://www.twitch.tv)
2. Go to your Creator Dashboard
3. Start streaming using OBS or Streamlabs
4. Get your channel name
5. Open `script.js` and find the Twitch section
6. Uncomment the code and replace `YOUR_CHANNEL_NAME` with your channel name

**Pros:**
- Free
- Great for live interaction
- Professional streaming tools

**Cons:**
- Requires streaming software (OBS is free)
- More technical setup

---

### 3. **Facebook Live** (Easy for Social Sharing)
**Best for:** Reaching Facebook audience

**Setup Steps:**
1. Go to your Facebook page or profile
2. Click "Live" to start streaming
3. After going live, copy the video/post URL
4. Extract the video ID from the URL
5. Open `script.js` and find the Facebook Live section
6. Uncomment and add your video ID

**Pros:**
- Free
- Easy to share on Facebook
- Built into Facebook

**Cons:**
- Embedding can be limited
- May require page setup

---

### 4. **Restream** (Multi-Platform Streaming)
**Best for:** Streaming to multiple platforms at once

**Setup Steps:**
1. Sign up at [restream.io](https://restream.io) (free tier available)
2. Connect your streaming platforms
3. Get your embed code from the dashboard
4. Open `script.js` and use the custom embed URL option

**Pros:**
- Stream to multiple platforms simultaneously
- Free tier available
- Professional features

**Cons:**
- Requires account setup
- May have limitations on free tier

---

## Quick Setup Instructions

1. **Choose your platform** (YouTube Live is recommended for memorials)
2. **Set up your stream** on that platform
3. **Open `script.js`** in a text editor
4. **Find the section** for your chosen platform
5. **Uncomment the code** (remove the `/*` and `*/`)
6. **Replace the placeholder** with your actual stream ID/URL
7. **Save the file** and refresh your webpage

## Testing Your Stream

- Make sure your stream is actually live before testing
- The embed will only work when the stream is active
- Test on both desktop and mobile devices
- Check that the stream loads properly

## Need Help?

- **YouTube:** [YouTube Live Help](https://support.google.com/youtube/topic/9257899)
- **Twitch:** [Twitch Creator Camp](https://www.twitch.tv/creatorcamp)
- **Facebook:** [Facebook Live Guide](https://www.facebook.com/help/1636872026560010)
