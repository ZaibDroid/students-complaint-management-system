import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/utils/result.dart';
import '../../../../shared/enums/user_role.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<Result<AuthResponseModel>> login({required String email, required String password});
  Future<Result<AuthResponseModel>> register({
    required String fullName,
    required String email,
    required String password,
    required String passwordConfirmation,
    required UserRole role,
  });
  Future<Result<bool>> verifyEmail({required String email, required String otpCode});
  Future<Result<bool>> resendVerificationEmail({required String email});
  Future<Result<UserModel>> completeProfile({
    required String regNo,
    required String batch,
    required String section,
    String? phone,
  });
  Future<Result<UserModel>> getCurrentUser();
  Future<Result<void>> logout();
  Future<Result<bool>> forgotPassword({required String email});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiService _apiService;

  AuthRemoteDataSourceImpl(this._apiService);

  @override
  Future<Result<AuthResponseModel>> login({
    required String email,
    required String password,
  }) async {
    final result = await _apiService.post(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );

    return result.when(
      onSuccess: (data) => Result.success(AuthResponseModel.fromJson(data as Map<String, dynamic>)),
      onError: (failure) => Result.error(failure),
    );
  }

  @override
  Future<Result<AuthResponseModel>> register({
    required String fullName,
    required String email,
    required String password,
    required String passwordConfirmation,
    required UserRole role,
  }) async {
    final result = await _apiService.post(
      ApiEndpoints.register,
      data: {
        'name': fullName,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'role': role.value,
      },
    );

    return result.when(
      onSuccess: (data) => Result.success(AuthResponseModel.fromJson(data as Map<String, dynamic>)),
      onError: (failure) => Result.error(failure),
    );
  }

  @override
  Future<Result<bool>> verifyEmail({
    required String email,
    required String otpCode,
  }) async {
    final result = await _apiService.post(
      ApiEndpoints.verifyEmail,
      data: {'email': email, 'otp': otpCode},
    );

    return result.when(
      onSuccess: (_) => Result.success(true),
      onError: (failure) => Result.error(failure),
    );
  }

  @override
  Future<Result<bool>> resendVerificationEmail({required String email}) async {
    final result = await _apiService.post(
      ApiEndpoints.resendVerification,
      data: {'email': email},
    );

    return result.when(
      onSuccess: (_) => Result.success(true),
      onError: (failure) => Result.error(failure),
    );
  }

  @override
  Future<Result<UserModel>> completeProfile({
    required String regNo,
    required String batch,
    required String section,
    String? phone,
  }) async {
    final result = await _apiService.post(
      ApiEndpoints.completeProfile,
      data: {
        'reg_no': regNo,
        'batch': batch,
        'section': section,
        if (phone != null) 'phone': phone,
      },
    );

    return result.when(
      onSuccess: (data) {
        final userMap = data['user'] ?? data['data'] ?? data;
        return Result.success(UserModel.fromJson(userMap as Map<String, dynamic>));
      },
      onError: (failure) => Result.error(failure),
    );
  }

  @override
  Future<Result<UserModel>> getCurrentUser() async {
    final result = await _apiService.get(ApiEndpoints.currentUser);
    return result.when(
      onSuccess: (data) {
        final userMap = data['user'] ?? data['data'] ?? data;
        return Result.success(UserModel.fromJson(userMap as Map<String, dynamic>));
      },
      onError: (failure) => Result.error(failure),
    );
  }

  @override
  Future<Result<void>> logout() async {
    final result = await _apiService.post(ApiEndpoints.logout);
    return result.when(
      onSuccess: (_) => Result.success(null),
      onError: (failure) => Result.error(failure),
    );
  }

  @override
  Future<Result<bool>> forgotPassword({required String email}) async {
    final result = await _apiService.post(
      ApiEndpoints.forgotPassword,
      data: {'email': email},
    );
    return result.when(
      onSuccess: (_) => Result.success(true),
      onError: (failure) => Result.error(failure),
    );
  }
}
