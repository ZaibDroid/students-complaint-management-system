import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_complaint_managment_system/features/auth/presentation/providers/auth_provider.dart';
import 'package:student_complaint_managment_system/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:student_complaint_managment_system/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:student_complaint_managment_system/features/dashboard/domain/entities/dashboard_stats_entity.dart';
import 'package:student_complaint_managment_system/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:student_complaint_managment_system/features/dashboard/domain/usecases/get_dashboard_stats_usecase.dart';

final dashboardRemoteDataSourceProvider = Provider<DashboardRemoteDataSource>((ref) {
  final api = ref.watch(apiServiceProvider);
  return DashboardRemoteDataSourceImpl(api);
});

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final remote = ref.watch(dashboardRemoteDataSourceProvider);
  return DashboardRepositoryImpl(remote);
});

final getDashboardStatsUseCaseProvider = Provider<GetDashboardStatsUseCase>((ref) {
  return GetDashboardStatsUseCase(ref.watch(dashboardRepositoryProvider));
});

class DashboardState {
  final bool isLoading;
  final DashboardStatsEntity stats;
  final String? errorMessage;

  const DashboardState({
    this.isLoading = false,
    this.stats = const DashboardStatsEntity(),
    this.errorMessage,
  });

  DashboardState copyWith({
    bool? isLoading,
    DashboardStatsEntity? stats,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      stats: stats ?? this.stats,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  final GetDashboardStatsUseCase _getStatsUseCase;

  DashboardNotifier(this._getStatsUseCase) : super(const DashboardState()) {
    fetchStats();
  }

  Future<void> fetchStats() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _getStatsUseCase();

    result.when(
      onSuccess: (stats) {
        state = state.copyWith(isLoading: false, stats: stats, clearError: true);
      },
      onError: (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
    );
  }
}

final dashboardProvider = StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  return DashboardNotifier(ref.watch(getDashboardStatsUseCaseProvider));
});
