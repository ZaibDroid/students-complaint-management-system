import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../providers/auth_provider.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(emailError)));
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
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(fail.message)));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Reset Password'), backgroundColor: Colors.transparent),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Forgot Password?',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Enter your @uetmardan.edu.pk email to receive password reset instructions.',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 24),
                    if (_sent) ...[
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.statusResolvedLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Password reset instructions have been sent to your university email.',
                          style: TextStyle(fontSize: 13, color: AppColors.statusResolved, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    AppTextField(
                      label: 'University Email',
                      hint: 'yourname@uetmardan.edu.pk',
                      controller: _emailController,
                      prefixIcon: const Icon(Icons.email_outlined, size: 20, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 24),
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
