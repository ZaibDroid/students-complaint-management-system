import 'package:student_complaint_managment_system/core/utils/result.dart';
import 'package:student_complaint_managment_system/features/profile/domain/entities/profile_entity.dart';

abstract class ProfileRepository {
  Future<Result<ProfileEntity>> getProfile();
  Future<Result<ProfileEntity>> updateProfile({
    required String fullName,
    String? phone,
    String? batch,
    String? section,
  });
  Future<Result<bool>> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}
