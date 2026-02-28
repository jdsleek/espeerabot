#!/usr/bin/env node
/**
 * PropEase — Initialize Postgres schema.
 * Run on first deploy or: DATABASE_URL=... node scripts/init-db.js
 */
const { Pool } = require('pg');

const DATABASE_URL = process.env.DATABASE_URL || process.env.POSTGRES_URL;

async function init() {
  if (!DATABASE_URL) {
    console.error('Set DATABASE_URL or POSTGRES_URL');
    process.exit(1);
  }
  const pool = new Pool({ connectionString: DATABASE_URL });
  try {
    await pool.query(`
      CREATE TABLE IF NOT EXISTS buildings (
        id SERIAL PRIMARY KEY,
        name TEXT NOT NULL,
        units JSONB NOT NULL DEFAULT '[]',
        created_at TIMESTAMPTZ DEFAULT NOW()
      );
      CREATE TABLE IF NOT EXISTS tenants (
        id SERIAL PRIMARY KEY,
        name TEXT NOT NULL,
        fname TEXT,
        lname TEXT,
        unit TEXT NOT NULL,
        rent INTEGER NOT NULL,
        phone TEXT,
        email TEXT,
        since TEXT,
        move_in DATE,
        lease_end DATE,
        deposit INTEGER DEFAULT 0,
        status TEXT DEFAULT 'pending',
        color TEXT DEFAULT '#c9a84c',
        pin TEXT,
        notes TEXT,
        building_id INTEGER REFERENCES buildings(id),
        created_at TIMESTAMPTZ DEFAULT NOW()
      );
      CREATE TABLE IF NOT EXISTS payments (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        tenant TEXT NOT NULL,
        unit TEXT NOT NULL,
        amount INTEGER NOT NULL,
        method TEXT,
        period TEXT,
        ref TEXT,
        status TEXT DEFAULT 'paid',
        created_at TIMESTAMPTZ DEFAULT NOW()
      );
      CREATE TABLE IF NOT EXISTS tickets (
        id TEXT PRIMARY KEY,
        tenant TEXT NOT NULL,
        unit TEXT NOT NULL,
        category TEXT,
        title TEXT NOT NULL,
        "desc" TEXT,
        priority TEXT,
        status TEXT DEFAULT 'open',
        date TEXT,
        updated_by TEXT,
        updated_at TIMESTAMPTZ,
        created_at TIMESTAMPTZ DEFAULT NOW()
      );
      CREATE TABLE IF NOT EXISTS activity (
        id SERIAL PRIMARY KEY,
        type TEXT,
        text TEXT,
        time TEXT,
        color TEXT,
        created_at TIMESTAMPTZ DEFAULT NOW()
      );
      CREATE TABLE IF NOT EXISTS reminders (
        id TEXT PRIMARY KEY,
        tenant TEXT,
        title TEXT,
        due_date TEXT,
        notes TEXT,
        created_at TIMESTAMPTZ DEFAULT NOW()
      );
      CREATE TABLE IF NOT EXISTS landlord (
        id SERIAL PRIMARY KEY,
        password_hash TEXT
      );
      CREATE TABLE IF NOT EXISTS agreement_templates (
        id SERIAL PRIMARY KEY,
        title TEXT NOT NULL DEFAULT 'Lease Agreement',
        content TEXT NOT NULL,
        created_at TIMESTAMPTZ DEFAULT NOW(),
        updated_at TIMESTAMPTZ DEFAULT NOW()
      );
      CREATE TABLE IF NOT EXISTS agreement_signatures (
        id SERIAL PRIMARY KEY,
        template_id INTEGER NOT NULL REFERENCES agreement_templates(id),
        tenant_name TEXT NOT NULL,
        signed_at TIMESTAMPTZ NOT NULL,
        ip_address TEXT,
        user_agent TEXT,
        signature_image TEXT,
        created_at TIMESTAMPTZ DEFAULT NOW(),
        UNIQUE(template_id, tenant_name)
      );
      CREATE TABLE IF NOT EXISTS change_requests (
        id SERIAL PRIMARY KEY,
        tenant_id INTEGER NOT NULL REFERENCES tenants(id),
        tenant_name TEXT NOT NULL,
        type TEXT NOT NULL,
        field_name TEXT NOT NULL,
        old_value TEXT,
        new_value TEXT,
        requested_by TEXT NOT NULL,
        status TEXT DEFAULT 'pending',
        created_at TIMESTAMPTZ DEFAULT NOW(),
        resolved_at TIMESTAMPTZ,
        resolved_by TEXT,
        notes TEXT
      );
    `);
    await pool.query(`
      DO $$ BEGIN ALTER TABLE tickets ADD COLUMN updated_by TEXT; EXCEPTION WHEN duplicate_column THEN NULL; END $$;
      DO $$ BEGIN ALTER TABLE tickets ADD COLUMN updated_at TIMESTAMPTZ; EXCEPTION WHEN duplicate_column THEN NULL; END $$;
      DO $$ BEGIN ALTER TABLE tenants ADD COLUMN building_id INTEGER REFERENCES buildings(id); EXCEPTION WHEN duplicate_column THEN NULL; END $$;
    `).catch(() => {});
    const buildCount = await pool.query('SELECT COUNT(*) FROM buildings');
    if (Number(buildCount.rows[0].count) === 0) {
      await pool.query(`
        INSERT INTO buildings (name, units) VALUES
          ('Empire Apartments', '["A1","A2","A3","A4","B1","B2","B3","B4"]'),
          ('23 Complex', '["Store 1","Store 2","Store 3","Store 4","Store 5","Store 6","Store 7","Store 8","Store 9","Store 10"]')
      `);
      console.log('Seeded default buildings: Empire Apartments (8 units), 23 Complex (10 stores)');
    }
    await pool.query(`UPDATE tenants SET building_id = (SELECT id FROM buildings LIMIT 1) WHERE building_id IS NULL`).catch(() => {});
    await pool.query(`
      CREATE TABLE IF NOT EXISTS change_requests (
        id SERIAL PRIMARY KEY,
        tenant_id INTEGER NOT NULL REFERENCES tenants(id),
        tenant_name TEXT NOT NULL,
        type TEXT NOT NULL,
        field_name TEXT NOT NULL,
        old_value TEXT,
        new_value TEXT,
        requested_by TEXT NOT NULL,
        status TEXT DEFAULT 'pending',
        created_at TIMESTAMPTZ DEFAULT NOW(),
        resolved_at TIMESTAMPTZ,
        resolved_by TEXT,
        notes TEXT
      )
    `).catch((e) => console.warn('change_requests migration:', e.message));
    const r = await pool.query('SELECT COUNT(*) FROM tenants');
    if (Number(r.rows[0].count) === 0) {
      const empId = (await pool.query('SELECT id FROM buildings WHERE name = $1', ['Empire Apartments'])).rows[0].id;
      await pool.query(`
        INSERT INTO tenants (name, fname, lname, unit, rent, phone, email, since, move_in, lease_end, deposit, status, color, pin, building_id)
        VALUES
          ('Amira Hassan','Amira','Hassan','A1',150000,'+234 802 111 2233','amira.h@gmail.com','Jan 2024','2024-01-01','2025-12-31',300000,'pending','#c9a84c','1234',$1),
          ('Tunde Bakare','Tunde','Bakare','A2',200000,'+234 803 222 3344','tunde.b@gmail.com','Feb 2025','2025-02-01','2026-01-31',400000,'pending','#5b8ccc','2345',$1),
          ('Chika Osei','Chika','Osei','A3',175000,'+234 804 333 4455','chika.o@gmail.com','Mar 2023','2023-03-01','2025-04-12',350000,'paid','#5bab6e','3456',$1),
          ('Emeka Nwosu','Emeka','Nwosu','A4',180000,'+234 805 444 5566','emeka.n@gmail.com','Jun 2023','2023-06-01','2026-05-31',360000,'paid','#d97c3a','4567',$1),
          ('Fatima Aliyu','Fatima','Aliyu','B1',145000,'+234 806 555 6677','fatima.a@gmail.com','Sep 2023','2023-09-01','2025-08-31',290000,'paid','#9b6bb5','5678',$1);
      `, [empId]);
      await pool.query(`
        INSERT INTO payments (id, date, tenant, unit, amount, method, period, ref, status)
        VALUES
          ('p1','2025-02-26','Chika Osei','A3',175000,'Bank Transfer','February 2025','TXN001','paid'),
          ('p2','2025-02-25','Emeka Nwosu','A4',180000,'Bank Transfer','February 2025','TXN002','paid'),
          ('p3','2025-02-25','Fatima Aliyu','B1',145000,'Cash','February 2025','CASH001','paid'),
          ('p4','2025-01-31','Amira Hassan','A1',150000,'Bank Transfer','January 2025','TXN003','paid'),
          ('p5','2025-01-31','Tunde Bakare','A2',200000,'Mobile Money','January 2025','MM001','paid');
      `);
      await pool.query(`
        INSERT INTO tickets (id, tenant, unit, category, title, "desc", priority, status, date)
        VALUES
          ('T001','Fatima Aliyu','B1','Plumbing','Leaking tap in kitchen','The kitchen tap has been dripping constantly for 3 days.','High','open','2025-02-24'),
          ('T002','Amira Hassan','A1','Electrical','Flickering lights in bedroom','The bedroom light flickers intermittently.','Medium','in-progress','2025-02-10'),
          ('T003','Chika Osei','A3','Structural','Window latch broken','The window latch on the main window is broken.','Low','resolved','2025-01-20');
      `);
      await pool.query(`
        INSERT INTO activity (type, text, time, color)
        VALUES
          ('payment','Chika Osei paid ₦175,000','Today, 9:14 AM','var(--green)'),
          ('payment','Emeka Nwosu paid ₦180,000','Yesterday, 3:40 PM','var(--green)'),
          ('maintenance','Maintenance request opened — Fatima Aliyu','2 days ago','var(--orange)'),
          ('onboard','New tenant onboarded: Tunde Bakare','1 week ago','var(--blue)');
      `);
      const tmpl = await pool.query('SELECT COUNT(*) FROM agreement_templates');
      if (Number(tmpl.rows[0].count) === 0) {
        const defaultContent = [
          'LEASE AGREEMENT',
          '',
          'This Lease Agreement is entered into between the Landlord and {tenant_name} ("Tenant") for the property at Unit {unit}.',
          '',
          'TERMS:',
          '• Monthly Rent: {rent} payable on the 1st of each month',
          '• Security Deposit: {deposit}',
          '• Lease Term: {move_in} to {lease_end}',
          '• Tenant agrees to maintain the premises and pay rent on time',
          '',
          'By signing below, Tenant acknowledges they have read and agree to these terms.'
        ].join('\n');
        await pool.query('INSERT INTO agreement_templates (title, content) VALUES ($1, $2)', ['Standard Lease Agreement', defaultContent]);
      }
      console.log('Seeded default data');
    }
    console.log('DB initialized OK');
  } catch (e) {
    console.error('Init failed:', e.message);
    process.exit(1);
  } finally {
    await pool.end();
  }
}

init();
