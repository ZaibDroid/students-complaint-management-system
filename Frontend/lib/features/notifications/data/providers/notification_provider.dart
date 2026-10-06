import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../models/notification_model.dart';
import '../repositories/api_notification_repository.dart';

final apiNotificationRepositoryProvider = Provider<ApiNotificationRepository>((ref) {
  return ApiNotificationRepository();
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final apiRepo = ref.watch(apiNotificationRepositoryProvider);
  return NotificationService(apiRepo);
});

final userNotificationsProvider = StreamProvider<List<NotificationModel>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);
  
  final service = ref.watch(notificationServiceProvider);
  return service.getUserNotifications(user.id);
});

final unreadNotificationCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(userNotificationsProvider).value;
  if (notifications == null) return 0;
  return notifications.where((n) => !n.isRead).length;
});

class NotificationService {
  final ApiNotificationRepository _apiRepo;

  NotificationService([ApiNotificationRepository? apiRepo]) : _apiRepo = apiRepo ?? ApiNotificationRepository();

  Stream<List<NotificationModel>> getUserNotifications(String userId) {
    return _apiRepo.streamUserNotifications(userId);
  }

  Future<void> markAsRead(String notificationId) async {
    await _apiRepo.markAsRead(notificationId);
  }

  Future<void> markAllAsRead(String userId) async {
    await _apiRepo.markAllAsRead();
  }

  Future<void> createNotification(NotificationModel notification) async {
    // Notifications are handled automatically on backend events
  }
}
