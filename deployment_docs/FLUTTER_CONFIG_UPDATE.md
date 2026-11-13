# DCMS Flutter Client — Post-Deployment Configuration Update

> **Codebase Reality Note:**  
> `Backend/README.md` shows an illustrative `Dio` + `flutter_secure_storage` example (`10.0.2.2:8000`), **however the actual `Frontend/` Flutter app uses:**
> - HTTP client: `package:http/http.dart` (`http: ^1.2.0`) in `Frontend/lib/core/services/api_client.dart`
> - Token persistence: `shared_preferences` (`ApiConfig.authTokenKey = 'dcms_auth_token'`)
> - Base URL config: `Frontend/lib/core/config/api_config.dart` (currently `http://localhost:8000/api/v1` on Web and `http://127.0.0.1:8000/api/v1` on Android/others)

---

## 1. Update Production API `baseUrl`

Edit **`Frontend/lib/core/config/api_config.dart`**:

**Current code:**
```dart
class ApiConfig {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000/api/v1';
    }
    if (Platform.isAndroid) {
      // Use 127.0.0.1 when running via USB with `adb reverse tcp:8000 tcp:8000`
      // Or change to your PC Wi-Fi IP (e.g. 'http://172.16.152.181:8000/api/v1')
      return 'http://127.0.0.1:8000/api/v1';
    }
    return 'http://127.0.0.1:8000/api/v1';
  }
```

**Update to your production HTTPS API domain (or use `--dart-define`):**
```dart
class ApiConfig {
  static const String _prodBaseUrl = 'https://api.domain.com/api/v1';

  static String get baseUrl {
    const definedUrl = String.fromEnvironment('API_BASE_URL');
    if (definedUrl.isNotEmpty) {
      return definedUrl;
    }
    if (kReleaseMode) {
      return _prodBaseUrl;
    }
    if (kIsWeb) {
      return 'http://localhost:8000/api/v1';
    }
    return 'http://127.0.0.1:8000/api/v1';
  }
```

With this setup, release builds (`flutter build apk --release`, `flutter build appbundle --release`, `flutter build web --release`) automatically target `https://api.domain.com/api/v1`, or you can override per environment with:
```bash
flutter build apk --release --dart-define=API_BASE_URL=https://api.domain.com/api/v1
```

*(Note: If you also migrate from `http` + `shared_preferences` to `Dio` + `flutter_secure_storage` in the future, configure `BaseOptions(baseUrl: ApiConfig.baseUrl)` in one place and store the Sanctum Bearer token in encrypted secure storage instead of plaintext SharedPreferences.)*

---

## 2. Add `INTERNET` Permission for Android Release Builds (Critical)

Currently:
- `Frontend/android/app/src/debug/AndroidManifest.xml` declares `<uses-permission android:name="android.permission.INTERNET"/>`
- **`Frontend/android/app/src/main/AndroidManifest.xml` does NOT declare `INTERNET`!**

Without `INTERNET` in `main/AndroidManifest.xml`, **`flutter build apk --release` will fail every network call on physical devices**.

Add this inside `<manifest>` (above `<application>`) in **`Frontend/android/app/src/main/AndroidManifest.xml`**:
```xml
<uses-permission android:name="android.permission.INTERNET" />
```

---

## 3. HTTPS & Cleartext Traffic Requirements

- **Always use `https://`** (`https://api.domain.com/api/v1`) in production:
  - Android 9+ (API 28+) and iOS App Transport Security (ATS) block plaintext `http://` traffic in release builds by default.
  - `Backend/app/Auth/Middlewares/SecureHeadersMiddleware.php` sends `Strict-Transport-Security: max-age=31536000; includeSubDomains` (HSTS), requiring valid TLS certificates on `api.domain.com`.
- **Do NOT** add `android:usesCleartextTraffic="true"` in production `AndroidManifest.xml`; switch `baseUrl` to `https://` instead.
- Check any hardcoded attachment/image URL handling: Laravel returns public attachment URLs via `asset('storage/' . $filePath)` using `APP_URL` (`config/filesystems.php`). Ensure backend `APP_URL=https://api.domain.com` is `https://` so Flutter renders images and PDFs over HTTPS without mixed-content errors.

---

## 4. CORS Requirements (If Deploying Flutter Web)

If building Flutter Web (`flutter build web`) hosted at e.g. `https://app.domain.com`:
1. In **`Backend/config/cors.php`**, restrict `'allowed_origins'` to your exact web origin (`['https://app.domain.com']`) instead of `['*']` (required by browsers whenever `'supports_credentials' => true`).
2. Add your web domain to **`SANCTUM_STATEFUL_DOMAINS`** and **`FRONTEND_URL`** in backend `.env`, then run `php artisan config:cache`.

*(Mobile Android/iOS builds using `Authorization: Bearer <token>` do not trigger browser CORS preflight checks.)*

---

## 5. Rebuild & Verify Release Artifact

```bash
cd Frontend
flutter pub get
flutter analyze
flutter build apk --release
```
Test the signed release APK on a physical phone over mobile data/Wi-Fi (without `adb reverse`) against `https://api.domain.com/api/v1`.

