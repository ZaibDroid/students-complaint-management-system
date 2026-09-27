import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Workflow Status of a Complaint
enum ComplaintStatus {
  submitted,
  underReview,
  forwardedToAdviser,
  forwardedToCoordinator,
  forwardedToChairman,
  forwardedToOffice,
  forwardedToDean,
  returned,
  resolved,
  rejected;

  String get displayName {
    switch (this) {
      case ComplaintStatus.submitted:
        return 'Submitted';
      case ComplaintStatus.underReview:
        return 'Under Review';
      case ComplaintStatus.forwardedToAdviser:
        return 'With Batch Adviser';
      case ComplaintStatus.forwardedToCoordinator:
        return 'With Coordinator';
      case ComplaintStatus.forwardedToChairman:
        return 'With Chairman';
      case ComplaintStatus.forwardedToOffice:
        return 'With Office Staff';
      case ComplaintStatus.forwardedToDean:
        return 'With Dean';
      case ComplaintStatus.returned:
        return 'Returned';
      case ComplaintStatus.resolved:
        return 'Resolved';
      case ComplaintStatus.rejected:
        return 'Rejected';
    }
  }

  String get value {
    switch (this) {
      case ComplaintStatus.submitted:
        return 'submitted';
      case ComplaintStatus.underReview:
        return 'under_review';
      case ComplaintStatus.forwardedToAdviser:
        return 'forwarded_to_adviser';
      case ComplaintStatus.forwardedToCoordinator:
        return 'forwarded_to_coordinator';
      case ComplaintStatus.forwardedToChairman:
        return 'forwarded_to_chairman';
      case ComplaintStatus.forwardedToOffice:
        return 'forwarded_to_office';
      case ComplaintStatus.forwardedToDean:
        return 'forwarded_to_dean';
      case ComplaintStatus.returned:
        return 'returned';
      case ComplaintStatus.resolved:
        return 'resolved';
      case ComplaintStatus.rejected:
        return 'rejected';
    }
  }

  Color get color {
    switch (this) {
      case ComplaintStatus.submitted:
        return AppColors.statusPending;
      case ComplaintStatus.underReview:
        return AppColors.statusInReview;
      case ComplaintStatus.forwardedToAdviser:
      case ComplaintStatus.forwardedToCoordinator:
      case ComplaintStatus.forwardedToChairman:
      case ComplaintStatus.forwardedToOffice:
      case ComplaintStatus.forwardedToDean:
        return AppColors.statusForwarded;
      case ComplaintStatus.returned:
        return AppColors.statusReturned;
      case ComplaintStatus.resolved:
        return AppColors.statusResolved;
      case ComplaintStatus.rejected:
        return AppColors.statusRejected;
    }
  }

  Color get backgroundColor {
    switch (this) {
      case ComplaintStatus.submitted:
        return AppColors.statusPendingLight;
      case ComplaintStatus.underReview:
        return AppColors.statusInReviewLight;
      case ComplaintStatus.forwardedToAdviser:
      case ComplaintStatus.forwardedToCoordinator:
      case ComplaintStatus.forwardedToChairman:
      case ComplaintStatus.forwardedToOffice:
      case ComplaintStatus.forwardedToDean:
        return AppColors.statusForwardedLight;
      case ComplaintStatus.returned:
        return AppColors.statusReturnedLight;
      case ComplaintStatus.resolved:
        return AppColors.statusResolvedLight;
      case ComplaintStatus.rejected:
        return AppColors.statusRejectedLight;
    }
  }

  static ComplaintStatus fromString(String? status) {
    if (status == null) return ComplaintStatus.submitted;
    switch (status.toLowerCase()) {
      case 'under_review':
        return ComplaintStatus.underReview;
      case 'forwarded_to_adviser':
        return ComplaintStatus.forwardedToAdviser;
      case 'forwarded_to_coordinator':
        return ComplaintStatus.forwardedToCoordinator;
      case 'forwarded_to_chairman':
        return ComplaintStatus.forwardedToChairman;
      case 'forwarded_to_office':
        return ComplaintStatus.forwardedToOffice;
      case 'forwarded_to_dean':
        return ComplaintStatus.forwardedToDean;
      case 'returned':
        return ComplaintStatus.returned;
      case 'resolved':
        return ComplaintStatus.resolved;
      case 'rejected':
        return ComplaintStatus.rejected;
      case 'submitted':
      case 'pending':
      default:
        return ComplaintStatus.submitted;
    }
  }

  bool get isTerminal => this == ComplaintStatus.resolved || this == ComplaintStatus.rejected;
}
