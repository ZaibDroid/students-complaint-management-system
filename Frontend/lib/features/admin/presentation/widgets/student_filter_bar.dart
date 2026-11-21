import 'package:flutter/material.dart';
import '../../../../core/constants/departments.dart';

/// Reusable filter and search bar for student accounts management.
class StudentFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final String? selectedDepartmentId;
  final ValueChanged<String?> onDepartmentChanged;
  final VoidCallback onSearch;
  final VoidCallback onClearSearch;
  final int totalStudents;
  final int currentPage;
  final int totalPages;

  const StudentFilterBar({
    super.key,
    required this.searchController,
    required this.selectedDepartmentId,
    required this.onDepartmentChanged,
    required this.onSearch,
    required this.onClearSearch,
    required this.totalStudents,
    required this.currentPage,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          color: Colors.white,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Search by name, email, or reg no...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: onClearSearch,
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onSubmitted: (_) => onSearch(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: onSearch,
                    child: const Text('Search'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String?>(
                      isExpanded: true,
                      initialValue: selectedDepartmentId,
                      decoration: InputDecoration(
                        labelText: 'Department',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('All Departments', overflow: TextOverflow.ellipsis),
                        ),
                        ...kOfficialDepartments.map((dept) => DropdownMenuItem<String?>(
                          value: dept.id,
                          child: Text(dept.name, overflow: TextOverflow.ellipsis),
                        )),
                      ],
                      onChanged: onDepartmentChanged,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Found $totalStudents students',
                style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade700, fontSize: 13),
              ),
              if (totalPages > 1)
                Text(
                  'Page $currentPage of $totalPages',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

