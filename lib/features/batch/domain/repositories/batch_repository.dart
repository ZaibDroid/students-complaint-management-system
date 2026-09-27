import 'package:student_complaint_managment_system/core/utils/result.dart';
import 'package:student_complaint_managment_system/features/batch/domain/entities/batch_entity.dart';

abstract class BatchRepository {
  Future<Result<List<BatchEntity>>> getBatches();
  Future<Result<bool>> requestAdviser({required String reason});
}
