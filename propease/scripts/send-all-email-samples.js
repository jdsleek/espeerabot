#!/usr/bin/env node
/**
 * Send ALL email types to your inbox so you can preview them.
 * Run: node scripts/send-all-email-samples.js
 * Or: EMAIL=you@example.com node scripts/send-all-email-samples.js
 */
require('dotenv').config({ path: require('path').join(__dirname, '../../.env') });
require('dotenv').config({ path: require('path').join(__dirname, '..', '.env') });

const email = require('./email.js');

const TO = process.env.EMAIL || process.env.LANDLORD_EMAIL || 'jdsleek@gmail.com';

const sampleTenant = {
  name: 'Sample Tenant',
  fname: 'Sample',
  lname: 'Tenant',
  unit: 'Flat 1A',
  rent: 150000,
  email: TO,
  lease_end: '2025-12-31',
};

async function main() {
  console.log('Sending all PropEase email samples to', TO, '...\n');
  const results = [];
  let r;

  r = await email.sendWelcomeLandlord(TO);
  results.push({ name: 'Landlord welcome', ok: r.ok, err: r.error });

  r = await email.sendWelcomeTenant(sampleTenant, TO);
  results.push({ name: 'Tenant welcome', ok: r.ok, err: r.error });

  r = await email.sendRentReminder(sampleTenant, 150000);
  results.push({ name: 'Rent reminder', ok: r.ok, err: r.error });

  r = await email.sendLeaseExpiryAlert(sampleTenant, 45, sampleTenant.lease_end);
  results.push({ name: 'Lease expiry alert', ok: r.ok, err: r.error });

  r = await email.sendAgreementSignedLandlord(TO, 'Sample Tenant', 'Flat 1A');
  results.push({ name: 'Agreement signed (landlord)', ok: r.ok, err: r.error });

  r = await email.sendAgreementSignedTenant(sampleTenant);
  results.push({ name: 'Agreement signed (tenant)', ok: r.ok, err: r.error });

  r = await email.sendMaintenanceUpdate(sampleTenant, 'Leaking tap in kitchen', 'In Progress');
  results.push({ name: 'Maintenance update', ok: r.ok, err: r.error });

  console.log('\n--- Results ---');
  results.forEach(({ name, ok, err }) => console.log(name + ':', ok ? '✓ sent' : '✗ ' + (err || 'failed')));
}

main().catch(console.error);
