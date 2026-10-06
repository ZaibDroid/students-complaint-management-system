import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/api_client.dart';
import '../../../../features/dashboard/presentation/widgets/dashboard_app_bar.dart';
import '../../../../features/dashboard/presentation/widgets/staff_complaint_card.dart';
import '../../../../features/complaints/presentation/providers/complaint_provider.dart';
import '../../../../features/complaints/data/models/complaint_model.dart';
import '../../../../features/auth/domain/entities/user.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../features/profile/presentation/widgets/stat_card.dart';
import '../../../../features/profile/presentation/pages/user_profile_page.dart';
import '../../../../features/notice_board/presentation/pages/staff_notice_board_page.dart';

class SelectedAssignmentNotifier extends Notifier<Map<String, dynamic>?> {
  @override
  Map<String, dynamic>? build() => null;
  void setAssignment(Map<String, dynamic>? assignment) => state = assignment;
}

final selectedAssignmentProvider = NotifierProvider<SelectedAssignmentNotifier, Map<String, dynamic>?>(() {
  return SelectedAssignmentNotifier();
});

final adviserStudentsProvider = StreamProvider.autoDispose<List<User>>((ref) async* {
  final authState = ref.watch(authStateProvider).value;
  if (authState == null) {
    yield [];
    return;
  }
  
  try {
    final apiClient = ApiClient();
    final data = await apiClient.get('/users/students');
    if (data is List) {
      final students = data.map((item) => User.fromJson(item as Map<String, dynamic>)).toList();
      final myNameLower = authState.name.toLowerCase().replaceAll('dr.', '').trim();
      final selectedAssignment = ref.watch(selectedAssignmentProvider);
      
      final filtered = students.where((s) {
        if (s.adviser == null || s.adviser!.isEmpty) return false;
        final adviserLower = s.adviser!.toLowerCase().replaceAll('dr.', '').trim();
        final matchesName = adviserLower.contains(myNameLower) || myNameLower.contains(adviserLower);
        
        if (!matchesName) return false;
        
        if (selectedAssignment != null) {
          return s.batch == selectedAssignment['batch'] && s.section == selectedAssignment['section'];
        }
        
        return true;
      }).toList();

      yield filtered;
    } else {
      yield [];
    }
  } catch (_) {
    yield [];
  }
});

final adviserComplaintsProvider = StreamProvider.autoDispose<List<ComplaintModel>>((ref) async* {
  final authState = ref.watch(authStateProvider).value;
  if (authState == null) {
    yield [];
    return;
  }
  
  final studentsAsync = ref.watch(adviserStudentsProvider);
  if (!studentsAsync.hasValue) {
    yield [];
    return;
  }
  
  final linkedStudentsIds = studentsAsync.value!.map((s) => s.id).toSet();
  
  try {
    final apiClient = ApiClient();
    final data = await apiClient.get('/complaints');
    if (data is List) {
      final complaints = data.map((item) => ComplaintModel.fromMap(item as Map<String, dynamic>, (item['id'] ?? '').toString())).toList();
      final filtered = complaints.where((c) => linkedStudentsIds.contains(c.studentId)).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      yield filtered;
    } else {
      yield [];
    }
  } catch (_) {
    yield [];
  }
});

class AdviserDashboardPage extends ConsumerStatefulWidget {
  const AdviserDashboardPage({super.key});

  @override
  ConsumerState<AdviserDashboardPage> createState() => _AdviserDashboardPageState();
}

class _AdviserDashboardPageState extends ConsumerState<AdviserDashboardPage> {
  String _selectedFilter = 'pending'; // 'pending', 'resolved', 'forwarded', 'processed', 'students'
  String _studentFilter = 'pending'; // 'pending', 'linked'
  int _bottomNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final asyncComplaints = ref.watch(adviserComplaintsProvider);
    final asyncStudents = ref.watch(adviserStudentsProvider);

    List<ComplaintModel> complaints = asyncComplaints.value ?? [];
    List<User> students = asyncStudents.value ?? [];
    List<User> pendingStudents = students.where((s) => s.status == 'pending').toList();

    final user = ref.read(authStateProvider).value;
    final userName = user?.name ?? '';
    final myNameLower = userName.toLowerCase().replaceAll('dr.', '').trim();
    
    bool isAssignedToMe(String? assignedTo) {
      if (assignedTo == null || assignedTo.isEmpty) return false;
      final assignedToLower = assignedTo.toLowerCase().replaceAll('dr.', '').trim();
      return assignedToLower == myNameLower;
    }
    
    final pendingCount = complaints.where((c) => isAssignedToMe(c.assignedTo) && c.status != 'resolved' && c.status != 'rejected').length;
    final resolvedCount = complaints.where((c) => c.status == 'resolved' && isAssignedToMe(c.assignedTo)).length;
    final forwardedCount = complaints.where((c) => !isAssignedToMe(c.assignedTo) && c.involvedStaffNames.any((name) {
      final involvedLower = name.toLowerCase().replaceAll('dr.', '').trim();
      return involvedLower == myNameLower;
    }) && c.status != 'resolved').length;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8FC),
      appBar: const DashboardAppBar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                if (_bottomNavIndex == 0) ...[
                  if (user?.assignedSections != null && user!.assignedSections!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: DropdownButtonFormField<Map<String, dynamic>>(
                        initialValue: ref.watch(selectedAssignmentProvider),
                        decoration: InputDecoration(
                          labelText: 'Filter by Batch & Section',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          prefixIcon: const Icon(Icons.filter_list),
                        ),
                        items: [
                          const DropdownMenuItem<Map<String, dynamic>>(
                            value: null,
                            child: Text('All Assigned Sections'),
                          ),
                          ...user.assignedSections!.map((assignment) {
                            return DropdownMenuItem<Map<String, dynamic>>(
                              value: assignment,
                              child: Text('${assignment['batch']} - Section ${assignment['section']}'),
                            );
                          }),
                        ],
                        onChanged: (val) {
                          ref.read(selectedAssignmentProvider.notifier).setAssignment(val);
                        },
                      ),
                    ),
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
                          value: resolvedCount.toString(),
                          label: 'RESOLVED',
                          isSelected: _selectedFilter == 'resolved',
                          onTap: () => setState(() => _selectedFilter = 'resolved'),
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
              ],
            ),
          ),
          const SizedBox(height: 12),
          
          Expanded(
            child: _bottomNavIndex == 3
                ? const UserProfilePage(isSubPage: false)
                : _bottomNavIndex == 2
                ? const StaffNoticeBoardPage()
                : _selectedFilter == 'students'
                ? _buildStudentsList(students, theme)
                : _buildComplaintsList(complaints, theme),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomNavIndex,
        onTap: (index) {
          setState(() {
            _bottomNavIndex = index;
            if (index == 0) _selectedFilter = 'pending';
            if (index == 1) _selectedFilter = 'students';
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: theme.primaryColor,
        unselectedItemColor: Colors.grey.shade400,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.person_add),
                if (pendingStudents.isNotEmpty)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      child: Text('${pendingStudents.length}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  )
              ],
            ),
            label: 'Requests',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.campaign), label: 'Notices'),
          const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }



  void _showActionDialog(BuildContext context, ComplaintModel c, String actionType) {
    final commentController = TextEditingController();
    bool forwardToOffice = false;
    
    showDialog(
      context: context,
      builder: (context) {
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
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final defaultResolvedComment = forwardToOffice 
                        ? 'Issue resolved by adviser (Forwarded to Office for notification)'
                        : 'Issue resolved by adviser';
                    final comment = commentController.text.trim().isEmpty 
                        ? (actionType == 'resolved' ? defaultResolvedComment : 'Invalid complaint')
                        : commentController.text.trim();
                    
                    final action = (actionType == 'resolved' && forwardToOffice) ? 'forwarded' : actionType;
                    final assignedTo = (actionType == 'resolved' && forwardToOffice) ? 'Office' : null;
                    
                    ref.read(submitComplaintProvider.notifier).updateStatus(c.id, action, comment, assignedTo: assignedTo);
                    Navigator.pop(context);
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
      if (_selectedFilter == 'resolved') return c.status == 'resolved' && isAssignedToMe(c.assignedTo);
      if (_selectedFilter == 'forwarded') {
        return !isAssignedToMe(c.assignedTo) && c.involvedStaffNames.any((name) {
          final involvedLower = name.toLowerCase().replaceAll('dr.', '').trim();
          return involvedLower == myNameLower;
        });
      }
      if (_selectedFilter == 'processed') return (c.status == 'resolved' || c.status == 'rejected') && isAssignedToMe(c.assignedTo);
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

  Widget _buildStudentsList(List<User> students, ThemeData theme) {
    final pendingStudents = students.where((s) => s.status == 'pending').toList();
    final approvedStudents = students.where((s) => s.status == 'approved').toList();

    final displayStudents = _studentFilter == 'pending' ? pendingStudents : approvedStudents;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: SizedBox(
            width: double.infinity,
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'pending',
                  label: Text('Pending Requests'),
                  icon: Icon(Icons.person_add, size: 18),
                ),
                ButtonSegment(
                  value: 'linked',
                  label: Text('Linked Students'),
                  icon: Icon(Icons.people, size: 18),
                ),
              ],
              selected: {_studentFilter},
              onSelectionChanged: (newSelection) {
                setState(() {
                  _studentFilter = newSelection.first;
                });
              },
              style: SegmentedButton.styleFrom(
                backgroundColor: Colors.white,
                selectedBackgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                selectedForegroundColor: theme.primaryColor,
              ),
            ),
          ),
        ),
        Expanded(
          child: displayStudents.isEmpty
              ? Center(
                  child: Text(
                    _studentFilter == 'pending'
                        ? 'No pending requests.'
                        : 'No linked students found.',
                    style: const TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: displayStudents.length,
                  itemBuilder: (context, index) {
                    return _buildStudentCard(
                      displayStudents[index],
                      theme,
                      isPending: _studentFilter == 'pending',
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildStudentCard(User s, ThemeData theme, {required bool isPending}) {
    final regNo = s.registrationNumber ?? 
        (s.email.contains('@') ? s.email.split('@')[0].toUpperCase() : 'N/A');

    String batchDisplay = s.batch ?? 'N/A';
    if (batchDisplay == 'N/A' && s.year != null && s.year!.isNotEmpty) {
      batchDisplay = s.year!;
    }
    if (batchDisplay == 'N/A' && RegExp(r'^\d{2}').hasMatch(regNo)) {
      final prefix = regNo.substring(0, 2);
      batchDisplay = 'Batch 20$prefix';
    }

    String sectionDisplay = s.section ?? 'N/A';
    if (sectionDisplay == 'N/A' && s.semester != null && s.semester!.isNotEmpty) {
      sectionDisplay = s.semester!;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
              backgroundImage: s.profileImageUrl != null ? NetworkImage(s.profileImageUrl!) : null,
              child: s.profileImageUrl == null ? Icon(Icons.person, color: theme.primaryColor, size: 28) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          s.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          regNo,
                          style: TextStyle(
                            color: theme.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    s.email,
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.school_outlined, size: 14, color: Colors.blue.shade800),
                            const SizedBox(width: 4),
                            Text(
                              'Batch: $batchDisplay',
                              style: TextStyle(color: Colors.blue.shade900, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.purple.shade200),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.class_outlined, size: 14, color: Colors.purple.shade800),
                            const SizedBox(width: 4),
                            Text(
                              'Section: $sectionDisplay',
                              style: TextStyle(color: Colors.purple.shade900, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            isPending
                ? Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.check, color: Colors.green, size: 20),
                          tooltip: 'Approve Student',
                          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                          padding: EdgeInsets.zero,
                          onPressed: () async {
                            await ref.read(apiAuthRepositoryProvider).updateUserStatus(s.id, 'approved');
                            ref.invalidate(adviserStudentsProvider);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Student approved successfully.')));
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.red, size: 20),
                          tooltip: 'Reject Student',
                          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                          padding: EdgeInsets.zero,
                          onPressed: () async {
                            await ref.read(apiAuthRepositoryProvider).updateUserStatus(s.id, 'rejected');
                            ref.invalidate(adviserStudentsProvider);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Student rejected.')));
                            }
                          },
                        ),
                      ),
                    ],
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: const Text('Linked', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 11)),
                  ),
          ],
        ),
      ),
    );
  }
}
