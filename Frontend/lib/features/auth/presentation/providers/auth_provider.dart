import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user.dart';
import '../../data/repositories/api_auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

final authRepositoryProvider = Provider<ApiAuthRepository>((ref) {
  return ApiAuthRepository();
});

final apiAuthRepositoryProvider = authRepositoryProvider;
final firebaseAuthRepositoryProvider = authRepositoryProvider;

final authStateProvider = AsyncNotifierProvider<AuthNotifier, User?>(() {
  return AuthNotifier();
});

class AuthNotifier extends AsyncNotifier<User?> {
  late final ApiAuthRepository _repository;

  @override
  FutureOr<User?> build() async {
    _repository = ref.read(apiAuthRepositoryProvider);
    final user = await _repository.getCurrentUser();
    if (user != null) {
      // User is logged in
    }
    return user;
  }



  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.login(email, password);
      state = AsyncValue.data(user);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    String? year,
    String? batch,
    String? section,
    String? adviser,
    String? phone,
    bool isCR = false,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.register(
        name: name,
        email: email,
        password: password,
        year: year,
        batch: batch,
        section: section,
        adviser: adviser,
        phone: phone,
        isCR: isCR,
      );
      state = AsyncValue.data(user);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> refreshUser() async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.getCurrentUser();
      state = AsyncValue.data(user);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    try {
      await _repository.logout();
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

// Provider to check if onboarding is complete
final onboardingStateProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('dcms_onboarding_complete') ?? false;
});

Future<void> setOnboardingComplete() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('dcms_onboarding_complete', true);
}
