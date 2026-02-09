#!/usr/bin/env node
/**
 * Register a new ClawTasks agent "jobmaster" and save all credentials.
 * Run once: node sentinel-nexus/register-jobmaster-bot.js
 *
 * Safety: Output may contain the new API key. Do not redirect to a public log or paste output.
 * Full registration (incl. private key) is saved to ~/.openclaw/; keep chmod 600 and never commit.
 */

const { ethers } = require('ethers');
const fs = require('fs');
const path = require('path');
const https = require('https');

const API_BASE = 'https://clawtasks.com/api';
const OPENCLAW = process.env.HOME + '/.openclaw';
const AGENT_NAME = process.env.AGENT_NAME || 'jobmaster';
const OUT_CREDS_FILE = process.env.OUT_CREDS_FILE || 'clawtasks-credentials.json';
const OUT_FULL_FILE = process.env.OUT_FULL_FILE || `clawtasks-${AGENT_NAME}-registration.json`;

function post(urlPath, body) {
  return new Promise((resolve, reject) => {
    const u = new URL(API_BASE + urlPath);
    const data = JSON.stringify(body);
    const req = https.request({
      hostname: u.hostname,
      path: u.pathname,
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'Content-Length': Buffer.byteLength(data) }
    }, res => {
      let buf = '';
      res.on('data', c => buf += c);
      res.on('end', () => {
        try { resolve(JSON.parse(buf)); } catch (e) { resolve(buf); }
      });
    });
    req.on('error', reject);
    req.write(data);
    req.end();
  });
}

async function main() {
  console.log('1. Generating new Base L2 wallet...');
  const wallet = ethers.Wallet.createRandom();
  const walletAddress = wallet.address;
  const privateKey = wallet.privateKey;
  console.log('   Wallet:', walletAddress);

  console.log('2. Registering with ClawTasks as "' + AGENT_NAME + '"...');
  const resp = await post('/agents', { name: AGENT_NAME, wallet_address: walletAddress });
  if (resp.error) {
    console.error('   Registration failed:', resp.error);
    process.exit(1);
  }

  const apiKey = resp.api_key;
  const verificationCode = resp.verification_code || '(check response)';
  console.log('   OK. API key received.');
  console.log('   Verification code:', verificationCode);

  const credsFile = path.join(OPENCLAW, OUT_CREDS_FILE);
  const fullFile = path.join(OPENCLAW, OUT_FULL_FILE);

  fs.mkdirSync(OPENCLAW, { recursive: true });

  const creds = { api_key: apiKey, agent_name: AGENT_NAME };
  fs.writeFileSync(credsFile, JSON.stringify(creds, null, 2));
  console.log('3. Saved API credentials to:', credsFile);

  const full = {
    agent_name: AGENT_NAME,
    api_key: apiKey,
    verification_code: verificationCode,
    wallet_address: walletAddress,
    private_key: privateKey,
    registered_at: new Date().toISOString(),
    funding_link: `https://clawtasks.com/fund/${walletAddress}`,
    verify_instructions: 'Post on Moltbook (e.g. m/clawtasks) with your code, then: curl -s -X POST ' + API_BASE + '/agents/verify -H "Authorization: Bearer ' + apiKey + '"'
  };
  fs.writeFileSync(fullFile, JSON.stringify(full, null, 2));
  fs.chmodSync(fullFile, 0o600);
  console.log('4. Saved full registration (incl. private key) to:', fullFile, '(chmod 600)');

  console.log('');
  console.log('--- Next steps ---');
  console.log('1. Fund the wallet (USDC + a little ETH on Base):', full.funding_link);
  console.log('2. Verify: post the verification message on Moltbook, then:');
  console.log('   curl -s -X POST ' + API_BASE + '/agents/verify -H "Authorization: Bearer ' + apiKey + '"');
  console.log('3. Post the water factory job: ./sentinel-nexus/post-water-factory-job.sh');
  console.log('');
  console.log('All necessary data is in:', fullFile);
}

main().catch(e => { console.error(e); process.exit(1); });
