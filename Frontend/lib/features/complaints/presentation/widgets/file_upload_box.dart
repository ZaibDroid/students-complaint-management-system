import 'package:flutter/material.dart';

class FileUploadBox extends StatelessWidget {
  final VoidCallback onTap;

  const FileUploadBox({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(32),
        width: double.infinity,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade400,
            width: 2,
            style: BorderStyle.none,
          ),
        ),
        // CustomPainter is better for dashed border, but for simplicity we'll use a container with a custom layout
        // For a true dashed border, we typically use the dotted_border package, 
        // but to keep it dependency-free we'll simulate it with a subtle solid border and icon.
        foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade400,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.cloud_upload, color: theme.primaryColor, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              'Upload Photos',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'PNG, JPG or PDF',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
