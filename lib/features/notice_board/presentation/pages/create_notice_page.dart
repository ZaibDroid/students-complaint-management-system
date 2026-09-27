import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../shared/enums/notice_target.dart';
import '../providers/notice_provider.dart';

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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notice published successfully! Push notifications dispatched to target audience.'),
            backgroundColor: AppColors.statusResolved,
          ),
        );
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
          padding: const EdgeInsets.all(20),
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
                const SizedBox(height: 16),

                // Target Audience
                const Text(
                  'Target Audience',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border, width: 1),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<NoticeTarget>(
                      isExpanded: true,
                      value: _selectedTarget,
                      items: NoticeTarget.values.map((target) {
                        return DropdownMenuItem(
                          value: target,
                          child: Text(target.displayName, style: const TextStyle(fontSize: 14)),
                        );
                      }).toList(),
                      onChanged: (target) {
                        if (target != null) setState(() => _selectedTarget = target);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

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
                  const SizedBox(height: 16),
                ],

                // Notice Content
                AppTextField(
                  label: 'Notice Body / Content',
                  hint: 'Enter full announcement details, deadlines, and instructions...',
                  controller: _contentController,
                  maxLines: 7,
                  validator: (v) => Validators.validateRequired(v, fieldName: 'Notice content'),
                ),
                const SizedBox(height: 16),

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
                const SizedBox(height: 24),

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
