import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/staff_accounts_provider.dart';

Future<void> showDeleteStaffDialog({
  required BuildContext context,
  required WidgetRef ref,
  required Map<String, dynamic> account,
}) async {
  final name = account['name'] ?? 'this user';
  final role = account['role'] ?? 'Staff';
  final userId = account['id']?.toString() ?? '';

  if (userId.isEmpty) return;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogCtx) => AlertDialog(
      title: const Text('Delete Account'),
      content: Text(
        'Are you sure you want to permanently delete the $role account for "$name"? This action cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogCtx, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade600,
            foregroundColor: Colors.white,
          ),
          onPressed: () => Navigator.pop(dialogCtx, true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );

  if (confirmed == true && context.mounted) {
    try {
      await ref.read(apiAuthRepositoryProvider).deleteStaffAccount(userId);
      ref.invalidate(staffAccountsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Account for "$name" deleted successfully.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '').replaceAll('ApiException: ', '')),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }
}

