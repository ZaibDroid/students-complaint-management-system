import 'package:flutter/material.dart';
import '../widgets/complaint_status_card.dart';

import '../widgets/dashboard_app_bar.dart';
import '../widgets/quick_action_card.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../complaints/presentation/providers/complaint_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../admin/presentation/providers/adviser_assignment_provider.dart';
import '../../../notice_board/presentation/providers/notice_provider.dart';
import '../../../notice_board/presentation/widgets/notice_board_card.dart';

class StudentDashboardPage extends ConsumerStatefulWidget {
  const StudentDashboardPage({super.key});

  @override
  ConsumerState<StudentDashboardPage> createState() => _StudentDashboardPageState();
}

class _StudentDashboardPageState extends ConsumerState<StudentDashboardPage> {
  String? _selectedAdviser;
  bool _isSubmitting = false;

  Future<void> _sendAdviserRequest(String uid) async {
    if (_selectedAdviser == null) return;
    setState(() => _isSubmitting = true);
    try {
      await ref.read(apiAuthRepositoryProvider).updateUserAdviser(uid, _selectedAdviser!);
      await ref.read(authStateProvider.notifier).refreshUser();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request sent successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(authStateProvider).value;
    final advisersAsync = ref.watch(batchAdvisersStreamProvider);
    final batchAdvisers = advisersAsync.value ?? [];

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isApproved = user.status == 'approved';
    final isPending = user.status == 'pending';
    final isRejected = user.status == 'rejected';

    if (!isApproved) {
      return Scaffold(
        backgroundColor: const Color(0xFFFBF8FC),
        appBar: const DashboardAppBar(),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isPending ? Colors.blue.shade50 : (isRejected ? Colors.red.shade50 : Colors.amber.shade50),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isPending ? Icons.hourglass_empty_rounded : (isRejected ? Icons.cancel_outlined : Icons.link),
                      size: 64,
                      color: isPending ? Colors.blue : (isRejected ? Colors.red : Colors.amber.shade700),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    isPending ? 'Request Pending' : (isRejected ? 'Request Rejected' : 'Link Batch Adviser'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isPending 
                        ? 'Your request is currently awaiting approval from ${user.adviser}. You will gain access to your dashboard once approved.'
                        : (isRejected 
                            ? 'Your previous request was rejected by the Batch Adviser. Please select a different adviser below.' 
                            : 'Welcome! Before you can access your dashboard and submit complaints, you must link your account to your Batch Adviser.'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.black54, height: 1.5),
                  ),
                  const SizedBox(height: 32),
                  
                  if (!isPending) ...[
                    const Text('Select Your Batch Adviser', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedAdviser,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      isExpanded: true,
                      items: batchAdvisers.map((a) {
                        String detail = '';
                        if (a.assignedSections != null && a.assignedSections!.isNotEmpty) {
                          final secList = a.assignedSections!.map((s) => '${s['batch'] ?? ''} ${s['section'] ?? ''}'.trim()).where((s) => s.isNotEmpty).join(', ');
                          if (secList.isNotEmpty) detail = ' ($secList)';
                        } else if (a.batch != null || a.section != null) {
                          final bName = a.batch ?? '';
                          final sName = a.section ?? '';
                          detail = ' ($bName $sName)'.trim();
                        }
                        final display = '${a.name}$detail';
                        return DropdownMenuItem(value: a.name, child: Text(display, overflow: TextOverflow.ellipsis));
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedAdviser = val),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isSubmitting || _selectedAdviser == null ? null : () => _sendAdviserRequest(user.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isSubmitting 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
                          : const Text('Send Link Request', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ],

                  if (isPending)
                    OutlinedButton(
                      onPressed: () {
                        // Reset status to unlinked if they want to cancel and choose someone else
                        ref.read(apiAuthRepositoryProvider).updateUserStatus(user.id, 'unlinked');
                        ref.read(authStateProvider.notifier).refreshUser();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Cancel Request'),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8FC),
      appBar: const DashboardAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [


            // Active Complaints
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Active Complaints',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: theme.primaryColor,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    context.push('/complaint_archive');
                  },
                  child: Text('View all', style: TextStyle(color: theme.primaryColor)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ref.watch(studentComplaintsProvider).when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error loading complaints: $e')),
              data: (complaints) {
                final activeComplaints = complaints.where((c) {
                  final status = c.status.toLowerCase();
                  return status != 'resolved' && status != 'rejected';
                }).toList();

                if (activeComplaints.isEmpty) {
                  return const Center(child: Text('No active complaints.'));
                }
                return Column(
                  children: activeComplaints.take(3).map((c) {
                    ComplaintStatus status;
                    switch (c.status.toLowerCase()) {
                      case 'resolved': status = ComplaintStatus.resolved; break;
                      case 'rejected': status = ComplaintStatus.rejected; break;
                      case 'forwarded': status = ComplaintStatus.forwarded; break;
                      default: status = ComplaintStatus.pending;
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: InkWell(
                        onTap: () => context.push('/complaint_details', extra: c),
                        borderRadius: BorderRadius.circular(12),
                        child: ComplaintStatusCard(
                          id: c.id.length > 6 ? c.id.substring(0, 6).toUpperCase() : c.id,
                          title: c.title,
                          description: c.description,
                          category: c.category,
                          assignedTo: c.assignedTo ?? 'Unassigned',
                          timeAgo: '${c.createdAt.day.toString().padLeft(2, '0')}-${c.createdAt.month.toString().padLeft(2, '0')}-${c.createdAt.year} ${c.createdAt.hour.toString().padLeft(2, '0')}:${c.createdAt.minute.toString().padLeft(2, '0')}',
                          status: status,
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 32),

            // Recent Notices
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.campaign, color: theme.primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      'Recent Notices',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: theme.primaryColor,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    context.push('/student_notices');
                  },
                  child: Text('See archives', style: TextStyle(color: theme.primaryColor)),
                ),
              ],
            ),
            ref.watch(noticesStreamProvider).when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error loading notices: $e')),
              data: (notices) {
                final studentBatch = user.batch ?? '';
                final studentSection = user.section ?? '';
                final isCR = user.isCR;

                final myNotices = notices.where((n) {
                  // If explicitly targeted roles exist but don't include Student, skip
                  if (n.targetRoles != null && n.targetRoles!.isNotEmpty && !n.targetRoles!.contains('Student')) {
                    return false;
                  }

                  // If it's targeted at Students, check student-specific constraints
                  if (n.targetRoles != null && n.targetRoles!.contains('Student')) {
                    if (n.targetCRsOnly == true && isCR == false) return false;
                    
                    if (n.targetBatches != null && n.targetBatches!.isNotEmpty) {
                      if (!n.targetBatches!.contains(studentBatch)) return false;
                    }
                    if (n.targetSections != null && n.targetSections!.isNotEmpty) {
                      if (!n.targetSections!.contains(studentSection)) return false;
                    }
                  }
                  return true;
                }).toList();

                if (myNotices.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: Text('No recent notices', style: TextStyle(color: Colors.grey))),
                  );
                }

                return Column(
                  children: myNotices.take(2).map((notice) {
                    final date = notice.createdAt;
                    final dateStr = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
                    
                    return NoticeBoardCard(
                      title: notice.title,
                      description: notice.description,
                      tag: notice.tag,
                      date: dateStr,
                      sender: notice.senderName,
                      senderIcon: Icons.person,
                      isUrgent: notice.tag == 'Urgent',
                      attachments: notice.attachments,
                      onTap: () {
                        context.push('/notice_details', extra: notice);
                      },
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 32),

            // Quick Actions
            Row(
              children: [
                Expanded(
                  child: QuickActionCard(
                    icon: Icons.help_center,
                    title: 'Filing Guide',
                    subtitle: 'Learn how to file',
                    color: theme.primaryColor,
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: QuickActionCard(
                    icon: Icons.history,
                    title: 'History',
                    subtitle: 'Check past cases',
                    color: Colors.orange,
                    onTap: () {
                      context.push('/complaint_archive');
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 80), // Padding for bottom nav
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/submit_complaint');
        },
        backgroundColor: theme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
