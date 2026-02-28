#!/usr/bin/env node
/**
 * Check Railway PropEase deployment and DATABASE_URL.
 * Run: railway login   (first time)
 *      cd propease && railway link   (select PropEase project)
 *      node scripts/railway-check-db.js
 *
 * Or run from eggy: cd propease && railway link && node scripts/railway-check-db.js
 */
const { execSync } = require('child_process');

function run(cmd) {
  try {
    return execSync(cmd, { encoding: 'utf8' });
  } catch (e) {
    return null;
  }
}

console.log('Checking Railway setup for PropEase...\n');

const status = run('railway status 2>&1');
if (!status || status.includes('Unauthorized')) {
  console.log('❌ Not linked. Run: railway login');
  console.log('   Then: cd propease && railway link');
  console.log('   Select the PropEase project and the web service.');
  process.exit(1);
}
console.log('✓ Railway linked\n');

const vars = run('railway variables --json 2>&1');
let hasDb = false;
if (vars) {
  try {
    const parsed = JSON.parse(vars);
    const keys = Object.keys(parsed);
    hasDb = keys.some(k => k.includes('DATABASE') || k.includes('POSTGRES'));
    console.log('Variables:', keys.join(', ') || '(none)');
    if (hasDb) {
      console.log('✓ DATABASE_URL or similar found');
    } else {
      console.log('❌ DATABASE_URL not found');
    }
  } catch (e) {
    console.log('Variables output:', vars?.slice(0, 200));
  }
}

const services = run('railway service 2>&1');
console.log('\nServices:', services || 'run: railway service');

if (!hasDb) {
  console.log('\n--- FIX: Link Postgres ---');
  console.log('1. Railway Dashboard → Your PropEase project');
  console.log('2. Click "+ New" → "Database" → "PostgreSQL" (if not already added)');
  console.log('3. Click your PropEase web service');
  console.log('4. Variables tab → "Add Variable" → "Add Reference"');
  console.log('5. Select Postgres service → DATABASE_URL');
  console.log('6. Redeploy');
}
