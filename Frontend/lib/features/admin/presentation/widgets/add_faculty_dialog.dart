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
  final String? initialBatchYear;
  final String? initialBatchId;
  final String? initialSection;
  final String? initialSectionId;

  const AddFacultyDialog({
    super.key,
    this.defaultRole = 'Batch Adviser',
    this.initialBatchYear,
    this.initialBatchId,
    this.initialSection,
    this.initialSectionId,
  });

  @override
  ConsumerState<AddFacultyDialog> createState() => _AddFacultyDialogState();
}

class _AddFacultyDialogState extends ConsumerState<AddFacultyDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _startYearController = TextEditingController();
  final _endYearController = TextEditingController();
  final _batchController = TextEditingController();
  final _sectionController = TextEditingController();

  String? _selectedBatchId;
  String? _selectedSection;
  bool _isLoading = false;

  bool get _isCoordinator => widget.defaultRole == 'Coordinator';
  bool get _isSectionContext => widget.initialSection != null && widget.initialSection!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    if (widget.initialBatchId != null) {
      _selectedBatchId = widget.initialBatchId;
    }
    if (widget.initialSection != null) {
      _selectedSection = widget.initialSection;
      _sectionController.text = widget.initialSection!;
    }
    if (widget.initialBatchYear != null) {
      final raw = widget.initialBatchYear!.replaceAll(RegExp(r'^Batch\s+', caseSensitive: false), '').trim();
      final parts = raw.split(RegExp(r'[-–—/]'));
      if (parts.isNotEmpty && parts[0].trim().isNotEmpty) {
        _startYearController.text = parts[0].trim();
        _batchController.text = parts[0].trim();
      }
      if (parts.length > 1 && parts[1].trim().isNotEmpty) {
        _endYearController.text = parts[1].trim();
      } else if (_startYearController.text.isNotEmpty) {
        final s = int.tryParse(_startYearController.text);
        if (s != null) _endYearController.text = (s + 4).toString();
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _startYearController.dispose();
    _endYearController.dispose();
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _isCoordinator
                      ? 'Add Coordinator'
                      : (widget.defaultRole == 'Batch Adviser' ? 'Add Batch Adviser' : 'Add New Faculty'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (_isSectionContext)
                  Text(
                    'Batch ${widget.initialBatchYear ?? ''} • Section ${widget.initialSection}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.normal),
                  ),
              ],
            ),
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
                const SizedBox(height: 16),
                // For Coordinator: only enter Start Year and End Year (NO batch dropdown)
                if (_isCoordinator)
                  _buildCoordinatorBatchYearFields()
                else if (widget.defaultRole == 'Batch Adviser' && !_isSectionContext)
                  _buildBatchAndSectionSelectors(),
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

  Widget _buildCoordinatorBatchYearFields() {
    return _buildManualCoordinatorYearFields();
  }

  Widget _buildManualCoordinatorYearFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Batch Duration',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF172548)),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppTextField(
                controller: _startYearController,
                labelText: 'Starting Year',
                hintText: 'e.g. 2022',
                prefixIcon: const Icon(Icons.calendar_today),
                keyboardType: TextInputType.number,
                onChanged: (val) {
                  final trimmed = val.trim();
                  if (trimmed.length == 4) {
                    final num = int.tryParse(trimmed);
                    if (num != null && _endYearController.text.trim().isEmpty) {
                      _endYearController.text = (num + 4).toString();
                    }
                  }
                },
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Required';
                  final num = int.tryParse(val.trim());
                  if (num == null || num < 2000 || num > 2100) return 'Invalid year';
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppTextField(
                controller: _endYearController,
                labelText: 'Ending Year',
                hintText: 'e.g. 2026',
                prefixIcon: const Icon(Icons.event),
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Required';
                  final num = int.tryParse(val.trim());
                  if (num == null || num < 2000 || num > 2100) return 'Invalid year';
                  final start = int.tryParse(_startYearController.text.trim());
                  if (start != null && num <= start) {
                    return 'Must be > start';
                  }
                  return null;
                },
              ),
            ),
          ],
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
      error: (err, stack) => _buildManualBatchSectionFallback(),
      data: (batches) {
        if (batches.isEmpty) {
          return _buildManualBatchSectionFallback();
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
        sections.sort();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              key: ValueKey('batch_select_$_selectedBatchId'),
              isExpanded: true,
              initialValue: batches.any((b) => b.id == _selectedBatchId) ? _selectedBatchId : null,
              decoration: const InputDecoration(
                labelText: 'Select Batch Year',
                prefixIcon: Icon(Icons.school),
              ),
              hint: const Text('Choose Batch Year'),
              items: batches.map((batch) {
                final secCount = batch.sections.length;
                final cleanBatchYear = batch.name.replaceAll(RegExp(r'^Batch\s+', caseSensitive: false), '').trim();
                return DropdownMenuItem<String>(
                  value: batch.id,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          cleanBatchYear,
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
                  if (_batchController.text.trim().isEmpty) {
                    return 'Please select or enter a batch';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            AppTextField(
              controller: _batchController,
              labelText: 'Or Enter Batch Year (e.g. 2022-2026)',
              prefixIcon: const Icon(Icons.numbers),
              keyboardType: TextInputType.text,
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
                if (selectedBatch == null && _batchController.text.trim().isEmpty) return 'Please select a batch';
                if (sections.isNotEmpty && (val == null || val.isEmpty) && _sectionController.text.trim().isEmpty) {
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
            hintText: 'e.g. 2022-2026',
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

        if (_isCoordinator) {
          final start = _startYearController.text.trim();
          final end = _endYearController.text.trim();
          batchVal = '$start-$end';

          final batches = ref.read(batchesStreamProvider).asData?.value ?? [];
          final matchingBatch = batches.where((b) {
            final clean = b.name.replaceAll(RegExp(r'^Batch\s+', caseSensitive: false), '').trim();
            return clean == batchVal || b.name == batchVal;
          }).firstOrNull;
          batchId = matchingBatch?.id;
        } else if (widget.defaultRole == 'Batch Adviser') {
          if (_isSectionContext) {
            batchVal = widget.initialBatchYear?.replaceAll(RegExp(r'^Batch\s+', caseSensitive: false), '').trim();
            batchId = widget.initialBatchId;
            sectionVal = widget.initialSection;

            if (batchId == null || batchId.isEmpty) {
              final batches = ref.read(batchesStreamProvider).asData?.value ?? [];
              final matchingBatch = batches.where((b) {
                final clean = b.name.replaceAll(RegExp(r'^Batch\s+', caseSensitive: false), '').trim();
                return clean == batchVal || b.name == batchVal;
              }).firstOrNull;
              batchId = matchingBatch?.id;
            }
          } else {
            final batches = ref.read(batchesStreamProvider).asData?.value ?? [];
            final selectedBatch = batches.where((b) => b.id == _selectedBatchId).firstOrNull;
            batchVal = (selectedBatch != null && selectedBatch.name.isNotEmpty)
                ? selectedBatch.name.replaceAll(RegExp(r'^Batch\s+', caseSensitive: false), '').trim()
                : _batchController.text.trim();
            batchId = selectedBatch?.id;
            sectionVal = _selectedSection ?? _sectionController.text.trim();
          }
        }

        await ref.read(apiAuthRepositoryProvider).createStaffAccount(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          role: widget.defaultRole,
          batch: (batchVal != null && batchVal.isNotEmpty) ? batchVal : null,
          batchId: batchId,
          section: (sectionVal != null && sectionVal.isNotEmpty) ? sectionVal : null,
          sectionId: _isSectionContext ? widget.initialSectionId : null,
          assignedSections: _isCoordinator
              ? null
              : [
                  if (batchVal != null && batchVal.isNotEmpty && sectionVal != null && sectionVal.isNotEmpty)
                    {
                      'batch': batchVal,
                      if (batchId != null) ...{'batch_id': batchId},
                      'section': sectionVal,
                      if (_isSectionContext && widget.initialSectionId != null)
                        ...{'section_id': widget.initialSectionId},
                    }
                ],
        );

        ref.invalidate(coordinatorsStreamProvider);
        ref.invalidate(batchAdvisersStreamProvider);
        ref.invalidate(batchesStreamProvider);
        ref.invalidate(staffAccountsProvider);

        navigator.pop(true);
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
