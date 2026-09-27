import 'package:student_complaint_managment_system/core/utils/result.dart';
import 'package:student_complaint_managment_system/features/dashboard/domain/entities/dashboard_stats_entity.dart';

abstract class DashboardRepository {
  Future<Result<DashboardStatsEntity>> getStats();
}
