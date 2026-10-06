import 'package:flutter/material.dart';
import 'dart:convert';

class NoticeBoardCard extends StatelessWidget {
  final String title;
  final String description;
  final String tag;
  final String date;
  final String sender;
  final IconData senderIcon;
  final bool isUrgent;
  final List<String>? attachments;
  final VoidCallback onTap;

  const NoticeBoardCard({
    super.key,
    required this.title,
    required this.description,
    required this.tag,
    required this.date,
    required this.sender,
    required this.senderIcon,
    this.isUrgent = false,
    this.attachments,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Color borderColor;
    Color bgColor;
    Color tagColor;
    Color tagBgColor;
    
    if (isUrgent) {
      borderColor = Colors.red.withValues(alpha: 0.2);
      bgColor = Colors.red.withValues(alpha: 0.05);
      tagColor = Colors.white;
      tagBgColor = Colors.red;
    } else {
      borderColor = Colors.grey.shade200;
      bgColor = Colors.white;
      
      switch (tag.toLowerCase()) {
        case 'academic':
          tagColor = theme.primaryColor;
          tagBgColor = theme.primaryColor.withValues(alpha: 0.1);
          break;
        case 'events':
          tagColor = Colors.indigo;
          tagBgColor = Colors.indigo.withValues(alpha: 0.1);
          break;
        default:
          tagColor = Colors.grey.shade700;
          tagBgColor = Colors.grey.shade200;
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
          boxShadow: isUrgent ? const [] : const [
            BoxShadow(
              color: Color(0x05000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: tagBgColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    tag.toUpperCase(),
                    style: TextStyle(
                      color: tagColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Text(
                  date,
                  style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            if (attachments != null && attachments!.isNotEmpty) ...[
              SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: attachments!.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, attachIdx) {
                    final b64 = attachments![attachIdx].split(',').last;
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(base64Decode(b64), width: 120, height: 120, fit: BoxFit.cover),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],
            Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(senderIcon, size: 14, color: theme.primaryColor),
                ),
                const SizedBox(width: 8),
                Text(
                  sender,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
