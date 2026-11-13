import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/staff_accounts_provider.dart';
import '../staff_overview_card.dart';

class AccountsOverviewTab extends ConsumerWidget {
  final List<Map<String, dynamic>> allAccounts;

  const AccountsOverviewTab({
    super.key,
    required this.allAccounts,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                        Icon(Icons.people_outline, size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          'No staff accounts provisioned yet.',
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
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 80),
              itemCount: allAccounts.length,
              itemBuilder: (context, index) {
                return StaffOverviewCard(account: allAccounts[index]);
              },
            ),
    );
  }
}
