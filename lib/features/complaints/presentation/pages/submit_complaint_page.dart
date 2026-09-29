import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../core/utils/image_compressor.dart';
import '../../../../core/utils/ui_helpers.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/image_picker_card.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../shared/enums/priority_level.dart';
import '../providers/complaints_provider.dart';
import '../widgets/priority_selector.dart';

class SubmitComplaintPage extends ConsumerStatefulWidget {
  const SubmitComplaintPage({super.key});

  @override
  ConsumerState<SubmitComplaintPage> createState() => _SubmitComplaintPageState();
}

class _SubmitComplaintPageState extends ConsumerState<SubmitComplaintPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedCategory = 'Academic Issues';
  PriorityLevel _selectedPriority = PriorityLevel.medium;
  final List<File> _attachedImages = [];
  bool _isSubmitting = false;

  static const List<String> _categories = [
    'Academic Issues',
    'Faculty / Teaching',
    'Lab & Equipment',
    'Examination & Results',
    'Hostel / Transport',
    'Fee & Scholarships',
    'Administrative / Office',
    'Harassment / Ethics',
    'Other',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final images = await ImageCompressor.pickMultiImage(maxImages: 4 - _attachedImages.length);
    if (images.isNotEmpty) {
      setState(() {
        _attachedImages.addAll(images);
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _attachedImages.removeAt(index);
    });
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSubmitting = true);

      final submitUseCase = ref.read(submitComplaintUseCaseProvider);
      final result = await submitUseCase(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        priority: _selectedPriority,
        attachments: _attachedImages,
      );

      setState(() => _isSubmitting = false);

      result.when(
        onSuccess: (complaint) {
          ref.read(complaintsListProvider.notifier).fetchComplaints(page: 1);
          context.showSuccessSnackBar('Complaint ${complaint.trackingNumber} submitted successfully!');
          context.pop();
        },
        onError: (failure) {
          context.showErrorSnackBar(failure.message);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Lodge New Complaint'),
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
                // Info Box
                Container(
                  padding: AppPaddings.all14,
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: AppBorderRadii.r12,
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                      AppSpacing.h10,
                      Expanded(
                        child: Text(
                          'Your complaint will be routed directly to your assigned Batch Adviser for initial review.',
                          style: TextStyle(fontSize: 12.5, color: AppColors.primary, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpacing.v20,

                // Complaint Title
                AppTextField(
                  label: 'Complaint Subject / Title',
                  hint: 'e.g. Broken lab equipment in CS Lab 2',
                  controller: _titleController,
                  validator: (v) => Validators.validateRequired(v, fieldName: 'Complaint subject'),
                ),
                AppSpacing.v16,

                // Category Selection
                const Text(
                  'Complaint Category',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                AppSpacing.v6,
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppBorderRadii.r12,
                    border: Border.all(color: AppColors.border, width: 1),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedCategory,
                      items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedCategory = val);
                      },
                    ),
                  ),
                ),
                AppSpacing.v16,

                // Priority Level Selector
                const Text(
                  'Urgency / Priority',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                AppSpacing.v8,
                PrioritySelector(
                  selectedPriority: _selectedPriority,
                  onPrioritySelected: (p) => setState(() => _selectedPriority = p),
                ),
                AppSpacing.v16,

                // Detailed Description
                AppTextField(
                  label: 'Detailed Description',
                  hint: 'Provide complete details about the incident, date, people involved, and affected parties...',
                  controller: _descriptionController,
                  maxLines: 6,
                  validator: (v) => Validators.validateRequired(v, fieldName: 'Complaint description'),
                ),
                AppSpacing.v16,

                // Image Upload & Compression
                ImagePickerCard(
                  selectedImages: _attachedImages,
                  onPickImages: _pickImages,
                  onRemoveImage: _removeImage,
                  maxImages: 4,
                ),
                AppSpacing.v28,

                // Submit Button
                PrimaryButton(
                  text: 'Submit to Batch Adviser',
                  isLoading: _isSubmitting,
                  icon: Icons.send_outlined,
                  onPressed: _handleSubmit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
