# PropEase E2E Test Report

**Test Date:** February 28, 2025  
**Target:** https://propease.up.railway.app  
**Test Framework:** Playwright

---

## Summary

| Flow | Status | Notes |
|------|--------|-------|
| 1. Landlord Flow | ✅ Pass | Login, dashboard, add tenant, edit rent work |
| 2. Tenant Flow | ✅ Pass | Login (phone OR name+PIN), portal, maintenance request work |
| 3. Rent Change Flow | ⚠️ Verify | Backend creates change_requests; tenant fetches by tenantId. Ensure change_requests table exists (migration added). |
| 4. Session Persistence | ✅ Pass | Both landlord and tenant stay logged in after refresh |
| 5. Error Handling | ✅ Pass | Wrong credentials show appropriate errors |
| 6. Clear All Data | ⚠️ Destructive | Requires password; permanently deletes all data |

---

## Issues Found & Fixes Applied

### 1. **Rent Change Flow — Pending Changes**
- **Fix:** Added standalone `change_requests` migration in init-db for existing DBs
- **Verify:** After deploy, landlord edits rent → tenant sees "Pending Changes" card with Accept/Decline

### 2. **Tenant Login — Phone + Name+PIN**
- **Fix:** Frontend now supports both: phone only, OR name + PIN
- **Backend:** Already supports both `{ phone }` and `{ name, pin }`

### 3. **Default Landlord Password**
- **Status:** Set `ADMIN_PASSWORD` in Railway Variables to override `admin123`
- **UI:** Placeholder is "Password" (no hint)

### 4. **Session in localStorage**
- **Status:** By design for simplicity; no server-side session
- **Note:** Logout clears localStorage

### 5. **Clear All Data**
- **Status:** Intentional; requires landlord password
- **Note:** Use with caution on production

---

## Railway Deployment Notes

- **Database:** Ensure Postgres is linked; `DATABASE_URL` must be set
- **Variables:** `ADMIN_PASSWORD`, `APP_URL`, Brevo SMTP vars
- **Health:** `/api/health` returns 503 if DB not configured

---

## Run E2E Tests

```bash
cd propease && npm run test:e2e
```

**Warning:** Clear All Data test permanently deletes data. Use staging DB.
