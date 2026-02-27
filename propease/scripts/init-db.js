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
    `);
    const r = await pool.query('SELECT COUNT(*) FROM tenants');
    if (Number(r.rows[0].count) === 0) {
      await pool.query(`
        INSERT INTO tenants (name, fname, lname, unit, rent, phone, email, since, move_in, lease_end, deposit, status, color, pin)
        VALUES
          ('Amira Hassan','Amira','Hassan','Flat 1A',150000,'+234 802 111 2233','amira.h@gmail.com','Jan 2024','2024-01-01','2025-12-31',300000,'pending','#c9a84c','1234'),
          ('Tunde Bakare','Tunde','Bakare','Flat 1B',200000,'+234 803 222 3344','tunde.b@gmail.com','Feb 2025','2025-02-01','2026-01-31',400000,'pending','#5b8ccc','2345'),
          ('Chika Osei','Chika','Osei','Flat 2A',175000,'+234 804 333 4455','chika.o@gmail.com','Mar 2023','2023-03-01','2025-04-12',350000,'paid','#5bab6e','3456'),
          ('Emeka Nwosu','Emeka','Nwosu','Flat 2B',180000,'+234 805 444 5566','emeka.n@gmail.com','Jun 2023','2023-06-01','2026-05-31',360000,'paid','#d97c3a','4567'),
          ('Fatima Aliyu','Fatima','Aliyu','Flat 2C',145000,'+234 806 555 6677','fatima.a@gmail.com','Sep 2023','2023-09-01','2025-08-31',290000,'paid','#9b6bb5','5678');
      `);
      await pool.query(`
        INSERT INTO payments (id, date, tenant, unit, amount, method, period, ref, status)
        VALUES
          ('p1','2025-02-26','Chika Osei','Flat 2A',175000,'Bank Transfer','February 2025','TXN001','paid'),
          ('p2','2025-02-25','Emeka Nwosu','Flat 2B',180000,'Bank Transfer','February 2025','TXN002','paid'),
          ('p3','2025-02-25','Fatima Aliyu','Flat 2C',145000,'Cash','February 2025','CASH001','paid'),
          ('p4','2025-01-31','Amira Hassan','Flat 1A',150000,'Bank Transfer','January 2025','TXN003','paid'),
          ('p5','2025-01-31','Tunde Bakare','Flat 1B',200000,'Mobile Money','January 2025','MM001','paid');
      `);
      await pool.query(`
        INSERT INTO tickets (id, tenant, unit, category, title, "desc", priority, status, date)
        VALUES
          ('T001','Fatima Aliyu','Flat 2C','Plumbing','Leaking tap in kitchen','The kitchen tap has been dripping constantly for 3 days.','High','open','2025-02-24'),
          ('T002','Amira Hassan','Flat 1A','Electrical','Flickering lights in bedroom','The bedroom light flickers intermittently.','Medium','in-progress','2025-02-10'),
          ('T003','Chika Osei','Flat 2A','Structural','Window latch broken','The window latch on the main window is broken.','Low','resolved','2025-01-20');
      `);
      await pool.query(`
        INSERT INTO activity (type, text, time, color)
        VALUES
          ('payment','Chika Osei paid ₦175,000','Today, 9:14 AM','var(--green)'),
          ('payment','Emeka Nwosu paid ₦180,000','Yesterday, 3:40 PM','var(--green)'),
          ('maintenance','Maintenance request opened — Fatima Aliyu','2 days ago','var(--orange)'),
          ('onboard','New tenant onboarded: Tunde Bakare','1 week ago','var(--blue)');
      `);
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
