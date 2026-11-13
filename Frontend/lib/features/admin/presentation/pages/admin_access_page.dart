import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/staff_accounts_provider.dart';
import '../widgets/create_staff_bottom_sheet.dart';
import '../widgets/tabs/accounts_overview_tab.dart';
import '../widgets/tabs/manage_accounts_tab.dart';

// Re-export for backward compatibility
export '../providers/staff_accounts_provider.dart';

class AdminAccessPage extends ConsumerStatefulWidget {
  const AdminAccessPage({super.key});

  @override
  ConsumerState<AdminAccessPage> createState() => _AdminAccessPageState();
}

class _AdminAccessPageState extends ConsumerState<AdminAccessPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final staffAccountsAsync = ref.watch(staffAccountsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Access Control'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.people_alt_outlined),
              text: 'All Accounts',
            ),
            Tab(
              icon: Icon(Icons.manage_accounts_outlined),
              text: 'Manage',
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reload Accounts',
            onPressed: () => ref.invalidate(staffAccountsProvider),
          ),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton.extended(
              onPressed: () => showCreateStaffBottomSheet(context),
              icon: const Icon(Icons.add),
              label: const Text('Create Staff'),
            )
          : null,
      body: staffAccountsAsync.when(
        data: (accounts) {
          return TabBarView(
            controller: _tabController,
            children: [
              AccountsOverviewTab(
                allAccounts: accounts,
              ),
              ManageAccountsTab(
                allAccounts: accounts,
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Error loading accounts: $err',
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => ref.invalidate(staffAccountsProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
