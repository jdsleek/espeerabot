#!/usr/bin/env node
/**
 * Remove all test tenants and related data. Run before adding real tenants.
 * Requires DATABASE_URL (from Railway → Connect → Postgres URL).
 * Run: DATABASE_URL=... node scripts/clear-tenants.js
 */
require('dotenv').config({ path: require('path').join(__dirname, '../../.env') });
require('dotenv').config({ path: require('path').join(__dirname, '..', '.env') });

const { Pool } = require('pg');
const DATABASE_URL = process.env.DATABASE_URL || process.env.POSTGRES_URL;

async function main() {
  if (!DATABASE_URL) {
    console.error('Set DATABASE_URL (from Railway → Connect → Postgres)');
    process.exit(1);
  }
  const pool = new Pool({ connectionString: DATABASE_URL });
  try {
    await pool.query('DELETE FROM agreement_signatures');
    await pool.query('DELETE FROM payments');
    await pool.query('DELETE FROM tickets');
    await pool.query('DELETE FROM reminders');
    await pool.query('DELETE FROM activity');
    await pool.query('DELETE FROM tenants');
    console.log('All tenants and related data cleared.');
  } catch (e) {
    console.error(e.message);
    process.exit(1);
  } finally {
    await pool.end();
  }
}

main();
