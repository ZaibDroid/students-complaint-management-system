import 'package:student_complaint_managment_system/core/utils/result.dart';
import 'package:student_complaint_managment_system/features/notifications/domain/entities/notification_entity.dart';

abstract class NotificationRepository {
  Future<Result<List<NotificationEntity>>> getNotifications();
  Future<Result<void>> markAsRead(String id);
  Future<Result<void>> markAllAsRead();
}
