import 'package:flutter/material.dart';

class StaffComplaintCard extends StatelessWidget {
  final String studentName;
  final String batch;
  final String title;
  final String status;
  final String? assignedTo;
  final String date;
  final VoidCallback? onForward;
  final VoidCallback? onResolve;
  final VoidCallback? onReject;

  const StaffComplaintCard({
    super.key,
    required this.studentName,
    required this.batch,
    required this.title,
    required this.status,
    this.assignedTo,
    required this.date,
    this.onForward,
    this.onResolve,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    
    Color statusColor;
    switch (status.toLowerCase()) {
      case 'resolved':
        statusColor = Colors.green;
        break;
      case 'forwarded':
        statusColor = Colors.indigo;
        break;
      case 'rejected':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.orange;
    }

    String displayStatus = status.toUpperCase();
    if (status.toLowerCase() == 'forwarded' && assignedTo != null && assignedTo!.isNotEmpty) {
      displayStatus = 'FORWARDED TO ${assignedTo!.toUpperCase()}';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: statusColor, width: 4)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    displayStatus,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Text(
                  date,
                  style: const TextStyle(
                    color: Colors.black45,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.person_outline, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  studentName,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                const SizedBox(width: 12),
                Icon(Icons.class_outlined, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  batch,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
            if (onForward != null || onResolve != null || onReject != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (onForward != null)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onForward,
                        icon: const Icon(Icons.forward_to_inbox, size: 16),
                        label: const Text('Forward'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.indigo,
                          side: const BorderSide(color: Colors.indigo),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  if (onForward != null && onResolve != null) const SizedBox(width: 8),
                  if (onResolve != null)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onResolve,
                        icon: const Icon(Icons.check_circle_outline, size: 16),
                        label: const Text('Resolve'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  if (onResolve != null && onReject != null) const SizedBox(width: 8),
                  if (onReject != null)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onReject,
                        icon: const Icon(Icons.cancel_outlined, size: 16),
                        label: const Text('Reject'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
