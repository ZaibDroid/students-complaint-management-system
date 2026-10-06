import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../features/dashboard/presentation/widgets/staff_complaint_card.dart';
import '../../../../features/complaints/presentation/providers/complaint_provider.dart';

class ChairmanComplaintsTab extends ConsumerWidget {
  const ChairmanComplaintsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final asyncComplaints = ref.watch(departmentComplaintsProvider);
    
    return asyncComplaints.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: $e')),
      data: (complaints) {
        final escalatedComplaints = complaints.where((c) => c.status != 'resolved' && c.status != 'rejected').toList();
        
        if (escalatedComplaints.isEmpty) {
          return Center(
            child: Text(
              'No escalated complaints',
              style: theme.textTheme.bodyLarge,
            ),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: escalatedComplaints.length,
          itemBuilder: (context, index) {
            final c = escalatedComplaints[index];
            return StaffComplaintCard(
              studentName: c.studentName,
              batch: c.studentBatch ?? 'N/A',
              title: c.title,
                status: c.status,
                assignedTo: c.assignedTo,
              date: 'Just now',
              onForward: () {
                 context.push('/select_recipient', extra: c);
              },
              onResolve: () {
                ref.read(submitComplaintProvider.notifier).updateStatus(c.id, 'resolved', 'Resolved by Chairman');
              },
              onReject: () {
                ref.read(submitComplaintProvider.notifier).updateStatus(c.id, 'rejected', 'Invalid');
              },
            );
          },
        );
      },
    );
  }
}
