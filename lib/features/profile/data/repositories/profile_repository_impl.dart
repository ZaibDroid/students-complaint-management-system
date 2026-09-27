import 'package:student_complaint_managment_system/core/utils/result.dart';
import 'package:student_complaint_managment_system/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:student_complaint_managment_system/features/profile/domain/entities/profile_entity.dart';
import 'package:student_complaint_managment_system/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remoteDataSource;

  ProfileRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<ProfileEntity>> getProfile() {
    return _remoteDataSource.getProfile();
  }

  @override
  Future<Result<ProfileEntity>> updateProfile({
    required String fullName,
    String? phone,
    String? batch,
    String? section,
  }) {
    return _remoteDataSource.updateProfile(
      fullName: fullName,
      phone: phone,
      batch: batch,
      section: section,
    );
  }

  @override
  Future<Result<bool>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    return _remoteDataSource.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}
