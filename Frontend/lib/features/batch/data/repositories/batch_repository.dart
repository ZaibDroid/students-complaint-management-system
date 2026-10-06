import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/batch_model.dart';
import 'api_batch_repository.dart';

final batchRepositoryProvider = Provider<BatchRepository>((ref) {
  return BatchRepository();
});

class BatchRepository {
  final ApiBatchRepository _apiRepository;

  BatchRepository([ApiBatchRepository? apiRepository]) : _apiRepository = apiRepository ?? ApiBatchRepository();

  Stream<List<BatchModel>> getBatches() {
    return _apiRepository.getBatches();
  }

  Future<void> addBatch({required String name, required List<String> sections}) async {
    await _apiRepository.addBatch(name: name, sections: sections);
  }

  Future<void> updateBatch(BatchModel batch) async {
    await _apiRepository.updateBatch(batch);
  }

  Future<void> deleteBatch(String id) async {
    await _apiRepository.deleteBatch(id);
  }
}
