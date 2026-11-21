import 'package:flutter/material.dart';

/// Placeholder view when a Coordinator is assigned to a batch year that hasn't had sections initialized yet.
class UninitializedBatchView extends StatelessWidget {
  final String batchYear;
  final VoidCallback onInitialize;

  const UninitializedBatchView({
    super.key,
    required this.batchYear,
    required this.onInitialize,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF172548).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.class_outlined, size: 48, color: Color(0xFF172548)),
            ),
            const SizedBox(height: 16),
            Text(
              'Batch $batchYear',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF172548)),
            ),
            const SizedBox(height: 8),
            Text(
              'Your assigned batch has not been initialized with sections yet.\nClick below to initialize Batch $batchYear.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onInitialize,
              icon: const Icon(Icons.playlist_add),
              label: const Text('Initialize Batch Sections', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF172548),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

