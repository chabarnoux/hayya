# ?? Hayya App Deployment Guide - Quick Start

This guide provides step-by-step instructions to deploy all fixes for the Hayya ride-hailing application.

---

## ?? Pre-Deployment Checklist

- [ ] SSH access to VPS
- [ ] Google Cloud Console access to `hayyaride` project
- [ ] gcloud CLI installed (optional, for automated API setup)
- [ ] Flutter SDK installed on VPS
- [ ] Android device for testing

---

## ?? Quick Deployment (3 Steps)

### Step 1: Fix Google Maps API Key (5 minutes)

**Option A - Manual (Recommended):**

1. Open: https://console.cloud.google.com/apis/credentials?project=hayyaride
2. Find the **Browser** API key ? Click **Edit**
3. Set **Application restrictions** ? `HTTP referrers (web sites)`
4. Add these 6 referrers:
   ```
   https://admin.hayyaride.com/*
   http://admin.hayyaride.com/*
   https://*.hayyaride.com/*
   http://*.hayyaride.com/*
   https://hayyaride.com/*
   http://hayyaride.com/*
   ```
5. Set **API restrictions** ? `Restrict key` ? Enable these 5 APIs:
   - ? Maps JavaScript API
   - ? Places API
   - ? Geocoding API
   - ? Directions API
   - ? Distance Matrix API
6. Click **SAVE**

**Option B - Automated (if gcloud CLI available):**
```bash
bash /workspace/deploy/scripts/fix_gcp_maps_api.sh
# Then follow the manual steps printed by the script
```

---

### Step 2: Deploy Code Fixes to VPS (10 minutes)

```bash
# SSH into VPS
ssh root@YOUR_VPS_IP

# Create utils directory if it doesn't exist
mkdir -p /var/www/tagxi/appsrc/Main-File-August-20/flutter_user/flutter_user/lib/utils
mkdir -p /var/www/tagxi/appsrc/Main-File-August-20/flutter_driver/flutter_driver/lib/utils
```

**Copy files from your local workspace:**

```bash
# From your local machine (where this repo is cloned)
cd /workspace

# Copy Rider fixes
scp rider/lib/utils/safe.dart \
  root@YOUR_VPS:/var/www/tagxi/appsrc/Main-File-August-20/flutter_user/flutter_user/lib/utils/

scp rider/lib/functions/functions.dart \
  root@YOUR_VPS:/var/www/tagxi/appsrc/Main-File-August-20/flutter_user/flutter_user/lib/functions/

# Copy Driver fixes
scp driver/lib/utils/safe.dart \
  root@YOUR_VPS:/var/www/tagxi/appsrc/Main-File-August-20/flutter_driver/flutter_driver/lib/utils/

scp driver/lib/functions/functions.dart \
  root@YOUR_VPS:/var/www/tagxi/appsrc/Main-File-August-20/flutter_driver/flutter_driver/lib/functions/
```

**OR use the automated script:**
```bash
bash /workspace/deploy/scripts/deploy_flutter_fixes.sh
```

---

### Step 3: Build & Test (15 minutes)

**3.1 Clear Admin Cache:**
```bash
ssh root@YOUR_VPS_IP
cd /var/www/tagxi/appsrc/Main-File-August-20/Admin-Panel-Aug-20-2025
php artisan config:clear
php artisan optimize:clear
php artisan view:clear
```

**3.2 Build Rider App:**
```bash
cd /var/www/tagxi/appsrc/Main-File-August-20/flutter_user/flutter_user
flutter clean
flutter pub get
flutter build apk --debug

# APK location:
# build/app/outputs/flutter-apk/app-debug.apk
```

**3.3 Build Driver App:**
```bash
cd /var/www/tagxi/appsrc/Main-File-August-20/flutter_driver/flutter_driver
flutter clean
flutter pub get
flutter build apk --debug

# APK location:
# build/app/outputs/flutter-apk/app-debug.apk
```

---

## ? Testing & Verification

### Admin Panel (5 minutes)
1. Visit: https://admin.hayyaride.com
2. Login with admin credentials
3. Test these pages:
   - **Geofencing** ? Map loads ?
   - **Dispatch** ? Map loads, shows drivers ?
   - **Web Booking** ? Map loads, autocomplete works ?
4. Open browser DevTools Console ? Should see NO "Authorization" errors ?

### Rider App (5 minutes)
1. Install `app-debug.apk` on Android device
2. Enter phone number ? Get OTP
3. Enter OTP ? Login
4. **Expected Results:**
   - ? No red error screen
   - ? Home screen loads with map
   - ? User profile shows in menu
   - ? Banners display (if configured)

### Driver App (5 minutes)
1. Install `app-debug.apk` on Android device
2. Enter phone number ? Get OTP
3. Enter OTP ? Login
4. **Expected Results:**
   - ? No red error screen
   - ? Dashboard loads
   - ? Map shows location

---

## ?? Troubleshooting

### Issue: Admin maps still show "Authorization" error
**Solution:**
1. Wait 5 minutes for GCP changes to propagate
2. Clear browser cache (Ctrl+Shift+Delete)
3. Verify API key in database:
   ```sql
   SELECT value FROM settings WHERE name = 'google_map_key';
   ```
4. Check API key has no IP restrictions (only HTTP referrers)

### Issue: Rider app still shows red screen
**Solution:**
1. Get detailed error:
   ```bash
   adb logcat | grep -iE "flutter|dart|exception|Null"
   ```
2. Look for field names in error message
3. Add safe parsing for those fields in `getUserDetails()`

### Issue: Flutter build fails
**Solution:**
```bash
# Check Flutter version
flutter --version

# Clean and retry
flutter clean
rm -rf .dart_tool
rm pubspec.lock
flutter pub get
flutter build apk --debug
```

### Issue: Cannot find safe.dart
**Solution:**
```bash
# Verify file exists
ls -la /var/www/tagxi/appsrc/Main-File-August-20/flutter_user/flutter_user/lib/utils/safe.dart

# If missing, copy again with full path
scp -v rider/lib/utils/safe.dart root@YOUR_VPS:/var/www/tagxi/appsrc/Main-File-August-20/flutter_user/flutter_user/lib/utils/
```

---

## ?? What Was Fixed

### 1. Admin Panel Maps ?
- **Issue:** Authorization errors on Maps JavaScript API
- **Fix:** Updated Browser API key with proper HTTP referrers
- **Files:** No code changes needed (Blade templates already correct)

### 2. Rider App Null Crash ?
- **Issue:** `type 'Null' is not a subtype of type 'String'` on login
- **Fix:** Added null-safe parsing in `getUserDetails()`
- **Files:**
  - `rider/lib/utils/safe.dart` (NEW)
  - `rider/lib/functions/functions.dart` (MODIFIED)

### 3. Driver App Null Safety ?
- **Issue:** Potential null crashes on login
- **Fix:** Added null-safe parsing in `getUserDetails()`
- **Files:**
  - `driver/lib/utils/safe.dart` (NEW)
  - `driver/lib/functions/functions.dart` (MODIFIED)

---

## ?? Support

For detailed technical documentation, see: `FIXES_APPLIED.md`

**Common Commands:**

```bash
# Check Flutter version
flutter --version

# Check PHP/Laravel version
php artisan --version

# Monitor app logs
adb logcat | grep flutter

# Test API endpoint
curl -X GET https://admin.hayyaride.com/api/v1/user \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

## ?? Estimated Time
- **Step 1 (Maps API):** 5 minutes
- **Step 2 (Code Deploy):** 10 minutes  
- **Step 3 (Build & Test):** 15 minutes
- **Total:** ~30 minutes

---

**Status:** ? Ready for deployment
**Last Updated:** 2025-10-31
