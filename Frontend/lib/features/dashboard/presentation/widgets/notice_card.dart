import 'package:flutter/material.dart';

enum NoticeType { academic, campusLife, general }

class NoticeCard extends StatelessWidget {
  final NoticeType type;
  final String title;
  final String description;
  final String date;

  const NoticeCard({
    super.key,
    required this.type,
    required this.title,
    required this.description,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPrimary = type == NoticeType.academic;

    final bgColor = isPrimary ? theme.primaryColor : const Color(0xFFF5F7FA);
    final textColor = isPrimary ? Colors.white : theme.primaryColor;
    final subTextColor = isPrimary ? Colors.white70 : Colors.black54;

    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: isPrimary ? null : Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isPrimary ? Colors.white24 : theme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _getCategoryText().toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isPrimary ? Colors.white : theme.primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: subTextColor,
              fontSize: 13,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Text(
            'Posted on $date',
            style: TextStyle(
              fontSize: 11,
              fontFamily: 'JetBrains Mono',
              color: subTextColor,
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryText() {
    switch (type) {
      case NoticeType.academic:
        return 'Academics';
      case NoticeType.campusLife:
        return 'Campus Life';
      case NoticeType.general:
        return 'General';
    }
  }
}
