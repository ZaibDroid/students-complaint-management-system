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

  if (role == 'Chairman') {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => _ChairmanSuccessionDialog(
        account: account,
        onSuccess: () {
          ref.invalidate(staffAccountsProvider);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Department leadership transferred from "$name" successfully.')),
            );
          }
        },
      ),
    );
    return;
  }

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

class _ChairmanSuccessionDialog extends ConsumerStatefulWidget {
  final Map<String, dynamic> account;
  final VoidCallback onSuccess;

  const _ChairmanSuccessionDialog({
    required this.account,
    required this.onSuccess,
  });

  @override
  ConsumerState<_ChairmanSuccessionDialog> createState() => _ChairmanSuccessionDialogState();
}

class _ChairmanSuccessionDialogState extends ConsumerState<_ChairmanSuccessionDialog> {
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;
  List<Map<String, dynamic>> _candidates = [];
  String? _selectedReplacementId;

  @override
  void initState() {
    super.initState();
    _loadCandidates();
  }

  Future<void> _loadCandidates() async {
    final userId = widget.account['id']?.toString() ?? '';
    try {
      final candidates = await ref.read(apiAuthRepositoryProvider).getChairmanCandidates(userId);
      if (mounted) {
        setState(() {
          _candidates = candidates;
          _isLoading = false;
          if (candidates.isNotEmpty) {
            _selectedReplacementId = candidates.first['id']?.toString();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '').replaceAll('ApiException: ', '');
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _transferAndProceed() async {
    if (_selectedReplacementId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a replacement Chairman.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final userId = widget.account['id']?.toString() ?? '';

    try {
      await ref.read(apiAuthRepositoryProvider).replaceChairman(
        chairmanId: userId,
        replacementChairmanId: _selectedReplacementId!,
      );
      if (mounted) {
        Navigator.pop(context);
        widget.onSuccess();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '').replaceAll('ApiException: ', '')),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.account['name'] ?? 'Chairman';
    final dept = widget.account['department'] ?? 'Department';

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.swap_horiz, color: Colors.orange.shade800),
          const SizedBox(width: 8),
          const Expanded(child: Text('Chairman Succession')),
        ],
      ),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Text(
                'A Chairman cannot be deleted without succession. All active complaints and departmental leadership for "$name" ($dept) will be atomically transferred to the selected replacement.',
                style: TextStyle(fontSize: 13, color: Colors.orange.shade900),
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_errorMessage != null)
              Text(
                'Error loading candidates: $_errorMessage',
                style: const TextStyle(color: Colors.red, fontSize: 13),
              )
            else if (_candidates.isEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'No eligible replacement candidates found in this department.',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Please provision or assign another staff member in $dept before removing the current Chairman.',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ],
              )
            else ...[
              const Text(
                'Select Replacement Chairman:',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: _selectedReplacementId,
                items: _candidates.map((c) => DropdownMenuItem(
                  value: c['id']?.toString(),
                  child: Text(
                    '${c['name']} (${c['email']})',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13),
                  ),
                )).toList(),
                onChanged: (val) => setState(() => _selectedReplacementId = val),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        if (!_isLoading && _candidates.isNotEmpty)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            onPressed: _isSubmitting ? null : _transferAndProceed,
            child: _isSubmitting
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Transfer Leadership & Delete'),
          ),
      ],
    );
  }
}
