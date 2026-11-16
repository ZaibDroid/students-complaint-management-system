import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../features/dashboard/presentation/widgets/dashboard_app_bar.dart';
import '../../../../features/dashboard/presentation/widgets/staff_complaint_card.dart';
import '../../../../features/complaints/presentation/providers/complaint_provider.dart';
import '../../../../features/complaints/data/models/complaint_model.dart';
import '../../../../features/profile/presentation/widgets/stat_card.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';

class ChairmanDashboardPage extends ConsumerStatefulWidget {
  const ChairmanDashboardPage({super.key});

  @override
  ConsumerState<ChairmanDashboardPage> createState() => _ChairmanDashboardPageState();
}

class _ChairmanDashboardPageState extends ConsumerState<ChairmanDashboardPage> {
  String _selectedFilter = 'pending'; // 'pending', 'processed', 'forwarded'

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final asyncComplaints = ref.watch(departmentComplaintsProvider);

    List<ComplaintModel> complaints = asyncComplaints.value ?? [];

    final user = ref.read(authStateProvider).value;
    final userName = user?.name ?? '';
    final myNameLower = userName.toLowerCase().replaceAll('dr.', '').trim();
    
    bool isAssignedToMe(String? assignedTo, [String? assignedToId]) {
      if (user != null && assignedToId != null && assignedToId == user.id) return true;
      if (assignedTo == null || assignedTo.isEmpty) return false;
      final assignedToLower = assignedTo.toLowerCase().replaceAll('dr.', '').trim();
      return assignedToLower == myNameLower;
    }
    
    final pendingCount = complaints.where((c) => isAssignedToMe(c.assignedTo, c.assignedToId) && c.status != 'resolved' && c.status != 'rejected').length;
    final processedCount = complaints.where((c) => c.status == 'resolved' || c.status == 'rejected').length;
    final forwardedCount = complaints.where((c) => !isAssignedToMe(c.assignedTo, c.assignedToId) && (c.status == 'forwarded' || c.involvedStaffNames.any((name) {
      final involvedLower = name.toLowerCase().replaceAll('dr.', '').trim();
      return involvedLower == myNameLower;
    })) && c.status != 'resolved' && c.status != 'rejected').length;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8FC),
      appBar: const DashboardAppBar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Chairman Portal',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF172548)),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        icon: Icons.pending_actions,
                        iconColor: Colors.amber,
                        value: pendingCount.toString(),
                        label: 'PENDING',
                        isSelected: _selectedFilter == 'pending',
                        onTap: () => setState(() => _selectedFilter = 'pending'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: StatCard(
                        icon: Icons.assignment_turned_in,
                        iconColor: Colors.green,
                        value: processedCount.toString(),
                        label: 'PROCESSED',
                        isSelected: _selectedFilter == 'processed',
                        onTap: () => setState(() => _selectedFilter = 'processed'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: StatCard(
                        icon: Icons.share_rounded,
                        iconColor: Colors.indigo,
                        value: forwardedCount.toString(),
                        label: 'FORWARDED',
                        isSelected: _selectedFilter == 'forwarded',
                        onTap: () => setState(() => _selectedFilter = 'forwarded'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: asyncComplaints.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error: $e')),
              data: (complaintsList) {
                return _buildComplaintsList(complaintsList, theme);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintsList(List<ComplaintModel> complaints, ThemeData theme) {
    final user = ref.read(authStateProvider).value;
    final userName = user?.name ?? '';
    final myNameLower = userName.toLowerCase().replaceAll('dr.', '').trim();
    
    bool isAssignedToMe(String? assignedTo, [String? assignedToId]) {
      if (user != null && assignedToId != null && assignedToId == user.id) return true;
      if (assignedTo == null || assignedTo.isEmpty) return false;
      final assignedToLower = assignedTo.toLowerCase().replaceAll('dr.', '').trim();
      return assignedToLower == myNameLower;
    }

    var filtered = complaints.where((c) {
      if (_selectedFilter == 'pending') return isAssignedToMe(c.assignedTo, c.assignedToId) && c.status != 'resolved' && c.status != 'rejected';
      if (_selectedFilter == 'processed') return c.status == 'resolved' || c.status == 'rejected';
      if (_selectedFilter == 'forwarded') {
        return !isAssignedToMe(c.assignedTo, c.assignedToId) && (c.status == 'forwarded' || c.involvedStaffNames.any((name) {
          final involvedLower = name.toLowerCase().replaceAll('dr.', '').trim();
          return involvedLower == myNameLower;
        }));
      }
      return true;
    }).toList();

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(departmentComplaintsProvider);
        await ref.read(departmentComplaintsProvider.notifier).refresh();
      },
      child: filtered.isEmpty
          ? LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text('No complaints found in this category.', style: TextStyle(color: Colors.grey)),
                    ),
                  ),
                ),
              ),
            )
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final c = filtered[index];
                final isAssigned = isAssignedToMe(c.assignedTo, c.assignedToId);
                final isPending = isAssigned && c.status != 'resolved' && c.status != 'rejected';
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => context.push('/complaint_details', extra: c),
            borderRadius: BorderRadius.circular(16),
            child: StaffComplaintCard(
              studentName: c.studentName,
              batch: c.studentBatch ?? 'N/A',
              title: c.title,
                status: c.status,
                assignedTo: c.assignedTo,
              date: '${c.createdAt.day.toString().padLeft(2, '0')}-${c.createdAt.month.toString().padLeft(2, '0')}-${c.createdAt.year} ${c.createdAt.hour.toString().padLeft(2, '0')}:${c.createdAt.minute.toString().padLeft(2, '0')}',
              onForward: isPending ? () => context.push('/select_recipient', extra: c) : null,
              onResolve: isPending ? () => _showActionDialog(context, c, 'resolved') : null,
              onReject: isPending ? () => _showActionDialog(context, c, 'rejected') : null,
            ),
          ),
        );
      },
    ),
    );
  }

  void _showActionDialog(BuildContext context, ComplaintModel c, String actionType) {
    final commentController = TextEditingController();
    bool forwardToOffice = false;
    String? errorMessage;
    
    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: Text('${actionType == 'resolved' ? 'Resolve' : 'Reject'} Complaint'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Remarks / Comments ',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey.shade800),
                      ),
                      const Text('*', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: commentController,
                    decoration: InputDecoration(
                      hintText: 'Enter mandatory remarks...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      errorText: errorMessage,
                    ),
                    maxLines: 3,
                    onChanged: (val) {
                      if (errorMessage != null && val.trim().isNotEmpty) {
                        setDialogState(() => errorMessage = null);
                      }
                    },
                  ),
                  if (actionType == 'resolved') ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Checkbox(
                          value: forwardToOffice,
                          onChanged: (val) {
                            setDialogState(() {
                              forwardToOffice = val ?? false;
                            });
                          },
                        ),
                        const Expanded(
                          child: Text('Forward to Office for manual notification'),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final comment = commentController.text.trim();
                    if (comment.isEmpty) {
                      setDialogState(() {
                        errorMessage = 'Remarks are compulsory to ${actionType == 'resolved' ? 'resolve' : 'reject'} this complaint.';
                      });
                      return;
                    }
                    
                    final action = (actionType == 'resolved' && forwardToOffice) ? 'forwarded' : actionType;
                    final assignedTo = (actionType == 'resolved' && forwardToOffice) ? 'Office' : null;
                    
                    ref.read(submitComplaintProvider.notifier).updateStatus(c.id, action, comment, assignedTo: assignedTo);
                    if (dialogContext.mounted) Navigator.pop(dialogContext);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: actionType == 'resolved' ? Colors.green : Colors.red, foregroundColor: Colors.white),
                  child: const Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
