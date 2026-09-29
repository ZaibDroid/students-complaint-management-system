import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/routes/route_names.dart';
import '../../../../core/utils/ui_helpers.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/password_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../shared/enums/user_role.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_card.dart';
import '../widgets/auth_error_banner.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_link_button.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  UserRole _selectedRole = UserRole.student;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState?.validate() ?? false) {
      final success = await ref.read(authProvider.notifier).register(
            fullName: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            passwordConfirmation: _confirmPasswordController.text,
            role: _selectedRole,
          );

      if (success && mounted) {
        context.go(RouteNames.verifyEmail);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: AppPaddings.all24,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AuthHeader(subtitle: AppStrings.universityName),
                    AppSpacing.v24,
                    AuthCard(
                      title: AppStrings.registerTitle,
                      subtitle: AppStrings.registerSubtitle,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AuthErrorBanner(errorMessage: authState.errorMessage),
                          AppTextField(
                            label: 'Full Name',
                            hint: 'e.g. Muhammad Ali',
                            controller: _nameController,
                            prefixIcon: const Icon(Icons.person_outline, size: 20, color: AppColors.textSecondary),
                            validator: (v) => Validators.validateRequired(v, fieldName: 'Full name'),
                          ),
                          AppSpacing.v16,
                          AppTextField(
                            label: 'University Email',
                            hint: 'student@uetmardan.edu.pk',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: const Icon(Icons.email_outlined, size: 20, color: AppColors.textSecondary),
                            validator: Validators.validateUetEmail,
                          ),
                          AppSpacing.v16,
                          const Text(
                            'Account Role',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          AppSpacing.v6,
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              borderRadius: AppBorderRadii.r12,
                              border: Border.all(color: AppColors.border, width: 1),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<UserRole>(
                                isExpanded: true,
                                value: _selectedRole,
                                items: [
                                  UserRole.student,
                                  UserRole.cr,
                                  UserRole.batchAdviser,
                                  UserRole.coordinator,
                                  UserRole.officeStaff,
                                ].map((role) {
                                  return DropdownMenuItem(
                                    value: role,
                                    child: Text(
                                      role.displayName,
                                      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (role) {
                                  if (role != null) {
                                    setState(() => _selectedRole = role);
                                  }
                                },
                              ),
                            ),
                          ),
                          AppSpacing.v16,
                          PasswordField(
                            label: 'Password',
                            hint: 'At least 8 characters',
                            controller: _passwordController,
                            validator: Validators.validatePassword,
                          ),
                          AppSpacing.v16,
                          PasswordField(
                            label: 'Confirm Password',
                            hint: 'Re-enter password',
                            controller: _confirmPasswordController,
                            validator: (v) => Validators.validateConfirmPassword(v, _passwordController.text),
                            onFieldSubmitted: (_) => _handleRegister(),
                          ),
                          AppSpacing.v24,
                          PrimaryButton(
                            text: 'Create Account',
                            isLoading: authState.isLoading,
                            icon: Icons.person_add_outlined,
                            onPressed: _handleRegister,
                          ),
                        ],
                      ),
                    ),
                    AppSpacing.v20,
                    AuthLinkButton(
                      promptText: 'Already registered?',
                      actionText: 'Sign In',
                      onTap: () => context.go(RouteNames.login),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
