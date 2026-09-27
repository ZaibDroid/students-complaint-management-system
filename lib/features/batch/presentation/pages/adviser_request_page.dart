import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../providers/batch_provider.dart';

class AdviserRequestPage extends ConsumerStatefulWidget {
  const AdviserRequestPage({super.key});

  @override
  ConsumerState<AdviserRequestPage> createState() => _AdviserRequestPageState();
}

class _AdviserRequestPageState extends ConsumerState<AdviserRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final success = await ref.read(batchProvider.notifier).requestMeeting(_reasonController.text.trim());

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Meeting request sent to your Batch Adviser successfully!'),
            backgroundColor: AppColors.statusResolved,
          ),
        );
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(batchProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Request Adviser Meeting'),
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Schedule Consultation',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Submit an official meeting request with your designated Batch Adviser for academic, registration, or grievance consultation.',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                  ),
                  const SizedBox(height: 20),
                  AppTextField(
                    label: 'Meeting Agenda / Purpose',
                    hint: 'Describe the topic you want to discuss with your Batch Adviser...',
                    controller: _reasonController,
                    maxLines: 5,
                    validator: (v) => Validators.validateRequired(v, fieldName: 'Meeting purpose'),
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    text: 'Send Meeting Request',
                    isLoading: state.isSubmittingRequest,
                    icon: Icons.send,
                    onPressed: _handleSubmit,
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
