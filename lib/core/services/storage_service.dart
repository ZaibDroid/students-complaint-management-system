import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

/// Local Storage Service for DCMS (persisting auth tokens, user info, cached preferences)
class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // Token Management
  Future<bool> saveToken(String token) async {
    return await _prefs.setString(AppConstants.keyAuthToken, token);
  }

  String? getToken() {
    return _prefs.getString(AppConstants.keyAuthToken);
  }

  Future<bool> clearToken() async {
    return await _prefs.remove(AppConstants.keyAuthToken);
  }

  // User Profile Data Management
  Future<bool> saveUserData(Map<String, dynamic> userMap) async {
    return await _prefs.setString(AppConstants.keyUserData, jsonEncode(userMap));
  }

  Map<String, dynamic>? getUserData() {
    final raw = _prefs.getString(AppConstants.keyUserData);
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<bool> clearUserData() async {
    return await _prefs.remove(AppConstants.keyUserData);
  }

  // FCM Token
  Future<bool> saveFcmToken(String token) async {
    return await _prefs.setString(AppConstants.keyFcmToken, token);
  }

  String? getFcmToken() {
    return _prefs.getString(AppConstants.keyFcmToken);
  }

  // Clear all session on Logout
  Future<void> clearAll() async {
    await _prefs.remove(AppConstants.keyAuthToken);
    await _prefs.remove(AppConstants.keyUserData);
    await _prefs.remove(AppConstants.keyIsLoggedIn);
  }
}
