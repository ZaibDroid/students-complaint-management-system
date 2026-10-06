import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../complaints/presentation/providers/complaint_provider.dart';

import '../../../../features/dashboard/presentation/widgets/staff_complaint_card.dart';

class AdminDashboardPage extends ConsumerStatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  ConsumerState<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends ConsumerState<AdminDashboardPage> {
  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final complaintsAsync = ref.watch(allComplaintsProvider);
    
    int totalComplaints = 0;
    int pendingComplaints = 0;
    int forwardedComplaints = 0;
    int resolvedComplaints = 0;

    complaintsAsync.whenData((complaints) {
      totalComplaints = complaints.length;
      for (var c in complaints) {
        if (c.status == 'pending') {
          pendingComplaints++;
        } else if (c.status == 'forwarded') {
          forwardedComplaints++;
        } else if (c.status == 'resolved' || c.status == 'rejected') {
          resolvedComplaints++;
        }
      }
    });
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Portal'),
      ),
      body: complaintsAsync.when(
        data: (complaints) {
          final filteredComplaints = complaints.where((c) {
            if (_selectedFilter == 'all') return true;
            if (_selectedFilter == 'pending') return c.status == 'pending';
            if (_selectedFilter == 'forwarded') return c.status == 'forwarded';
            if (_selectedFilter == 'resolved') return c.status == 'resolved' || c.status == 'rejected';
            return true;
          }).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "System Analytics",
                      style: theme.textTheme.displayMedium,
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.35,
                      children: [
                        _buildStatCard('Total', totalComplaints.toString(), Colors.blue, Icons.assessment, 'all'),
                        _buildStatCard('Pending', pendingComplaints.toString(), Colors.orange, Icons.pending_actions, 'pending'),
                        _buildStatCard('Forwarded', forwardedComplaints.toString(), Colors.purple, Icons.forward_to_inbox, 'forwarded'),
                        _buildStatCard('Resolved', resolvedComplaints.toString(), Colors.green, Icons.check_circle, 'resolved'),
                      ],
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Complaints',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: filteredComplaints.isEmpty
                    ? const Center(child: Text('No complaints found in this category.', style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        itemCount: filteredComplaints.length,
                        itemBuilder: (context, index) {
                          final c = filteredComplaints[index];
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
                                onForward: null,
                                onResolve: null,
                                onReject: null,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading data: $err', style: const TextStyle(color: Colors.red))),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon, String filterValue) {
    final isSelected = _selectedFilter == filterValue;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedFilter = filterValue;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? color.withValues(alpha: 0.8) : color.withValues(alpha: 0.2), width: isSelected ? 2 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const Spacer(),
                Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87)),
          ],
        ),
      ),
    );
  }
}
