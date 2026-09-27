import 'package:student_complaint_managment_system/core/constants/api_endpoints.dart';
import 'package:student_complaint_managment_system/core/services/api_service.dart';
import 'package:student_complaint_managment_system/core/utils/result.dart';
import 'package:student_complaint_managment_system/features/profile/data/models/profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<Result<ProfileModel>> getProfile();
  Future<Result<ProfileModel>> updateProfile({
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

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiService _apiService;

  ProfileRemoteDataSourceImpl(this._apiService);

  @override
  Future<Result<ProfileModel>> getProfile() async {
    final result = await _apiService.get(ApiEndpoints.currentUser);
    return result.when(
      onSuccess: (data) {
        final userData = data is Map && data.containsKey('data')
            ? data['data']
            : (data is Map && data.containsKey('user') ? data['user'] : data);
        return Result.success(ProfileModel.fromJson(userData as Map<String, dynamic>));
      },
      onError: (failure) => Result.error(failure),
    );
  }

  @override
  Future<Result<ProfileModel>> updateProfile({
    required String fullName,
    String? phone,
    String? batch,
    String? section,
  }) async {
    final result = await _apiService.put(
      ApiEndpoints.currentUser,
      data: {
        'name': fullName,
        if (phone != null) 'phone': phone,
        if (batch != null) 'batch': batch,
        if (section != null) 'section': section,
      },
    );

    return result.when(
      onSuccess: (data) {
        final userData = data is Map && data.containsKey('data')
            ? data['data']
            : (data is Map && data.containsKey('user') ? data['user'] : data);
        return Result.success(ProfileModel.fromJson(userData as Map<String, dynamic>));
      },
      onError: (failure) => Result.error(failure),
    );
  }

  @override
  Future<Result<bool>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final result = await _apiService.post(
      '${ApiEndpoints.currentUser}/change-password',
      data: {
        'current_password': currentPassword,
        'new_password': newPassword,
      },
    );

    return result.when(
      onSuccess: (_) => Result.success(true),
      onError: (failure) => Result.error(failure),
    );
  }
}
