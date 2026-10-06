import '../../../../core/services/api_client.dart';
import '../../../../core/config/api_config.dart';
import '../../domain/entities/batch_model.dart';

class ApiBatchRepository {
  final ApiClient _apiClient;

  ApiBatchRepository([ApiClient? apiClient]) : _apiClient = apiClient ?? ApiClient();

  Future<List<BatchModel>> fetchBatches() async {
    final data = await _apiClient.get(ApiConfig.batches);
    if (data is List) {
      return data.map((item) => BatchModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Stream<List<BatchModel>> getBatches() async* {
    final batches = await fetchBatches();
    yield batches;
  }

  Future<void> addBatch({required String name, required List<String> sections}) async {
    await _apiClient.post(ApiConfig.batches, body: {
      'name': name,
      'sections': sections,
    });
  }

  Future<void> updateBatch(BatchModel batch) async {
    await _apiClient.put('${ApiConfig.batches}/${batch.id}', body: batch.toJson());
  }

  Future<void> deleteBatch(String id) async {
    await _apiClient.delete('${ApiConfig.batches}/$id');
  }
}
