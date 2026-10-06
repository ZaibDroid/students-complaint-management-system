import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user.dart';

class LocalAuthRepository {
  static const String _userKey = 'dcms_current_user';
  static const String _onboardingKey = 'dcms_onboarding_complete';

  Future<bool> hasCompletedOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;
  }

  Future<void> setOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
  }

  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      return User.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  Future<User> login(String email, String password) async {
    // Mock login logic
    await Future.delayed(const Duration(seconds: 1)); // Simulate network
    
    String role = 'Student';
    if (email == 'admin@uetmardan.edu.pk') {
      role = 'Admin';
    } else if (email == 'chairman@uetmardan.edu.pk') {
      role = 'Chairman';
    } else if (email.startsWith('adviser')) {
      role = 'Batch Adviser';
    } else if (email == 'dean@uetmardan.edu.pk') {
      role = 'Dean';
    } else if (email == 'coordinator@uetmardan.edu.pk') {
      role = 'Coordinator';
    } else if (email == 'office@uetmardan.edu.pk') {
      role = 'Office';
    }

    final user = User(
      id: 'mock_${DateTime.now().millisecondsSinceEpoch}',
      name: role == 'Student' ? 'Test Student' : 'Test $role',
      email: email,
      role: role,
    );
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
    
    return user;
  }

  Future<User> register(String name, String email, String password) async {
    // Mock register logic
    await Future.delayed(const Duration(seconds: 1));
    final user = User(
      id: 'mock_123',
      name: name,
      email: email,
      role: 'Student',
    );
    
    // Auto login after registration
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
    
    return user;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }
}
