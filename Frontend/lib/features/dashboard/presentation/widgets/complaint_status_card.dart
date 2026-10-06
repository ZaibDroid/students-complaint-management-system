import 'package:flutter/material.dart';

enum ComplaintStatus { pending, forwarded, resolved, rejected }

class ComplaintStatusCard extends StatelessWidget {
  final String id;
  final String title;
  final String description;
  final String timeAgo;
  final String category;
  final String assignedTo;
  final ComplaintStatus status;

  const ComplaintStatusCard({
    super.key,
    required this.id,
    required this.title,
    required this.description,
    required this.timeAgo,
    this.category = '',
    this.assignedTo = '',
    required this.status,
  });

  Color _getStatusColor() {
    switch (status) {
      case ComplaintStatus.resolved:
        return const Color(0xFF10B981);
      case ComplaintStatus.forwarded:
        return const Color(0xFF6366F1);
      case ComplaintStatus.pending:
        return const Color(0xFFF59E0B);
      case ComplaintStatus.rejected:
        return const Color(0xFFEF4444);
    }
  }

  String _getStatusText() {
    switch (status) {
      case ComplaintStatus.resolved:
        return 'RESOLVED';
      case ComplaintStatus.forwarded:
      case ComplaintStatus.pending:
        return 'IN PROCESS';
      case ComplaintStatus.rejected:
        return 'REJECTED';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: statusColor),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                id.toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.2,
                  color: Colors.black54,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _getStatusText(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.primaryColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.black54,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),
          if (category.isNotEmpty || assignedTo.isNotEmpty) ...[
            Row(
              children: [
                if (category.isNotEmpty) ...[
                  Icon(Icons.category, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(category.toUpperCase(), style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 12),
                ],
                if (assignedTo.isNotEmpty) ...[
                  Icon(Icons.person, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(assignedTo, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ],
              ],
            ),
            const SizedBox(height: 8),
          ],
          Row(
            children: [
              Icon(Icons.schedule, size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                timeAgo,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      ),
    ),
  ),
],
        ),
      ),
    );
  }
}
