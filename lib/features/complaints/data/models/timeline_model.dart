import '../../../../shared/enums/complaint_status.dart';
import '../../domain/entities/timeline_entity.dart';

class TimelineModel extends TimelineEntity {
  const TimelineModel({
    required super.id,
    required super.title,
    required super.actorName,
    required super.actorRole,
    required super.status,
    super.remarks,
    required super.timestamp,
  });

  factory TimelineModel.fromJson(Map<String, dynamic> json) {
    return TimelineModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? json['action'] ?? 'Status Update',
      actorName: json['actor_name'] ?? json['user_name'] ?? 'Staff',
      actorRole: json['actor_role'] ?? json['role'] ?? 'Authority',
      status: ComplaintStatus.fromString(json['status']?.toString()),
      remarks: json['remarks'] ?? json['comment'],
      timestamp: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'actor_name': actorName,
      'actor_role': actorRole,
      'status': status.value,
      'remarks': remarks,
      'created_at': timestamp.toIso8601String(),
    };
  }
}
