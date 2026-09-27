import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/utils/result.dart';
import '../../../../shared/enums/user_role.dart';
import '../models/user_management_model.dart';

abstract class UsersRemoteDataSource {
  Future<Result<List<UserManagementModel>>> getUsers({String? search, UserRole? role});
  Future<Result<bool>> updateUserRole({required String userId, required UserRole role});
}

class UsersRemoteDataSourceImpl implements UsersRemoteDataSource {
  final ApiService _apiService;

  UsersRemoteDataSourceImpl(this._apiService);

  @override
  Future<Result<List<UserManagementModel>>> getUsers({String? search, UserRole? role}) async {
    final queryParams = <String, dynamic>{
      if (search != null && search.isNotEmpty) 'search': search,
      if (role != null) 'role': role.value,
    };

    final result = await _apiService.get(ApiEndpoints.adminUsers, queryParameters: queryParams);

    return result.when(
      onSuccess: (data) {
        final rawList = data is Map && data.containsKey('data')
            ? data['data'] as List
            : (data is List ? data : []);
        final items = rawList
            .whereType<Map<String, dynamic>>()
            .map((e) => UserManagementModel.fromJson(e))
            .toList();
        return Result.success(items);
      },
      onError: (failure) => Result.error(failure),
    );
  }

  @override
  Future<Result<bool>> updateUserRole({required String userId, required UserRole role}) async {
    final path = ApiEndpoints.updateUserRole.replaceAll('{id}', userId);
    final result = await _apiService.put(path, data: {'role': role.value});

    return result.when(
      onSuccess: (_) => Result.success(true),
      onError: (failure) => Result.error(failure),
    );
  }
}
