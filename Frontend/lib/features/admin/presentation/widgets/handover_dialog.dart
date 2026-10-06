import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/auth/domain/entities/user.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';

class HandoverDialog extends ConsumerStatefulWidget {
  final User oldAdviser;
  final List<User> allAdvisers;

  const HandoverDialog({
    super.key,
    required this.oldAdviser,
    required this.allAdvisers,
  });

  @override
  ConsumerState<HandoverDialog> createState() => _HandoverDialogState();
}

class _HandoverDialogState extends ConsumerState<HandoverDialog> {
  String? _selectedAdviserName;
  bool _isLoading = false;

  Future<void> _submitHandover() async {
    if (_selectedAdviserName == null) return;
    
    setState(() => _isLoading = true);

    final isCoordinator = widget.oldAdviser.role == 'Coordinator';
    
    try {
      final updatedCount = isCoordinator
          ? await ref.read(apiAuthRepositoryProvider).handoverAdvisers(widget.oldAdviser.name, _selectedAdviserName!)
          : await ref.read(apiAuthRepositoryProvider).handoverStudents(widget.oldAdviser.name, _selectedAdviserName!);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully transferred $updatedCount ${isCoordinator ? 'advisers' : 'students'} to $_selectedAdviserName!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error transferring ${isCoordinator ? 'advisers' : 'students'}: $e'),
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
        .where((a) => a.id != widget.oldAdviser.id)
        .toList();

    final isCoordinator = widget.oldAdviser.role == 'Coordinator';
    final targetRole = isCoordinator ? 'advisers' : 'students';
    final titleRole = isCoordinator ? 'Coordinator' : 'Adviser';

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.transfer_within_a_station, color: Colors.blue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Handover $targetRole',
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
            'Transfer all $targetRole currently linked to ${widget.oldAdviser.name} to a new $titleRole.',
            style: const TextStyle(color: Colors.black87),
          ),
          const SizedBox(height: 20),
          Text('Select New $titleRole', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (eligibleAdvisers.isEmpty)
            Text(
              'No other ${titleRole.toLowerCase()}s available. Please create a new ${titleRole.toLowerCase()} account first.',
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
          onPressed: (_isLoading || _selectedAdviserName == null) ? null : _submitHandover,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Transfer'),
        ),
      ],
    );
  }
}
