#!/usr/bin/env node
/**
 * PropEase — Brevo SMTP email sender.
 * Set BREVO_SMTP_* env vars.
 */
const nodemailer = require('nodemailer');

const HOST = process.env.BREVO_SMTP_HOST || process.env.SMTP_HOST || 'smtp-relay.brevo.com';
const PORT = Number(process.env.BREVO_SMTP_PORT || process.env.SMTP_PORT || 587);
const USER = process.env.BREVO_SMTP_USER || process.env.SMTP_USER;
const PASS = process.env.BREVO_SMTP_PASS || process.env.SMTP_PASS;
const FROM = process.env.BREVO_FROM_EMAIL || process.env.SMTP_FROM_EMAIL || 'naijaaiacademy@gmail.com';
const FROM_NAME = process.env.BREVO_FROM_NAME || process.env.SMTP_FROM_NAME || 'Property Ease Manager';

let transporter = null;

function getTransporter() {
  if (!USER || !PASS) return null;
  if (!transporter) {
    transporter = nodemailer.createTransport({
      host: HOST,
      port: PORT,
      secure: false,
      auth: { user: USER, pass: PASS },
    });
  }
  return transporter;
}

async function sendEmail({ to, subject, text, html }) {
  const trans = getTransporter();
  if (!trans) {
    console.warn('[email] SMTP not configured, skipping');
    return { ok: false, reason: 'not_configured' };
  }
  try {
    const info = await trans.sendMail({
      from: `"${FROM_NAME}" <${FROM}>`,
      to: Array.isArray(to) ? to.join(', ') : to,
      subject: subject || 'PropEase',
      text: text || '',
      html: html || text?.replace(/\n/g, '<br>') || '',
    });
    console.log('[email] sent to', to, info.messageId);
    return { ok: true, messageId: info.messageId };
  } catch (e) {
    console.error('[email] failed:', e.message);
    return { ok: false, error: e.message };
  }
}

const APP_URL = process.env.APP_URL || process.env.RAILWAY_STATIC_URL || 'https://propease.up.railway.app';
const PORTAL_LINK = `<a href="${APP_URL}" style="display:inline-block;background:#c9a84c;color:#0f0e0c;padding:10px 20px;border-radius:8px;text-decoration:none;font-weight:600;margin:12px 0">Open Tenant Portal →</a>`;

async function sendRentReminder(tenant, rent) {
  const fmt = (n) => '₦' + Number(n).toLocaleString();
  return sendEmail({
    to: tenant.email,
    subject: `Rent Reminder — ${tenant.unit} · ${fmt(rent)} due`,
    text: `Dear ${tenant.fname},\n\nThis is a friendly reminder that your rent of ${fmt(rent)} for ${tenant.unit} is due. Please ensure payment is made on time.\n\nPortal: ${APP_URL}\n\nThank you,\n${FROM_NAME}`,
    html: `<div style="font-family:sans-serif;max-width:560px"><p>Dear ${tenant.fname},</p><p>This is a friendly reminder that your rent of <strong>${fmt(rent)}</strong> for ${tenant.unit} is due. Please ensure payment is made on time.</p><p>${PORTAL_LINK}</p><p>Thank you,<br>${FROM_NAME}</p></div>`,
  });
}

async function sendLeaseExpiryAlert(tenant, daysLeft, leaseEnd) {
  const fmtDate = (d) => new Date(d).toLocaleDateString('en-NG', { day: '2-digit', month: 'short', year: 'numeric' });
  return sendEmail({
    to: tenant.email,
    subject: `Lease Expiring Soon — ${tenant.unit} · ${daysLeft} days left`,
    text: `Dear ${tenant.fname},\n\nYour lease for ${tenant.unit} expires on ${fmtDate(leaseEnd)} (${daysLeft} days left). Please contact your landlord to discuss renewal.\n\nPortal: ${APP_URL}\n\nThank you,\n${FROM_NAME}`,
    html: `<div style="font-family:sans-serif;max-width:560px"><p>Dear ${tenant.fname},</p><p>Your lease for ${tenant.unit} expires on ${fmtDate(leaseEnd)} (${daysLeft} days left). Please contact your landlord to discuss renewal.</p><p>${PORTAL_LINK}</p><p>Thank you,<br>${FROM_NAME}</p></div>`,
  });
}

async function sendAgreementSignedTenant(tenant) {
  return sendEmail({
    to: tenant.email,
    subject: `Agreement Confirmation — ${tenant.unit}`,
    text: `Dear ${tenant.fname},\n\nYour signed lease agreement for ${tenant.unit} has been recorded. Thank you for using PropEase.\n\nPortal: ${APP_URL}\n\n— ${FROM_NAME}`,
    html: `<div style="font-family:sans-serif;max-width:560px"><p>Dear ${tenant.fname},</p><p>Your signed lease agreement for ${tenant.unit} has been recorded. Thank you for using PropEase.</p><p>${PORTAL_LINK}</p><p>— ${FROM_NAME}</p></div>`,
  });
}

async function sendAgreementSignedLandlord(landlordEmail, tenantName, unit) {
  return sendEmail({
    to: landlordEmail,
    subject: `Agreement Signed — ${tenantName} (${unit})`,
    text: `${tenantName} has signed the lease agreement for ${unit}. View in PropEase: ${APP_URL}`,
    html: `<div style="font-family:sans-serif;max-width:560px"><p>${tenantName} has signed the lease agreement for ${unit}.</p><p><a href="${APP_URL}" style="display:inline-block;background:#c9a84c;color:#0f0e0c;padding:10px 20px;border-radius:8px;text-decoration:none;font-weight:600">View in PropEase →</a></p></div>`,
  });
}

async function sendMaintenanceUpdate(tenant, ticketTitle, status) {
  return sendEmail({
    to: tenant.email,
    subject: `Maintenance Update — ${ticketTitle}`,
    text: `Dear ${tenant.fname},\n\nUpdate on your maintenance request "${ticketTitle}": Status is now ${status}.\n\nPortal: ${APP_URL}\n\n— ${FROM_NAME}`,
    html: `<div style="font-family:sans-serif;max-width:560px"><p>Dear ${tenant.fname},</p><p>Update on your maintenance request "<strong>${ticketTitle}</strong>": Status is now <strong>${status}</strong>.</p><p>${PORTAL_LINK}</p><p>— ${FROM_NAME}</p></div>`,
  });
}

async function sendWelcomeLandlord(toEmail) {
  const to = toEmail || process.env.LANDLORD_EMAIL || FROM;
  const loginUrl = APP_URL;
  const html = `<div style="font-family:sans-serif;max-width:560px;margin:0 auto"><h2 style="color:#c9a84c">Welcome to PropEase</h2><p>As a property manager, PropEase helps you streamline tenant management, rent collection, and maintenance tracking—all in one place.</p><p><strong>What you can do:</strong></p><ul style="line-height:1.8"><li>Manage tenants, payments, and lease agreements</li><li>Track maintenance requests and send updates by email</li><li>Send rent reminders and lease expiry alerts via WhatsApp or email</li><li>Get notified when tenants sign agreements</li></ul><p>We're here to manage your stay and rental period smoothly.</p><p><a href="${loginUrl}" style="display:inline-block;background:#c9a84c;color:#0f0e0c;padding:12px 24px;border-radius:8px;text-decoration:none;font-weight:600;margin-top:16px">Login to PropEase →</a></p><p>— ${FROM_NAME}</p></div>`;
  return sendEmail({ to, subject: 'Welcome to PropEase — Property Management Made Easy', text: `Welcome to PropEase! Login at ${loginUrl} — As a property manager, you can now manage tenants, payments, agreements, and maintenance in one place. We're here to manage your stay and rental period smoothly. — ${FROM_NAME}`, html });
}

async function sendWelcomeTenant(tenant, toEmail) {
  const to = toEmail || (tenant && tenant.email);
  if (!to) return { ok: false, error: 'No email' };
  const name = tenant ? tenant.fname : 'Tenant';
  const unit = tenant ? tenant.unit : 'your unit';
  const loginUrl = APP_URL;
  const html = `<div style="font-family:sans-serif;max-width:560px;margin:0 auto"><h2 style="color:#c9a84c">Welcome to PropEase</h2><p>Dear ${name},</p><p>Welcome! We're excited to have you. As we manage your stay and rental period, you can use the PropEase Tenant Portal to view notices, payments, submit maintenance requests, and sign your agreement.</p><p><strong>Login with your phone number</strong> (the one we have on file).</p><p><a href="${loginUrl}" style="display:inline-block;background:#c9a84c;color:#0f0e0c;padding:12px 24px;border-radius:8px;text-decoration:none;font-weight:600;margin:16px 0">Open Tenant Portal →</a></p><p style="font-size:13px;color:#666">Switch to the "Tenant" tab, enter your phone number, then sign in.</p><p>— ${FROM_NAME}</p></div>`;
  return sendEmail({ to, subject: `Welcome to PropEase — ${unit}`, text: `Dear ${name}, Welcome! Open the Tenant Portal: ${loginUrl} — Use the Tenant tab, enter your phone number. — ${FROM_NAME}`, html });
}

async function sendRentChangeProposal(tenant, oldRent, newRent) {
  const fmt = (n) => '₦' + Number(n).toLocaleString();
  return sendEmail({
    to: tenant.email,
    subject: `Rent Change Proposal — ${tenant.unit} · Review & Accept`,
    text: `Dear ${tenant.fname},\n\nYour landlord has proposed a rent change for ${tenant.unit}: from ${fmt(oldRent)} to ${fmt(newRent)} per month.\n\nPlease log in to the Tenant Portal to review and accept or decline this change. All changes are recorded for your records.\n\nPortal: ${APP_URL}\n\n— ${FROM_NAME}`,
    html: `<div style="font-family:sans-serif;max-width:560px"><p>Dear ${tenant.fname},</p><p>Your landlord has proposed a rent change for <strong>${tenant.unit}</strong>:</p><p style="font-size:18px;margin:16px 0"><del>${fmt(oldRent)}</del> → <strong>${fmt(newRent)}</strong> per month</p><p>Please log in to the Tenant Portal to review and accept or decline. All changes are recorded for your records.</p><p>${PORTAL_LINK}</p><p>— ${FROM_NAME}</p></div>`,
  });
}

module.exports = {
  sendEmail,
  sendRentReminder,
  sendLeaseExpiryAlert,
  sendAgreementSignedLandlord,
  sendAgreementSignedTenant,
  sendMaintenanceUpdate,
  sendWelcomeLandlord,
  sendWelcomeTenant,
  sendRentChangeProposal,
};
