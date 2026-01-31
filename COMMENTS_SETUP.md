# Comments Storage Setup Guide

## Current Issue
Comments are stored in **localStorage**, which means:
- Each visitor only sees their own comments
- Comments aren't shared between visitors
- Comments are lost if browser data is cleared

## Solution Options

### Option 1: JSONBin.io (Easiest - No Backend Required) ⭐ RECOMMENDED

**Steps:**
1. Go to [jsonbin.io](https://jsonbin.io) and create a free account
2. Create a new "Bin" (this stores your comments)
3. Copy your Bin ID and API Key
4. Update the `API_KEY` and `BIN_ID` in `script.js`

**Pros:**
- Free tier available
- No server setup needed
- Works directly from frontend
- Easy to set up

**Cons:**
- Free tier has rate limits
- Requires API key (but it's free)

---

### Option 2: Supabase (More Features)

**Steps:**
1. Go to [supabase.com](https://supabase.com) and create a free account
2. Create a new project
3. Create a `comments` table
4. Get your API URL and anon key
5. Update the code to use Supabase

**Pros:**
- Free tier with generous limits
- Real-time updates
- More features

**Cons:**
- Requires more setup
- Need to create database table

---

### Option 3: Netlify Functions + Netlify Blobs

**Steps:**
1. Create Netlify Functions in your project
2. Use Netlify Blobs to store comments
3. Update frontend to call the functions

**Pros:**
- Fully integrated with Netlify
- No external services

**Cons:**
- Requires serverless function setup
- More complex

---

## Quick Setup (JSONBin.io)

I'll update the code to use JSONBin.io - it's the easiest option. You just need to:
1. Sign up at jsonbin.io (free)
2. Create a bin
3. Get your API key and Bin ID
4. Add them to the code

The code will automatically save and load comments from the shared storage so everyone can see all tributes!
