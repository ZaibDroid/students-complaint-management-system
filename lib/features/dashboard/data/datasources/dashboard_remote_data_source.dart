import 'package:student_complaint_managment_system/core/constants/api_endpoints.dart';
import 'package:student_complaint_managment_system/core/services/api_service.dart';
import 'package:student_complaint_managment_system/core/utils/result.dart';
import 'package:student_complaint_managment_system/features/dashboard/data/models/dashboard_stats_model.dart';

abstract class DashboardRemoteDataSource {
  Future<Result<DashboardStatsModel>> getStats();
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final ApiService _apiService;

  DashboardRemoteDataSourceImpl(this._apiService);

  @override
  Future<Result<DashboardStatsModel>> getStats() async {
    final result = await _apiService.get(ApiEndpoints.dashboardStats);

    return result.when(
      onSuccess: (data) {
        final statsData = data is Map && data.containsKey('data') ? data['data'] : data;
        if (statsData is Map<String, dynamic>) {
          return Result.success(DashboardStatsModel.fromJson(statsData));
        }
        return Result.success(const DashboardStatsModel());
      },
      onError: (failure) => Result.error(failure),
    );
  }
}
