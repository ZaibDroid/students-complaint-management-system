import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/adviser_assignment_provider.dart';
import 'add_faculty_dialog.dart';

class AssignSectionAdviserDialog extends ConsumerStatefulWidget {
  final String batchName;
  final String sectionName;
  final String? currentAdviserId;
  final String? sectionId;

  const AssignSectionAdviserDialog({
    super.key,
    required this.batchName,
    required this.sectionName,
    this.currentAdviserId,
    this.sectionId,
  });

  @override
  ConsumerState<AssignSectionAdviserDialog> createState() => _AssignSectionAdviserDialogState();
}

class _AssignSectionAdviserDialogState extends ConsumerState<AssignSectionAdviserDialog> {
  String? _selectedAdviserId;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedAdviserId = widget.currentAdviserId ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final advisersAsync = ref.watch(batchAdvisersStreamProvider);
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF172548).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.assignment_ind, color: Color(0xFF172548), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Assign Batch Adviser',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF172548)),
                ),
                Text(
                  'Batch ${widget.batchName} • Section ${widget.sectionName}',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 420,
        child: advisersAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (err, stack) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text('Error loading advisers: $err', style: const TextStyle(color: Colors.red)),
          ),
          data: (advisers) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Select a faculty member to serve as the Batch Adviser for this section:',
                  style: TextStyle(fontSize: 13, color: Colors.black87),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: _selectedAdviserId,
                  decoration: InputDecoration(
                    labelText: 'Faculty Batch Adviser',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: '',
                      child: Text('Not Assigned (Unassign)', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                    ),
                    ...advisers.map(
                      (adv) => DropdownMenuItem<String>(
                        value: adv.id,
                        child: Text(
                          '${adv.name} (${adv.email})',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                  onChanged: _isSaving ? null : (val) => setState(() => _selectedAdviserId = val),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AddFacultyDialog(
                          defaultRole: 'Batch Adviser',
                          initialBatchYear: widget.batchName,
                        ),
                      );
                    },
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add New Faculty Adviser', style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _saveAssignment,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
          child: _isSaving
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Save Assignment', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Future<void> _saveAssignment() async {
    setState(() => _isSaving = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      final success = await ref.read(assignAdviserActionProvider.notifier).assign(
        adviserId: (_selectedAdviserId != null && _selectedAdviserId!.isNotEmpty) ? _selectedAdviserId : null,
        semester: widget.batchName,
        section: widget.sectionName,
        sectionId: widget.sectionId,
      );

      if (success) {
        navigator.pop();
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              _selectedAdviserId == null || _selectedAdviserId!.isEmpty
                  ? 'Batch Adviser unassigned successfully.'
                  : 'Batch Adviser assigned to Section ${widget.sectionName} successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() => _isSaving = false);
        messenger.showSnackBar(
          const SnackBar(content: Text('Failed to update assignment.'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) setState(() => _isSaving = false);
      messenger.showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }
}

