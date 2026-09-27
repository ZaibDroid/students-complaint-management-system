import 'package:student_complaint_managment_system/core/utils/result.dart';
import 'package:student_complaint_managment_system/features/notifications/domain/entities/notification_entity.dart';
import 'package:student_complaint_managment_system/features/notifications/domain/repositories/notification_repository.dart';

class GetNotificationsUseCase {
  final NotificationRepository _repository;
  GetNotificationsUseCase(this._repository);

  Future<Result<List<NotificationEntity>>> call() {
    return _repository.getNotifications();
  }
}

class MarkNotificationReadUseCase {
  final NotificationRepository _repository;
  MarkNotificationReadUseCase(this._repository);

  Future<Result<void>> call(String id) {
    return _repository.markAsRead(id);
  }
}

class MarkAllNotificationsReadUseCase {
  final NotificationRepository _repository;
  MarkAllNotificationsReadUseCase(this._repository);

  Future<Result<void>> call() {
    return _repository.markAllAsRead();
  }
}
