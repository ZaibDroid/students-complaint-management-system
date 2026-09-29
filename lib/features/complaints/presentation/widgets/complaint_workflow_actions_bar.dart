import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/ui_helpers.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/secondary_button.dart';

/// Reusable bottom workflow action bar for faculty / staff
class ComplaintWorkflowActionsBar extends StatelessWidget {
  final VoidCallback onReturn;
  final VoidCallback onReject;
  final VoidCallback onForward;
  final VoidCallback onResolve;

  const ComplaintWorkflowActionsBar({
    super.key,
    required this.onReturn,
    required this.onReject,
    required this.onForward,
    required this.onResolve,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppPaddings.all16,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: SafeArea(
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            SizedBox(
              width: 100,
              child: SecondaryButton(
                text: 'Return',
                height: 40,
                borderColor: AppColors.statusReturned,
                textColor: AppColors.statusReturned,
                onPressed: onReturn,
              ),
            ),
            SizedBox(
              width: 100,
              child: SecondaryButton(
                text: 'Reject',
                height: 40,
                borderColor: AppColors.statusRejected,
                textColor: AppColors.statusRejected,
                onPressed: onReject,
              ),
            ),
            SizedBox(
              width: 110,
              child: PrimaryButton(
                text: 'Forward',
                height: 40,
                backgroundColor: AppColors.statusForwarded,
                onPressed: onForward,
              ),
            ),
            SizedBox(
              width: 110,
              child: PrimaryButton(
                text: 'Resolve',
                height: 40,
                backgroundColor: AppColors.statusResolved,
                onPressed: onResolve,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
