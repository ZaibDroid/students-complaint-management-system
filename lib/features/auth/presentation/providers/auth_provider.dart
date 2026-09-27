import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/push_notification_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../shared/enums/user_role.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/auth_usecases.dart';
import '../../domain/usecases/login_usecase.dart';

// Core Service Providers
final dioProvider = Provider<Dio>((ref) => Dio());

final storageServiceProvider = Provider<StorageService>((ref) {
  throw UnimplementedError('StorageService must be overridden in main.dart');
});

final apiServiceProvider = Provider<ApiService>((ref) {
  final dio = ref.watch(dioProvider);
  final storage = ref.watch(storageServiceProvider);
  return ApiService(dio, storage);
});

final pushNotificationServiceProvider = Provider<PushNotificationService>((ref) {
  final api = ref.watch(apiServiceProvider);
  final storage = ref.watch(storageServiceProvider);
  return PushNotificationService(api, storage);
});

// Auth Data & Repository Providers
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final api = ref.watch(apiServiceProvider);
  return AuthRemoteDataSourceImpl(api);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remote = ref.watch(authRemoteDataSourceProvider);
  final storage = ref.watch(storageServiceProvider);
  return AuthRepositoryImpl(remote, storage);
});

// Auth UseCases
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  return RegisterUseCase(ref.watch(authRepositoryProvider));
});

final verifyEmailUseCaseProvider = Provider<VerifyEmailUseCase>((ref) {
  return VerifyEmailUseCase(ref.watch(authRepositoryProvider));
});

final completeProfileUseCaseProvider = Provider<CompleteProfileUseCase>((ref) {
  return CompleteProfileUseCase(ref.watch(authRepositoryProvider));
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(ref.watch(authRepositoryProvider));
});

// Auth State Class
class AuthState {
  final bool isLoading;
  final UserEntity? user;
  final String? errorMessage;
  final bool isAuthenticated;
  final String? pendingVerificationEmail;

  const AuthState({
    this.isLoading = false,
    this.user,
    this.errorMessage,
    this.isAuthenticated = false,
    this.pendingVerificationEmail,
  });

  AuthState copyWith({
    bool? isLoading,
    UserEntity? user,
    String? errorMessage,
    bool? isAuthenticated,
    String? pendingVerificationEmail,
    bool clearError = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      pendingVerificationEmail: pendingVerificationEmail ?? this.pendingVerificationEmail,
    );
  }
}

// Auth State Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final VerifyEmailUseCase _verifyEmailUseCase;
  final CompleteProfileUseCase _completeProfileUseCase;
  final LogoutUseCase _logoutUseCase;
  final StorageService _storageService;
  final AuthRepository _authRepository;

  AuthNotifier(
    this._loginUseCase,
    this._registerUseCase,
    this._verifyEmailUseCase,
    this._completeProfileUseCase,
    this._logoutUseCase,
    this._storageService,
    this._authRepository,
  ) : super(const AuthState()) {
    _initSession();
  }

  void _initSession() {
    final token = _storageService.getToken();
    final userData = _storageService.getUserData();

    if (token != null && userData != null) {
      final user = UserModel.fromJson(userData);
      state = state.copyWith(
        isAuthenticated: true,
        user: user,
      );
      // Refresh current user in background
      _authRepository.getCurrentUser().then((result) {
        result.when(
          onSuccess: (freshUser) {
            state = state.copyWith(user: freshUser);
          },
          onError: (_) {},
        );
      });
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _loginUseCase(email: email, password: password);

    return result.when(
      onSuccess: (user) {
        state = state.copyWith(
          isLoading: false,
          user: user,
          isAuthenticated: true,
          clearError: true,
        );
        return true;
      },
      onError: (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
    );
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    required String passwordConfirmation,
    required UserRole role,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _registerUseCase(
      fullName: fullName,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
      role: role,
    );

    return result.when(
      onSuccess: (user) {
        state = state.copyWith(
          isLoading: false,
          user: user,
          pendingVerificationEmail: email,
          clearError: true,
        );
        return true;
      },
      onError: (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
    );
  }

  Future<bool> verifyEmail(String otpCode) async {
    final email = state.pendingVerificationEmail ?? state.user?.email;
    if (email == null) return false;

    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _verifyEmailUseCase(email: email, otpCode: otpCode);

    return result.when(
      onSuccess: (_) {
        if (state.user != null) {
          final updatedUser = UserModel(
            id: state.user!.id,
            fullName: state.user!.fullName,
            email: state.user!.email,
            role: state.user!.role,
            regNo: state.user!.regNo,
            batch: state.user!.batch,
            section: state.user!.section,
            phone: state.user!.phone,
            avatarUrl: state.user!.avatarUrl,
            isEmailVerified: true,
            isProfileCompleted: state.user!.isProfileCompleted,
            createdAt: state.user!.createdAt,
          );
          state = state.copyWith(
            isLoading: false,
            user: updatedUser,
            isAuthenticated: true,
            clearError: true,
          );
        } else {
          state = state.copyWith(isLoading: false, clearError: true);
        }
        return true;
      },
      onError: (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
    );
  }

  Future<bool> completeProfile({
    required String regNo,
    required String batch,
    required String section,
    String? phone,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _completeProfileUseCase(
      regNo: regNo,
      batch: batch,
      section: section,
      phone: phone,
    );

    return result.when(
      onSuccess: (user) {
        state = state.copyWith(
          isLoading: false,
          user: user,
          clearError: true,
        );
        return true;
      },
      onError: (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
    );
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    await _logoutUseCase();
    state = const AuthState();
  }

  void switchDemoRole(UserRole newRole) {
    if (state.user != null) {
      final updated = UserModel(
        id: state.user!.id,
        fullName: state.user!.fullName,
        email: state.user!.email,
        role: newRole,
        regNo: state.user!.regNo,
        batch: state.user!.batch,
        section: state.user!.section,
        phone: state.user!.phone,
        avatarUrl: state.user!.avatarUrl,
        isEmailVerified: true,
        isProfileCompleted: true,
        createdAt: state.user!.createdAt,
      );
      state = state.copyWith(user: updated);
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.watch(loginUseCaseProvider),
    ref.watch(registerUseCaseProvider),
    ref.watch(verifyEmailUseCaseProvider),
    ref.watch(completeProfileUseCaseProvider),
    ref.watch(logoutUseCaseProvider),
    ref.watch(storageServiceProvider),
    ref.watch(authRepositoryProvider),
  );
});
