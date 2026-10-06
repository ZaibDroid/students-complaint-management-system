import '../../../../core/services/api_client.dart';
import '../../../../core/config/api_config.dart';
import '../models/notification_model.dart';

class ApiNotificationRepository {
  final ApiClient _apiClient;

  ApiNotificationRepository([ApiClient? apiClient]) : _apiClient = apiClient ?? ApiClient();

  Future<List<NotificationModel>> getNotifications() async {
    final data = await _apiClient.get(ApiConfig.notifications);
    if (data is List) {
      return data
          .map((item) => NotificationModel.fromMap(item as Map<String, dynamic>, (item['id'] ?? '').toString()))
          .toList();
    }
    return [];
  }

  Stream<List<NotificationModel>> streamUserNotifications(String userId) async* {
    final list = await getNotifications();
    yield list;
  }

  Future<int> getUnreadCount() async {
    final data = await _apiClient.get('${ApiConfig.notifications}/unread-count');
    if (data is Map<String, dynamic> && data['unread_count'] != null) {
      return data['unread_count'] as int;
    }
    return 0;
  }

  Future<void> markAsRead(String notificationId) async {
    await _apiClient.put('${ApiConfig.notifications}/$notificationId/read');
  }

  Future<void> markAllAsRead() async {
    await _apiClient.put('${ApiConfig.notifications}/read-all');
  }

  Future<void> deleteNotification(String notificationId) async {
    await _apiClient.delete('${ApiConfig.notifications}/$notificationId');
  }
}
