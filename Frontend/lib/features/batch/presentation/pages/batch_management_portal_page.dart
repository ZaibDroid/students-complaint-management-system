import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/batch_provider.dart';
import '../../../admin/presentation/providers/adviser_assignment_provider.dart';

import '../../data/repositories/batch_repository.dart';
import '../../../admin/domain/entities/adviser_assignment.dart';
import '../../domain/entities/batch_model.dart';

class BatchManagementPortalPage extends ConsumerStatefulWidget {
  final bool isEmbedded;
  const BatchManagementPortalPage({super.key, this.isEmbedded = false});

  @override
  ConsumerState<BatchManagementPortalPage> createState() => _BatchManagementPortalPageState();
}

class _BatchManagementPortalPageState extends ConsumerState<BatchManagementPortalPage> {
  final _batchNameController = TextEditingController();
  final _sectionsController = TextEditingController();
  bool _isCreatingBatch = false;

  @override
  void dispose() {
    _batchNameController.dispose();
    _sectionsController.dispose();
    super.dispose();
  }

  void _createBatch() async {
    if (_batchNameController.text.trim().isEmpty || _sectionsController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a batch name and sections')),
      );
      return;
    }

    final name = _batchNameController.text.trim();
    final sectionsList = _sectionsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    setState(() => _isCreatingBatch = true);

    try {
      final repository = ref.read(batchRepositoryProvider);
      await repository.addBatch(name: name, sections: sectionsList);
      
      if (mounted) {
        _batchNameController.clear();
        _sectionsController.clear();
        ref.invalidate(batchesStreamProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Batch created successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create batch: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isCreatingBatch = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final batchesAsync = ref.watch(batchesStreamProvider);
    final assignments = ref.watch(adviserAssignmentsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: widget.isEmbedded 
          ? null 
          : AppBar(
              title: const Text('Batch Management', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.5)),
              backgroundColor: Colors.transparent,
              elevation: 0,
              foregroundColor: const Color(0xFF1E293B),
            ),
      body: batchesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (batches) {
          int totalSections = 0;
          for (var b in batches) {
            totalSections += b.sections.length;
          }
          
          int assignedSections = assignments.where((a) => a.adviserId != null).length;
          double progress = totalSections == 0 ? 0 : assignedSections / totalSections;
          
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            children: [
              // Operational Overview Statistics
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'OPERATIONAL OVERVIEW', 
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.white54)
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        _buildStatColumn('BATCHES', '${batches.length}', Icons.layers_rounded),
                        Container(width: 1, height: 40, color: Colors.white24, margin: const EdgeInsets.symmetric(horizontal: 24)),
                        _buildStatColumn('SECTIONS', '$totalSections', Icons.grid_view_rounded),
                        Container(width: 1, height: 40, color: Colors.white24, margin: const EdgeInsets.symmetric(horizontal: 24)),
                        _buildStatColumn('ASSIGNED', '$assignedSections', Icons.check_circle_outline),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.white12,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          progress == 1.0 ? const Color(0xFF10B981) : const Color(0xFF3B82F6)
                        ),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(progress * 100).toInt()}% of sections assigned',
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Create Batch Form
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 24, offset: const Offset(0, 8)),
                  ],
                ),
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.add_box_rounded, color: Color(0xFF4F46E5), size: 20),
                        ),
                        const SizedBox(width: 16),
                        const Text('Create New Batch', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Batch Year', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _batchNameController,
                                decoration: InputDecoration(
                                  hintText: 'e.g., 2024',
                                  hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFC),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16), 
                                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16), 
                                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Sections', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _sectionsController,
                                decoration: InputDecoration(
                                  hintText: 'e.g., A, B',
                                  hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFC),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16), 
                                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16), 
                                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton.icon(
                            onPressed: _isCreatingBatch ? null : _createBatch,
                            icon: _isCreatingBatch 
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
                                : const Icon(Icons.add, size: 20),
                            label: const Text('Add Batch', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4F46E5),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

              // Master Table
              const Text('MASTER TABLE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Color(0xFF64748B))),
              const SizedBox(height: 16),
              
              if (batches.isEmpty)
                Container(
                  padding: const EdgeInsets.all(48),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.folder_open_rounded, size: 48, color: Color(0xFFCBD5E1)),
                      SizedBox(height: 16),
                      Text('No batches created yet.', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 16)),
                    ],
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: batches.length,
                  itemBuilder: (context, index) {
                    final batch = batches[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Batch Header
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            decoration: const BoxDecoration(
                              color: Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.class_rounded, color: Color(0xFF475569), size: 22),
                                    const SizedBox(width: 12),
                                    Text(batch.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                                  ],
                                ),
                                Row(
                                  children: [
                                    InkWell(
                                      onTap: () async {
                                        final sectionController = TextEditingController();
                                        final newSection = await showDialog<String>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                            title: const Text('Add Section'),
                                            content: TextField(
                                              controller: sectionController,
                                              decoration: const InputDecoration(hintText: 'e.g., C'),
                                            ),
                                            actions: [
                                              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                                              TextButton(
                                                onPressed: () => Navigator.pop(context, sectionController.text.trim()), 
                                                child: const Text('Add')
                                              ),
                                            ],
                                          ),
                                        );
                                        if (newSection != null && newSection.isNotEmpty) {
                                          if (batch.sections.contains(newSection)) {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Section already exists')));
                                            }
                                          } else {
                                            final updatedBatch = BatchModel(id: batch.id, name: batch.name, sections: [...batch.sections, newSection]);
                                            await ref.read(batchRepositoryProvider).updateBatch(updatedBatch);
                                            ref.invalidate(batchesStreamProvider);
                                          }
                                        }
                                      },
                                      child: const Icon(Icons.add_circle_outline, color: Color(0xFF10B981), size: 20),
                                    ),
                                    const SizedBox(width: 16),
                                    InkWell(
                                      onTap: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                            title: const Text('Delete Batch?'),
                                            content: const Text('This will remove the batch and its sections. Continue?'),
                                            actions: [
                                              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                                            ],
                                          ),
                                        );
                                        if (confirm == true) {
                                          await ref.read(batchRepositoryProvider).deleteBatch(batch.id);
                                          ref.invalidate(batchesStreamProvider);
                                        }
                                      },
                                      child: const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 20),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Table Header
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9)))),
                            child: const Row(
                              children: [
                                SizedBox(width: 40, child: Text('Sec', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B)))),
                                SizedBox(width: 16),
                                Expanded(child: Text('Adviser', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B)))),
                              ],
                            ),
                          ),
                          // Table Rows
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: batch.sections.length,
                            itemBuilder: (context, sIndex) {
                              final section = batch.sections[sIndex];
                              final assignment = assignments.firstWhere(
                                (a) => a.semester == batch.name && a.section == section,
                                orElse: () => AdviserAssignment(semester: batch.name, section: section),
                              );
                              final isAssigned = assignment.adviserId != null;

                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                decoration: BoxDecoration(
                                  color: sIndex.isEven ? Colors.white : const Color(0xFFF8FAFC).withValues(alpha: 0.5),
                                  border: sIndex != batch.sections.length - 1 ? const Border(bottom: BorderSide(color: Color(0xFFF1F5F9))) : null,
                                ),
                                child: Row(
                                  children: [
                                    // Section
                                    SizedBox(
                                      width: 40,
                                      child: Text(section, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                                    ),
                                    const SizedBox(width: 16),
                                    // Adviser
                                    Expanded(
                                      child: isAssigned
                                          ? Text(assignment.adviserName ?? '', style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)
                                          : const Text('Not Assigned', style: TextStyle(color: Color(0xFFEF4444), fontSize: 13, fontStyle: FontStyle.italic)),
                                    ),
                                    InkWell(
                                      onTap: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                            title: const Text('Delete Section?'),
                                            content: Text('Remove section $section from batch ${batch.name}?'),
                                            actions: [
                                              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                                            ],
                                          ),
                                        );
                                        if (confirm == true) {
                                          final newSections = batch.sections.where((s) => s != section).toList();
                                          final updatedBatch = BatchModel(id: batch.id, name: batch.name, sections: newSections);
                                          await ref.read(batchRepositoryProvider).updateBatch(updatedBatch);
                                        }
                                      },
                                      child: const Icon(Icons.remove_circle_outline, color: Color(0xFFEF4444), size: 18),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white54, size: 14),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label, 
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5, color: Colors.white54),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white, height: 1.0)),
          ),
        ],
      ),
    );
  }
}
