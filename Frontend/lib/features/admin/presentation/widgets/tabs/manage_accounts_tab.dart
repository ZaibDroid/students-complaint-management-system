import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../auth/presentation/providers/auth_provider.dart';
import '../../providers/staff_accounts_provider.dart';
import '../delete_staff_dialog.dart';
import '../edit_staff_bottom_sheet.dart';
import '../staff_manage_card.dart';

class ManageAccountsTab extends ConsumerWidget {
  final List<Map<String, dynamic>> allAccounts;

  const ManageAccountsTab({
    super.key,
    required this.allAccounts,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authStateProvider).value;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(staffAccountsProvider);
        await ref.read(staffAccountsProvider.future);
      },
      child: allAccounts.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Padding(
                  padding: const EdgeInsets.all(48.0),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.manage_accounts_outlined, size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          'No staff accounts to manage.',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
              itemCount: allAccounts.length,
              itemBuilder: (context, index) {
                final account = allAccounts[index];
                final isSelf = currentUser != null && account['id']?.toString() == currentUser.id.toString();
                return StaffManageCard(
                  account: account,
                  showDelete: !isSelf,
                  onEdit: () => showEditStaffBottomSheet(context, account),
                  onDelete: isSelf ? () {} : () => showDeleteStaffDialog(
                    context: context,
                    ref: ref,
                    account: account,
                  ),
                );
              },
            ),
    );
  }
}

