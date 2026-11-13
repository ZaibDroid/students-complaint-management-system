import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/api_client.dart';
import '../../../auth/domain/entities/user.dart';

final coordinatorsStreamProvider = FutureProvider.autoDispose<List<User>>((ref) async {
  try {
    final apiClient = ApiClient();
    final data = await apiClient.get('/users', queryParams: {
      'role': 'Coordinator',
      'per_page': '100',
    });
    if (data is List) {
      return data.map((item) => User.fromJson(item as Map<String, dynamic>)).toList();
    } else {
      return [];
    }
  } catch (_) {
    return [];
  }
});
