import '../../../../core/utils/result.dart';
import '../../../../shared/enums/user_role.dart';
import '../../domain/entities/user_management_entity.dart';
import '../../domain/repositories/users_repository.dart';
import '../datasources/users_remote_data_source.dart';

class UsersRepositoryImpl implements UsersRepository {
  final UsersRemoteDataSource _remoteDataSource;

  UsersRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<List<UserManagementEntity>>> getUsers({String? search, UserRole? role}) {
    return _remoteDataSource.getUsers(search: search, role: role);
  }

  @override
  Future<Result<bool>> updateUserRole({required String userId, required UserRole role}) {
    return _remoteDataSource.updateUserRole(userId: userId, role: role);
  }
}
