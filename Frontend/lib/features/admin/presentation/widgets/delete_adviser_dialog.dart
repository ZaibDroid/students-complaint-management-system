import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/auth/domain/entities/user.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';

class DeleteAdviserDialog extends ConsumerStatefulWidget {
  final User adviserToDelete;
  final List<User> allAdvisers;

  const DeleteAdviserDialog({
    super.key,
    required this.adviserToDelete,
    required this.allAdvisers,
  });

  @override
  ConsumerState<DeleteAdviserDialog> createState() => _DeleteAdviserDialogState();
}

class _DeleteAdviserDialogState extends ConsumerState<DeleteAdviserDialog> {
  String? _selectedAdviserName;
  bool _isLoading = false;

  Future<void> _submitDelete() async {
    if (_selectedAdviserName == null) return;
    
    setState(() => _isLoading = true);

    final isCoordinator = widget.adviserToDelete.role == 'Coordinator';
    
    try {
      final updatedCount = isCoordinator
          ? await ref.read(apiAuthRepositoryProvider).handoverAdvisers(widget.adviserToDelete.name, _selectedAdviserName!)
          : await ref.read(apiAuthRepositoryProvider).handoverStudents(widget.adviserToDelete.name, _selectedAdviserName!);

      await ref
          .read(apiAuthRepositoryProvider)
          .deleteStaffAccount(widget.adviserToDelete.id);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully transferred $updatedCount ${isCoordinator ? 'advisers' : 'students'} and deleted ${isCoordinator ? 'coordinator' : 'adviser'}!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter out the current adviser from the dropdown options
    final eligibleAdvisers = widget.allAdvisers
        .where((a) => a.id != widget.adviserToDelete.id)
        .toList();

    final isCoordinator = widget.adviserToDelete.role == 'Coordinator';
    final targetRole = isCoordinator ? 'advisers' : 'students';
    final titleRole = isCoordinator ? 'Coordinator' : 'Adviser';

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.delete_forever, color: Colors.red),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Delete $titleRole',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'You are about to delete ${widget.adviserToDelete.name}. Before deleting, you must transfer any currently linked $targetRole to a new $titleRole.',
            style: const TextStyle(color: Colors.black87),
          ),
          const SizedBox(height: 20),
          Text('Select New $titleRole for ${isCoordinator ? 'Advisers' : 'Students'}', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (eligibleAdvisers.isEmpty)
            Text(
              'No other $titleRole available. Please create a new $titleRole account first to transfer the $targetRole before deleting.',
              style: const TextStyle(color: Colors.red, fontStyle: FontStyle.italic),
            )
          else
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              hint: Text('Choose new ${titleRole.toLowerCase()}...'),
              initialValue: _selectedAdviserName,
              items: eligibleAdvisers.map((a) {
                final batchInfo = a.semester ?? a.batch ?? 'Unassigned';
                return DropdownMenuItem(
                  value: a.name,
                  child: Text('${a.name} ($batchInfo)'),
                );
              }).toList(),
              onChanged: (val) {
                setState(() => _selectedAdviserName = val);
              },
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: (_isLoading || _selectedAdviserName == null) ? null : _submitDelete,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Transfer & Delete'),
        ),
      ],
    );
  }
}
