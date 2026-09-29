import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/route_names.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../core/utils/ui_helpers.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/remark_card.dart';
import '../../../../shared/enums/user_role.dart';
import 'package:student_complaint_managment_system/features/auth/presentation/providers/auth_provider.dart';
import '../providers/complaints_provider.dart';
import '../widgets/complainant_info_card.dart';
import '../widgets/complaint_action_modal.dart';
import '../widgets/complaint_detail_header.dart';
import '../widgets/complaint_evidence_grid.dart';
import '../widgets/complaint_workflow_actions_bar.dart';

class ComplaintDetailPage extends ConsumerStatefulWidget {
  final String complaintId;

  const ComplaintDetailPage({super.key, required this.complaintId});

  @override
  ConsumerState<ComplaintDetailPage> createState() => _ComplaintDetailPageState();
}

class _ComplaintDetailPageState extends ConsumerState<ComplaintDetailPage> {
  final _remarkController = TextEditingController();
  final bool _isOfficialRemark = false;

  @override
  void dispose() {
    _remarkController.dispose();
    super.dispose();
  }

  void _showActionModal(ComplaintActionType actionType, UserRole role) {
    ComplaintActionModal.show(
      context: context,
      actionType: actionType,
      currentUserRole: role,
      onConfirm: ({required remarks, targetRole}) async {
        final notifier = ref.read(complaintDetailProvider(widget.complaintId).notifier);
        bool success = false;

        switch (actionType) {
          case ComplaintActionType.forward:
            if (targetRole != null) {
              success = await notifier.forward(widget.complaintId, targetRole, remarks);
            }
            break;
          case ComplaintActionType.resolve:
            success = await notifier.resolve(widget.complaintId, remarks);
            break;
          case ComplaintActionType.reject:
            success = await notifier.reject(widget.complaintId, remarks);
            break;
          case ComplaintActionType.returnAction:
            success = await notifier.returnBack(widget.complaintId, remarks);
            break;
        }

        if (success && mounted) {
          ref.read(complaintsListProvider.notifier).fetchComplaints(page: 1);
          context.showSuccessSnackBar('Action processed successfully!');
        }
      },
    );
  }

  Future<void> _handleAddRemark() async {
    final text = _remarkController.text.trim();
    if (text.isEmpty) return;

    final notifier = ref.read(complaintDetailProvider(widget.complaintId).notifier);
    final success = await notifier.addRemark(widget.complaintId, text, _isOfficialRemark);

    if (success && mounted) {
      _remarkController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(complaintDetailProvider(widget.complaintId));
    final currentUser = ref.watch(authProvider).user;
    final currentRole = currentUser?.role ?? UserRole.student;
    final isStaff = currentRole.isStaff;

    if (state.isLoading && state.complaint == null) {
      return const Scaffold(body: LoadingWidget(message: 'Loading complaint details...'));
    }

    if (state.errorMessage != null && state.complaint == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Complaint')),
        body: AppErrorWidget(
          message: state.errorMessage!,
          onRetry: () => ref.read(complaintDetailProvider(widget.complaintId).notifier).loadComplaint(widget.complaintId),
        ),
      );
    }

    final complaint = state.complaint;
    if (complaint == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Complaint')),
        body: const Center(child: Text('Complaint not found')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(complaint.trackingNumber),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.timeline_outlined),
            tooltip: 'View Timeline',
            onPressed: () => context.push(RouteNames.complaintTrackingPath(complaint.id)),
          ),
        ],
      ),
      bottomNavigationBar: isStaff && !complaint.status.isTerminal
          ? ComplaintWorkflowActionsBar(
              onReturn: () => _showActionModal(ComplaintActionType.returnAction, currentRole),
              onReject: () => _showActionModal(ComplaintActionType.reject, currentRole),
              onForward: () => _showActionModal(ComplaintActionType.forward, currentRole),
              onResolve: () => _showActionModal(ComplaintActionType.resolve, currentRole),
            )
          : null,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppPaddings.page,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card with Status, Priority, Date
              ComplaintDetailHeader(
                title: complaint.title,
                category: complaint.category,
                status: complaint.status,
                priority: complaint.priority,
                createdAt: complaint.createdAt,
              ),
              AppSpacing.v14,

              // Complainant Details Card
              ComplainantInfoCard(
                studentName: complaint.studentName,
                studentAvatarUrl: complaint.studentAvatarUrl,
                batch: complaint.batch,
                section: complaint.section,
                studentEmail: complaint.studentEmail,
                handlerRole: complaint.currentHandlerRole,
              ),
              AppSpacing.v14,

              // Description Card
              Container(
                padding: AppPaddings.all16,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppBorderRadii.r16,
                  border: Border.all(color: AppColors.border, width: 1),
                  boxShadow: AppShadows.card,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Complaint Details',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    AppSpacing.v8,
                    Text(
                      complaint.description,
                      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.5),
                    ),
                  ],
                ),
              ),
              AppSpacing.v14,

              // Attachments (if any)
              if (complaint.attachmentUrls.isNotEmpty) ...[
                ComplaintEvidenceGrid(attachmentUrls: complaint.attachmentUrls),
                AppSpacing.v14,
              ],

              // Remarks & Discussion Thread
              Container(
                padding: AppPaddings.all16,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppBorderRadii.r16,
                  border: Border.all(color: AppColors.border, width: 1),
                  boxShadow: AppShadows.card,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Remarks & Comments',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        ),
                        Text(
                          '${complaint.remarks.length} total',
                          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                    AppSpacing.v12,
                    if (complaint.remarks.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'No remarks posted yet.',
                          style: TextStyle(fontSize: 13, color: AppColors.textMuted, fontStyle: FontStyle.italic),
                        ),
                      )
                    else
                      ...complaint.remarks.map((r) => RemarkCard(
                            authorName: r.authorName,
                            authorRole: r.authorRole,
                            authorAvatarUrl: r.authorAvatarUrl,
                            content: r.content,
                            createdAt: r.createdAt,
                            isOfficial: r.isOfficial,
                          )),

                    // Add Remark Box
                    const Divider(color: AppColors.divider),
                    AppSpacing.v8,
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            hint: 'Type a remark or update...',
                            controller: _remarkController,
                          ),
                        ),
                        AppSpacing.h8,
                        IconButton(
                          icon: const Icon(Icons.send, color: AppColors.primary),
                          onPressed: _handleAddRemark,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              AppSpacing.v40,
            ],
          ),
        ),
      ),
    );
  }
}
