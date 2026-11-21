import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Modal dialog component to reset a student's password with validation.
class ResetStudentPasswordDialog extends ConsumerStatefulWidget {
  final Map<String, dynamic> student;
  final VoidCallback onSuccess;

  const ResetStudentPasswordDialog({
    super.key,
    required this.student,
    required this.onSuccess,
  });

  @override
  ConsumerState<ResetStudentPasswordDialog> createState() => _ResetStudentPasswordDialogState();
}

class _ResetStudentPasswordDialogState extends ConsumerState<ResetStudentPasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _pwdController = TextEditingController();
  final _confirmPwdController = TextEditingController();
  bool _isResetting = false;

  @override
  void dispose() {
    _pwdController.dispose();
    _confirmPwdController.dispose();
    super.dispose();
  }

  Future<void> _reset() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isResetting = true);
    final studentId = widget.student['id']?.toString() ?? '';

    try {
      await ref.read(apiAuthRepositoryProvider).updateStudent(studentId, {
        'password': _pwdController.text,
      });

      if (mounted) {
        Navigator.pop(context);
        widget.onSuccess();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isResetting = false);
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
    final name = widget.student['name'] ?? 'Student';

    return AlertDialog(
      title: Row(
        children: const [
          Icon(Icons.lock_reset, color: Colors.teal),
          SizedBox(width: 8),
          Expanded(child: Text('Reset Password')),
        ],
      ),
      content: SizedBox(
        width: 380,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Reset password for student "$name":', style: const TextStyle(fontSize: 13)),
              const SizedBox(height: 16),
              AppTextField(
                controller: _pwdController,
                labelText: 'New Password',
                isPassword: true,
                prefixIcon: const Icon(Icons.lock_outline),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Password is required';
                  if (v.length < 6) return 'Minimum 6 characters required';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller: _confirmPwdController,
                labelText: 'Confirm Password',
                isPassword: true,
                prefixIcon: const Icon(Icons.lock_outline),
                validator: (v) {
                  if (v != _pwdController.text) return 'Passwords do not match';
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isResetting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
          ),
          onPressed: _isResetting ? null : _reset,
          child: _isResetting
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Reset Password'),
        ),
      ],
    );
  }
}

