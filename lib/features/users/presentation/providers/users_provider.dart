import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_complaint_managment_system/features/auth/presentation/providers/auth_provider.dart';
import 'package:student_complaint_managment_system/features/users/data/datasources/users_remote_data_source.dart';
import 'package:student_complaint_managment_system/features/users/data/repositories/users_repository_impl.dart';
import 'package:student_complaint_managment_system/features/users/domain/entities/user_management_entity.dart';
import 'package:student_complaint_managment_system/features/users/domain/repositories/users_repository.dart';
import 'package:student_complaint_managment_system/features/users/domain/usecases/users_usecases.dart';
import 'package:student_complaint_managment_system/shared/enums/user_role.dart';

final usersRemoteDataSourceProvider = Provider<UsersRemoteDataSource>((ref) {
  final api = ref.watch(apiServiceProvider);
  return UsersRemoteDataSourceImpl(api);
});

final usersRepositoryProvider = Provider<UsersRepository>((ref) {
  final remote = ref.watch(usersRemoteDataSourceProvider);
  return UsersRepositoryImpl(remote);
});

final getUsersUseCaseProvider = Provider<GetUsersUseCase>((ref) {
  return GetUsersUseCase(ref.watch(usersRepositoryProvider));
});

final updateUserRoleUseCaseProvider = Provider<UpdateUserRoleUseCase>((ref) {
  return UpdateUserRoleUseCase(ref.watch(usersRepositoryProvider));
});

class UsersState {
  final bool isLoading;
  final List<UserManagementEntity> users;
  final String? errorMessage;
  final String searchQuery;
  final UserRole? selectedRole;

  const UsersState({
    this.isLoading = false,
    this.users = const [],
    this.errorMessage,
    this.searchQuery = '',
    this.selectedRole,
  });

  UsersState copyWith({
    bool? isLoading,
    List<UserManagementEntity>? users,
    String? errorMessage,
    String? searchQuery,
    UserRole? selectedRole,
    bool clearError = false,
    bool clearRole = false,
  }) {
    return UsersState(
      isLoading: isLoading ?? this.isLoading,
      users: users ?? this.users,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      searchQuery: searchQuery ?? this.searchQuery,
      selectedRole: clearRole ? null : (selectedRole ?? this.selectedRole),
    );
  }
}

class UsersNotifier extends StateNotifier<UsersState> {
  final GetUsersUseCase _getUsersUseCase;
  final UpdateUserRoleUseCase _updateUserRoleUseCase;

  UsersNotifier(
    this._getUsersUseCase,
    this._updateUserRoleUseCase,
  ) : super(const UsersState()) {
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _getUsersUseCase(search: state.searchQuery, role: state.selectedRole);

    result.when(
      onSuccess: (users) {
        state = state.copyWith(isLoading: false, users: users, clearError: true);
      },
      onError: (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
    );
  }

  void search(String query) {
    state = state.copyWith(searchQuery: query);
    fetchUsers();
  }

  void filterByRole(UserRole? role) {
    state = state.copyWith(selectedRole: role, clearRole: role == null);
    fetchUsers();
  }

  Future<bool> updateRole(String userId, UserRole role) async {
    final result = await _updateUserRoleUseCase(userId: userId, role: role);
    return result.when(
      onSuccess: (_) {
        fetchUsers();
        return true;
      },
      onError: (failure) => false,
    );
  }
}

final usersProvider = StateNotifierProvider<UsersNotifier, UsersState>((ref) {
  return UsersNotifier(
    ref.watch(getUsersUseCaseProvider),
    ref.watch(updateUserRoleUseCaseProvider),
  );
});
