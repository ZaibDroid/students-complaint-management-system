import 'package:equatable/equatable.dart';
import '../../../../shared/enums/complaint_status.dart';
import '../../../../shared/enums/priority_level.dart';
import '../../../../shared/enums/user_role.dart';
import 'remark_entity.dart';
import 'timeline_entity.dart';

class ComplaintEntity extends Equatable {
  final String id;
  final String trackingNumber;
  final String title;
  final String description;
  final String category;
  final ComplaintStatus status;
  final PriorityLevel priority;
  final String studentId;
  final String studentName;
  final String? studentEmail;
  final String? batch;
  final String? section;
  final UserRole currentHandlerRole;
  final String? currentHandlerName;
  final List<String> attachmentUrls;
  final List<TimelineEntity> timeline;
  final List<RemarkEntity> remarks;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? resolvedAt;

  const ComplaintEntity({
    required this.id,
    required this.trackingNumber,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.priority,
    required this.studentId,
    required this.studentName,
    this.studentEmail,
    this.batch,
    this.section,
    required this.currentHandlerRole,
    this.currentHandlerName,
    this.attachmentUrls = const [],
    this.timeline = const [],
    this.remarks = const [],
    required this.createdAt,
    this.updatedAt,
    this.resolvedAt,
  });

  @override
  List<Object?> get props => [
        id,
        trackingNumber,
        title,
        description,
        category,
        status,
        priority,
        studentId,
        studentName,
        studentEmail,
        batch,
        section,
        currentHandlerRole,
        currentHandlerName,
        attachmentUrls,
        timeline,
        remarks,
        createdAt,
        updatedAt,
        resolvedAt,
      ];
}
