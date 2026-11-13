import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/api_client.dart';

final staffAccountsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  try {
    final apiClient = ApiClient();
    final data = await apiClient.get('/users/staff');
    if (data is List) {
      return List<Map<String, dynamic>>.from(data);
    }
    return [];
  } catch (_) {
    return [];
  }
});

