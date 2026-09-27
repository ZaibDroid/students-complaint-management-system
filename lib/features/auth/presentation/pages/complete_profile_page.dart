import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/routes/route_names.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../providers/auth_provider.dart';

class CompleteProfilePage extends ConsumerStatefulWidget {
  const CompleteProfilePage({super.key});

  @override
  ConsumerState<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends ConsumerState<CompleteProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _regNoController = TextEditingController(text: '22MRCS042');
  final _phoneController = TextEditingController(text: '03001234567');
  String _selectedBatch = '2022-2026';
  String _selectedSection = 'Section A';

  final List<String> _batches = ['2020-2024', '2021-2025', '2022-2026', '2023-2027', '2024-2028'];
  final List<String> _sections = ['Section A', 'Section B', 'Section C', 'Evening'];

  @override
  void dispose() {
    _regNoController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleComplete() async {
    if (_formKey.currentState?.validate() ?? false) {
      final success = await ref.read(authProvider.notifier).completeProfile(
            regNo: _regNoController.text.trim(),
            batch: _selectedBatch,
            section: _selectedSection,
            phone: _phoneController.text.trim(),
          );

      if (success && mounted) {
        context.go(RouteNames.dashboard);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Complete Academic Profile'),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Form(
                key: _formKey,
                child: Container(
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
                        AppStrings.completeProfileTitle,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        AppStrings.completeProfileSubtitle,
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 24),

                      // Registration Number
                      AppTextField(
                        label: 'Registration Number',
                        hint: 'e.g. 22MRCS042',
                        controller: _regNoController,
                        prefixIcon: const Icon(Icons.badge_outlined, size: 20, color: AppColors.textSecondary),
                        validator: Validators.validateRegNo,
                      ),
                      const SizedBox(height: 16),

                      // Batch Selection
                      const Text(
                        'Academic Batch',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border, width: 1),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: _selectedBatch,
                            items: _batches.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedBatch = val);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Section Selection
                      const Text(
                        'Class Section',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border, width: 1),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: _selectedSection,
                            items: _sections.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedSection = val);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Contact Phone
                      AppTextField(
                        label: 'Contact Phone Number (Optional)',
                        hint: '0300-1234567',
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        prefixIcon: const Icon(Icons.phone_outlined, size: 20, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 24),

                      PrimaryButton(
                        text: 'Save & Go to Dashboard',
                        isLoading: authState.isLoading,
                        onPressed: _handleComplete,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
