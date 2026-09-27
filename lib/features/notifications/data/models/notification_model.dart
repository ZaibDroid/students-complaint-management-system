import '../../domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.title,
    required super.message,
    super.type,
    super.referenceId,
    super.isRead = false,
    required super.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? json['data']?['title'] ?? 'Notification',
      message: json['message'] ?? json['data']?['message'] ?? json['body'] ?? '',
      type: json['type'] ?? json['data']?['type'],
      referenceId: json['reference_id']?.toString() ?? json['data']?['reference_id']?.toString(),
      isRead: json['read_at'] != null || json['is_read'] == true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'reference_id': referenceId,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
