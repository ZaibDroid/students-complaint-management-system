import 'package:flutter/material.dart';

class ComplaintInfoCard extends StatelessWidget {
  final String title;
  final String content;
  final Color? backgroundColor;
  final Color? textColor;

  const ComplaintInfoCard({
    super.key,
    required this.title,
    required this.content,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            content,
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }
}

