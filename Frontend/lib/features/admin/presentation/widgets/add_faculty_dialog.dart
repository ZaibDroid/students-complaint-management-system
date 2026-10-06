import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../providers/adviser_assignment_provider.dart';
import '../../../../features/batch/presentation/providers/batch_provider.dart';

class AddFacultyDialog extends ConsumerStatefulWidget {
  final String defaultRole;

  const AddFacultyDialog({super.key, this.defaultRole = 'Batch Adviser'});

  @override
  ConsumerState<AddFacultyDialog> createState() => _AddFacultyDialogState();
}

class _AddFacultyDialogState extends ConsumerState<AddFacultyDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _batchController = TextEditingController();
  final _sectionController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _batchController.dispose();
    _sectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(
        children: [
          Icon(Icons.person_add, color: Colors.blue),
          SizedBox(width: 10),
          Text('Add New Faculty', style: TextStyle(fontWeight: FontWeight.bold)),
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
              AppTextField(
                controller: _emailController,
                labelText: 'Email Address',
                prefixIcon: const Icon(Icons.email),
                keyboardType: TextInputType.emailAddress,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Email is required';
                  if (!val.contains('@uetmardan.edu.pk')) {
                    return 'Use official email e.g., name@uetmardan.edu.pk';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _passwordController,
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock),
                isPassword: true,
                validator: (val) => val == null || val.length < 6 ? 'Min 6 characters' : null,
              ),
              const SizedBox(height: 16),
              if (widget.defaultRole == 'Batch Adviser')
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _batchController,
                        labelText: 'Batch No.',
                        hintText: 'e.g. 6',
                        keyboardType: TextInputType.number,
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
            text: 'Add',
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
        final batchVal = _batchController.text.trim();
        final sectionVal = _sectionController.text.trim();
        await ref.read(apiAuthRepositoryProvider).createStaffAccount(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          role: widget.defaultRole,
          batch: batchVal.isNotEmpty ? batchVal : null,
          section: sectionVal.isNotEmpty ? sectionVal : null,
          assignedSections: [
            if (batchVal.isNotEmpty && sectionVal.isNotEmpty)
              {'batch': batchVal, 'section': sectionVal}
          ],
        );
        if (mounted) {
          ref.invalidate(batchAdvisersStreamProvider);
          ref.invalidate(batchesStreamProvider);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('New faculty member registered successfully!'),
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
