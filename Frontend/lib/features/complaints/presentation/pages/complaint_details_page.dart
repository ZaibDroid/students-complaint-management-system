import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/complaint_model.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../providers/complaint_provider.dart';
import '../widgets/complaint_action_bar.dart';
import '../widgets/complaint_action_dialog.dart';
import '../widgets/complaint_attachment_card.dart';
import '../widgets/complaint_info_card.dart';
import '../widgets/complaint_location_card.dart';
import '../widgets/complaint_remarks_section.dart';
import '../widgets/complaint_status_header.dart';

class ComplaintDetailsPage extends ConsumerStatefulWidget {
  final ComplaintModel complaint;

  const ComplaintDetailsPage({super.key, required this.complaint});

  @override
  ConsumerState<ComplaintDetailsPage> createState() => _ComplaintDetailsPageState();
}

class _ComplaintDetailsPageState extends ConsumerState<ComplaintDetailsPage> {
  late ComplaintModel _complaint;

  @override
  void initState() {
    super.initState();
    _complaint = widget.complaint;
    _refreshComplaint();
  }

  Future<void> _refreshComplaint() async {
    if (_complaint.id.isEmpty) return;
    try {
      final repo = ref.read(apiComplaintRepositoryProvider);
      final fresh = await repo.getComplaintById(_complaint.id);
      if (fresh != null && mounted) {
        setState(() {
          _complaint = fresh;
        });
      }
    } catch (_) {}
  }

  String _getCurrentLocation() {
    final status = _complaint.status.toLowerCase();
    if (status == 'pending') {
      return 'Batch Adviser';
    } else if (status == 'forwarded') {
      final assignedTo = _complaint.assignedTo ?? '';
      final RegExp roleExp = RegExp(r'\((.*?)\)');
      final match = roleExp.firstMatch(assignedTo);
      if (match != null) {
        return match.group(1)!;
      }
      return assignedTo.isNotEmpty ? assignedTo : 'Coordinator/Chairman';
    } else if (status == 'resolved') {
      return 'Resolved';
    } else if (status == 'rejected') {
      return 'Rejected';
    }
    return 'Unknown';
  }

  bool _isAssignedToMe(dynamic authState) {
    if (authState == null) return false;
    if (_complaint.assignedToId != null && _complaint.assignedToId!.isNotEmpty) {
      if (_complaint.assignedToId == authState.id) return true;
    }
    if (_complaint.assignedTo != null && _complaint.assignedTo!.isNotEmpty) {
      final assignedLower = _complaint.assignedTo!.toLowerCase().replaceAll('dr.', '').trim();
      final myNameLower = authState.name.toLowerCase().replaceAll('dr.', '').trim();
      if (assignedLower == myNameLower) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider).value;
    final isStaff = authState != null && authState.role != 'Student';
    final isAdmin = authState != null && authState.role.toLowerCase() == 'admin';
    final currentUserRole = authState?.role.toLowerCase() ?? '';
    final isBatchAdviser = currentUserRole.contains('adviser') || currentUserRole.contains('advisor');
    final isCoordinator = currentUserRole.contains('coordinator');
    final isChairman = currentUserRole.contains('chairman') || currentUserRole.contains('chair');
    final isAssigned = _isAssignedToMe(authState);

    bool isActionable = (isAdmin || isAssigned) &&
        _complaint.status != 'resolved' &&
        _complaint.status != 'rejected';

    // Batch Adviser has no access once forwarded to someone else
    if (isBatchAdviser && _complaint.status == 'forwarded' && !isAssigned) {
      isActionable = false;
    }

    if (!isAssigned && !isAdmin) {
      isActionable = false;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8FC),
      appBar: AppBar(
        title: const Text('Complaint Details'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status, Ticket ID, Title, and Meta info
            ComplaintStatusHeader(complaint: _complaint),
            const SizedBox(height: 24),

            // Current Location Card
            ComplaintLocationCard(location: _getCurrentLocation()),
            const SizedBox(height: 24),

            // Description Card
            ComplaintInfoCard(
              title: 'Description',
              content: _complaint.description,
            ),
            const SizedBox(height: 24),

            // Remarks & Activity Notes Section (Shows all historical remarks: Adviser, Coordinator, Chairman, VC, etc.)
            ComplaintRemarksSection(
              remarks: _complaint.remarks,
              fallbackAdminRemarks: _complaint.adminRemarks,
            ),

            // Attachments
            if (_complaint.attachments.isNotEmpty) ...[
              const Text(
                'Evidence & Attachments',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ..._complaint.attachments.map(
                (att) => ComplaintAttachmentCard(attachment: att),
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
      bottomNavigationBar: isStaff && isActionable
          ? ComplaintActionBar(
              isChairman: isChairman,
              forwardLabel: isCoordinator
                  ? 'Forward / Send Back Complaint'
                  : (isChairman
                      ? 'Forward to Dean / Dept Office'
                      : 'Forward to Chairman / Coordinator'),
              onForward: () => context.push('/select_recipient', extra: _complaint),
              onReject: () => showComplaintActionDialog(
                context: context,
                ref: ref,
                complaintId: _complaint.id,
                actionType: 'rejected',
              ),
              onResolve: () => showComplaintActionDialog(
                context: context,
                ref: ref,
                complaintId: _complaint.id,
                actionType: 'resolved',
              ),
            )
          : null,
    );
  }
}
