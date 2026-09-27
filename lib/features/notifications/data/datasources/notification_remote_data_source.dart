import 'package:student_complaint_managment_system/core/constants/api_endpoints.dart';
import 'package:student_complaint_managment_system/core/services/api_service.dart';
import 'package:student_complaint_managment_system/core/utils/result.dart';
import 'package:student_complaint_managment_system/features/notifications/data/models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<Result<List<NotificationModel>>> getNotifications();
  Future<Result<void>> markAsRead(String id);
  Future<Result<void>> markAllAsRead();
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final ApiService _apiService;

  NotificationRemoteDataSourceImpl(this._apiService);

  @override
  Future<Result<List<NotificationModel>>> getNotifications() async {
    final result = await _apiService.get(ApiEndpoints.notifications);

    return result.when(
      onSuccess: (data) {
        final rawList = data is Map && data.containsKey('data')
            ? data['data'] as List
            : (data is List ? data : []);
        final items = rawList
            .whereType<Map<String, dynamic>>()
            .map((json) => NotificationModel.fromJson(json))
            .toList();
        return Result.success(items);
      },
      onError: (failure) => Result.error(failure),
    );
  }

  @override
  Future<Result<void>> markAsRead(String id) async {
    final path = ApiEndpoints.markNotificationAsRead.replaceAll('{id}', id);
    final result = await _apiService.post(path);
    return result.when(
      onSuccess: (_) => Result.success(null),
      onError: (failure) => Result.error(failure),
    );
  }

  @override
  Future<Result<void>> markAllAsRead() async {
    final result = await _apiService.post(ApiEndpoints.markAllNotificationsRead);
    return result.when(
      onSuccess: (_) => Result.success(null),
      onError: (failure) => Result.error(failure),
    );
  }
}
