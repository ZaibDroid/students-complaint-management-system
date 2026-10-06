import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000/api/v1';
    }
    if (Platform.isAndroid) {
      return 'http://192.168.1.2:8000/api/v1';
    }
    return 'http://127.0.0.1:8000/api/v1';
  }

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';
  static const String updateProfile = '/auth/profile';
  static const String changePassword = '/auth/password';
  static const String uploadProfileImage = '/auth/profile-image';

  // Complaints
  static const String complaints = '/complaints';

  // Notices
  static const String notices = '/notices';

  // Batches & Sections
  static const String batches = '/batches';
  static const String sections = '/sections';
  static const String departments = '/departments';

  // Notifications
  static const String notifications = '/notifications';

  // Users
  static const String users = '/users';

  // Keys
  static const String authTokenKey = 'dcms_auth_token';
  static const String userProfileKey = 'dcms_user_profile';
}
