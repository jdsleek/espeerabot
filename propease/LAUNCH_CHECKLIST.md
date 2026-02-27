# PropEase — Pre-Launch Checklist

Use this list before going live with real landlords and tenants.

---

## Environment & Config

- [ ] **`APP_URL`** set in Railway (or `.env` locally) to your public URL (e.g. `https://propease.up.railway.app`)
- [ ] **Brevo SMTP** configured: `BREVO_SMTP_*`, `LANDLORD_EMAIL`
- [ ] **Landlord password** changed from default (`admin123`) — consider adding password reset flow
- [ ] **Database backups** enabled on Railway (or scheduled elsewhere)

---

## Security & Auth

- [ ] Landlord password is strong and unique
- [ ] Tenant PINs are communicated securely (not in plain email if sensitive)
- [ ] (Optional) Add rate limiting on `/api/*` to prevent abuse
- [ ] (Optional) Add forgot-PIN flow for tenants

---

## Email & Notifications

- [ ] Welcome emails (landlord + tenant) include login link — ✅ done
- [ ] Rent reminders, lease expiry, maintenance updates include portal link — ✅ done
- [ ] Test all email types in production (Brevo sender domain verified)
- [ ] Check spam folders; consider SPF/DKIM if needed

---

## UX & Mobile

- [ ] PWA installed on a test phone (Add to Home Screen) — ✅ PWA setup done
- [ ] Login flow works when opened from email links (especially mobile)
- [ ] Tenant tab is default/obvious when shared link opens in tenant context

---

## Legal & Compliance

- [ ] Terms of Service page (or linked document)
- [ ] Privacy Policy / data handling disclosure
- [ ] Lease agreement templates reviewed for local law
- [ ] (If EU) GDPR considerations for tenant data

---

## Testing Before Launch

- [ ] Landlord: add tenant, send welcome, view dashboard
- [ ] Tenant: receive email, click link, log in with name + PIN
- [ ] Tenant: view agreement, sign, submit maintenance
- [ ] Landlord: send rent reminder (WhatsApp + Email), maintenance status update
- [ ] Agreement signed notifications received by both parties
- [ ] Mobile: install PWA, use in standalone mode

---

## Post-Launch

- [ ] Monitor Railway logs for errors
- [ ] Monitor Brevo for bounces / delivery issues
- [ ] Gather feedback on PIN login friction (consider magic link later)
- [ ] Consider: payment gateway integration for rent collection
- [ ] Consider: document storage (signed PDFs, receipts)
