import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:student_complaint_managment_system/core/constants/app_colors.dart';
import 'package:student_complaint_managment_system/core/utils/context_extensions.dart';
import 'package:student_complaint_managment_system/core/utils/ui_helpers.dart';
import 'package:student_complaint_managment_system/core/utils/validators.dart';
import 'package:student_complaint_managment_system/core/widgets/password_field.dart';
import 'package:student_complaint_managment_system/core/widgets/primary_button.dart';
import 'package:student_complaint_managment_system/features/profile/presentation/providers/profile_provider.dart';

class ChangePasswordPage extends ConsumerStatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  ConsumerState<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends ConsumerState<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleChange() async {
    if (_formKey.currentState?.validate() ?? false) {
      final success = await ref.read(profileProvider.notifier).changePassword(
            currentPassword: _currentPasswordController.text,
            newPassword: _newPasswordController.text,
          );

      if (success && mounted) {
        context.showSuccessSnackBar('Password changed successfully!');
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Change Password'), backgroundColor: Colors.white),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppPaddings.all20,
          child: Form(
            key: _formKey,
            child: Container(
              padding: AppPaddings.all20,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppBorderRadii.r16,
                border: Border.all(color: AppColors.border),
                boxShadow: AppShadows.card,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PasswordField(
                    label: 'Current Password',
                    controller: _currentPasswordController,
                    validator: Validators.validatePassword,
                  ),
                  AppSpacing.v16,
                  PasswordField(
                    label: 'New Password',
                    controller: _newPasswordController,
                    validator: Validators.validatePassword,
                  ),
                  AppSpacing.v16,
                  PasswordField(
                    label: 'Confirm New Password',
                    controller: _confirmPasswordController,
                    validator: (v) => Validators.validateConfirmPassword(v, _newPasswordController.text),
                  ),
                  AppSpacing.v24,
                  PrimaryButton(
                    text: 'Update Password',
                    isLoading: state.isSaving,
                    onPressed: _handleChange,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
