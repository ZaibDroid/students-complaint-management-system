import '../../../../core/services/storage_service.dart';
import '../../../../core/utils/result.dart';
import '../../../../shared/enums/user_role.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final StorageService _storageService;

  AuthRepositoryImpl(this._remoteDataSource, this._storageService);

  @override
  Future<Result<UserEntity>> login({
    required String email,
    required String password,
  }) async {
    final result = await _remoteDataSource.login(email: email, password: password);
    return result.when(
      onSuccess: (authResponse) async {
        await _storageService.saveToken(authResponse.token);
        await _storageService.saveUserData(authResponse.user.toJson());
        return Result.success(authResponse.user);
      },
      onError: (failure) => Result.error(failure),
    );
  }

  @override
  Future<Result<UserEntity>> register({
    required String fullName,
    required String email,
    required String password,
    required String passwordConfirmation,
    required UserRole role,
  }) async {
    final result = await _remoteDataSource.register(
      fullName: fullName,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
      role: role,
    );

    return result.when(
      onSuccess: (authResponse) async {
        if (authResponse.token.isNotEmpty) {
          await _storageService.saveToken(authResponse.token);
          await _storageService.saveUserData(authResponse.user.toJson());
        }
        return Result.success(authResponse.user);
      },
      onError: (failure) => Result.error(failure),
    );
  }

  @override
  Future<Result<bool>> verifyEmail({
    required String email,
    required String otpCode,
  }) async {
    return await _remoteDataSource.verifyEmail(email: email, otpCode: otpCode);
  }

  @override
  Future<Result<bool>> resendVerificationEmail({required String email}) async {
    return await _remoteDataSource.resendVerificationEmail(email: email);
  }

  @override
  Future<Result<UserEntity>> completeProfile({
    required String regNo,
    required String batch,
    required String section,
    String? phone,
  }) async {
    final result = await _remoteDataSource.completeProfile(
      regNo: regNo,
      batch: batch,
      section: section,
      phone: phone,
    );

    return result.when(
      onSuccess: (userModel) async {
        await _storageService.saveUserData(userModel.toJson());
        return Result.success(userModel);
      },
      onError: (failure) => Result.error(failure),
    );
  }

  @override
  Future<Result<UserEntity>> getCurrentUser() async {
    final localData = _storageService.getUserData();
    if (localData != null) {
      // Return cached user first while updating in background
    }

    final result = await _remoteDataSource.getCurrentUser();
    return result.when(
      onSuccess: (userModel) async {
        await _storageService.saveUserData(userModel.toJson());
        return Result.success(userModel);
      },
      onError: (failure) => Result.error(failure),
    );
  }

  @override
  Future<Result<void>> logout() async {
    await _remoteDataSource.logout();
    await _storageService.clearAll();
    return Result.success(null);
  }

  @override
  Future<Result<bool>> forgotPassword({required String email}) async {
    return await _remoteDataSource.forgotPassword(email: email);
  }
}
