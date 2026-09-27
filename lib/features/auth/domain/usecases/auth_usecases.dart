import '../../../../core/utils/result.dart';
import '../../../../shared/enums/user_role.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository _repository;

  RegisterUseCase(this._repository);

  Future<Result<UserEntity>> call({
    required String fullName,
    required String email,
    required String password,
    required String passwordConfirmation,
    required UserRole role,
  }) {
    return _repository.register(
      fullName: fullName,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
      role: role,
    );
  }
}

class VerifyEmailUseCase {
  final AuthRepository _repository;

  VerifyEmailUseCase(this._repository);

  Future<Result<bool>> call({
    required String email,
    required String otpCode,
  }) {
    return _repository.verifyEmail(email: email, otpCode: otpCode);
  }
}

class CompleteProfileUseCase {
  final AuthRepository _repository;

  CompleteProfileUseCase(this._repository);

  Future<Result<UserEntity>> call({
    required String regNo,
    required String batch,
    required String section,
    String? phone,
  }) {
    return _repository.completeProfile(
      regNo: regNo,
      batch: batch,
      section: section,
      phone: phone,
    );
  }
}

class LogoutUseCase {
  final AuthRepository _repository;

  LogoutUseCase(this._repository);

  Future<Result<void>> call() {
    return _repository.logout();
  }
}
