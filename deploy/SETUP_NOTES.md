# Hayya Ride Integration Phase 2 (Maps + Firebase + Mobile Apps)

This document captures end-to-end steps to configure Google Maps, Firebase (FCM + Auth), and mobile apps for production.

Use a terminal with root access to the VPS where Nginx/PHP-FPM/Laravel is running.

## VPS Layout
- Admin panel path: `/var/www/tagxi/appsrc/Main-File-August-20/Admin-Panel-Aug-20-2025`
- Nginx conf (admin): `/etc/nginx/conf.d/admin.hayyaride.com.conf`
- SSL: `/etc/letsencrypt/live/hayyaride.com/`
- PHP: 8.2.29
- Laravel: 8.x

## 1) Google Cloud Project and Maps APIs

1. Login to Google Cloud Console using the provided Gmail account.
2. Create a new project named `hayyaride`.
3. Enable APIs for the project:
   - Maps JavaScript API
   - Geocoding API
   - Directions API
   - Distance Matrix API
   - Places API
4. Create two API keys:
   - Browser key: restrict to HTTP referrers `*.hayyaride.com/*` (both `www` and `admin`).
   - Server key: restrict by VPS IP (`159.198.36.105`) and optionally to specific APIs.
5. Copy the keys into the Laravel `.env` on the VPS (see `.env` section below).

## 2) Firebase Project Setup

1. Login to Firebase Console with the same Gmail and create a new project named `hayyaride`. Link to the Google Cloud project.
2. In Firebase settings, retrieve:
   - Project ID
   - Web API Key
   - Cloud Messaging Server Key (legacy) or configure the FCM v1 API (recommended).
3. Add Android and iOS apps:
   - Android rider: `com.hayyaride.rider`
   - Android driver: `com.hayyaride.driver`
   - iOS rider: `com.hayyaride.rider`
   - iOS driver: `com.hayyaride.driver`
4. Download `google-services.json` for Android apps and `GoogleService-Info.plist` for iOS apps; place them in the respective app module targets.

## 3) Laravel `.env` Configuration

SSH to the server as root and edit the `.env` in the admin panel app path.

Example `.env` additions (add if missing):

```
# Google Maps
GOOGLE_MAPS_API_KEY=
GOOGLE_MAPS_SERVER_KEY=

# Firebase / FCM
FIREBASE_PROJECT_ID=
FIREBASE_WEB_API_KEY=
FCM_SERVER_KEY=

# Optional: FCM v1
# GOOGLE_APPLICATION_CREDENTIALS=/var/www/tagxi/secrets/firebase-service-account.json
```

After editing, clear and rebuild Laravel caches:

```
cd /var/www/tagxi/appsrc/Main-File-August-20/Admin-Panel-Aug-20-2025
php artisan optimize:clear && php artisan config:cache && php artisan route:cache
```

## 4) Integrating Maps in Web Frontends

- Ensure landing site uses the browser key in the Maps JS script tag (if the landing site is a separate app/CMS, update its config similarly).
- Admin panel (Laravel blade or React/Vue view) should load Maps JS via:

```
<script src="https://maps.googleapis.com/maps/api/js?key={{ config('services.google.maps_js_key', env('GOOGLE_MAPS_API_KEY')) }}&libraries=places"></script>
```

- If there is a server-side geocoding/distance calculation, use `GOOGLE_MAPS_SERVER_KEY` in backend services.

## 5) FCM from Laravel

Add a simple notification sender using HTTP client. For legacy key use:

```
POST https://fcm.googleapis.com/fcm/send
Authorization: key=<FCM_SERVER_KEY>
Content-Type: application/json
{
  "to": "<device_token>",
  "notification": {"title": "Test", "body": "Hello from Hayya Ride"},
  "data": {"type": "test"}
}
```

For FCM v1 (recommended), use a service account JSON and send to:
`https://fcm.googleapis.com/v1/projects/<FIREBASE_PROJECT_ID>/messages:send`

A Laravel example service using `Http::post` can be created at `app/Services/FcmService.php`. See `deploy/scripts/test_fcm_legacy.sh` for a quick manual test.

## 6) Android Setup

- Update package IDs in Gradle for rider and driver apps: `com.hayyaride.rider` and `com.hayyaride.driver`.
- Place `google-services.json` under each Android app module: `app/` directory.
- Add Maps key in `AndroidManifest.xml` inside the application tag:

```
<meta-data android:name="com.google.android.geo.API_KEY" android:value="@string/google_maps_key" />
```

- Ensure `google_maps_key` is present in `app/src/main/res/values/google_maps_api.xml` using the browser key (or Android-restricted key).
- Ensure Firebase BOM and `com.google.gms.google-services` plugin are applied.
- Build release APKs with signing config.

## 7) iOS Setup

- Place `GoogleService-Info.plist` into each iOS target.
- Add Maps SDK key, typically in `AppDelegate`:

```
GMSServices.provideAPIKey(Bundle.main.object(forInfoDictionaryKey: "GMSApiKey") as? String ?? "")
```

- Configure push notifications capability and APNs key; ensure Firebase Messaging is initialized.
- Build archive `.ipa` via Xcode, using correct bundle IDs.

## 8) Key Restrictions

- Browser key: restrict to `https://*.hayyaride.com/*`.
- Server key: restrict to server IP `159.198.36.105` and APIs.
- Android key: restrict to package names and SHA-1 certificates.
- iOS key: restrict to bundle IDs.

## 9) Testing

- Web: visit `https://www.hayyaride.com` and `https://admin.hayyaride.com` and confirm Maps load and no console auth errors.
- Auth flow: test `/login`, `/dashboard`, `/logout` on admin domain.
- FCM: run `deploy/scripts/test_fcm_legacy.sh` or `deploy/scripts/test_fcm_v1.sh` with a sample device token.

## 10) Useful Scripts

- `deploy/scripts/update_env.sh` — safely insert/replace keys in `.env`.
- `deploy/scripts/clear_cache.sh` — clear and rebuild Laravel caches.
- `deploy/scripts/test_fcm_legacy.sh` — send a test notification via legacy key.
- `deploy/scripts/test_fcm_v1.sh` — send a test notification via v1 API.

## 11) Rollback and Safety

- Back up `.env` before changes.
- Do not reset database.
- If Nginx reload is needed: `nginx -t && systemctl reload nginx`.
