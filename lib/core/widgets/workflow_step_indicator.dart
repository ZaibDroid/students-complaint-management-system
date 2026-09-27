import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../../shared/enums/complaint_status.dart';

/// Reusable Stepped Visual Workflow Progress Indicator
class WorkflowStepIndicator extends StatelessWidget {
  final ComplaintStatus currentStatus;

  const WorkflowStepIndicator({
    super.key,
    required this.currentStatus,
  });

  @override
  Widget build(BuildContext context) {
    final steps = [
      {'label': 'Lodge', 'sub': 'Student'},
      {'label': 'Adviser', 'sub': 'Review'},
      {'label': 'Coord.', 'sub': 'Review'},
      {'label': 'Chairman', 'sub': 'Decision'},
      {'label': 'Resolved', 'sub': 'Closed'},
    ];

    int activeIndex = 0;
    switch (currentStatus) {
      case ComplaintStatus.submitted:
        activeIndex = 0;
        break;
      case ComplaintStatus.underReview:
      case ComplaintStatus.forwardedToAdviser:
        activeIndex = 1;
        break;
      case ComplaintStatus.forwardedToCoordinator:
        activeIndex = 2;
        break;
      case ComplaintStatus.forwardedToChairman:
      case ComplaintStatus.forwardedToOffice:
      case ComplaintStatus.forwardedToDean:
        activeIndex = 3;
        break;
      case ComplaintStatus.resolved:
        activeIndex = 4;
        break;
      case ComplaintStatus.rejected:
      case ComplaintStatus.returned:
        activeIndex = 1;
        break;
    }

    final isRejected = currentStatus == ComplaintStatus.rejected;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(steps.length * 2 - 1, (index) {
          if (index.isOdd) {
            final stepIdx = index ~/ 2;
            final isPassed = stepIdx < activeIndex;
            return Expanded(
              child: Container(
                height: 2,
                color: isPassed ? AppColors.primary : AppColors.border,
              ),
            );
          }

          final stepIdx = index ~/ 2;
          final isCompleted = stepIdx < activeIndex;
          final isCurrent = stepIdx == activeIndex;

          Color circleColor;
          Color iconColor;
          IconData icon;

          if (isCompleted) {
            circleColor = AppColors.statusResolved;
            iconColor = Colors.white;
            icon = Icons.check;
          } else if (isCurrent) {
            circleColor = isRejected ? AppColors.statusRejected : AppColors.primary;
            iconColor = Colors.white;
            icon = isRejected ? Icons.close : Icons.circle;
          } else {
            circleColor = AppColors.borderLight;
            iconColor = AppColors.textMuted;
            icon = Icons.circle_outlined;
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: circleColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 12, color: iconColor),
              ),
              const SizedBox(height: 4),
              Text(
                steps[stepIdx]['label']!,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isCurrent || isCompleted ? FontWeight.w700 : FontWeight.w500,
                  color: isCurrent ? AppColors.primary : (isCompleted ? AppColors.textPrimary : AppColors.textMuted),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
