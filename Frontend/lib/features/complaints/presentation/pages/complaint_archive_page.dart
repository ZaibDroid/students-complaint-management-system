import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/dashboard/presentation/widgets/dashboard_app_bar.dart';
import '../../../../features/complaints/presentation/providers/complaint_provider.dart';
import '../../../../features/dashboard/presentation/widgets/staff_complaint_card.dart';
import '../../../../features/dashboard/presentation/widgets/complaint_status_card.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

class ComplaintArchivePage extends ConsumerStatefulWidget {
  final String initialFilter;
  const ComplaintArchivePage({super.key, this.initialFilter = 'all'});

  @override
  ConsumerState<ComplaintArchivePage> createState() => _ComplaintArchivePageState();
}

class _ComplaintArchivePageState extends ConsumerState<ComplaintArchivePage> {
  String _selectedFilter = 'all'; // all, pending, resolved, rejected, forwarded

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.initialFilter;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider).value;
    final role = authState?.role.toLowerCase() ?? '';
    final isStudent = role == 'student';
    final isAdmin = role == 'admin';
    
    final asyncComplaints = isAdmin 
        ? ref.watch(allComplaintsProvider) 
        : (isStudent ? ref.watch(studentComplaintsProvider) : ref.watch(departmentComplaintsProvider));

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8FC),
      appBar: const DashboardAppBar(),
      body: Column(
        children: [
          // Header & Filters
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Access and review all historical resolution records.',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All', 'all'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Pending', 'pending'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Resolved', 'resolved'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Rejected', 'rejected'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Forwarded', 'forwarded'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // List
          Expanded(
            child: asyncComplaints.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error: $e')),
              data: (complaints) {
                final archived = complaints.where((c) {
                  // Filter by status
                  if (_selectedFilter != 'all' && c.status.toLowerCase() != _selectedFilter) {
                    return false;
                  }
                  return true;
                }).toList();

                if (archived.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      await ref.read(studentComplaintsProvider.notifier).refresh();
                      await ref.read(allComplaintsProvider.notifier).refresh();
                      await ref.read(departmentComplaintsProvider.notifier).refresh();
                    },
                    child: ListView(
                      children: const [
                        SizedBox(height: 100),
                        Center(child: Text('No archived records found.')),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await ref.read(studentComplaintsProvider.notifier).refresh();
                    await ref.read(allComplaintsProvider.notifier).refresh();
                    await ref.read(departmentComplaintsProvider.notifier).refresh();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: archived.length,
                    itemBuilder: (context, index) {
                      final c = archived[index];
                      
                      if (isStudent) {
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
                            borderRadius: BorderRadius.circular(16),
                            child: ComplaintStatusCard(
                              title: c.title,
                              description: c.description,
                              category: c.category,
                              assignedTo: c.assignedTo ?? 'Unassigned',
                              createdAt: c.createdAt,
                              status: status,
                            ),
                          ),
                        );
                      }
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: InkWell(
                        onTap: () => context.push('/complaint_details', extra: c),
                        child: StaffComplaintCard(
                          studentName: c.studentName,
                          batch: c.studentBatch ?? 'N/A',
                          title: c.title,
                          status: c.status,
                          assignedTo: c.assignedTo,
                          date: 'Archived', 
                          onForward: () {}, 
                          onResolve: () {}, 
                          onReject: () {}, 
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    final theme = Theme.of(context);
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedFilter = value);
        }
      },
      selectedColor: theme.primaryColor.withValues(alpha: 0.1),
      labelStyle: TextStyle(
        color: isSelected ? theme.primaryColor : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: Colors.grey.shade100,
      side: BorderSide(
        color: isSelected ? theme.primaryColor : Colors.grey.shade300,
      ),
    );
  }
}
