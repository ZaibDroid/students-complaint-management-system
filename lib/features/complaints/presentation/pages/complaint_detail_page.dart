import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/route_names.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/remark_card.dart';
import '../../../../core/widgets/secondary_button.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../../shared/enums/user_role.dart';
import 'package:student_complaint_managment_system/features/auth/presentation/providers/auth_provider.dart';
import '../providers/complaints_provider.dart';
import '../widgets/complaint_action_modal.dart';

class ComplaintDetailPage extends ConsumerStatefulWidget {
  final String complaintId;

  const ComplaintDetailPage({super.key, required this.complaintId});

  @override
  ConsumerState<ComplaintDetailPage> createState() => _ComplaintDetailPageState();
}

class _ComplaintDetailPageState extends ConsumerState<ComplaintDetailPage> {
  final _remarkController = TextEditingController();
  bool _isOfficialRemark = false;

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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Action processed successfully!'),
              backgroundColor: AppColors.statusResolved,
            ),
          );
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
          ? Container(
              padding: const EdgeInsets.all(16),
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
                        onPressed: () => _showActionModal(ComplaintActionType.returnAction, currentRole),
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: SecondaryButton(
                        text: 'Reject',
                        height: 40,
                        borderColor: AppColors.statusRejected,
                        textColor: AppColors.statusRejected,
                        onPressed: () => _showActionModal(ComplaintActionType.reject, currentRole),
                      ),
                    ),
                    SizedBox(
                      width: 110,
                      child: PrimaryButton(
                        text: 'Forward',
                        height: 40,
                        backgroundColor: AppColors.statusForwarded,
                        onPressed: () => _showActionModal(ComplaintActionType.forward, currentRole),
                      ),
                    ),
                    SizedBox(
                      width: 110,
                      child: PrimaryButton(
                        text: 'Resolve',
                        height: 40,
                        backgroundColor: AppColors.statusResolved,
                        onPressed: () => _showActionModal(ComplaintActionType.resolve, currentRole),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card with Status, Priority, Date
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        StatusChip(status: complaint.status),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: complaint.priority.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${complaint.priority.displayName.toUpperCase()} PRIORITY',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: complaint.priority.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      complaint.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.category_outlined, size: 14, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          complaint.category,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                        ),
                        const Text(' • ', style: TextStyle(color: AppColors.textMuted)),
                        const Icon(Icons.calendar_today_outlined, size: 13, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          DateFormatter.formatDate(complaint.createdAt),
                          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Complainant Details Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: Row(
                  children: [
                    UserAvatar(name: complaint.studentName, size: 44),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            complaint.studentName,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Batch: ${complaint.batch ?? 'N/A'} • Section: ${complaint.section ?? 'N/A'}',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                          if (complaint.studentEmail != null)
                            Text(
                              complaint.studentEmail!,
                              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                            ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Handler: ${complaint.currentHandlerRole.displayName}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Description Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Complaint Details',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      complaint.description,
                      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Attachments (if any)
              if (complaint.attachmentUrls.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Attached Proof & Evidence',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 100,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: complaint.attachmentUrls.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 10),
                          itemBuilder: (context, index) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                complaint.attachmentUrls[index],
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 100,
                                  height: 100,
                                  color: AppColors.primarySurface,
                                  child: const Icon(Icons.image, color: AppColors.primary),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Remarks & Discussion Thread
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border, width: 1),
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
                    const SizedBox(height: 12),
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
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            hint: 'Type a remark or update...',
                            controller: _remarkController,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.send, color: AppColors.primary),
                          onPressed: _handleAddRemark,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
