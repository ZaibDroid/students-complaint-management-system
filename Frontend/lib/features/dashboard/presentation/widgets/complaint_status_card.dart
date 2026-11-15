import 'package:flutter/material.dart';

enum ComplaintStatus { pending, forwarded, resolved, rejected }

class ComplaintStatusCard extends StatelessWidget {
  final String? id;
  final String title;
  final String description;
  final DateTime? createdAt;
  final String timeAgo;
  final String category;
  final String assignedTo;
  final ComplaintStatus status;

  const ComplaintStatusCard({
    super.key,
    this.id,
    required this.title,
    required this.description,
    this.createdAt,
    this.timeAgo = '',
    this.category = '',
    this.assignedTo = '',
    required this.status,
  });

  static String formatDateTime(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final month = months[dt.month - 1];
    final day = dt.day.toString().padLeft(2, '0');
    final year = dt.year;

    final hour24 = dt.hour;
    final hour12 = hour24 == 0 ? 12 : (hour24 > 12 ? hour24 - 12 : hour24);
    final minute = dt.minute.toString().padLeft(2, '0');
    final ampm = hour24 >= 12 ? 'PM' : 'AM';

    return '$day $month $year • $hour12:$minute $ampm';
  }

  String get _formattedDateTime {
    if (createdAt != null) {
      return formatDateTime(createdAt!);
    }
    if (timeAgo.isNotEmpty) {
      return timeAgo;
    }
    return '';
  }

  Color _getStatusColor() {
    switch (status) {
      case ComplaintStatus.resolved:
        return const Color(0xFF10B981);
      case ComplaintStatus.forwarded:
        return const Color(0xFF4F46E5);
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
        return 'FORWARDED';
      case ComplaintStatus.pending:
        return 'PENDING';
      case ComplaintStatus.rejected:
        return 'REJECTED';
    }
  }

  IconData _getStatusIcon() {
    switch (status) {
      case ComplaintStatus.resolved:
        return Icons.check_circle_rounded;
      case ComplaintStatus.forwarded:
        return Icons.forward_to_inbox_rounded;
      case ComplaintStatus.pending:
        return Icons.hourglass_top_rounded;
      case ComplaintStatus.rejected:
        return Icons.cancel_rounded;
    }
  }

  String _displayAssignedTo() {
    if (assignedTo.isEmpty || assignedTo.toLowerCase() == 'unassigned') {
      return 'Batch Adviser';
    }
    return assignedTo;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor();
    final formattedTime = _formattedDateTime;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left Status Accent Strip
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),

            // Card Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Row: Formatted Date/Time on left, Status Badge on right (ID is hidden)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (formattedTime.isNotEmpty)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 13,
                                color: Colors.grey.shade500,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                formattedTime,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          )
                        else
                          const SizedBox.shrink(),

                        // Status Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: statusColor.withValues(alpha: 0.25)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_getStatusIcon(), size: 12, color: statusColor),
                              const SizedBox(width: 4),
                              Text(
                                _getStatusText(),
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.4,
                                  color: statusColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Complaint Title
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                        height: 1.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 5),

                    // Complaint Description
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 12),
                    Divider(height: 1, color: Colors.grey.shade100),
                    const SizedBox(height: 10),

                    // Bottom Row: Category on left side, Teacher/Adviser on right side
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Left: Category Tag
                        if (category.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.label_outline_rounded,
                                  size: 13,
                                  color: theme.primaryColor,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  category,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: theme.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          const SizedBox.shrink(),

                        const SizedBox(width: 8),

                        // Right: Teacher or Batch Adviser Name
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Icon(
                                Icons.person_outline_rounded,
                                size: 15,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 5),
                              Flexible(
                                child: Text(
                                  _displayAssignedTo(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade800,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
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
