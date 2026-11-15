import 'package:flutter/material.dart';

class StaffComplaintCard extends StatelessWidget {
  final String studentName;
  final String batch;
  final String? section;
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
    this.section,
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
    IconData statusIcon;

    switch (status.toLowerCase()) {
      case 'resolved':
        statusColor = const Color(0xFF16A34A); // Green
        statusIcon = Icons.check_circle_outline_rounded;
        break;
      case 'forwarded':
        statusColor = const Color(0xFF4F46E5); // Indigo
        statusIcon = Icons.forward_to_inbox_rounded;
        break;
      case 'rejected':
        statusColor = const Color(0xFFDC2626); // Red
        statusIcon = Icons.cancel_outlined;
        break;
      case 'in_progress':
      case 'under_review':
        statusColor = const Color(0xFF2563EB); // Blue
        statusIcon = Icons.sync_rounded;
        break;
      default:
        statusColor = const Color(0xFFD97706); // Amber
        statusIcon = Icons.schedule_rounded;
    }

    final displayStatus = status.replaceAll('_', ' ').toUpperCase();

    // Format badge text combining batch and section
    final cleanSection = (section ?? '').trim();
    String secLabel = '';
    if (cleanSection.isNotEmpty) {
      secLabel = cleanSection.toUpperCase().startsWith('SEC') 
          ? cleanSection 
          : 'Sec $cleanSection';
    }

    String badgeText = batch.trim();
    if (badgeText.isEmpty || badgeText.toUpperCase() == 'N/A') {
      badgeText = secLabel.isNotEmpty ? secLabel : 'Student';
    } else if (secLabel.isNotEmpty && !badgeText.toUpperCase().contains(secLabel.toUpperCase())) {
      badgeText = '$badgeText • $secLabel';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: statusColor, width: 4)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Status on Top-Left, Formatted Date & Time on Top-Right
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Top-Left Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 13, color: statusColor),
                      const SizedBox(width: 5),
                      Text(
                        displayStatus,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                // Top-Right Formatted Date & Time
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.access_time_rounded, size: 13, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      date,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Complaint Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),

            // Below Title: Complainer Name on Left, Batch & Section Badge on Right
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Complainer / Student Name
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.person_outline_rounded, size: 14, color: Colors.grey.shade700),
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          studentName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Batch & Section Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.school_outlined, size: 13, color: Color(0xFF475569)),
                      const SizedBox(width: 5),
                      Text(
                        badgeText,
                        style: const TextStyle(
                          color: Color(0xFF334155),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Forwarded Details (if status is forwarded)
            if (status.toLowerCase() == 'forwarded' && assignedTo != null && assignedTo!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.forward_to_inbox, size: 14, color: statusColor),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Forwarded to: $assignedTo',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Action Buttons (Forward, Resolve, Reject)
            if (onForward != null || onResolve != null || onReject != null) ...[
              const SizedBox(height: 14),
              const Divider(height: 1),
              const SizedBox(height: 10),
              Row(
                children: [
                  if (onForward != null)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onForward,
                        icon: const Icon(Icons.forward_to_inbox, size: 15),
                        label: const Text('Forward', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF4F46E5),
                          side: const BorderSide(color: Color(0xFF4F46E5)),
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  if (onForward != null && onResolve != null) const SizedBox(width: 8),
                  if (onResolve != null)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onResolve,
                        icon: const Icon(Icons.check_circle_outline, size: 15),
                        label: const Text('Resolve', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF16A34A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                      ),
                    ),
                  if (onResolve != null && onReject != null) const SizedBox(width: 8),
                  if (onReject != null)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onReject,
                        icon: const Icon(Icons.cancel_outlined, size: 15),
                        label: const Text('Reject', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFDC2626),
                          side: const BorderSide(color: Color(0xFFDC2626)),
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
