#!/usr/bin/env node
/** Run: node scripts/generate-admin-password.js — prints a secure password for ADMIN_PASSWORD */
console.log(require('crypto').randomBytes(16).toString('base64url'));
