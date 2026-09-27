import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../../core/widgets/timeline_card.dart';
import '../providers/complaints_provider.dart';

class ComplaintTrackingPage extends ConsumerWidget {
  final String complaintId;

  const ComplaintTrackingPage({super.key, required this.complaintId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(complaintDetailProvider(complaintId));
    final complaint = state.complaint;

    if (state.isLoading && complaint == null) {
      return const Scaffold(body: LoadingWidget(message: 'Loading tracking timeline...'));
    }

    if (complaint == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Complaint Tracking')),
        body: const Center(child: Text('Complaint not found')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Lifecycle & Timeline'),
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ticket Header
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
                        Text(
                          complaint.trackingNumber,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        StatusChip(status: complaint.status),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      complaint.title,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'Workflow History',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 16),

              if (complaint.timeline.isEmpty)
                const EmptyState(
                  icon: Icons.timeline,
                  title: 'No Timeline Events',
                  message: 'This complaint is newly lodged and awaiting action.',
                )
              else
                ...complaint.timeline.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return TimelineCard(
                    title: item.title,
                    actorName: item.actorName,
                    actorRole: item.actorRole,
                    remarks: item.remarks,
                    status: item.status,
                    timestamp: item.timestamp,
                    isFirst: index == 0,
                    isLast: index == complaint.timeline.length - 1,
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}
