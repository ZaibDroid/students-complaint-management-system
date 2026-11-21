import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/student_account_card.dart';
import '../widgets/edit_student_dialog.dart';
import '../widgets/reset_student_password_dialog.dart';
import '../widgets/student_filter_bar.dart';

/// Modular, clean Student Accounts Management page.
class StudentAccountsPage extends ConsumerStatefulWidget {
  const StudentAccountsPage({super.key});

  @override
  ConsumerState<StudentAccountsPage> createState() => _StudentAccountsPageState();
}

class _StudentAccountsPageState extends ConsumerState<StudentAccountsPage> {
  final _searchController = TextEditingController();
  String? _selectedDepartmentId;
  String? _selectedBatchId;
  String? _selectedSectionId;

  bool _isLoading = false;
  String? _errorMessage;
  List<Map<String, dynamic>> _students = [];
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalStudents = 0;

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchStudents({int page = 1}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final res = await ref.read(apiAuthRepositoryProvider).getStudents(
        search: _searchController.text.trim().isNotEmpty ? _searchController.text.trim() : null,
        departmentId: _selectedDepartmentId,
        batchId: _selectedBatchId,
        sectionId: _selectedSectionId,
        page: page,
        perPage: 15,
      );

      final items = res['items'] as List<Map<String, dynamic>>? ?? [];
      final meta = res['meta'] as Map<String, dynamic>?;
      final pagination = meta != null ? meta['pagination'] as Map<String, dynamic>? : null;

      setState(() {
        _students = items;
        _currentPage = pagination?['current_page'] ?? page;
        _totalPages = pagination?['total_pages'] ?? 1;
        _totalStudents = pagination?['total'] ?? items.length;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '').replaceAll('ApiException: ', '');
        _isLoading = false;
      });
    }
  }

  void _showEditStudentDialog(Map<String, dynamic> student) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => EditStudentDialog(
        student: student,
        onSuccess: () => _fetchStudents(page: _currentPage),
      ),
    );
  }

  void _showResetPasswordDialog(Map<String, dynamic> student) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => ResetStudentPasswordDialog(
        student: student,
        onSuccess: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Password for "${student['name']}" reset successfully.')),
          );
        },
      ),
    );
  }

  void _showDeleteStudentDialog(Map<String, dynamic> student) {
    final name = student['name'] ?? 'Student';
    final studentId = student['id']?.toString() ?? '';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Deactivate Student Account'),
        content: Text(
          'Are you sure you want to deactivate "$name"?\n\nExisting complaint history, timeline entries, and remarks submitted by this student will be fully preserved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref.read(apiAuthRepositoryProvider).deleteStudent(studentId);
                _fetchStudents(page: _currentPage);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Student "$name" deactivated successfully.')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString().replaceAll('Exception: ', '').replaceAll('ApiException: ', '')),
                      backgroundColor: Colors.red.shade700,
                    ),
                  );
                }
              }
            },
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Student Accounts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _fetchStudents(page: _currentPage),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          StudentFilterBar(
            searchController: _searchController,
            selectedDepartmentId: _selectedDepartmentId,
            onDepartmentChanged: (val) {
              setState(() {
                _selectedDepartmentId = val;
                _selectedBatchId = null;
                _selectedSectionId = null;
              });
              _fetchStudents(page: 1);
            },
            onSearch: () => _fetchStudents(page: 1),
            onClearSearch: () {
              _searchController.clear();
              _fetchStudents(page: 1);
            },
            totalStudents: _totalStudents,
            currentPage: _currentPage,
            totalPages: _totalPages,
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Error: $_errorMessage', style: const TextStyle(color: Colors.red)),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () => _fetchStudents(page: _currentPage),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _students.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.school_outlined, size: 56, color: Colors.grey.shade400),
                                const SizedBox(height: 12),
                                Text('No student accounts found.', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemCount: _students.length,
                            itemBuilder: (ctx, index) {
                              final student = _students[index];
                              return StudentAccountCard(
                                student: student,
                                onEdit: () => _showEditStudentDialog(student),
                                onResetPassword: () => _showResetPasswordDialog(student),
                                onDelete: () => _showDeleteStudentDialog(student),
                              );
                            },
                          ),
          ),
          if (_totalPages > 1)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _currentPage > 1 ? () => _fetchStudents(page: _currentPage - 1) : null,
                  ),
                  Text('$_currentPage / $_totalPages', style: const TextStyle(fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _currentPage < _totalPages ? () => _fetchStudents(page: _currentPage + 1) : null,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
