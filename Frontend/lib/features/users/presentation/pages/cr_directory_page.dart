import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/dashboard/presentation/widgets/dashboard_app_bar.dart';
import '../providers/cr_provider.dart';

class CRDirectoryPage extends ConsumerStatefulWidget {
  const CRDirectoryPage({super.key});

  @override
  ConsumerState<CRDirectoryPage> createState() => _CRDirectoryPageState();
}

class _CRDirectoryPageState extends ConsumerState<CRDirectoryPage> {
  String? _selectedYear;
  String? _selectedBatch;
  String? _selectedSection;

  final List<String> _years = ['1st Year', '2nd Year', '3rd Year', '4th Year'];
  final List<String> _batches = ['Fall 2021', 'Fall 2022', 'Fall 2023', 'Fall 2024'];
  final List<String> _sections = ['A', 'B', 'C'];



  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final crListAsync = ref.watch(crListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8FC),
      appBar: const DashboardAppBar(),
      body: Column(
        children: [
          // Filter Section
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Find Class Representatives',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF010F32),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Year',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        initialValue: _selectedYear,
                        items: _years.map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(),
                        onChanged: (val) => setState(() => _selectedYear = val),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Batch',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        initialValue: _selectedBatch,
                        items: _batches.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                        onChanged: (val) => setState(() => _selectedBatch = val),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Section',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        initialValue: _selectedSection,
                        items: _sections.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (val) => setState(() => _selectedSection = val),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedYear = null;
                        _selectedBatch = null;
                        _selectedSection = null;
                      });
                    },
                    icon: const Icon(Icons.clear_all, size: 18),
                    label: const Text('Clear Filters'),
                  ),
                ),
              ],
            ),
          ),
          
          // Results Section
          Expanded(
            child: crListAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (crList) {
                // Apply filters
                final filteredCRs = crList.where((cr) {
                  if (_selectedYear != null && cr.year != _selectedYear) return false;
                  if (_selectedBatch != null && cr.batch != _selectedBatch) return false;
                  if (_selectedSection != null && cr.section != _selectedSection) return false;
                  return true;
                }).toList();

                if (filteredCRs.isEmpty) {
                  return const Center(
                    child: Text('No CRs found matching the criteria.', style: TextStyle(color: Colors.grey)),
                  );
                }
                
                return ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: filteredCRs.length,
                    itemBuilder: (context, index) {
                      final cr = filteredCRs[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                                child: Text(
                                  cr.name.isNotEmpty ? cr.name[0].toUpperCase() : 'C',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: theme.primaryColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      cr.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF010F32),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: theme.primaryColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '${cr.year ?? 'N/A'} • ${cr.batch ?? 'N/A'} • Sec ${cr.section ?? 'N/A'}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: theme.primaryColor,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.email_outlined, size: 14, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text(cr.email, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.phone_outlined, size: 14, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        const Text('N/A', style: TextStyle(fontSize: 13, color: Colors.grey)), // Phone removed from user entity
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.message, color: Color(0xFF6366F1)),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Opening chat with ${cr.name}')),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
              },
            ),
          ),
        ],
      ),
    );
  }
}
