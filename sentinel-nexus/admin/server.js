#!/usr/bin/env node
/**
 * Sentinel_Nexus admin server — live stats locally.
 * Serves dashboard at http://localhost:3880 and GET /api/stats (Moltbook + OpenClaw state).
 * Run: node sentinel-nexus/admin/server.js
 */

const http = require("http");
const fs = require("fs");
const path = require("path");
const https = require("https");

const PORT = Number(process.env.ADMIN_PORT) || 3880;
const OPENCLAW = process.env.OPENCLAW_STATE_DIR || path.join(process.env.HOME || process.env.USERPROFILE || "", ".openclaw");

function readJson(filePath) {
  try {
    const raw = fs.readFileSync(filePath, "utf8");
    return JSON.parse(raw);
  } catch {
    return null;
  }
}

function readText(filePath) {
  try {
    return fs.readFileSync(filePath, "utf8");
  } catch {
    return null;
  }
}

function getWorkspaceDir() {
  const configPath = path.join(OPENCLAW, "openclaw.json");
  const cfg = readJson(configPath);
  return (cfg && cfg.agents && cfg.agents.defaults && cfg.agents.defaults.workspace) || path.join(OPENCLAW, "workspace");
}

function fetchMoltbookMe(apiKey) {
  return new Promise((resolve) => {
    const url = new URL("https://www.moltbook.com/api/v1/agents/me");
    const opts = { hostname: url.hostname, path: url.pathname, method: "GET", headers: { Authorization: `Bearer ${apiKey}` } };
    const req = https.request(opts, (res) => {
      let body = "";
      res.on("data", (c) => (body += c));
      res.on("end", () => {
        try {
          resolve(JSON.parse(body));
        } catch {
          resolve({ success: false, error: body || res.statusCode });
        }
      });
    });
    req.on("error", (e) => resolve({ success: false, error: e.message }));
    req.setTimeout(8000, () => {
      req.destroy();
      resolve({ success: false, error: "timeout" });
    });
    req.end();
  });
}

function getStats() {
  const workspace = getWorkspaceDir();
  const statePath = path.join(workspace, "memory", "heartbeat-state.json");
  const learningsPath = path.join(workspace, "memory", "sentinel-learnings.md");
  const credsPath = path.join(OPENCLAW, "moltbook-credentials.json");

  const state = readJson(statePath) || {};
  const learnings = readText(learningsPath) || "";
  const creds = readJson(credsPath);

  if (creds && creds.api_key) {
    return fetchMoltbookMe(creds.api_key).then((mb) => ({
      state,
      learnings,
      moltbook: mb.success ? mb : { success: false, agent: null, error: mb.error },
      workspace,
      openclawRoot: OPENCLAW,
    }));
  }

  return Promise.resolve({
    state,
    learnings,
    moltbook: { success: false, agent: null, error: "no moltbook credentials" },
    workspace,
    openclawRoot: OPENCLAW,
  });
}

function serveFile(filePath, contentType, res) {
  fs.readFile(filePath, (err, data) => {
    if (err) {
      res.writeHead(404);
      res.end("Not found");
      return;
    }
    res.writeHead(200, { "Content-Type": contentType });
    res.end(data);
  });
}

const server = http.createServer((req, res) => {
  const url = req.url || "/";
  const base = path.join(__dirname, "index.html");

  if (url === "/api/stats" || url === "/api/stats/") {
    getStats()
      .then((data) => {
        res.writeHead(200, { "Content-Type": "application/json", "Cache-Control": "no-store" });
        res.end(JSON.stringify(data));
      })
      .catch((e) => {
        res.writeHead(500, { "Content-Type": "application/json" });
        res.end(JSON.stringify({ error: String(e.message || e) }));
      });
    return;
  }

  if (url === "/" || url === "/index.html") {
    serveFile(base, "text/html", res);
    return;
  }

  res.writeHead(404);
  res.end("Not found");
});

server.listen(PORT, "127.0.0.1", () => {
  console.log(`Sentinel admin: http://127.0.0.1:${PORT}`);
  console.log("Live stats: http://127.0.0.1:" + PORT + "/api/stats");
});
