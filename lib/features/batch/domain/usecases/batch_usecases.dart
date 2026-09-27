import 'package:student_complaint_managment_system/core/utils/result.dart';
import 'package:student_complaint_managment_system/features/batch/domain/entities/batch_entity.dart';
import 'package:student_complaint_managment_system/features/batch/domain/repositories/batch_repository.dart';

class GetBatchesUseCase {
  final BatchRepository _repository;
  GetBatchesUseCase(this._repository);

  Future<Result<List<BatchEntity>>> call() => _repository.getBatches();
}

class RequestAdviserUseCase {
  final BatchRepository _repository;
  RequestAdviserUseCase(this._repository);

  Future<Result<bool>> call({required String reason}) => _repository.requestAdviser(reason: reason);
}
