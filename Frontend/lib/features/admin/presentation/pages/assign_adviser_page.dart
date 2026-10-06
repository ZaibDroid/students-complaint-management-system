import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/adviser_assignment_provider.dart';
import '../widgets/advisers_list.dart';
import '../widgets/add_faculty_dialog.dart';


class AssignAdviserPage extends ConsumerStatefulWidget {
  final bool isEmbedded;
  const AssignAdviserPage({super.key, this.isEmbedded = false});

  @override
  ConsumerState<AssignAdviserPage> createState() => _AssignAdviserPageState();
}

class _AssignAdviserPageState extends ConsumerState<AssignAdviserPage> {

  @override
  Widget build(BuildContext context) {
    final advisersAsync = ref.watch(batchAdvisersStreamProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8FC),
      appBar: widget.isEmbedded
          ? null
          : AppBar(
              title: const Text(
                'Assign Batch Adviser',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
              foregroundColor: const Color(0xFF010F32),
            ),
      body: advisersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text(
            'Error loading faculty: $err',
            style: const TextStyle(color: Colors.red),
          ),
        ),
        data: (advisers) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Faculty Advisers',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF010F32),
                  ),
                ),
                const SizedBox(height: 16),
                AdvisersList(advisers: advisers),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const AddFacultyDialog(),
          );
        },
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text('Add Adviser', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: theme.primaryColor,
      ),
    );
  }

}
