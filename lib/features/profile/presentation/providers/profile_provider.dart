import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_complaint_managment_system/features/auth/presentation/providers/auth_provider.dart';
import 'package:student_complaint_managment_system/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:student_complaint_managment_system/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:student_complaint_managment_system/features/profile/domain/entities/profile_entity.dart';
import 'package:student_complaint_managment_system/features/profile/domain/repositories/profile_repository.dart';
import 'package:student_complaint_managment_system/features/profile/domain/usecases/profile_usecases.dart';

final profileRemoteDataSourceProvider = Provider<ProfileRemoteDataSource>((ref) {
  final api = ref.watch(apiServiceProvider);
  return ProfileRemoteDataSourceImpl(api);
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final remote = ref.watch(profileRemoteDataSourceProvider);
  return ProfileRepositoryImpl(remote);
});

final getProfileUseCaseProvider = Provider<GetProfileUseCase>((ref) {
  return GetProfileUseCase(ref.watch(profileRepositoryProvider));
});

final updateProfileUseCaseProvider = Provider<UpdateProfileUseCase>((ref) {
  return UpdateProfileUseCase(ref.watch(profileRepositoryProvider));
});

final changePasswordUseCaseProvider = Provider<ChangePasswordUseCase>((ref) {
  return ChangePasswordUseCase(ref.watch(profileRepositoryProvider));
});

class ProfileState {
  final bool isLoading;
  final ProfileEntity? profile;
  final String? errorMessage;
  final bool isSaving;

  const ProfileState({
    this.isLoading = false,
    this.profile,
    this.errorMessage,
    this.isSaving = false,
  });

  ProfileState copyWith({
    bool? isLoading,
    ProfileEntity? profile,
    String? errorMessage,
    bool? isSaving,
    bool clearError = false,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      profile: profile ?? this.profile,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  final GetProfileUseCase _getProfileUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;
  final ChangePasswordUseCase _changePasswordUseCase;

  ProfileNotifier(
    this._getProfileUseCase,
    this._updateProfileUseCase,
    this._changePasswordUseCase,
  ) : super(const ProfileState()) {
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _getProfileUseCase();

    result.when(
      onSuccess: (profile) {
        state = state.copyWith(isLoading: false, profile: profile, clearError: true);
      },
      onError: (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
    );
  }

  Future<bool> updateProfile({
    required String fullName,
    String? phone,
    String? batch,
    String? section,
  }) async {
    state = state.copyWith(isSaving: true, clearError: true);
    final result = await _updateProfileUseCase(
      fullName: fullName,
      phone: phone,
      batch: batch,
      section: section,
    );

    return result.when(
      onSuccess: (updated) {
        state = state.copyWith(isSaving: false, profile: updated);
        return true;
      },
      onError: (failure) {
        state = state.copyWith(isSaving: false, errorMessage: failure.message);
        return false;
      },
    );
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    state = state.copyWith(isSaving: true, clearError: true);
    final result = await _changePasswordUseCase(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );

    return result.when(
      onSuccess: (_) {
        state = state.copyWith(isSaving: false);
        return true;
      },
      onError: (failure) {
        state = state.copyWith(isSaving: false, errorMessage: failure.message);
        return false;
      },
    );
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier(
    ref.watch(getProfileUseCaseProvider),
    ref.watch(updateProfileUseCaseProvider),
    ref.watch(changePasswordUseCaseProvider),
  );
});
