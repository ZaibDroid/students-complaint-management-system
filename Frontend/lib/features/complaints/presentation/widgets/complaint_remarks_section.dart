import 'package:flutter/material.dart';

class ComplaintRemarksSection extends StatelessWidget {
  final List<Map<String, dynamic>> remarks;
  final String? fallbackAdminRemarks;

  const ComplaintRemarksSection({
    super.key,
    required this.remarks,
    this.fallbackAdminRemarks,
  });

  String _getRoleHeading(String authorRole) {
    final lower = authorRole.toLowerCase();
    if (lower.contains('adviser') || lower.contains('advisor')) {
      return 'Batch Adviser Remarks';
    } else if (lower.contains('coordinator')) {
      return 'Coordinator Remarks';
    } else if (lower.contains('chairman') || lower.contains('chair')) {
      return 'Chairman Remarks';
    } else if (lower.contains('dean')) {
      return 'Dean Remarks';
    } else if (lower.contains('vc') || lower.contains('vice chancellor')) {
      return 'Vice Chancellor Remarks';
    } else if (lower.contains('office')) {
      return 'Department Office Remarks';
    } else if (lower.contains('admin')) {
      return 'System Admin Remarks';
    }
    return authorRole.isNotEmpty ? '$authorRole Remarks' : 'Official Remarks';
  }

  Color _getRoleColor(String authorRole) {
    final lower = authorRole.toLowerCase();
    if (lower.contains('adviser') || lower.contains('advisor')) {
      return const Color(0xFF4F46E5); // Indigo
    } else if (lower.contains('coordinator')) {
      return const Color(0xFF7C3AED); // Purple
    } else if (lower.contains('chairman') || lower.contains('chair')) {
      return const Color(0xFFD97706); // Amber
    } else if (lower.contains('dean')) {
      return const Color(0xFF0D9488); // Teal
    } else if (lower.contains('vc') || lower.contains('vice chancellor')) {
      return const Color(0xFF059669); // Emerald
    } else if (lower.contains('office')) {
      return const Color(0xFF0284C7); // Sky Blue
    }
    return const Color(0xFF64748B); // Slate
  }

  IconData _getRoleIcon(String authorRole) {
    final lower = authorRole.toLowerCase();
    if (lower.contains('adviser') || lower.contains('advisor')) {
      return Icons.school_outlined;
    } else if (lower.contains('coordinator')) {
      return Icons.alt_route_rounded;
    } else if (lower.contains('chairman') || lower.contains('chair')) {
      return Icons.account_balance_outlined;
    } else if (lower.contains('dean')) {
      return Icons.workspace_premium_outlined;
    } else if (lower.contains('vc') || lower.contains('vice chancellor')) {
      return Icons.military_tech_outlined;
    } else if (lower.contains('office')) {
      return Icons.desk_outlined;
    }
    return Icons.comment_outlined;
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    final dt = DateTime.tryParse(dateStr);
    if (dt == null) return dateStr;
    final year = dt.year;
    final month = dt.month.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$year-$month-$day $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final hasRemarks = remarks.isNotEmpty;
    final hasFallback = fallbackAdminRemarks != null && fallbackAdminRemarks!.trim().isNotEmpty;

    if (!hasRemarks && !hasFallback) {
      return const SizedBox.shrink();
    }

    // If no structured remarks exist, display fallback single admin remarks
    if (!hasRemarks && hasFallback) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Official Remarks',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Text(
              fallbackAdminRemarks!,
              style: TextStyle(fontSize: 15, height: 1.5, color: Colors.blue.shade900),
            ),
          ),
          const SizedBox(height: 24),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.history_edu_rounded, size: 22, color: Color(0xFF010F32)),
            const SizedBox(width: 8),
            const Text(
              'Remarks & Activity Notes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF010F32)),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${remarks.length}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...remarks.map((item) {
          final remarkText = item['remark']?.toString() ?? '';
          final authorName = item['author_name']?.toString() ??
              item['authorName']?.toString() ??
              (item['author'] is Map ? (item['author'] as Map)['name']?.toString() : null) ??
              'Staff';
          final authorRole = item['author_role']?.toString() ??
              item['authorRole']?.toString() ??
              (item['author'] is Map ? (item['author'] as Map)['role']?.toString() : null) ??
              '';
          final actionTaken = item['action_taken']?.toString() ?? item['actionTaken']?.toString();
          final createdAt = item['created_at']?.toString() ?? item['createdAt']?.toString();

          final heading = _getRoleHeading(authorRole);
          final roleColor = _getRoleColor(authorRole);
          final roleIcon = _getRoleIcon(authorRole);
          final formattedDate = _formatDate(createdAt);

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: roleColor.withValues(alpha: 0.25)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Role header banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: roleColor.withValues(alpha: 0.08),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(13),
                      topRight: Radius.circular(13),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: roleColor.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(roleIcon, size: 18, color: roleColor),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              heading,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: roleColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 6,
                              children: [
                                Text(
                                  authorName,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                                if (authorRole.isNotEmpty)
                                  Text(
                                    '($authorRole)',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (actionTaken != null && actionTaken.isNotEmpty && actionTaken != 'Remark Added')
                            Container(
                              margin: const EdgeInsets.only(bottom: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: roleColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                actionTaken,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: roleColor,
                                ),
                              ),
                            ),
                          if (formattedDate.isNotEmpty)
                            Text(
                              formattedDate,
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Remark content
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    remarkText,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 12),
      ],
    );
  }
}

