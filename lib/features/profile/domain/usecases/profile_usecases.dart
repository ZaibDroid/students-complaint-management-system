import 'package:student_complaint_managment_system/core/utils/result.dart';
import 'package:student_complaint_managment_system/features/profile/domain/entities/profile_entity.dart';
import 'package:student_complaint_managment_system/features/profile/domain/repositories/profile_repository.dart';

class GetProfileUseCase {
  final ProfileRepository _repository;
  GetProfileUseCase(this._repository);

  Future<Result<ProfileEntity>> call() => _repository.getProfile();
}

class UpdateProfileUseCase {
  final ProfileRepository _repository;
  UpdateProfileUseCase(this._repository);

  Future<Result<ProfileEntity>> call({
    required String fullName,
    String? phone,
    String? batch,
    String? section,
  }) {
    return _repository.updateProfile(
      fullName: fullName,
      phone: phone,
      batch: batch,
      section: section,
    );
  }
}

class ChangePasswordUseCase {
  final ProfileRepository _repository;
  ChangePasswordUseCase(this._repository);

  Future<Result<bool>> call({
    required String currentPassword,
    required String newPassword,
  }) {
    return _repository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}
