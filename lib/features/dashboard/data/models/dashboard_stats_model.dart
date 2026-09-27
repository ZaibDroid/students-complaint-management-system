import '../../domain/entities/dashboard_stats_entity.dart';

class DashboardStatsModel extends DashboardStatsEntity {
  const DashboardStatsModel({
    super.totalComplaints,
    super.pendingComplaints,
    super.inReviewComplaints,
    super.resolvedComplaints,
    super.rejectedComplaints,
    super.forwardedComplaints,
    super.activeNotices,
    super.totalStudents,
    super.totalStaff,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      totalComplaints: json['total_complaints'] ?? json['total'] ?? 0,
      pendingComplaints: json['pending_complaints'] ?? json['pending'] ?? 0,
      inReviewComplaints: json['in_review_complaints'] ?? json['in_review'] ?? 0,
      resolvedComplaints: json['resolved_complaints'] ?? json['resolved'] ?? 0,
      rejectedComplaints: json['rejected_complaints'] ?? json['rejected'] ?? 0,
      forwardedComplaints: json['forwarded_complaints'] ?? json['forwarded'] ?? 0,
      activeNotices: json['active_notices'] ?? json['notices_count'] ?? 0,
      totalStudents: json['total_students'] ?? 0,
      totalStaff: json['total_staff'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_complaints': totalComplaints,
      'pending_complaints': pendingComplaints,
      'in_review_complaints': inReviewComplaints,
      'resolved_complaints': resolvedComplaints,
      'rejected_complaints': rejectedComplaints,
      'forwarded_complaints': forwardedComplaints,
      'active_notices': activeNotices,
      'total_students': totalStudents,
      'total_staff': totalStaff,
    };
  }
}
