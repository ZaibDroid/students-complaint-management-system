import 'package:equatable/equatable.dart';
import '../../../../shared/enums/complaint_status.dart';

class TimelineEntity extends Equatable {
  final String id;
  final String title;
  final String actorName;
  final String actorRole;
  final ComplaintStatus status;
  final String? remarks;
  final DateTime timestamp;

  const TimelineEntity({
    required this.id,
    required this.title,
    required this.actorName,
    required this.actorRole,
    required this.status,
    this.remarks,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, title, actorName, actorRole, status, remarks, timestamp];
}
