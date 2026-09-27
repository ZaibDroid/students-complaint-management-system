import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/secondary_button.dart';
import '../../../../shared/enums/user_role.dart';

enum ComplaintActionType {
  forward,
  resolve,
  reject,
  returnAction,
}

class ComplaintActionModal extends StatefulWidget {
  final ComplaintActionType actionType;
  final UserRole currentUserRole;
  final Function({required String remarks, UserRole? targetRole}) onConfirm;

  const ComplaintActionModal({
    super.key,
    required this.actionType,
    required this.currentUserRole,
    required this.onConfirm,
  });

  static Future<void> show({
    required BuildContext context,
    required ComplaintActionType actionType,
    required UserRole currentUserRole,
    required Function({required String remarks, UserRole? targetRole}) onConfirm,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => ComplaintActionModal(
        actionType: actionType,
        currentUserRole: currentUserRole,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  State<ComplaintActionModal> createState() => _ComplaintActionModalState();
}

class _ComplaintActionModalState extends State<ComplaintActionModal> {
  final _remarksController = TextEditingController();
  UserRole _selectedTargetRole = UserRole.coordinator;

  @override
  void initState() {
    super.initState();
    // Default forward target based on workflow:
    // Student -> Batch Adviser -> Coordinator (optional) -> Chairman -> Office/Dean (if required)
    if (widget.currentUserRole == UserRole.batchAdviser) {
      _selectedTargetRole = UserRole.coordinator;
    } else if (widget.currentUserRole == UserRole.coordinator) {
      _selectedTargetRole = UserRole.chairman;
    } else if (widget.currentUserRole == UserRole.chairman) {
      _selectedTargetRole = UserRole.officeStaff;
    }
  }

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }

  String get _title {
    switch (widget.actionType) {
      case ComplaintActionType.forward:
        return 'Forward Complaint';
      case ComplaintActionType.resolve:
        return 'Resolve Complaint';
      case ComplaintActionType.reject:
        return 'Reject Complaint';
      case ComplaintActionType.returnAction:
        return 'Return Complaint';
    }
  }

  Color get _actionColor {
    switch (widget.actionType) {
      case ComplaintActionType.forward:
        return AppColors.statusForwarded;
      case ComplaintActionType.resolve:
        return AppColors.statusResolved;
      case ComplaintActionType.reject:
        return AppColors.statusRejected;
      case ComplaintActionType.returnAction:
        return AppColors.statusReturned;
    }
  }

  List<UserRole> get _availableForwardTargets {
    // Determine possible roles to forward to in the hierarchy
    if (widget.currentUserRole == UserRole.batchAdviser) {
      return [UserRole.coordinator, UserRole.chairman];
    } else if (widget.currentUserRole == UserRole.coordinator) {
      return [UserRole.chairman, UserRole.batchAdviser];
    } else if (widget.currentUserRole == UserRole.chairman) {
      return [UserRole.officeStaff, UserRole.dean, UserRole.coordinator, UserRole.batchAdviser];
    } else if (widget.currentUserRole == UserRole.officeStaff) {
      return [UserRole.chairman];
    } else if (widget.currentUserRole == UserRole.dean) {
      return [UserRole.chairman];
    }
    return [UserRole.batchAdviser, UserRole.coordinator, UserRole.chairman];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            _title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _actionColor,
            ),
          ),
          const SizedBox(height: 16),

          // Forward Role Selector
          if (widget.actionType == ComplaintActionType.forward) ...[
            const Text(
              'Select Forward Target',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<UserRole>(
                  isExpanded: true,
                  value: _selectedTargetRole,
                  items: _availableForwardTargets.map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(role.displayName, style: const TextStyle(fontSize: 14)),
                    );
                  }).toList(),
                  onChanged: (role) {
                    if (role != null) setState(() => _selectedTargetRole = role);
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Remarks / Justification Input
          AppTextField(
            label: 'Official Remarks / Reason (Required)',
            hint: 'Enter your justification or decision remarks...',
            controller: _remarksController,
            maxLines: 4,
          ),
          const SizedBox(height: 24),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  text: 'Cancel',
                  height: 46,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PrimaryButton(
                  text: 'Submit Decision',
                  backgroundColor: _actionColor,
                  height: 46,
                  onPressed: () {
                    if (_remarksController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter official remarks to proceed.')),
                      );
                      return;
                    }

                    widget.onConfirm(
                      remarks: _remarksController.text.trim(),
                      targetRole: widget.actionType == ComplaintActionType.forward ? _selectedTargetRole : null,
                    );
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
