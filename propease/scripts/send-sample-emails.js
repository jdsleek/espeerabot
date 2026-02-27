#!/usr/bin/env node
/**
 * Send sample welcome emails to jdsleek@gmail.com
 * Run: node scripts/send-sample-emails.js
 */
require('dotenv').config({ path: require('path').join(__dirname, '..', '.env') });
const email = require('./email.js');

async function main() {
  const to = 'jdsleek@gmail.com';
  console.log('Sending sample welcome emails to', to, '...');
  const r1 = await email.sendWelcomeLandlord(to);
  console.log('Landlord welcome:', r1.ok ? 'sent' : r1.error);
  const r2 = await email.sendWelcomeTenant({ fname: 'Sample', unit: 'Flat 1A' }, to);
  console.log('Tenant welcome:', r2.ok ? 'sent' : r2.error);
}

main().catch(console.error);
