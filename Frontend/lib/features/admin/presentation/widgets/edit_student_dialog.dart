import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/departments.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../batch/presentation/providers/batch_provider.dart';

/// Modal dialog component to edit student details (Name, Email, Dept, Batch, Section).
class EditStudentDialog extends ConsumerStatefulWidget {
  final Map<String, dynamic> student;
  final VoidCallback onSuccess;

  const EditStudentDialog({
    super.key,
    required this.student,
    required this.onSuccess,
  });

  @override
  ConsumerState<EditStudentDialog> createState() => _EditStudentDialogState();
}

class _EditStudentDialogState extends ConsumerState<EditStudentDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;

  String? _selectedDepartmentId;
  String? _selectedBatchId;
  String? _selectedSectionId;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.student['name'] ?? '');
    _emailController = TextEditingController(text: widget.student['email'] ?? '');
    _selectedDepartmentId = widget.student['department_id']?.toString() ?? widget.student['departmentId']?.toString();
    _selectedBatchId = widget.student['batch_id']?.toString() ?? widget.student['batchId']?.toString();
    _selectedSectionId = widget.student['section_id']?.toString() ?? widget.student['sectionId']?.toString();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final studentId = widget.student['id']?.toString() ?? '';

    try {
      await ref.read(apiAuthRepositoryProvider).updateStudent(studentId, {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'department_id': _selectedDepartmentId,
        'batch_id': _selectedBatchId,
        'section_id': _selectedSectionId,
      });

      if (mounted) {
        Navigator.pop(context);
        widget.onSuccess();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Student details updated successfully.')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
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
    final batchesAsync = ref.watch(batchesStreamProvider);

    return AlertDialog(
      title: const Text('Edit Student Account'),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTextField(
                  controller: _nameController,
                  labelText: 'Full Name',
                  prefixIcon: const Icon(Icons.person_outline),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: _emailController,
                  labelText: 'University Email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Required';
                    if (!v.trim().endsWith('@uetmardan.edu.pk')) {
                      return 'Must be @uetmardan.edu.pk email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: _selectedDepartmentId,
                  decoration: const InputDecoration(
                    labelText: 'Department',
                    prefixIcon: Icon(Icons.business_outlined),
                  ),
                  items: kOfficialDepartments.map((dept) => DropdownMenuItem(
                    value: dept.id,
                    child: Text(dept.name, overflow: TextOverflow.ellipsis),
                  )).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedDepartmentId = val;
                      _selectedBatchId = null;
                      _selectedSectionId = null;
                    });
                  },
                ),
                const SizedBox(height: 14),
                batchesAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (_, _) => const Text('Error loading batches', style: TextStyle(color: Colors.red)),
                  data: (batches) {
                    final filteredBatches = _selectedDepartmentId != null
                        ? batches.where((b) => b.departmentId == null || b.departmentId.toString() == _selectedDepartmentId).toList()
                        : batches;

                    final currentBatch = filteredBatches.where((b) => b.id == _selectedBatchId).firstOrNull;
                    final sections = currentBatch?.sections ?? [];

                    return Column(
                      children: [
                        DropdownButtonFormField<String>(
                          key: ValueKey('batch_sel_$_selectedBatchId'),
                          isExpanded: true,
                          initialValue: _selectedBatchId,
                          decoration: const InputDecoration(
                            labelText: 'Batch',
                            prefixIcon: Icon(Icons.calendar_today_outlined),
                          ),
                          items: filteredBatches.map((b) => DropdownMenuItem(
                            value: b.id,
                            child: Text(b.name, overflow: TextOverflow.ellipsis),
                          )).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedBatchId = val;
                              _selectedSectionId = null;
                            });
                          },
                        ),
                        const SizedBox(height: 14),
                        DropdownButtonFormField<String>(
                          key: ValueKey('sec_sel_$_selectedSectionId'),
                          isExpanded: true,
                          initialValue: _selectedSectionId,
                          decoration: const InputDecoration(
                            labelText: 'Section',
                            prefixIcon: Icon(Icons.class_outlined),
                          ),
                          items: sections.map((s) => DropdownMenuItem(
                            value: s,
                            child: Text(s, overflow: TextOverflow.ellipsis),
                          )).toList(),
                          onChanged: (val) => setState(() => _selectedSectionId = val),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _submit,
          child: _isSaving
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Save Changes'),
        ),
      ],
    );
  }
}

