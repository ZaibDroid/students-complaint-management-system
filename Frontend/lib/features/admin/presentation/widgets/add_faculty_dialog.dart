import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../providers/adviser_assignment_provider.dart';
import '../providers/coordinator_provider.dart';
import '../providers/staff_accounts_provider.dart';
import '../../../../features/batch/presentation/providers/batch_provider.dart';
import '../../../../features/batch/domain/entities/batch_model.dart';

class AddFacultyDialog extends ConsumerStatefulWidget {
  final String defaultRole;

  const AddFacultyDialog({super.key, this.defaultRole = 'Batch Adviser'});

  @override
  ConsumerState<AddFacultyDialog> createState() => _AddFacultyDialogState();
}

class _AddFacultyDialogState extends ConsumerState<AddFacultyDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _batchController = TextEditingController();
  final _sectionController = TextEditingController();

  String? _selectedBatchId;
  String? _selectedSection;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _batchController.dispose();
    _sectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          const Icon(Icons.person_add, color: Colors.blue),
          const SizedBox(width: 10),
          Text(
            widget.defaultRole == 'Batch Adviser' ? 'Add Batch Adviser' : 'Add New Faculty',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  controller: _nameController,
                  labelText: 'Full Name',
                  prefixIcon: const Icon(Icons.person),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _emailController,
                  labelText: 'Email Address',
                  prefixIcon: const Icon(Icons.email),
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Email is required';
                    if (!val.contains('@uetmardan.edu.pk')) {
                      return 'Use official email e.g., name@uetmardan.edu.pk';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _passwordController,
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  isPassword: true,
                  validator: (val) => val == null || val.length < 6 ? 'Min 6 characters' : null,
                ),
                if (widget.defaultRole == 'Batch Adviser') ...[
                  const SizedBox(height: 16),
                  _buildBatchAndSectionSelectors(),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        SizedBox(
          width: 100,
          child: PrimaryButton(
            text: 'Add',
            isLoading: _isLoading,
            onPressed: _isLoading ? null : _submit,
          ),
        ),
      ],
    );
  }

  Widget _buildBatchAndSectionSelectors() {
    final batchesAsync = ref.watch(batchesStreamProvider);

    return batchesAsync.when(
      loading: () => Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('Loading available batches...', style: TextStyle(fontSize: 13, color: Colors.grey)),
          ],
        ),
      ),
      error: (err, stack) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Could not load batches: $err',
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, size: 18),
                tooltip: 'Retry',
                onPressed: () => ref.invalidate(batchesStreamProvider),
              ),
            ],
          ),
          _buildManualBatchSectionFallback(),
        ],
      ),
      data: (batches) {
        if (batches.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, size: 18, color: Colors.amber),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'No batches found. Enter batch details manually:',
                        style: TextStyle(fontSize: 12, color: Colors.brown),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              _buildManualBatchSectionFallback(),
            ],
          );
        }

        BatchModel? selectedBatch;
        if (_selectedBatchId != null) {
          selectedBatch = batches.where((b) => b.id == _selectedBatchId).firstOrNull;
        }

        final sections = selectedBatch?.sections
                .map((s) => s.trim())
                .where((s) => s.isNotEmpty)
                .toSet()
                .toList() ??
            [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              key: ValueKey('batch_select_$_selectedBatchId'),
              isExpanded: true,
              initialValue: batches.any((b) => b.id == _selectedBatchId) ? _selectedBatchId : null,
              decoration: const InputDecoration(
                labelText: 'Select Batch',
                prefixIcon: Icon(Icons.school),
              ),
              hint: const Text('Choose Batch'),
              items: batches.map((batch) {
                final secCount = batch.sections.length;
                return DropdownMenuItem<String>(
                  value: batch.id,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          batch.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '$secCount ${secCount == 1 ? 'sec' : 'secs'}',
                          style: TextStyle(fontSize: 11, color: Colors.blue.shade700, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedBatchId = val;
                  _selectedSection = null;
                });
              },
              validator: (val) {
                if (widget.defaultRole == 'Batch Adviser') {
                  if (val == null || val.isEmpty) return 'Please select a batch';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              key: ValueKey('section_select_${selectedBatch?.id}_$_selectedSection'),
              isExpanded: true,
              initialValue: sections.contains(_selectedSection) ? _selectedSection : null,
              decoration: InputDecoration(
                labelText: 'Select Section',
                prefixIcon: const Icon(Icons.view_module),
                helperText: selectedBatch == null
                    ? 'Select a batch above to view sections'
                    : (sections.isEmpty ? 'No sections defined for this batch' : null),
              ),
              hint: Text(selectedBatch == null ? 'Select Batch First' : 'Choose Section'),
              items: sections.map((sec) {
                return DropdownMenuItem<String>(
                  value: sec,
                  child: Text(sec, style: const TextStyle(fontWeight: FontWeight.w500)),
                );
              }).toList(),
              onChanged: selectedBatch == null || sections.isEmpty
                  ? null
                  : (val) {
                      setState(() {
                        _selectedSection = val;
                      });
                    },
              validator: (val) {
                if (widget.defaultRole == 'Batch Adviser') {
                  if (selectedBatch == null) return 'Please select a batch';
                  if (sections.isNotEmpty && (val == null || val.isEmpty)) {
                    return 'Please select a section';
                  }
                }
                return null;
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildManualBatchSectionFallback() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: AppTextField(
            controller: _batchController,
            labelText: 'Batch No.',
            hintText: 'e.g. 2023',
            prefixIcon: const Icon(Icons.numbers),
            validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AppTextField(
            controller: _sectionController,
            labelText: 'Section',
            hintText: 'e.g. A',
            prefixIcon: const Icon(Icons.view_module),
            validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
          ),
        ),
      ],
    );
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final messenger = ScaffoldMessenger.of(context);
      final navigator = Navigator.of(context);

      setState(() => _isLoading = true);
      try {
        String? batchVal;
        String? batchId;
        String? sectionVal;

        if (widget.defaultRole == 'Batch Adviser') {
          final batches = ref.read(batchesStreamProvider).asData?.value ?? [];
          final selectedBatch = batches.where((b) => b.id == _selectedBatchId).firstOrNull;
          batchVal = selectedBatch?.name ?? _batchController.text.trim();
          batchId = selectedBatch?.id;
          sectionVal = _selectedSection ?? _sectionController.text.trim();
        }

        await ref.read(apiAuthRepositoryProvider).createStaffAccount(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          role: widget.defaultRole,
          batch: (batchVal != null && batchVal.isNotEmpty) ? batchVal : null,
          batchId: batchId,
          section: (sectionVal != null && sectionVal.isNotEmpty) ? sectionVal : null,
          assignedSections: [
            if (batchVal != null && batchVal.isNotEmpty && sectionVal != null && sectionVal.isNotEmpty)
              {
                'batch': batchVal,
                if (batchId != null) 'batch_id': batchId,
                'section': sectionVal,
              }
          ],
        );

        ref.invalidate(coordinatorsStreamProvider);
        ref.invalidate(batchAdvisersStreamProvider);
        ref.invalidate(batchesStreamProvider);
        ref.invalidate(staffAccountsProvider);

        navigator.pop();
        messenger.showSnackBar(
          SnackBar(
            content: Text('${widget.defaultRole} registered successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
        }
        messenger.showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '').replaceAll('ApiException: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
