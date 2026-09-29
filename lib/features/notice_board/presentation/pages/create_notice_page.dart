import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../core/utils/ui_helpers.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../shared/enums/notice_target.dart';
import '../providers/notice_provider.dart';
import '../widgets/notice_audience_selector.dart';

class CreateNoticePage extends ConsumerStatefulWidget {
  const CreateNoticePage({super.key});

  @override
  ConsumerState<CreateNoticePage> createState() => _CreateNoticePageState();
}

class _CreateNoticePageState extends ConsumerState<CreateNoticePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _targetValueController = TextEditingController();

  NoticeTarget _selectedTarget = NoticeTarget.all;
  bool _isPinned = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _targetValueController.dispose();
    super.dispose();
  }

  Future<void> _handlePublish() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSubmitting = true);

      final success = await ref.read(noticeProvider.notifier).createNotice(
            title: _titleController.text.trim(),
            content: _contentController.text.trim(),
            target: _selectedTarget,
            targetValue: _selectedTarget != NoticeTarget.all ? _targetValueController.text.trim() : null,
            isPinned: _isPinned,
          );

      setState(() => _isSubmitting = false);

      if (success && mounted) {
        context.showSuccessSnackBar('Notice published successfully! Push notifications dispatched to target audience.');
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Publish Department Notice'),
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppPaddings.all20,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Notice Title
                AppTextField(
                  label: 'Notice Title / Headline',
                  hint: 'e.g. Schedule for Midterm Examination Fall 2026',
                  controller: _titleController,
                  validator: (v) => Validators.validateRequired(v, fieldName: 'Notice title'),
                ),
                AppSpacing.v16,

                // Target Audience
                NoticeAudienceSelector(
                  selectedTarget: _selectedTarget,
                  onTargetChanged: (target) => setState(() => _selectedTarget = target),
                ),
                AppSpacing.v16,

                // Conditional Target Identifier
                if (_selectedTarget != NoticeTarget.all) ...[
                  AppTextField(
                    label: _selectedTarget == NoticeTarget.year
                        ? 'Specify Year (e.g. 3rd Year)'
                        : (_selectedTarget == NoticeTarget.batch ? 'Specify Batch (e.g. 2022-2026)' : 'Specify Section (e.g. Section A)'),
                    hint: 'Enter target identifier...',
                    controller: _targetValueController,
                    validator: (v) => Validators.validateRequired(v, fieldName: 'Target identifier'),
                  ),
                  AppSpacing.v16,
                ],

                // Notice Content
                AppTextField(
                  label: 'Notice Body / Content',
                  hint: 'Enter full announcement details, deadlines, and instructions...',
                  controller: _contentController,
                  maxLines: 7,
                  validator: (v) => Validators.validateRequired(v, fieldName: 'Notice content'),
                ),
                AppSpacing.v16,

                // Pin to Top Switch
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Pin to Top of Notice Board',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                  subtitle: const Text(
                    'Pinned notices remain highlighted at the top for all students',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  value: _isPinned,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) => setState(() => _isPinned = val),
                ),
                AppSpacing.v24,

                // Publish Button
                PrimaryButton(
                  text: 'Publish Notice & Notify Students',
                  isLoading: _isSubmitting,
                  icon: Icons.send,
                  onPressed: _handlePublish,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
