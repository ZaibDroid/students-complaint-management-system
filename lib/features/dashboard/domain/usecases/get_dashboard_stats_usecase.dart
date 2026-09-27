import 'package:student_complaint_managment_system/core/utils/result.dart';
import 'package:student_complaint_managment_system/features/dashboard/domain/entities/dashboard_stats_entity.dart';
import 'package:student_complaint_managment_system/features/dashboard/domain/repositories/dashboard_repository.dart';

class GetDashboardStatsUseCase {
  final DashboardRepository _repository;

  GetDashboardStatsUseCase(this._repository);

  Future<Result<DashboardStatsEntity>> call() {
    return _repository.getStats();
  }
}
