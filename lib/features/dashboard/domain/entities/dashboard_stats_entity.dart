import 'package:equatable/equatable.dart';

class DashboardStatsEntity extends Equatable {
  final int totalComplaints;
  final int pendingComplaints;
  final int inReviewComplaints;
  final int resolvedComplaints;
  final int rejectedComplaints;
  final int forwardedComplaints;
  final int activeNotices;
  final int totalStudents;
  final int totalStaff;

  const DashboardStatsEntity({
    this.totalComplaints = 0,
    this.pendingComplaints = 0,
    this.inReviewComplaints = 0,
    this.resolvedComplaints = 0,
    this.rejectedComplaints = 0,
    this.forwardedComplaints = 0,
    this.activeNotices = 0,
    this.totalStudents = 0,
    this.totalStaff = 0,
  });

  @override
  List<Object?> get props => [
        totalComplaints,
        pendingComplaints,
        inReviewComplaints,
        resolvedComplaints,
        rejectedComplaints,
        forwardedComplaints,
        activeNotices,
        totalStudents,
        totalStaff,
      ];
}
