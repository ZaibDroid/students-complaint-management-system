import '../../../../shared/enums/complaint_status.dart';
import '../../../../shared/enums/priority_level.dart';
import '../../../../shared/enums/user_role.dart';
import '../../domain/entities/complaint_entity.dart';
import 'remark_model.dart';
import 'timeline_model.dart';

class ComplaintModel extends ComplaintEntity {
  const ComplaintModel({
    required super.id,
    required super.trackingNumber,
    required super.title,
    required super.description,
    required super.category,
    required super.status,
    required super.priority,
    required super.studentId,
    required super.studentName,
    super.studentEmail,
    super.batch,
    super.section,
    required super.currentHandlerRole,
    super.currentHandlerName,
    super.attachmentUrls,
    super.timeline,
    super.remarks,
    required super.createdAt,
    super.updatedAt,
    super.resolvedAt,
  });

  factory ComplaintModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawAttachments = json['attachments'] is List ? json['attachments'] as List : [];
    final attachmentUrls = rawAttachments.map((e) => e.toString()).toList();

    final List<dynamic> rawTimeline = json['timeline'] is List ? json['timeline'] as List : (json['history'] is List ? json['history'] as List : []);
    final timeline = rawTimeline
        .whereType<Map<String, dynamic>>()
        .map((e) => TimelineModel.fromJson(e))
        .toList();

    final List<dynamic> rawRemarks = json['remarks'] is List ? json['remarks'] as List : [];
    final remarks = rawRemarks
        .whereType<Map<String, dynamic>>()
        .map((e) => RemarkModel.fromJson(e))
        .toList();

    return ComplaintModel(
      id: json['id']?.toString() ?? '',
      trackingNumber: json['tracking_number'] ?? json['ticket_no'] ?? '#CMP-${json['id'] ?? '0000'}',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? 'General',
      status: ComplaintStatus.fromString(json['status']?.toString()),
      priority: PriorityLevel.fromString(json['priority']?.toString()),
      studentId: json['student_id']?.toString() ?? json['user_id']?.toString() ?? '',
      studentName: json['student_name'] ?? json['student']?['name'] ?? 'Student',
      studentEmail: json['student_email'] ?? json['student']?['email'],
      batch: json['batch'] ?? json['student']?['batch'],
      section: json['section'] ?? json['student']?['section'],
      currentHandlerRole: UserRole.fromString(json['current_handler_role']?.toString() ?? json['assigned_role']?.toString()),
      currentHandlerName: json['current_handler_name'] ?? json['assigned_user']?['name'],
      attachmentUrls: attachmentUrls,
      timeline: timeline,
      remarks: remarks,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
      resolvedAt: json['resolved_at'] != null ? DateTime.tryParse(json['resolved_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tracking_number': trackingNumber,
      'title': title,
      'description': description,
      'category': category,
      'status': status.value,
      'priority': priority.value,
      'student_id': studentId,
      'student_name': studentName,
      'student_email': studentEmail,
      'batch': batch,
      'section': section,
      'current_handler_role': currentHandlerRole.value,
      'current_handler_name': currentHandlerName,
      'attachments': attachmentUrls,
      'timeline': timeline.map((e) => (e as TimelineModel).toJson()).toList(),
      'remarks': remarks.map((e) => (e as RemarkModel).toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'resolved_at': resolvedAt?.toIso8601String(),
    };
  }
}
