#!/usr/bin/env node
require('dotenv').config({ path: require('path').join(__dirname, '.env') });
/**
 * PropEase — Property Management with Postgres.
 * Serves SPA + REST API. Set DATABASE_URL for DB mode.
 * Email via Brevo SMTP: BREVO_SMTP_*
 */
const http = require('http');
const fs = require('fs');
const path = require('path');
const { Pool } = require('pg');
const email = require('./scripts/email.js');

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
  '.webmanifest': 'application/manifest+json',
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

function json(res, data, status) {
  if (res.headersSent) return;
  if (status) {
    res.writeHead(status, { 'Content-Type': 'application/json' });
  } else {
    res.setHeader('Content-Type', 'application/json');
  }
  res.end(JSON.stringify(data));
}

function cors(res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
}

function mapTenantRow(row) {
  return { id: row.id, name: row.name, fname: row.fname, lname: row.lname, unit: row.unit, rent: row.rent, phone: row.phone, email: row.email, since: row.since, moveIn: row.move_in, leaseEnd: row.lease_end, deposit: row.deposit, status: row.status, color: row.color, pin: row.pin, notes: row.notes || '' };
}

function normPhone(s) {
  const d = String(s || '').replace(/\D/g, '');
  return d.length >= 10 ? d.slice(-10) : d;
}

async function apiAuthTenant(req, res, body) {
  if (req.method !== 'POST') { res.writeHead(405); res.end(); return; }
  const phone = normPhone(body?.phone);
  if (!phone || phone.length < 10) return json(res, { ok: false, error: 'Enter a valid phone number' }, 400);
  const r = await pool.query(`SELECT * FROM tenants WHERE RIGHT(REGEXP_REPLACE(COALESCE(phone,''), '[^0-9]', '', 'g'), 10) = $1`, [phone]);
  const t = r.rows[0];
  if (!t) return json(res, { ok: false, error: 'Phone not found' }, 404);
  return json(res, { ok: true, tenant: mapTenantRow(t) });
}

async function apiChangeRequests(req, res, body) {
  if (req.method === 'GET') {
    const tenantId = (new URL(req.url || '', 'http://x').searchParams).get('tenantId');
    let q = 'SELECT * FROM change_requests ORDER BY created_at DESC';
    const params = [];
    if (tenantId) { params.push(tenantId); q = 'SELECT * FROM change_requests WHERE tenant_id = $1 ORDER BY created_at DESC'; }
    const r = await pool.query(q, params);
    return json(res, r.rows.map(x => ({ id: x.id, tenantId: x.tenant_id, tenantName: x.tenant_name, type: x.type, fieldName: x.field_name, oldValue: x.old_value, newValue: x.new_value, requestedBy: x.requested_by, status: x.status, createdAt: x.created_at, resolvedAt: x.resolved_at, resolvedBy: x.resolved_by, notes: x.notes })));
  }
  if (req.method === 'POST') {
    const { tenantId, tenantName, type, fieldName, oldValue, newValue, requestedBy } = body;
    const r = await pool.query(
      `INSERT INTO change_requests (tenant_id, tenant_name, type, field_name, old_value, new_value, requested_by) VALUES ($1,$2,$3,$4,$5,$6,$7) RETURNING *`,
      [tenantId, tenantName, type, fieldName, oldValue || '', newValue || '', requestedBy || 'landlord']
    );
    return json(res, { id: r.rows[0].id, status: 'pending' });
  }
  if (req.method === 'PUT') {
    const { id, status } = body;
    if (!id || !['accepted', 'rejected'].includes(status)) return json(res, { error: 'Invalid' }, 400);
    const cr = await pool.query('SELECT * FROM change_requests WHERE id = $1', [id]);
    const reqRow = cr.rows[0];
    if (!reqRow || reqRow.status !== 'pending') return json(res, { error: 'Not found or already resolved' }, 404);
    await pool.query('UPDATE change_requests SET status = $2, resolved_at = NOW(), resolved_by = $3 WHERE id = $1', [id, status, body.resolvedBy || 'tenant']);
    if (status === 'accepted' && reqRow.field_name === 'rent') {
      await pool.query('UPDATE tenants SET rent = $2 WHERE id = $1', [reqRow.tenant_id, parseInt(reqRow.new_value, 10)]);
    }
    if (status === 'accepted' && ['email', 'phone', 'fname', 'lname'].includes(reqRow.field_name)) {
      const col = reqRow.field_name === 'fname' ? 'fname' : reqRow.field_name === 'lname' ? 'lname' : reqRow.field_name;
      await pool.query(`UPDATE tenants SET ${col} = $2 WHERE id = $1`, [reqRow.tenant_id, reqRow.new_value]);
      if (['fname', 'lname'].includes(reqRow.field_name)) {
        const t = await pool.query('SELECT fname, lname FROM tenants WHERE id = $1', [reqRow.tenant_id]);
        const r = t.rows[0];
        if (r) await pool.query('UPDATE tenants SET name = $2 WHERE id = $1', [reqRow.tenant_id, [r.fname, r.lname].filter(Boolean).join(' ')]);
      }
    }
    return json(res, { ok: true });
  }
  res.writeHead(405);
  res.end();
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
    const cur = await pool.query('SELECT * FROM tenants WHERE id = $1', [id]);
    const t = cur.rows[0];
    if (!t) return json(res, { error: 'Tenant not found' }, 404);
    if (rent != null && Number(rent) !== Number(t.rent)) {
      await pool.query(
        `INSERT INTO change_requests (tenant_id, tenant_name, type, field_name, old_value, new_value, requested_by) VALUES ($1,$2,'rent_change','rent',$3,$4,'landlord')`,
        [id, t.name, String(t.rent), String(rent)]
      );
      if (t.email) email.sendRentChangeProposal(t, t.rent, rent).catch(() => {});
      return json(res, { ok: true, pendingRent: true, message: 'Rent change proposed. Tenant must accept.' });
    }
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
    return json(res, r.rows.map(t => ({
      id: t.id, tenant: t.tenant, unit: t.unit, category: t.category, title: t.title, desc: t.desc,
      priority: t.priority, status: t.status, date: t.date, updatedBy: t.updated_by, updatedAt: t.updated_at
    })));
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
    const { id, status, updatedBy } = body;
    await pool.query(
      'UPDATE tickets SET status=$2, updated_by=$3, updated_at=NOW() WHERE id=$1',
      [id, status, updatedBy || 'Landlord']
    );
    const tk = await pool.query('SELECT * FROM tickets WHERE id = $1', [id]);
    const ticket = tk.rows[0];
    if (ticket) {
      const t = await pool.query('SELECT * FROM tenants WHERE name = $1', [ticket.tenant]);
      const tenant = t.rows[0];
      if (tenant && tenant.email) email.sendMaintenanceUpdate(tenant, ticket.title, status).catch(() => {});
    }
    return json(res, { ok: true });
  }
  return json(res, { error: 'Method not allowed' }, 405);
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

async function apiAgreementTemplates(req, res, body) {
  if (req.method === 'GET') {
    const r = await pool.query('SELECT * FROM agreement_templates ORDER BY id DESC LIMIT 1');
    const row = r.rows[0];
    return json(res, row ? { id: row.id, title: row.title, content: row.content } : null);
  }
  if (req.method === 'POST' || req.method === 'PUT') {
    const { id, title, content } = body;
    if (id) {
      await pool.query('UPDATE agreement_templates SET title=$2, content=$3, updated_at=NOW() WHERE id=$1', [id, title || 'Lease Agreement', content || '']);
      return json(res, { ok: true, id });
    }
    const r = await pool.query('INSERT INTO agreement_templates (title, content) VALUES ($1, $2) RETURNING id', [title || 'Lease Agreement', content || '']);
    return json(res, { ok: true, id: r.rows[0].id });
  }
  res.writeHead(405);
  res.end();
}

async function apiSendEmail(req, res, body) {
  if (req.method !== 'POST') { res.writeHead(405); res.end(); return; }
  const { type, tenantName, tenantId } = body;
  if (type === 'rent-reminder' && (tenantName || tenantId)) {
    const q = tenantId ? await pool.query('SELECT * FROM tenants WHERE id = $1', [tenantId]) : await pool.query('SELECT * FROM tenants WHERE name = $1', [tenantName]);
    const t = q.rows[0];
    if (t && t.email) {
      const r = await email.sendRentReminder(t, t.rent);
      return json(res, r);
    }
  }
  if (type === 'lease-expiry' && (tenantName || tenantId)) {
    const q = tenantId ? await pool.query('SELECT * FROM tenants WHERE id = $1', [tenantId]) : await pool.query('SELECT * FROM tenants WHERE name = $1', [tenantName]);
    const t = q.rows[0];
    if (t && t.email) {
      const daysLeft = Math.round((new Date(t.lease_end || t.leaseEnd) - new Date()) / 86400000);
      const r = await email.sendLeaseExpiryAlert(t, daysLeft, t.lease_end || t.leaseEnd);
      return json(res, r);
    }
  }
  if (type === 'maintenance-update') {
    const { ticketId, status } = body;
    const tk = await pool.query('SELECT * FROM tickets WHERE id = $1', [ticketId]);
    const ticket = tk.rows[0];
    if (!ticket) return json(res, { ok: false, error: 'Ticket not found' }, 404);
    const t = await pool.query('SELECT * FROM tenants WHERE name = $1', [ticket.tenant]);
    const tenant = t.rows[0];
    if (tenant && tenant.email) {
      const r = await email.sendMaintenanceUpdate(tenant, ticket.title, status || ticket.status);
      return json(res, r);
    }
  }
  return json(res, { ok: false, error: 'Invalid request or tenant has no email' }, 400);
}

async function apiClearData(req, res, body) {
  if (req.method !== 'POST') { res.writeHead(405); res.end(); return; }
  const expected = process.env.ADMIN_PASSWORD || process.env.LANDLORD_PASSWORD || 'admin123';
  if (body?.password !== expected) return json(res, { ok: false, error: 'Incorrect password' }, 403);
  try {
    await pool.query('DELETE FROM change_requests');
    await pool.query('DELETE FROM agreement_signatures');
    await pool.query('DELETE FROM payments');
    await pool.query('DELETE FROM tickets');
    await pool.query('DELETE FROM reminders');
    await pool.query('DELETE FROM activity');
    await pool.query('DELETE FROM tenants');
    return json(res, { ok: true });
  } catch (e) {
    console.error('Clear data failed:', e);
    return json(res, { error: e.message }, 500);
  }
}

async function apiAgreementSignatures(req, res, body) {
  if (req.method === 'GET') {
    const tenant = (new URL(req.url || '', 'http://x').searchParams).get('tenant');
    let q = 'SELECT s.*, t.title FROM agreement_signatures s JOIN agreement_templates t ON t.id = s.template_id ORDER BY s.signed_at DESC';
    const params = [];
    if (tenant) {
      params.push(tenant);
      q = 'SELECT s.*, t.title FROM agreement_signatures s JOIN agreement_templates t ON t.id = s.template_id WHERE s.tenant_name = $1 ORDER BY s.signed_at DESC';
    }
    const r = await pool.query(q, params);
    return json(res, r.rows.map(x => ({ id: x.id, templateId: x.template_id, tenantName: x.tenant_name, signedAt: x.signed_at, ipAddress: x.ip_address, hasSignature: !!x.signature_image })));
  }
  if (req.method === 'POST') {
    const templateId = body.templateId ?? body.template_id;
    const tenantName = body.tenantName ?? body.tenant_name;
    const sigImg = body.signatureImage ?? body.signature_image ?? null;
    const ip = (req.headers['x-forwarded-for'] || '').split(',')[0]?.trim() || req.socket?.remoteAddress || '';
    const ua = req.headers['user-agent'] || '';
    await pool.query(
      `INSERT INTO agreement_signatures (template_id, tenant_name, signed_at, ip_address, user_agent, signature_image) VALUES ($1,$2,NOW(),$3,$4,$5)
       ON CONFLICT (template_id, tenant_name) DO UPDATE SET signed_at=NOW(), ip_address=EXCLUDED.ip_address, user_agent=EXCLUDED.user_agent, signature_image=COALESCE(EXCLUDED.signature_image, agreement_signatures.signature_image)`,
      [templateId, tenantName, ip, ua, sigImg]
    );
    const t = await pool.query('SELECT name, fname, unit, email FROM tenants WHERE name = $1', [tenantName]);
    const tenant = t.rows[0];
    if (tenant && tenant.email) {
      email.sendAgreementSignedTenant(tenant).catch(() => {});
      const landlordEmail = process.env.LANDLORD_EMAIL || process.env.BREVO_FROM_EMAIL;
      if (landlordEmail) email.sendAgreementSignedLandlord(landlordEmail, tenantName, tenant.unit).catch(() => {});
    }
    return json(res, { ok: true });
  }
  res.writeHead(405);
  res.end();
}

async function handleApi(req, res, pathname, body) {
  cors(res);
  if (pathname === '/api/auth/landlord' && req.method === 'POST') {
    const expected = process.env.ADMIN_PASSWORD || process.env.LANDLORD_PASSWORD || 'admin123';
    const ok = body?.password === expected;
    return json(res, { ok });
  }
  if (!pool) {
    return json(res, { error: 'Database not configured' }, 503);
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
    if (pathname === '/api/agreement-templates') return apiAgreementTemplates(req, res, body);
    if (pathname === '/api/agreement-signatures') return apiAgreementSignatures(req, res, body);
    if (pathname === '/api/send-email') return apiSendEmail(req, res, body);
    if (pathname === '/api/clear-data' && req.method === 'POST') return apiClearData(req, res, body);
    if (pathname === '/api/auth/tenant' && req.method === 'POST') return apiAuthTenant(req, res, body);
    if (pathname === '/api/change-requests') return apiChangeRequests(req, res, body);
    return json(res, { error: 'Not found' }, 404);
  } catch (e) {
    console.error('API error:', e);
    return json(res, { error: e.message }, 500);
  }
}

async function serveStatic(req, res, pathname) {
  let p = pathname === '/' ? '/index.html' : pathname;
  p = p.split('?')[0].replace(/^\/+/, '') || 'index.html';
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
