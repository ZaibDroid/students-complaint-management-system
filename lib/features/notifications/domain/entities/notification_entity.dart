import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {
  final String id;
  final String title;
  final String message;
  final String? type; // complaint_forwarded, complaint_resolved, complaint_rejected, new_notice
  final String? referenceId;
  final bool isRead;
  final DateTime createdAt;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.message,
    this.type,
    this.referenceId,
    this.isRead = false,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, title, message, type, referenceId, isRead, createdAt];
}
