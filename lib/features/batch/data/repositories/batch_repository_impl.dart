import 'package:student_complaint_managment_system/core/utils/result.dart';
import 'package:student_complaint_managment_system/features/batch/data/datasources/batch_remote_data_source.dart';
import 'package:student_complaint_managment_system/features/batch/domain/entities/batch_entity.dart';
import 'package:student_complaint_managment_system/features/batch/domain/repositories/batch_repository.dart';

class BatchRepositoryImpl implements BatchRepository {
  final BatchRemoteDataSource _remoteDataSource;

  BatchRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<List<BatchEntity>>> getBatches() {
    return _remoteDataSource.getBatches();
  }

  @override
  Future<Result<bool>> requestAdviser({required String reason}) {
    return _remoteDataSource.requestAdviser(reason: reason);
  }
}
