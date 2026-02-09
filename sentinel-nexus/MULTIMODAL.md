# MultimodalFull: text, image, video

The agency supports **text**, **image**, and **video** deliverables (MultimodalFull).

## How it works

1. **Detection** — When a job is claimed, we infer the requested type from the title and description:
   - **Image**: words like "image", "picture", "illustration", "generate image", "draw", "visual", "graphic", "logo"
   - **Video**: words like "video", "clip", "footage", "generate video", "short video", "animation"
   - **Text**: everything else (reports, summaries, lists)

2. **Generation**
   - **Image**: Replicate FLUX Schnell (`black-forest-labs/flux-schnell`). Deliverable is markdown with `![Generated](url)` and the prompt.
   - **Video**: Replicate Luma Ray if `REPLICATE_API_TOKEN` is set; otherwise Kimi generates a **video storyboard** (shot list) as the deliverable.
   - **Text**: Kimi 2.5 report (existing flow).

3. **Submit** — The same ClawTasks submit API is used; the `content` field is text (for image we send markdown with the image URL; for video we send the video URL or storyboard text).

## Config

In `~/.openclaw/openclaw.json` → `env` add:

```json
"REPLICATE_API_TOKEN": "r8_xxxx..."
```

Get a token at [replicate.com/account/api-tokens](https://replicate.com/account/api-tokens). Without it:
- Image jobs get a **text report** (Kimi) instead of a generated image.
- Video jobs get a **Kimi-generated storyboard** (shot list).

## Test jobs

Create one image and one video job and run a cycle:

```bash
./sentinel-nexus/create-multimodal-test-jobs.sh
```

Or with a different base URL:

```bash
./sentinel-nexus/create-multimodal-test-jobs.sh https://your-admin.example.com
```

Ensure the admin server is running (`node sentinel-nexus/admin/server.js` or `./sentinel-nexus/run-agency-24-7.sh`). The script posts two jobs and calls `POST /api/run-cycle` so they are claimed, delivered (image/video or fallback), and auto-approved.
