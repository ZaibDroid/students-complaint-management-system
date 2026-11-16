import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../admin/presentation/pages/adviser_dashboard_page.dart';
import '../providers/complaint_provider.dart';

Future<void> showComplaintActionDialog({
  required BuildContext context,
  required WidgetRef ref,
  required String complaintId,
  required String actionType,
}) async {
  final commentController = TextEditingController();
  String? errorMessage;

  return showDialog(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          final isResolved = actionType.toLowerCase() == 'resolved';
          final actionTitle = isResolved ? 'Resolve' : 'Reject';

          return AlertDialog(
            title: Text('$actionTitle Complaint'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Remarks / Comments ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.grey.shade800,
                      ),
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
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final comment = commentController.text.trim();
                  if (comment.isEmpty) {
                    setDialogState(() {
                      errorMessage = 'Remarks are compulsory to ${isResolved ? 'resolve' : 'reject'} this complaint.';
                    });
                    return;
                  }

                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => const Center(child: CircularProgressIndicator()),
                  );

                  final success = await ref
                      .read(submitComplaintProvider.notifier)
                      .updateStatus(complaintId, actionType, comment);

                  if (context.mounted) {
                    Navigator.pop(context); // close loading
                    Navigator.pop(context); // close dialog
                    if (success) {
                      ref.invalidate(adviserComplaintsProvider);
                      ref.invalidate(departmentComplaintsProvider);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Complaint $actionType successfully.')),
                      );
                      context.pop(); // go back from details page
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Action failed.')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isResolved ? Colors.green : Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Confirm'),
              ),
            ],
          );
        },
      );
    },
  );
}

