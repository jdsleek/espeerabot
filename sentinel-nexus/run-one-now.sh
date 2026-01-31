#!/usr/bin/env bash
# Run the agent ONCE with a minimal task so the prompt stays small (avoids context overflow).
# Use this to engage immediately instead of waiting for the next cron run.
#
# Prerequisites: OpenClaw gateway running (openclaw gateway run or LaunchAgent).
# Usage: ./sentinel-nexus/run-one-now.sh

set -e
# One short task: create m/agentsofhope if missing, then reply. Keeps context small.
MSG="Do only this: 1) If m/agentsofhope does not exist on Moltbook, create it via the API (credentials in ~/.openclaw/moltbook-credentials.json). 2) Reply with DONE or the error message."

openclaw system event --text "$MSG" --mode now
