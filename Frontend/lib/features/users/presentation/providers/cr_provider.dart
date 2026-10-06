import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/api_client.dart';
import '../../../auth/domain/entities/user.dart';

final crListProvider = FutureProvider<List<User>>((ref) async {
  try {
    final apiClient = ApiClient();
    final data = await apiClient.get('/crs');
    if (data is List) {
      return data.map((item) => User.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  } catch (_) {
    return [];
  }
});
