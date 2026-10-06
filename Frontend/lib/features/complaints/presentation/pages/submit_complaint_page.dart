import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../widgets/file_upload_box.dart';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../providers/complaint_provider.dart';
import '../../data/models/complaint_model.dart';

class SubmitComplaintPage extends ConsumerStatefulWidget {
  const SubmitComplaintPage({super.key});

  @override
  ConsumerState<SubmitComplaintPage> createState() => _SubmitComplaintPageState();
}

class _SubmitComplaintPageState extends ConsumerState<SubmitComplaintPage> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedCategory;

  File? _selectedFile;

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final sizeInBytes = await file.length();
      final sizeInMB = sizeInBytes / (1024 * 1024);

      if (sizeInMB > 5) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File is too large. Maximum allowed size is 5MB.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
        return;
      }

      setState(() {
        _selectedFile = file;
      });
    }
  }

  void _removeFile() {
    setState(() {
      _selectedFile = null;
    });
  }

  Future<void> _submit() async {
    final user = ref.read(authStateProvider).value;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User not found. Please log in again.')));
      return;
    }

    if (user.role == 'Student' && (user.adviser == null || user.status != 'approved')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must link and be approved by a Batch Adviser before submitting a complaint. Please go to your Profile.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate() && _selectedCategory != null) {
      final complaint = ComplaintModel(
        id: '',
        studentId: user.id,
        studentName: user.name,
        studentBatch: user.batch ?? 'N/A',
        title: _subjectController.text,
        description: _descriptionController.text,
        category: _selectedCategory!,
        status: 'pending',
        priority: 'medium',
        createdAt: DateTime.now(),
        assignedTo: user.adviser,
        involvedStaffNames: user.adviser != null ? [user.adviser!] : [],
      );

      final success = await ref.read(submitComplaintProvider.notifier).submit(complaint, attachment: _selectedFile);
      
      if (!mounted) return;
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Complaint submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      } else {
        final error = ref.read(submitComplaintProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: ${error.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8FC),
      appBar: AppBar(
        title: const Text('Complaint System', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ADMINISTRATION SERVICES',
                style: TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.2,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Submit a New Complaint',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Please provide accurate details to help us address your concern effectively. Your submission will be routed to the relevant department immediately.',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 32),

              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Category', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCategory,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      hint: const Text('Select a category'),
                      items: const [
                        DropdownMenuItem(value: 'Academic Affairs', child: Text('Academic Affairs')),
                        DropdownMenuItem(value: 'Facility & Infrastructure', child: Text('Facility & Infrastructure')),
                        DropdownMenuItem(value: 'IT & Network Support', child: Text('IT & Network Support')),
                        DropdownMenuItem(value: 'Finance & Fees', child: Text('Finance & Fees')),
                      ],
                      onChanged: (val) => setState(() => _selectedCategory = val),
                      validator: (val) => val == null ? 'Please select a category' : null,
                    ),
                    const SizedBox(height: 24),
                    
                    const Text('Subject', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    AppTextField(
                      controller: _subjectController,
                      labelText: '',
                      hintText: 'Brief summary of the issue',
                      validator: (val) => val == null || val.isEmpty ? 'Required field' : null,
                    ),
                    const SizedBox(height: 24),
                    
                    const Text('Detailed Description', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Describe the problem in detail...',
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      validator: (val) => val == null || val.isEmpty ? 'Required field' : null,
                    ),
                    const SizedBox(height: 24),
                    
                    const Text('Evidence & Attachments (Max 5MB)', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    FileUploadBox(onTap: _pickFile),
                    
                    if (_selectedFile != null) ...[
                      const SizedBox(height: 16),
                      Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.insert_drive_file, color: Colors.blue),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _selectedFile!.path.split(Platform.pathSeparator).last,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: -4,
                            right: -4,
                            child: IconButton(
                              icon: const Icon(Icons.cancel, color: Colors.red),
                              onPressed: _removeFile,
                            ),
                          ),
                        ],
                      ),
                    ],
                    
                    const SizedBox(height: 32),
                    
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border(left: BorderSide(color: theme.primaryColor, width: 4)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info, color: theme.primaryColor, size: 20),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'By submitting this complaint, you verify that all information provided is accurate and truthful. Purposeful misinformation may lead to disciplinary action.',
                              style: TextStyle(fontSize: 13, color: Colors.black54),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    Row(
                      children: [
                        Expanded(
                          child: PrimaryButton(
                            text: 'Submit Complaint',
                            isLoading: ref.watch(submitComplaintProvider).isLoading,
                            onPressed: _submit,
                          ),
                        ),
                        const SizedBox(width: 16),
                        OutlinedButton(
                          onPressed: () => context.pop(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(color: theme.primaryColor),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
