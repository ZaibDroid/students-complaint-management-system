import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../features/auth/domain/entities/user.dart';
import '../providers/adviser_assignment_provider.dart';
import '../../../../features/batch/presentation/providers/batch_provider.dart';

class EditFacultyDialog extends ConsumerStatefulWidget {
  final User adviser;
  
  const EditFacultyDialog({super.key, required this.adviser});

  @override
  ConsumerState<EditFacultyDialog> createState() => _EditFacultyDialogState();
}

class _EditFacultyDialogState extends ConsumerState<EditFacultyDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _batchController;
  late final TextEditingController _sectionController;
  late final TextEditingController _semesterController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.adviser.name);
    _batchController = TextEditingController(text: widget.adviser.batch ?? '');
    _sectionController = TextEditingController(text: widget.adviser.section ?? '');
    _semesterController = TextEditingController(text: widget.adviser.semester ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _batchController.dispose();
    _sectionController.dispose();
    _semesterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(
        children: [
          Icon(Icons.edit, color: Colors.blue),
          SizedBox(width: 10),
          Text('Edit Batch Adviser', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                controller: _nameController,
                labelText: 'Full Name',
                prefixIcon: const Icon(Icons.person),
                validator: (val) => val == null || val.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _batchController,
                      labelText: 'Batch No.',
                      hintText: 'e.g. 2021',
                      prefixIcon: const Icon(Icons.numbers),
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppTextField(
                      controller: _sectionController,
                      labelText: 'Section',
                      hintText: 'e.g. A',
                      prefixIcon: const Icon(Icons.view_module),
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _semesterController,
                labelText: 'Semester',
                hintText: 'e.g. BSCS-1',
                prefixIcon: const Icon(Icons.class_),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        SizedBox(
          width: 100,
          child: PrimaryButton(
            text: 'Save',
            isLoading: _isLoading,
            onPressed: _isLoading ? null : _submit,
          ),
        ),
      ],
    );
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await ref.read(apiAuthRepositoryProvider).updateStaffAccount(
          widget.adviser.id,
          name: _nameController.text.trim(),
          batch: _batchController.text.trim(),
          section: _sectionController.text.trim(),
          semester: _semesterController.text.trim(),
        );
        if (mounted) {
          ref.invalidate(batchAdvisersStreamProvider);
          ref.invalidate(batchesStreamProvider);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Batch adviser details updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
