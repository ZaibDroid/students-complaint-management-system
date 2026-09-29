import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../core/utils/ui_helpers.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_card.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final emailError = Validators.validateUetEmail(_emailController.text);
    if (emailError != null) {
      context.showErrorSnackBar(emailError);
      return;
    }

    setState(() => _isLoading = true);
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.forgotPassword(email: _emailController.text.trim());
    setState(() {
      _isLoading = false;
      _sent = true;
    });

    result.when(
      onSuccess: (_) {},
      onError: (fail) {
        if (mounted) {
          context.showErrorSnackBar(fail.message);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Reset Password'),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: AppPaddings.all24,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: AuthCard(
                title: 'Forgot Password?',
                subtitle: 'Enter your @uetmardan.edu.pk email to receive password reset instructions.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_sent) ...[
                      Container(
                        padding: AppPaddings.all12,
                        decoration: const BoxDecoration(
                          color: AppColors.statusResolvedLight,
                          borderRadius: AppBorderRadii.r10,
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.check_circle_outline, color: AppColors.statusResolved, size: 20),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Password reset instructions have been sent to your university email.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.statusResolved,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      AppSpacing.v20,
                    ],
                    AppTextField(
                      label: 'University Email',
                      hint: 'yourname@uetmardan.edu.pk',
                      controller: _emailController,
                      prefixIcon: const Icon(Icons.email_outlined, size: 20, color: AppColors.textSecondary),
                      validator: Validators.validateUetEmail,
                    ),
                    AppSpacing.v24,
                    PrimaryButton(
                      text: 'Send Reset Link',
                      isLoading: _isLoading,
                      onPressed: _handleSubmit,
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
