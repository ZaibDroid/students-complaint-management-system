import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../features/auth/domain/entities/user.dart';
import '../providers/adviser_assignment_provider.dart';
import '../providers/coordinator_provider.dart';
import '../providers/staff_accounts_provider.dart';
import '../../../../features/batch/presentation/providers/batch_provider.dart';
import '../../../../features/batch/domain/entities/batch_model.dart';

class EditFacultyDialog extends ConsumerStatefulWidget {
  final User adviser;

  const EditFacultyDialog({super.key, required this.adviser});

  @override
  ConsumerState<EditFacultyDialog> createState() => _EditFacultyDialogState();
}

class _EditFacultyDialogState extends ConsumerState<EditFacultyDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _batchController;
  late final TextEditingController _sectionController;
  late final TextEditingController _semesterController;

  String? _selectedBatchId;
  String? _selectedSection;
  bool _isLoading = false;
  bool _initializedDefaults = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.adviser.name);
    _batchController = TextEditingController(text: widget.adviser.batch ?? '');
    _sectionController = TextEditingController(text: widget.adviser.section ?? '');
    _semesterController = TextEditingController(text: widget.adviser.semester ?? '');
    _selectedSection = widget.adviser.section;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _batchController.dispose();
    _sectionController.dispose();
    _semesterController.dispose();
    super.dispose();
  }

  void _matchInitialBatch(List<BatchModel> batches) {
    if (_initializedDefaults || batches.isEmpty) return;
    _initializedDefaults = true;

    final target = (widget.adviser.batch ?? '').trim().toLowerCase();
    if (target.isEmpty) return;

    for (var b in batches) {
      if (b.id == target || b.name.toLowerCase() == target || b.name.toLowerCase().contains(target)) {
        _selectedBatchId = b.id;
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(
        children: [
          Icon(Icons.edit, color: Colors.blue),
          SizedBox(width: 10),
          Text('Edit Batch Adviser', style: TextStyle(fontWeight: FontWeight.bold)),
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
                _buildBatchAndSectionSelectors(),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _semesterController,
                  labelText: 'Semester',
                  hintText: 'e.g. BSCS-1',
                  prefixIcon: const Icon(Icons.class_),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                ),
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
            text: 'Save',
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
            Text('Loading batches...', style: TextStyle(fontSize: 13, color: Colors.grey)),
          ],
        ),
      ),
      error: (err, stack) => _buildManualBatchSectionFallback(),
      data: (batches) {
        if (batches.isEmpty) {
          return _buildManualBatchSectionFallback();
        }

        _matchInitialBatch(batches);

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
                if (val == null || val.isEmpty) {
                  return 'Please select a batch';
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
                if (selectedBatch == null) return 'Please select a batch';
                if (sections.isNotEmpty && (val == null || val.isEmpty)) {
                  return 'Please select a section';
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
        final batches = ref.read(batchesStreamProvider).asData?.value ?? [];
        final selectedBatch = batches.where((b) => b.id == _selectedBatchId).firstOrNull;
        final batchVal = selectedBatch?.name ?? _batchController.text.trim();
        final batchId = selectedBatch?.id;
        final sectionVal = _selectedSection ?? _sectionController.text.trim();

        await ref.read(apiAuthRepositoryProvider).updateStaffAccount(
          widget.adviser.id,
          name: _nameController.text.trim(),
          batch: batchVal.isNotEmpty ? batchVal : null,
          batchId: batchId,
          section: sectionVal.isNotEmpty ? sectionVal : null,
          semester: _semesterController.text.trim(),
          assignedSections: [
            if (batchVal.isNotEmpty && sectionVal.isNotEmpty)
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
          const SnackBar(
            content: Text('Faculty details updated successfully!'),
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
