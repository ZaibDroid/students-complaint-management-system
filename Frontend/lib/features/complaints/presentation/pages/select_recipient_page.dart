import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/complaint_model.dart';
import '../providers/complaint_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../admin/presentation/pages/adviser_dashboard_page.dart';
import '../../../../core/services/api_client.dart';
import '../widgets/recipient_filter_helper.dart';
import '../widgets/recipient_staff_card.dart';
import '../widgets/forward_complaint_footer.dart';

final availableStaffProvider = StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) async* {
  try {
    final apiClient = ApiClient();
    final data = await apiClient.get('/users/staff', queryParams: {'per_page': '100'});
    if (data is List) {
      final staffList = data.map((item) {
        final map = item as Map<String, dynamic>;
        final coordBatchIds = (map['coordinated_batch_ids'] as List? ?? [])
            .map((e) => e.toString())
            .toList();
        return {
          'id': (map['id'] ?? '').toString(),
          'name': map['name'] ?? 'Unknown',
          'role': map['role']?.toString() ?? 'Staff',
          'coordinated_batch_ids': coordBatchIds,
        };
      }).where((staff) => staff['id']!.isNotEmpty && !staff['id']!.startsWith('mock_')).toList();

      yield staffList;
    } else {
      yield [];
    }
  } catch (_) {
    yield [];
  }
});

/// Modularized Select Recipient Page for forwarding complaints.
class SelectRecipientPage extends ConsumerStatefulWidget {
  final ComplaintModel complaint;

  const SelectRecipientPage({super.key, required this.complaint});

  @override
  ConsumerState<SelectRecipientPage> createState() => _SelectRecipientPageState();
}

class _SelectRecipientPageState extends ConsumerState<SelectRecipientPage> {
  String? _selectedStaffId;
  String? _selectedStaffName;
  final TextEditingController _commentController = TextEditingController();
  String? _commentError;

  @override
  void initState() {
    super.initState();
    final coordId = widget.complaint.assignedCoordinatorId;
    if (coordId != null && coordId.isNotEmpty) {
      _selectedStaffId = coordId;
      _selectedStaffName = widget.complaint.assignedCoordinatorName ?? 'Assigned Coordinator';
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _confirmTransfer() async {
    if (_selectedStaffId == null || _selectedStaffName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a recipient faculty member first.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final commentText = _commentController.text.trim();
    if (commentText.isEmpty) {
      setState(() => _commentError = 'Remarks are compulsory before forwarding.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Remarks / comments are compulsory before forwarding this complaint.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final success = await ref.read(submitComplaintProvider.notifier).updateStatus(
      widget.complaint.id,
      'forwarded',
      commentText,
      assignedToId: _selectedStaffId,
      assignedTo: _selectedStaffName,
      newInvolvedStaff: [_selectedStaffName!],
    );

    if (mounted) {
      Navigator.pop(context); // close loading
      if (success) {
        ref.invalidate(adviserComplaintsProvider);
        ref.invalidate(departmentComplaintsProvider);
        ref.invalidate(allComplaintsProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Case transferred successfully!')),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to transfer case')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final staffAsync = ref.watch(availableStaffProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Forward Complaint', style: TextStyle(color: Color(0xFF010F32), fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Color(0xFF010F32)),
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.help_outline), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Chip(label: Text('STEP 3 OF 4', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)), backgroundColor: Color(0xFFEFEDF1)),
                    Text('BATCH ACTION', style: TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('Select Recipient', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF010F32))),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.swap_horiz, size: 18, color: Colors.black54),
                    const SizedBox(width: 8),
                    Text(
                      'Transferring Complaint #${widget.complaint.ticketNumber ?? (widget.complaint.id.length > 6 ? widget.complaint.id.substring(0, 6).toUpperCase() : widget.complaint.id)}',
                      style: const TextStyle(color: Colors.black54, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                const Text('AVAILABLE STAFF MEMBERS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54, letterSpacing: 1.2)),
                const SizedBox(height: 16),

                staffAsync.when(
                  data: (staffList) {
                    final currentUserId = ref.watch(authStateProvider).value?.id.toString() ?? '';
                    final currentUserRole = ref.watch(authStateProvider).value?.role.toLowerCase() ?? '';
                    final isBatchAdviser = currentUserRole.contains('adviser') || currentUserRole.contains('advisor');
                    final isCoordinator = currentUserRole.contains('coordinator');

                    final targetCoordId = RecipientFilterHelper.resolveTargetCoordinatorId(
                      staffList: staffList,
                      assignedCoordinatorId: widget.complaint.assignedCoordinatorId,
                      studentBatchId: widget.complaint.studentBatchId,
                    );
                    final hasAssignedCoordinator = targetCoordId != null && targetCoordId.isNotEmpty;

                    // Automatically pre-select the assigned Coordinator when present for Batch Adviser
                    if (isBatchAdviser && _selectedStaffId == null && hasAssignedCoordinator) {
                      final match = staffList.where((s) => s['id'] == targetCoordId).firstOrNull;
                      if (match != null) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted && _selectedStaffId == null) {
                            setState(() {
                              _selectedStaffId = match['id'];
                              _selectedStaffName = match['name'];
                            });
                          }
                        });
                      }
                    }

                    final filteredStaff = RecipientFilterHelper.filterAndSortRecipients(
                      staffList: staffList,
                      currentUserId: currentUserId,
                      currentUserRole: currentUserRole,
                      complaint: widget.complaint,
                      targetCoordId: targetCoordId,
                    );

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (isBatchAdviser && !hasAssignedCoordinator)
                          Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFBEB),
                              border: Border.all(color: const Color(0xFFFDE68A)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.info_outline, color: Color(0xFFD97706), size: 22),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'No Coordinator is currently assigned to this batch.',
                                    style: TextStyle(
                                      color: Color(0xFF92400E),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (filteredStaff.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('No staff members available for forwarding.'),
                          )
                        else
                          ...filteredStaff.map((staff) {
                            final isSelected = _selectedStaffId == staff['id'];
                            final roleLower = (staff['role'] as String).toLowerCase();
                            final isAdviserSendBack = isCoordinator &&
                                (roleLower.contains('adviser') || roleLower.contains('advisor'));
                            final isOffice = roleLower.contains('office');

                            String roleLabel = staff['role'];
                            if (isAdviserSendBack) {
                              roleLabel = 'Batch Adviser (Send Back)';
                            } else if (isOffice) {
                              roleLabel = 'Department Office (${staff['role']})';
                            }

                            return RecipientStaffCard(
                              staff: staff,
                              isSelected: isSelected,
                              isAdviserSendBack: isAdviserSendBack,
                              isOffice: isOffice,
                              roleLabel: roleLabel,
                              onSelected: (id) => setState(() {
                                _selectedStaffId = id;
                                _selectedStaffName = staff['name'];
                              }),
                            );
                          }),
                      ],
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Error: $err')),
                ),

                const SizedBox(height: 12),
                Row(
                  children: const [
                    Text('REMARKS / REASON FOR FORWARDING ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54, letterSpacing: 1.2)),
                    Text('*', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red)),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _commentController,
                  maxLines: 4,
                  onChanged: (val) {
                    if (_commentError != null && val.trim().isNotEmpty) {
                      setState(() => _commentError = null);
                    }
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter compulsory remarks explaining why this complaint is being forwarded...',
                    errorText: _commentError,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: theme.primaryColor, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ForwardComplaintFooter(
            selectedStaffName: _selectedStaffName,
            onCancel: () => context.pop(),
            onConfirm: _selectedStaffId == null ? null : _confirmTransfer,
          ),
        ],
      ),
    );
  }
}
