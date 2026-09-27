import '../constants/api_endpoints.dart';

/// Environment Configurations
enum Environment { dev, staging, prod }

class AppConfig {
  static Environment environment = Environment.dev;
  static String appVersion = '1.0.0';
  static bool enableLogging = true;

  static void initialize({
    Environment env = Environment.dev,
    bool logging = true,
  }) {
    environment = env;
    enableLogging = logging;
  }
}

class ApiConfig {
  static String baseUrl = ApiEndpoints.defaultBaseUrl;

  static void setBaseUrl(String url) {
    if (url.isNotEmpty) {
      baseUrl = url;
    }
  }
}
