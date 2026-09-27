import '../../../../core/utils/result.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<Result<UserEntity>> call({
    required String email,
    required String password,
  }) {
    return _repository.login(email: email, password: password);
  }
}
