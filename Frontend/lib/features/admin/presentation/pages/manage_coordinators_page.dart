import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/auth/domain/entities/user.dart';
import '../widgets/advisers_list.dart';
import '../widgets/add_faculty_dialog.dart';
import '../widgets/chairman_adviser_table.dart';

import '../../../../core/services/api_client.dart';

final coordinatorsStreamProvider = StreamProvider.autoDispose<List<User>>((ref) async* {
  try {
    final apiClient = ApiClient();
    final data = await apiClient.get('/users', queryParams: {'role': 'Coordinator'});
    if (data is List) {
      yield data.map((item) => User.fromJson(item as Map<String, dynamic>)).toList();
    } else {
      yield [];
    }
  } catch (_) {
    yield [];
  }
});

class ManageCoordinatorsPage extends ConsumerWidget {
  const ManageCoordinatorsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coordinatorsAsync = ref.watch(coordinatorsStreamProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8FC),
      appBar: AppBar(
        title: const Text('Manage Coordinators', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF010F32))),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: coordinatorsAsync.when(
        data: (coordinators) {
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.table_chart, size: 22),
                  label: const Text('View Batch Adviser Master Table', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF010F32),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Scaffold(
                          appBar: AppBar(
                            title: const Text('Batch Adviser Master Table'),
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF010F32),
                            elevation: 0,
                          ),
                          backgroundColor: const Color(0xFFFBF8FC),
                          body: const ChairmanAdviserTable(),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Department Coordinators',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF010F32)),
              ),
              const SizedBox(height: 8),
              const Text(
                'Manage the coordinators who oversee batch advisers and handle escalated complaints.',
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 24),
              AdvisersList(advisers: coordinators),
              const SizedBox(height: 80),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const AddFacultyDialog(defaultRole: 'Coordinator'),
          );
        },
        backgroundColor: Theme.of(context).primaryColor,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text('Add Coordinator', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
