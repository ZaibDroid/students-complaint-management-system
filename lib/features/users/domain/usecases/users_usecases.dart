import '../../../../core/utils/result.dart';
import '../../../../shared/enums/user_role.dart';
import '../entities/user_management_entity.dart';
import '../repositories/users_repository.dart';

class GetUsersUseCase {
  final UsersRepository _repository;
  GetUsersUseCase(this._repository);

  Future<Result<List<UserManagementEntity>>> call({String? search, UserRole? role}) {
    return _repository.getUsers(search: search, role: role);
  }
}

class UpdateUserRoleUseCase {
  final UsersRepository _repository;
  UpdateUserRoleUseCase(this._repository);

  Future<Result<bool>> call({required String userId, required UserRole role}) {
    return _repository.updateUserRole(userId: userId, role: role);
  }
}
