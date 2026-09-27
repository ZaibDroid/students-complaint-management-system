/// System & UI Constants
class AppConstants {
  AppConstants._();

  // Storage Keys (SharedPreferences / Secure Storage)
  static const String keyAuthToken = 'auth_token';
  static const String keyUserData = 'user_data';
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyFcmToken = 'fcm_token';
  static const String keyThemeMode = 'theme_mode';
  static const String keyBaseUrl = 'api_base_url';

  // File & Upload Limits
  static const int maxImageFileSizeKB = 1024; // 1 MB compressed max
  static const int maxAttachedImages = 4;
  static const int imageQuality = 80;

  // Pagination defaults
  static const int defaultPageSize = 15;

  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
