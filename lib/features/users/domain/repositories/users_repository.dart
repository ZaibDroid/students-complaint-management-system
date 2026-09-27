import '../../../../core/utils/result.dart';
import '../../../../shared/enums/user_role.dart';
import '../entities/user_management_entity.dart';

abstract class UsersRepository {
  Future<Result<List<UserManagementEntity>>> getUsers({String? search, UserRole? role});
  Future<Result<bool>> updateUserRole({required String userId, required UserRole role});
}
