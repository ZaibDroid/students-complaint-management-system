import 'package:flutter/material.dart';
import '../../data/models/complaint_model.dart';

class ComplaintStatusHeader extends StatelessWidget {
  final ComplaintModel complaint;

  const ComplaintStatusHeader({super.key, required this.complaint});

  Color _getStatusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
        return Colors.green.shade100;
      case 'rejected':
        return Colors.red.shade100;
      case 'forwarded':
        return Colors.indigo.shade100;
      default:
        return Colors.orange.shade100;
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
        return Colors.green.shade700;
      case 'rejected':
        return Colors.red.shade700;
      case 'forwarded':
        return Colors.indigo.shade700;
      default:
        return Colors.orange.shade700;
    }
  }

  String _formatDate(DateTime dt) {
    final year = dt.year;
    final month = dt.month.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$year-$month-$day $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final ticketDisplay = complaint.ticketNumber ??
        'ID: ${complaint.id.length > 8 ? complaint.id.substring(0, 8).toUpperCase() : complaint.id}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Ticket Number & Status Badge
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              ticketDisplay,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusBgColor(complaint.status),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                complaint.status.toUpperCase(),
                style: TextStyle(
                  color: _getStatusTextColor(complaint.status),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Complaint Title
        Text(
          complaint.title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        // Metadata: Date & Category
        Row(
          children: [
            Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: 4),
            Text(
              _formatDate(complaint.createdAt),
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            const SizedBox(width: 16),
            Icon(Icons.category, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: 4),
            Text(
              complaint.category,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }
}

