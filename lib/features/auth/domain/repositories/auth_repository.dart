import '../../../../core/utils/result.dart';
import '../../../../shared/enums/user_role.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Result<UserEntity>> login({
    required String email,
    required String password,
  });

  Future<Result<UserEntity>> register({
    required String fullName,
    required String email,
    required String password,
    required String passwordConfirmation,
    required UserRole role,
  });

  Future<Result<bool>> verifyEmail({
    required String email,
    required String otpCode,
  });

  Future<Result<bool>> resendVerificationEmail({required String email});

  Future<Result<UserEntity>> completeProfile({
    required String regNo,
    required String batch,
    required String section,
    String? phone,
  });

  Future<Result<UserEntity>> getCurrentUser();

  Future<Result<void>> logout();

  Future<Result<bool>> forgotPassword({required String email});
}
