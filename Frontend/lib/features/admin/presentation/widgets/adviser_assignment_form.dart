import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../features/auth/domain/entities/user.dart';
import '../providers/adviser_assignment_provider.dart';
import '../../domain/entities/adviser_assignment.dart';
import './add_faculty_dialog.dart';

class AdviserAssignmentForm extends ConsumerStatefulWidget {
  final List<User> advisers;

  const AdviserAssignmentForm({
    super.key,
    required this.advisers,
  });

  @override
  ConsumerState<AdviserAssignmentForm> createState() => _AdviserAssignmentFormState();
}

class _AdviserAssignmentFormState extends ConsumerState<AdviserAssignmentForm> {
  final List<String> _semesters = ['BSCS-1', 'BSCS-2', 'BSCS-3', 'BSCS-4', 'BSCS-5', 'BSCS-6', 'BSCS-7', 'BSCS-8'];
  final List<String> _sections = ['A', 'B'];

  String? _selectedAdviserId = '';

  @override
  void initState() {
    super.initState();
    // Initialize the default adviser mapping based on first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final initial = ref.read(selectedAssignmentProvider);
      final assignments = ref.read(adviserAssignmentsProvider);
      final matched = assignments.firstWhere(
        (a) => a.semester == initial.semester && a.section == initial.section,
        orElse: () => AdviserAssignment(semester: initial.semester, section: initial.section),
      );
      setState(() {
        _selectedAdviserId = matched.adviserId ?? '';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isActionLoading = ref.watch(assignAdviserActionProvider).isLoading;
    final assignments = ref.watch(adviserAssignmentsProvider);
    
    // Watch provider for active selection
    final selectedAssignment = ref.watch(selectedAssignmentProvider);

    // Listen to changes in selected semester/section to reset adviser dropdown input
    ref.listen<SelectedAssignmentState>(selectedAssignmentProvider, (prev, next) {
      final nextAssignment = assignments.firstWhere(
        (a) => a.semester == next.semester && a.section == next.section,
        orElse: () => AdviserAssignment(semester: next.semester, section: next.section),
      );
      setState(() {
        _selectedAdviserId = nextAssignment.adviserId ?? '';
      });
    });

    // Find the currently assigned adviser for the selected semester + section
    final currentAssignment = assignments.firstWhere(
      (a) => a.semester == selectedAssignment.semester && a.section == selectedAssignment.section,
      orElse: () => AdviserAssignment(semester: selectedAssignment.semester, section: selectedAssignment.section),
    );

    final hasCurrentAdviser = currentAssignment.adviserName != null;

    return Card(
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Assign Batch Adviser',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF010F32),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Select a semester and section to assign or change its Batch Adviser.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 24),

            // Semester Dropdown
            const Text(
              'Semester',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: selectedAssignment.semester,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              items: _semesters.map((sem) => DropdownMenuItem(
                value: sem,
                child: Text(sem),
              )).toList(),
              onChanged: isActionLoading
                  ? null
                  : (val) {
                      if (val != null) {
                        ref.read(selectedAssignmentProvider.notifier).select(
                          val,
                          selectedAssignment.section,
                        );
                      }
                    },
            ),
            const SizedBox(height: 16),

            // Section Dropdown
            const Text(
              'Section',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: selectedAssignment.section,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              items: _sections.map((sec) => DropdownMenuItem(
                value: sec,
                child: Text(sec),
              )).toList(),
              onChanged: isActionLoading
                  ? null
                  : (val) {
                      if (val != null) {
                        ref.read(selectedAssignmentProvider.notifier).select(
                          selectedAssignment.semester,
                          val,
                        );
                      }
                    },
            ),
            const SizedBox(height: 24),

            // Current Adviser Info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: hasCurrentAdviser
                    ? theme.primaryColor.withValues(alpha: 0.05)
                    : Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: hasCurrentAdviser
                      ? theme.primaryColor.withValues(alpha: 0.1)
                      : Colors.red.shade100,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    hasCurrentAdviser ? Icons.verified_user : Icons.warning_amber_rounded,
                    color: hasCurrentAdviser ? theme.primaryColor : Colors.red,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Current Batch Adviser',
                          style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          hasCurrentAdviser
                              ? currentAssignment.adviserName!
                              : 'Not Assigned',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: hasCurrentAdviser ? const Color(0xFF010F32) : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Faculty Dropdown Header with Add option
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Faculty Member',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
                TextButton.icon(
                  onPressed: isActionLoading
                      ? null
                      : () => _showAddFacultyDialog(context),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Faculty', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedAdviserId,
              hint: const Text('Select Batch Adviser'),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: '',
                  child: Text('Not Assigned (Unassign)'),
                ),
                ...widget.advisers.map((adviser) => DropdownMenuItem<String>(
                  value: adviser.id,
                  child: Text(adviser.name),
                )),
              ],
              onChanged: isActionLoading
                  ? null
                  : (val) {
                      setState(() {
                        _selectedAdviserId = val;
                      });
                    },
            ),
            const SizedBox(height: 32),

            // Submit Button
            PrimaryButton(
              text: 'Assign Batch Adviser',
              isLoading: isActionLoading,
              onPressed: isActionLoading ? null : _submitAssignment,
            ),
          ],
        ),
      ),
    );
  }

  void _showAddFacultyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddFacultyDialog(),
    );
  }

  void _submitAssignment() async {
    final selectedAssignment = ref.read(selectedAssignmentProvider);
    final success = await ref.read(assignAdviserActionProvider.notifier).assign(
          adviserId: _selectedAdviserId == '' ? null : _selectedAdviserId,
          semester: selectedAssignment.semester,
          section: selectedAssignment.section,
        );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Batch Adviser assignment updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update assignment. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
