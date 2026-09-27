import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/routes/route_names.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/password_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../shared/enums/user_role.dart';
import '../providers/auth_provider.dart';

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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // University Header
                    Center(
                      child: Column(
                        children: [
                          const Text(
                            AppStrings.appName,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppStrings.universityName,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Card Container
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            AppStrings.registerTitle,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            AppStrings.registerSubtitle,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 20),

                          if (authState.errorMessage != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.statusRejectedLight,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                authState.errorMessage!,
                                style: const TextStyle(color: AppColors.statusRejected, fontSize: 13),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Full Name
                          AppTextField(
                            label: 'Full Name',
                            hint: 'e.g. Muhammad Ali',
                            controller: _nameController,
                            prefixIcon: const Icon(Icons.person_outline, size: 20, color: AppColors.textSecondary),
                            validator: (v) => Validators.validateRequired(v, fieldName: 'Full name'),
                          ),
                          const SizedBox(height: 16),

                          // University Email
                          AppTextField(
                            label: 'University Email',
                            hint: 'student@uetmardan.edu.pk',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: const Icon(Icons.email_outlined, size: 20, color: AppColors.textSecondary),
                            validator: Validators.validateUetEmail,
                          ),
                          const SizedBox(height: 16),

                          // Role Selection
                          const Text(
                            'Account Role',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
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
                          const SizedBox(height: 16),

                          // Password
                          PasswordField(
                            label: 'Password',
                            hint: 'At least 8 characters',
                            controller: _passwordController,
                            validator: Validators.validatePassword,
                          ),
                          const SizedBox(height: 16),

                          // Confirm Password
                          PasswordField(
                            label: 'Confirm Password',
                            hint: 'Re-enter password',
                            controller: _confirmPasswordController,
                            validator: (v) => Validators.validateConfirmPassword(v, _passwordController.text),
                            onFieldSubmitted: (_) => _handleRegister(),
                          ),
                          const SizedBox(height: 24),

                          // Register Button
                          PrimaryButton(
                            text: 'Create Account',
                            isLoading: authState.isLoading,
                            icon: Icons.person_add_outlined,
                            onPressed: _handleRegister,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Already have an account?
                    Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Already registered? ',
                              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                            ),
                            GestureDetector(
                              onTap: () => context.go(RouteNames.login),
                              child: const Text(
                                'Sign In',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
