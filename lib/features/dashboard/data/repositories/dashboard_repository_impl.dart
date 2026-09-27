import 'package:student_complaint_managment_system/core/utils/result.dart';
import 'package:student_complaint_managment_system/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:student_complaint_managment_system/features/dashboard/domain/entities/dashboard_stats_entity.dart';
import 'package:student_complaint_managment_system/features/dashboard/domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource _remoteDataSource;

  DashboardRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<DashboardStatsEntity>> getStats() {
    return _remoteDataSource.getStats();
  }
}
