import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/routes/route_names.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../core/utils/ui_helpers.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../shared/enums/user_role.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_error_banner.dart';

class VerifyEmailPage extends ConsumerStatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  ConsumerState<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends ConsumerState<VerifyEmailPage> {
  final _otpController = TextEditingController();
  bool _isResending = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _handleVerify() async {
    if (_otpController.text.trim().isEmpty) return;

    final success = await ref.read(authProvider.notifier).verifyEmail(_otpController.text.trim());

    if (success && mounted) {
      final user = ref.read(authProvider).user;
      if (user != null && !user.isProfileCompleted && user.role == UserRole.student) {
        context.go(RouteNames.completeProfile);
      } else {
        context.go(RouteNames.dashboard);
      }
    }
  }

  Future<void> _handleResend() async {
    setState(() => _isResending = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _isResending = false);
    context.showSuccessSnackBar('A new verification code has been dispatched.');
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final targetEmail = authState.pendingVerificationEmail ?? authState.user?.email ?? 'your email';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Email Verification'),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: AppPaddings.all24,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Container(
                padding: AppPaddings.all24,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppBorderRadii.r20,
                  border: Border.all(color: AppColors.border, width: 1),
                  boxShadow: AppShadows.card,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: AppPaddings.all16,
                      decoration: const BoxDecoration(
                        color: AppColors.primarySurface,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.mark_email_read_outlined, size: 40, color: AppColors.primary),
                    ),
                    AppSpacing.v16,
                    const Text(
                      AppStrings.emailVerificationTitle,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    AppSpacing.v8,
                    Text(
                      'We have sent a verification code to\n$targetEmail',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    AppSpacing.v24,
                    AuthErrorBanner(errorMessage: authState.errorMessage),
                    AppTextField(
                      label: '6-Digit Verification Code',
                      hint: '123456',
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(Icons.pin_outlined, size: 20, color: AppColors.textSecondary),
                    ),
                    AppSpacing.v24,
                    PrimaryButton(
                      text: 'Verify & Continue',
                      isLoading: authState.isLoading,
                      onPressed: _handleVerify,
                    ),
                    AppSpacing.v16,
                    TextButton(
                      onPressed: _isResending ? null : _handleResend,
                      child: Text(
                        _isResending ? 'Resending...' : 'Resend Code',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
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
