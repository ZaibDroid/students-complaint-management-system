import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/api_client.dart';
import '../../../../features/auth/domain/entities/user.dart';

final adviserAssignmentRepositoryProvider = Provider<AdviserAssignmentRepository>((ref) {
  return AdviserAssignmentRepository();
});

class AdviserAssignmentRepository {
  final ApiClient _apiClient;

  AdviserAssignmentRepository([ApiClient? apiClient])
      : _apiClient = apiClient ?? ApiClient();

  Stream<List<User>> getBatchAdvisers() async* {
    try {
      final data = await _apiClient.get('/users', queryParams: {'role': 'Batch Adviser'});
      if (data is List) {
        yield data.map((item) => User.fromJson(item as Map<String, dynamic>)).toList();
      } else {
        yield [];
      }
    } catch (_) {
      yield [];
    }
  }

  Future<void> assignAdviser({
    String? adviserId,
    required String semester,
    required String section,
  }) async {
    await _apiClient.post('/users/assign-adviser', body: {
      'adviser_id': ?adviserId,
      'semester': semester,
      'section': section,
    });
  }
}
