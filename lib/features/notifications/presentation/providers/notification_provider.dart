import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_complaint_managment_system/features/auth/presentation/providers/auth_provider.dart';
import 'package:student_complaint_managment_system/features/notifications/data/datasources/notification_remote_data_source.dart';
import 'package:student_complaint_managment_system/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:student_complaint_managment_system/features/notifications/domain/entities/notification_entity.dart';
import 'package:student_complaint_managment_system/features/notifications/domain/repositories/notification_repository.dart';
import 'package:student_complaint_managment_system/features/notifications/domain/usecases/notification_usecases.dart';

final notificationRemoteDataSourceProvider = Provider<NotificationRemoteDataSource>((ref) {
  final api = ref.watch(apiServiceProvider);
  return NotificationRemoteDataSourceImpl(api);
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final remote = ref.watch(notificationRemoteDataSourceProvider);
  return NotificationRepositoryImpl(remote);
});

final getNotificationsUseCaseProvider = Provider<GetNotificationsUseCase>((ref) {
  return GetNotificationsUseCase(ref.watch(notificationRepositoryProvider));
});

final markNotificationReadUseCaseProvider = Provider<MarkNotificationReadUseCase>((ref) {
  return MarkNotificationReadUseCase(ref.watch(notificationRepositoryProvider));
});

final markAllNotificationsReadUseCaseProvider = Provider<MarkAllNotificationsReadUseCase>((ref) {
  return MarkAllNotificationsReadUseCase(ref.watch(notificationRepositoryProvider));
});

class NotificationState {
  final bool isLoading;
  final List<NotificationEntity> notifications;
  final String? errorMessage;

  const NotificationState({
    this.isLoading = false,
    this.notifications = const [],
    this.errorMessage,
  });

  NotificationState copyWith({
    bool? isLoading,
    List<NotificationEntity>? notifications,
    String? errorMessage,
    bool clearError = false,
  }) {
    return NotificationState(
      isLoading: isLoading ?? this.isLoading,
      notifications: notifications ?? this.notifications,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  int get unreadCount => notifications.where((n) => !n.isRead).length;
}

class NotificationNotifier extends StateNotifier<NotificationState> {
  final GetNotificationsUseCase _getNotificationsUseCase;
  final MarkNotificationReadUseCase _markReadUseCase;
  final MarkAllNotificationsReadUseCase _markAllReadUseCase;

  NotificationNotifier(
    this._getNotificationsUseCase,
    this._markReadUseCase,
    this._markAllReadUseCase,
  ) : super(const NotificationState()) {
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _getNotificationsUseCase();

    result.when(
      onSuccess: (notifications) {
        state = state.copyWith(isLoading: false, notifications: notifications, clearError: true);
      },
      onError: (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
    );
  }

  Future<void> markAsRead(String id) async {
    await _markReadUseCase(id);
    final updated = state.notifications.map((n) {
      if (n.id == id) {
        return NotificationEntity(
          id: n.id,
          title: n.title,
          message: n.message,
          type: n.type,
          referenceId: n.referenceId,
          isRead: true,
          createdAt: n.createdAt,
        );
      }
      return n;
    }).toList();

    state = state.copyWith(notifications: updated);
  }

  Future<void> markAllAsRead() async {
    await _markAllReadUseCase();
    final updated = state.notifications.map((n) {
      return NotificationEntity(
        id: n.id,
        title: n.title,
        message: n.message,
        type: n.type,
        referenceId: n.referenceId,
        isRead: true,
        createdAt: n.createdAt,
      );
    }).toList();

    state = state.copyWith(notifications: updated);
  }
}

final notificationProvider = StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  return NotificationNotifier(
    ref.watch(getNotificationsUseCaseProvider),
    ref.watch(markNotificationReadUseCaseProvider),
    ref.watch(markAllNotificationsReadUseCaseProvider),
  );
});
