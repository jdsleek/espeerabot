#!/usr/bin/env node
/**
 * PropEase — Property Management with Postgres.
 * Serves SPA + REST API. Set DATABASE_URL for DB mode.
 */
const http = require('http');
const fs = require('fs');
const path = require('path');
const { Pool } = require('pg');

const PORT = Number(process.env.PORT) || 3000;
const ROOT = __dirname;
const DATABASE_URL = process.env.DATABASE_URL || process.env.POSTGRES_URL;

const MIME = {
  '.html': 'text/html',
  '.js': 'application/javascript',
  '.css': 'text/css',
  '.json': 'application/json',
  '.ico': 'image/x-icon',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.svg': 'image/svg+xml',
  '.woff2': 'font/woff2',
};

let pool = null;
if (DATABASE_URL) {
  pool = new Pool({ connectionString: DATABASE_URL });
}

async function initDb() {
  if (!pool) return;
  const { execSync } = require('child_process');
  try {
    execSync('node scripts/init-db.js', { stdio: 'inherit', env: { ...process.env, DATABASE_URL } });
  } catch (e) {
    console.warn('DB init failed (may already exist):', e.message);
  }
}

function parseBody(req) {
  return new Promise((resolve) => {
    let body = '';
    req.on('data', (c) => (body += c));
    req.on('end', () => {
      try {
        resolve(body ? JSON.parse(body) : {});
      } catch {
        resolve({});
      }
    });
  });
}

function json(res, data) {
  res.setHeader('Content-Type', 'application/json');
  res.end(JSON.stringify(data));
}

function cors(res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
}

// API routes
async function apiTenants(req, res, body) {
  if (req.method === 'GET') {
    const r = await pool.query('SELECT * FROM tenants ORDER BY id');
    const rows = r.rows.map(row => ({
      id: row.id,
      name: row.name,
      fname: row.fname,
      lname: row.lname,
      unit: row.unit,
      rent: row.rent,
      phone: row.phone,
      email: row.email,
      since: row.since,
      moveIn: row.move_in,
      leaseEnd: row.lease_end,
      deposit: row.deposit,
      status: row.status,
      color: row.color,
      pin: row.pin,
      notes: row.notes || '',
    }));
    return json(res, rows);
  }
  if (req.method === 'POST') {
    const move_in = body.move_in ?? body.moveIn;
    const lease_end = body.lease_end ?? body.leaseEnd;
    const { name, fname, lname, unit, rent, phone, email, since, deposit, status, color, pin, notes } = body;
    const r = await pool.query(
      `INSERT INTO tenants (name, fname, lname, unit, rent, phone, email, since, move_in, lease_end, deposit, status, color, pin, notes)
       VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15) RETURNING *`,
      [name || '', fname || '', lname || '', unit || '', rent || 0, phone || '', email || '', since || '', move_in || null, lease_end || null, deposit || 0, status || 'pending', color || '#c9a84c', pin || '1234', notes || '']
    );
    const row = r.rows[0];
    return json(res, { id: row.id, name: row.name, fname: row.fname, lname: row.lname, unit: row.unit, rent: row.rent, phone: row.phone, email: row.email, since: row.since, moveIn: row.move_in, leaseEnd: row.lease_end, deposit: row.deposit, status: row.status, color: row.color, pin: row.pin, notes: row.notes || '' });
  }
  if (req.method === 'PUT') {
    const { id, fname, lname, phone, email, rent, lease_end, status, pin } = body;
    const name = fname && lname ? `${fname} ${lname}` : body.name;
    await pool.query(
      `UPDATE tenants SET name=COALESCE($2,name), fname=COALESCE($3,fname), lname=COALESCE($4,lname), phone=$5, email=$6, rent=COALESCE($7,rent), lease_end=COALESCE($8,lease_end), status=COALESCE($9,status), pin=COALESCE($10,pin) WHERE id=$1`,
      [id, name, fname, lname, phone, email, rent, lease_end, status, pin]
    );
    return json(res, { ok: true });
  }
  if (req.method === 'DELETE') {
    await pool.query('DELETE FROM tenants WHERE id=$1', [body.id]);
    return json(res, { ok: true });
  }
  res.writeHead(405);
  res.end();
}

async function apiPayments(req, res, body) {
  if (req.method === 'GET') {
    const r = await pool.query('SELECT * FROM payments ORDER BY created_at DESC');
    return json(res, r.rows.map(p => ({ id: p.id, date: p.date, tenant: p.tenant, unit: p.unit, amount: p.amount, method: p.method, period: p.period, ref: p.ref, status: p.status })));
  }
  if (req.method === 'POST') {
    const { id, date, tenant, unit, amount, method, period, ref, status } = body;
    await pool.query(
      'INSERT INTO payments (id, date, tenant, unit, amount, method, period, ref, status) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9)',
      [id || 'p' + Date.now(), date, tenant, unit, amount, method || 'Cash', period || '', ref || '', status || 'paid']
    );
    await pool.query("UPDATE tenants SET status='paid' WHERE name=$1", [tenant]);
    return json(res, { ok: true });
  }
  res.writeHead(405);
  res.end();
}

async function apiTickets(req, res, body) {
  if (req.method === 'GET') {
    const r = await pool.query('SELECT * FROM tickets ORDER BY created_at DESC');
    return json(res, r.rows.map(t => ({ id: t.id, tenant: t.tenant, unit: t.unit, category: t.category, title: t.title, desc: t.desc, priority: t.priority, status: t.status, date: t.date })));
  }
  if (req.method === 'POST') {
    const { id, tenant, unit, category, title, desc, priority, status, date } = body;
    await pool.query(
      'INSERT INTO tickets (id, tenant, unit, category, title, "desc", priority, status, date) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9)',
      [id || 'T' + Date.now().toString(36).toUpperCase(), tenant, unit || '', category, title, desc || '', priority || 'Medium', status || 'open', date || new Date().toISOString().slice(0, 10)]
    );
    return json(res, { ok: true });
  }
  if (req.method === 'PUT' && body.status) {
    await pool.query('UPDATE tickets SET status=$2 WHERE id=$1', [body.id, body.status]);
    return json(res, { ok: true });
  }
  res.writeHead(405);
  res.end();
}

async function apiActivity(req, res, body) {
  if (req.method === 'GET') {
    const r = await pool.query('SELECT * FROM activity ORDER BY created_at DESC LIMIT 20');
    return json(res, r.rows.map(a => ({ type: a.type, text: a.text, time: a.time, color: a.color })));
  }
  if (req.method === 'POST') {
    const { type, text, time, color } = body;
    await pool.query('INSERT INTO activity (type, text, time, color) VALUES ($1,$2,$3,$4)', [type || '', text || '', time || 'Just now', color || 'var(--blue)']);
    return json(res, { ok: true });
  }
  res.writeHead(405);
  res.end();
}

async function apiReminders(req, res, body) {
  if (req.method === 'GET') {
    const r = await pool.query('SELECT * FROM reminders ORDER BY created_at DESC');
    return json(res, r.rows.map(r => ({ id: r.id, tenant: r.tenant, title: r.title, due_date: r.due_date, notes: r.notes, type: r.title, message: r.notes, date: r.due_date })));
  }
  if (req.method === 'POST') {
    const { id, tenant, title, type, message, date, due_date } = body;
    const rid = id || 'r' + Date.now();
    await pool.query('INSERT INTO reminders (id, tenant, title, due_date, notes) VALUES ($1,$2,$3,$4,$5)', [rid, tenant || 'all', title || type, date || due_date, message || '']);
    return json(res, { ok: true });
  }
  if (req.method === 'DELETE') {
    await pool.query('DELETE FROM reminders WHERE id=$1', [body.id]);
    return json(res, { ok: true });
  }
  res.writeHead(405);
  res.end();
}

async function handleApi(req, res, pathname, body) {
  cors(res);
  if (!pool) {
    res.writeHead(503);
    return json(res, { error: 'Database not configured' });
  }
  try {
    if (pathname === '/api/health') {
      const r = await pool.query('SELECT 1');
      return json(res, { ok: true, db: !!r });
    }
    if (pathname === '/api/tenants') return apiTenants(req, res, body);
    if (pathname === '/api/payments') return apiPayments(req, res, body);
    if (pathname === '/api/tickets') return apiTickets(req, res, body);
    if (pathname === '/api/activity') return apiActivity(req, res, body);
    if (pathname === '/api/reminders') return apiReminders(req, res, body);
    res.writeHead(404);
    json(res, { error: 'Not found' });
  } catch (e) {
    console.error('API error:', e);
    res.writeHead(500);
    json(res, { error: e.message });
  }
}

async function serveStatic(req, res, pathname) {
  let p = pathname === '/' ? '/index.html' : pathname;
  p = p.split('?')[0];
  const file = path.join(ROOT, p);
  const ext = path.extname(file);
  if (p !== '/index.html' && p !== '/' && !p.startsWith('/.')) {
    if (!fs.existsSync(file) || !fs.statSync(file).isFile()) {
      res.writeHead(404);
      res.end('Not found');
      return;
    }
  }
  const target = p === '/' || p === '' ? path.join(ROOT, 'index.html') : file;
  fs.readFile(target, (err, data) => {
    if (err) {
      res.writeHead(500);
      res.end('Error');
      return;
    }
    res.setHeader('Content-Type', MIME[ext] || 'application/octet-stream');
    res.end(data);
  });
}

const server = http.createServer(async (req, res) => {
  const url = new URL(req.url || '/', `http://${req.headers.host}`);
  const pathname = url.pathname;
  if (req.method === 'OPTIONS') {
    cors(res);
    res.writeHead(204);
    res.end();
    return;
  }
  if (pathname.startsWith('/api/')) {
    const body = ['POST', 'PUT', 'DELETE'].includes(req.method) ? await parseBody(req) : {};
    return handleApi(req, res, pathname, body);
  }
  serveStatic(req, res, pathname);
});

async function start() {
  if (pool) {
    await initDb();
  }
  server.listen(PORT, '0.0.0.0', () => {
    console.log('PropEase running at http://0.0.0.0:' + PORT + (pool ? ' (DB)' : ' (static)'));
  });
}

start().catch((e) => {
  console.error('Start failed:', e);
  process.exit(1);
});
