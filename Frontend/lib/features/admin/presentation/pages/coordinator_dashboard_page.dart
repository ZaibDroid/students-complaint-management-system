import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/dashboard/presentation/widgets/dashboard_app_bar.dart';
import '../../../../features/dashboard/presentation/widgets/staff_complaint_card.dart';
import '../../../../features/complaints/presentation/providers/complaint_provider.dart';
import '../../../../features/complaints/data/models/complaint_model.dart';
import '../../../../features/profile/presentation/widgets/stat_card.dart';
import '../../../../features/profile/presentation/pages/user_profile_page.dart';
import 'assign_adviser_page.dart';
import '../../../../features/batch/presentation/pages/batch_management_portal_page.dart';
import 'package:go_router/go_router.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../features/notice_board/presentation/pages/staff_notice_board_page.dart';

class CoordinatorDashboardPage extends ConsumerStatefulWidget {
  const CoordinatorDashboardPage({super.key});

  @override
  ConsumerState<CoordinatorDashboardPage> createState() => _CoordinatorDashboardPageState();
}

class _CoordinatorDashboardPageState extends ConsumerState<CoordinatorDashboardPage> {
  String _selectedFilter = 'pending'; // 'pending', 'processed', 'forwarded'
  int _bottomNavIndex = 0; // 0 for Dashboard, 1 for Profile

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final asyncComplaints = ref.watch(departmentComplaintsProvider);

    List<ComplaintModel> complaints = asyncComplaints.value ?? [];

    final user = ref.read(authStateProvider).value;
    final userName = user?.name ?? '';
    final myNameLower = userName.toLowerCase().replaceAll('dr.', '').trim();
    
    bool isAssignedToMe(String? assignedTo) {
      if (assignedTo == null || assignedTo.isEmpty) return false;
      final assignedToLower = assignedTo.toLowerCase().replaceAll('dr.', '').trim();
      return assignedToLower == myNameLower;
    }
    
    final pendingCount = complaints.where((c) => isAssignedToMe(c.assignedTo) && c.status != 'resolved' && c.status != 'rejected').length;
    final processedCount = complaints.where((c) => (c.status == 'resolved' || c.status == 'rejected') && isAssignedToMe(c.assignedTo)).length;
    final forwardedCount = complaints.where((c) => !isAssignedToMe(c.assignedTo) && c.involvedStaffNames.any((name) {
      final involvedLower = name.toLowerCase().replaceAll('dr.', '').trim();
      return involvedLower == myNameLower;
    })).length;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8FC),
      appBar: const DashboardAppBar(),
      body: Column(
        children: [
          if (_bottomNavIndex == 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Coordinator Portal',
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
            child: _bottomNavIndex == 4
                ? const UserProfilePage(isSubPage: false)
                : _bottomNavIndex == 3
                    ? const StaffNoticeBoardPage()
                : _bottomNavIndex == 2
                    ? const BatchManagementPortalPage(isEmbedded: true)
                : _bottomNavIndex == 1
                    ? const AssignAdviserPage(isEmbedded: true)
                    : asyncComplaints.when(
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (e, st) => Center(child: Text('Error: $e')),
                        data: (complaintsList) {
                          return _buildComplaintsList(complaintsList, theme);
                        },
                      ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomNavIndex,
        onTap: (index) {
          setState(() {
            _bottomNavIndex = index;
            if (index == 0) _selectedFilter = 'pending'; // Reset filter when switching back
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: theme.primaryColor,
        unselectedItemColor: Colors.grey.shade400,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.group_add), label: 'Advisers'),
          BottomNavigationBarItem(icon: Icon(Icons.class_), label: 'Batches'),
          BottomNavigationBarItem(icon: Icon(Icons.campaign), label: 'Notices'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildComplaintsList(List<ComplaintModel> complaints, ThemeData theme) {
    final user = ref.read(authStateProvider).value;
    final userName = user?.name ?? '';
    final myNameLower = userName.toLowerCase().replaceAll('dr.', '').trim();
    
    bool isAssignedToMe(String? assignedTo) {
      if (assignedTo == null || assignedTo.isEmpty) return false;
      final assignedToLower = assignedTo.toLowerCase().replaceAll('dr.', '').trim();
      return assignedToLower == myNameLower;
    }

    var filtered = complaints.where((c) {
      if (_selectedFilter == 'pending') return isAssignedToMe(c.assignedTo) && c.status != 'resolved' && c.status != 'rejected';
      if (_selectedFilter == 'processed') return (c.status == 'resolved' || c.status == 'rejected') && isAssignedToMe(c.assignedTo);
      if (_selectedFilter == 'forwarded') {
        return !isAssignedToMe(c.assignedTo) && c.involvedStaffNames.any((name) {
          final involvedLower = name.toLowerCase().replaceAll('dr.', '').trim();
          return involvedLower == myNameLower;
        });
      }
      return true;
    }).toList();

    if (filtered.isEmpty) {
      return const Center(child: Text('No complaints found in this category.', style: TextStyle(color: Colors.grey)));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final c = filtered[index];
        final myNameLower = (ref.read(authStateProvider).value?.name ?? '').toLowerCase().replaceAll('dr.', '').trim();
        final assignedToLower = (c.assignedTo ?? '').toLowerCase().replaceAll('dr.', '').trim();
        final isAssignedToMe = assignedToLower == myNameLower;
        final isPending = isAssignedToMe && c.status != 'resolved' && c.status != 'rejected';
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
    );
  }

  void _showActionDialog(BuildContext context, ComplaintModel c, String actionType) {
    final commentController = TextEditingController();
    bool forwardToOffice = false;
    
    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('${actionType == 'resolved' ? 'Resolve' : 'Reject'} Complaint'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Please provide a comment for this action:'),
                  const SizedBox(height: 12),
                  TextField(
                    controller: commentController,
                    decoration: InputDecoration(
                      hintText: 'Enter comment...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    maxLines: 3,
                  ),
                  if (actionType == 'resolved') ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Checkbox(
                          value: forwardToOffice,
                          onChanged: (val) {
                            setState(() {
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
                    final defaultResolvedComment = forwardToOffice 
                        ? 'Issue resolved by coordinator (Forwarded to Office for notification)'
                        : 'Issue resolved by coordinator';
                    final comment = commentController.text.trim().isEmpty 
                        ? (actionType == 'resolved' ? defaultResolvedComment : 'Returned by coordinator')
                        : commentController.text.trim();
                    
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
