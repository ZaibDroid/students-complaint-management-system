import 'package:student_complaint_managment_system/core/utils/result.dart';
import 'package:student_complaint_managment_system/features/notifications/data/datasources/notification_remote_data_source.dart';
import 'package:student_complaint_managment_system/features/notifications/domain/entities/notification_entity.dart';
import 'package:student_complaint_managment_system/features/notifications/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource _remoteDataSource;

  NotificationRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<List<NotificationEntity>>> getNotifications() {
    return _remoteDataSource.getNotifications();
  }

  @override
  Future<Result<void>> markAsRead(String id) {
    return _remoteDataSource.markAsRead(id);
  }

  @override
  Future<Result<void>> markAllAsRead() {
    return _remoteDataSource.markAllAsRead();
  }
}
