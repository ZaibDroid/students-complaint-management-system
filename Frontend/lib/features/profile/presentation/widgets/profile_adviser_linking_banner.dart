import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../admin/presentation/providers/adviser_assignment_provider.dart';

class ProfileAdviserLinkingBanner extends ConsumerStatefulWidget {
  final User user;

  const ProfileAdviserLinkingBanner({super.key, required this.user});

  @override
  ConsumerState<ProfileAdviserLinkingBanner> createState() => _ProfileAdviserLinkingBannerState();
}

class _ProfileAdviserLinkingBannerState extends ConsumerState<ProfileAdviserLinkingBanner> {
  String? _selectedAdviser;
  bool _isSubmitting = false;

  Future<void> _sendAdviserRequest(String uid, [String? adviserName]) async {
    final target = adviserName ?? _selectedAdviser;
    if (target == null) return;
    setState(() => _isSubmitting = true);
    try {
      await ref.read(apiAuthRepositoryProvider).updateUserAdviser(uid, target);
      await ref.read(authStateProvider.notifier).refreshUser();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request sent successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final bool isStudent = user.role == 'Student';
    final bool isRejected = isStudent && (user.status == 'rejected' || user.status == 'cancelled');
    final bool isUnlinked = isStudent && (user.status == 'unlinked' || isRejected);
    final bool isPending = isStudent && user.status == 'pending';

    if (!isUnlinked && !isPending) {
      return const SizedBox.shrink();
    }

    final advisersAsyncValue = ref.watch(batchAdvisersStreamProvider);
    final allAdvisers = advisersAsyncValue.value ?? [];
    final matchingAdvisers = allAdvisers.where((a) => doesAdviserMatchStudent(a, user)).toList();
    final List<String> advisers = matchingAdvisers.map((u) => u.name).toSet().toList();
    final String? activeSelectedAdviser = advisers.contains(_selectedAdviser)
        ? _selectedAdviser
        : (advisers.isNotEmpty ? advisers.first : null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isUnlinked) ...[
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isRejected ? Colors.red.shade50 : Colors.amber.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isRejected ? Colors.red.shade200 : Colors.amber.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isRejected ? Icons.cancel_outlined : Icons.warning_amber_rounded,
                      color: isRejected ? Colors.red.shade700 : Colors.amber,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isRejected ? 'Action Required: Previous Request Rejected' : 'Action Required: Link Batch Adviser',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isRejected ? Colors.red.shade900 : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (isRejected)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      'Your previous adviser-linking request was rejected. You can update your profile details if needed and send a new request below.',
                      style: TextStyle(fontSize: 14, color: Colors.red.shade800, height: 1.4),
                    ),
                  ),
                if (advisers.isEmpty) ...[
                  Text(
                    'No Batch Adviser has been assigned to ${user.batch ?? "your batch"}${user.section != null && user.section!.isNotEmpty ? " (Section ${user.section})" : ""} yet. Please contact your Department Coordinator to assign your adviser.',
                    style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () => ref.invalidate(batchAdvisersStreamProvider),
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Check Again'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.amber.shade900,
                      side: BorderSide(color: Colors.amber.shade400),
                    ),
                  ),
                ] else ...[
                  const Text(
                    'You must link your account to a Batch Adviser to submit complaints. Please select your adviser below.',
                  ),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DropdownButtonFormField<String>(
                        key: ValueKey(activeSelectedAdviser),
                        isExpanded: true,
                        initialValue: activeSelectedAdviser,
                        decoration: const InputDecoration(
                          labelText: 'Select Batch Adviser',
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: matchingAdvisers.map((a) {
                          String detail = '';
                          if (a.assignedSections != null && a.assignedSections!.isNotEmpty) {
                            final secList = a.assignedSections!
                                .map((s) => '${s['batch'] ?? ''} ${s['section'] ?? ''}'.trim())
                                .where((s) => s.isNotEmpty)
                                .join(', ');
                            if (secList.isNotEmpty) detail = ' ($secList)';
                          }
                          final display = '${a.name}$detail';
                          return DropdownMenuItem(value: a.name, child: Text(display, overflow: TextOverflow.ellipsis));
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedAdviser = val),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _isSubmitting || activeSelectedAdviser == null
                            ? null
                            : () => _sendAdviserRequest(user.id, activeSelectedAdviser),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text('Send Request'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
        if (isPending) ...[
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.hourglass_empty_rounded, color: Colors.blue, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Request Pending',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Your request is awaiting approval from ${user.adviser}. You will be notified once approved.',
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ],
    );
  }
}

