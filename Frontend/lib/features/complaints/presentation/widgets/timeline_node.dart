import 'package:flutter/material.dart';

enum TimelineNodeStatus { completed, active, future }

class TimelineNode extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? time;
  final TimelineNodeStatus status;
  final IconData icon;
  final bool isLast;
  final Widget? content;

  const TimelineNode({
    super.key,
    required this.title,
    required this.subtitle,
    this.time,
    required this.status,
    required this.icon,
    this.isLast = false,
    this.content,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Color dotColor;
    Color iconColor;
    Color lineColor = Colors.grey.shade300;

    switch (status) {
      case TimelineNodeStatus.completed:
        dotColor = Colors.green;
        iconColor = Colors.white;
        break;
      case TimelineNodeStatus.active:
        dotColor = theme.primaryColor;
        iconColor = Colors.white;
        break;
      case TimelineNodeStatus.future:
        dotColor = Colors.grey.shade200;
        iconColor = Colors.grey;
        break;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline Line & Dot
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                  border: status == TimelineNodeStatus.future 
                      ? Border.all(color: Colors.grey.shade400, width: 2) 
                      : null,
                ),
                child: Icon(icon, size: 14, color: iconColor),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: lineColor,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: status == TimelineNodeStatus.future 
                              ? Colors.grey.shade600 
                              : (status == TimelineNodeStatus.active ? theme.primaryColor : Colors.black87),
                        ),
                      ),
                      if (time != null)
                        Text(
                          time!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontStyle: status == TimelineNodeStatus.future ? FontStyle.italic : FontStyle.normal,
                    ),
                  ),
                  if (content != null) ...[
                    const SizedBox(height: 12),
                    content!,
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
