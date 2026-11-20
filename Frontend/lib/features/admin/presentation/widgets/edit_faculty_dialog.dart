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
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _startYearController;
  late final TextEditingController _endYearController;
  late final TextEditingController _batchController;
  late final TextEditingController _sectionController;

  String? _selectedBatchId;
  String? _selectedSection;
  bool _isLoading = false;
  bool _initializedDefaults = false;

  bool get _isCoordinator => widget.adviser.role.trim().toLowerCase() == 'coordinator';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.adviser.name);
    _emailController = TextEditingController(text: widget.adviser.email);
    final initialPass = widget.adviser.assignedPassword ?? '123456';
    _passwordController = TextEditingController(text: initialPass);

    final rawBatch = (widget.adviser.batch ?? '').replaceAll(RegExp(r'^Batch\s+', caseSensitive: false), '').trim();
    _batchController = TextEditingController(text: rawBatch);
    _sectionController = TextEditingController(text: widget.adviser.section ?? '');
    _selectedSection = widget.adviser.section;

    // Parse starting and ending years for coordinator
    String startVal = '';
    String endVal = '';
    if (rawBatch.isNotEmpty) {
      final parts = rawBatch.split(RegExp(r'[-–—/]'));
      if (parts.isNotEmpty && parts[0].trim().isNotEmpty) {
        startVal = parts[0].trim();
      }
      if (parts.length > 1 && parts[1].trim().isNotEmpty) {
        endVal = parts[1].trim();
      } else if (startVal.isNotEmpty) {
        final s = int.tryParse(startVal);
        if (s != null) endVal = (s + 4).toString();
      }
    }
    _startYearController = TextEditingController(text: startVal);
    _endYearController = TextEditingController(text: endVal);
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

  void _matchInitialBatch(List<BatchModel> batches) {
    if (_initializedDefaults || batches.isEmpty || _isCoordinator) return;
    _initializedDefaults = true;

    if (widget.adviser.batchId != null && widget.adviser.batchId!.isNotEmpty) {
      if (batches.any((b) => b.id == widget.adviser.batchId)) {
        _selectedBatchId = widget.adviser.batchId;
        return;
      }
    }

    final target = (widget.adviser.batch ?? '')
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'^batch\s+', caseSensitive: false), '');
    if (target.isEmpty) return;

    for (var b in batches) {
      final cleanName = b.name.toLowerCase().replaceAll(RegExp(r'^batch\s+', caseSensitive: false), '').trim();
      if (b.id == target || cleanName == target || cleanName.contains(target) || target.contains(cleanName)) {
        _selectedBatchId = b.id;
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          const Icon(Icons.edit, color: Colors.blue),
          const SizedBox(width: 10),
          Text(
            _isCoordinator ? 'Edit Coordinator' : 'Edit Batch Adviser',
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
                  prefixIcon: const Icon(Icons.lock_outline),
                  isPassword: true,
                  helperText: 'Click the eye icon to view or change the password',
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Password is required';
                    }
                    if (val.trim().length < 6) {
                      return 'Min 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // For Coordinator: only Start Year & End Year (NO batch dropdown, NO section)
                if (_isCoordinator)
                  _buildCoordinatorBatchYearFields()
                else
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
            text: 'Save',
            isLoading: _isLoading,
            onPressed: _isLoading ? null : _submit,
          ),
        ),
      ],
    );
  }

  Widget _buildCoordinatorBatchYearFields() {
    final batchesAsync = ref.watch(batchesStreamProvider);

    return batchesAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
            SizedBox(width: 8),
            Text('Loading batches...', style: TextStyle(fontSize: 13, color: Colors.grey)),
          ],
        ),
      ),
      error: (error, stack) => _buildManualCoordinatorYearFields(),
      data: (batches) {
        final availableBatches = batches.where((b) {
          final isCurrent = (b.coordinatorId != null && b.coordinatorId == widget.adviser.id) ||
              (widget.adviser.batch != null && (b.name == widget.adviser.batch || b.name == 'Batch ${widget.adviser.batch}'));
          return isCurrent || !b.isCoordinatorAssigned;
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (availableBatches.isNotEmpty) ...[
              DropdownButtonFormField<String>(
                key: ValueKey('edit_coord_batch_$_selectedBatchId'),
                isExpanded: true,
                initialValue: availableBatches.any((b) => b.id == _selectedBatchId) ? _selectedBatchId : null,
                decoration: const InputDecoration(
                  labelText: 'Select Batch Assignment',
                  prefixIcon: Icon(Icons.school),
                ),
                hint: const Text('Choose Batch'),
                items: availableBatches.map((batch) {
                  final isCurrent = (batch.coordinatorId != null && batch.coordinatorId == widget.adviser.id);
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
                        if (isCurrent)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Current',
                              style: TextStyle(fontSize: 11, color: Colors.green.shade800, fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedBatchId = val;
                    final b = availableBatches.firstWhere((x) => x.id == val);
                    final clean = b.name.replaceAll(RegExp(r'^Batch\s+', caseSensitive: false), '').trim();
                    final parts = clean.split(RegExp(r'[-–—/]'));
                    if (parts.isNotEmpty && parts[0].trim().isNotEmpty) {
                      _startYearController.text = parts[0].trim();
                    }
                    if (parts.length > 1 && parts[1].trim().isNotEmpty) {
                      _endYearController.text = parts[1].trim();
                    }
                  });
                },
              ),
              const SizedBox(height: 12),
              const Text(
                'Or specify batch years manually:',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 8),
            ],
            _buildManualCoordinatorYearFields(),
          ],
        );
      },
    );
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
        sections.sort();

        // Auto-match initial section if needed
        if (_selectedSection != null && !sections.contains(_selectedSection)) {
          final cleanCurrent = _selectedSection!.replaceAll(RegExp(r'^section\s+', caseSensitive: false), '').trim().toLowerCase();
          for (final s in sections) {
            final cleanS = s.replaceAll(RegExp(r'^section\s+', caseSensitive: false), '').trim().toLowerCase();
            if (cleanS == cleanCurrent) {
              _selectedSection = s;
              break;
            }
          }
        }

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
                    return 'Please select a batch';
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
        } else {
          final batches = ref.read(batchesStreamProvider).asData?.value ?? [];
          final selectedBatch = batches.where((b) => b.id == _selectedBatchId).firstOrNull;
          batchVal = selectedBatch != null
              ? selectedBatch.name.replaceAll(RegExp(r'^Batch\s+', caseSensitive: false), '').trim()
              : _batchController.text.trim().replaceAll(RegExp(r'^Batch\s+', caseSensitive: false), '').trim();
          batchId = selectedBatch?.id;
          sectionVal = _selectedSection ?? _sectionController.text.trim();
        }

        final newPassword = _passwordController.text.trim();

        await ref.read(apiAuthRepositoryProvider).updateStaffAccount(
          widget.adviser.id,
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: newPassword.isNotEmpty ? newPassword : null,
          batch: batchVal.isNotEmpty ? batchVal : null,
          batchId: batchId,
          section: (sectionVal != null && sectionVal.isNotEmpty) ? sectionVal : null,
          semester: widget.adviser.semester,
          assignedSections: _isCoordinator
              ? null
              : [
                  if (batchVal.isNotEmpty && sectionVal != null && sectionVal.isNotEmpty)
                    {
                      'batch': batchVal,
                      if (batchId != null) ...{'batch_id': batchId},
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
            content: Text(_isCoordinator ? 'Coordinator details updated successfully!' : 'Batch Adviser details updated successfully!'),
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
