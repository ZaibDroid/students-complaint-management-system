import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/dashboard/presentation/widgets/dashboard_app_bar.dart';
import '../../../../features/dashboard/presentation/widgets/staff_complaint_card.dart';
import '../../../../features/complaints/presentation/providers/complaint_provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../features/notice_board/presentation/pages/staff_notice_board_page.dart';
import '../../../../features/profile/presentation/pages/user_profile_page.dart';

class OfficeDashboardPage extends ConsumerStatefulWidget {
  const OfficeDashboardPage({super.key});

  @override
  ConsumerState<OfficeDashboardPage> createState() => _OfficeDashboardPageState();
}

class _OfficeDashboardPageState extends ConsumerState<OfficeDashboardPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _bottomNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final asyncComplaints = ref.watch(departmentComplaintsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8FC),
      appBar: const DashboardAppBar(),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            color: Colors.white,
            width: double.infinity,
            child: const Text(
              'Office Staff Dashboard',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF172548)),
            ),
          ),
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: theme.primaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: theme.primaryColor,
              tabs: const [
                Tab(text: 'Tasks / Cases'),
                Tab(text: 'Completed'),
              ],
            ),
          ),
          _bottomNavIndex == 0 ? Expanded(
            child: asyncComplaints.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error: $e')),
              data: (complaints) {
                final user = ref.read(authStateProvider).value;
                final userName = user?.name ?? '';
                final newComplaints = complaints.where((c) => (c.assignedTo == userName || c.assignedTo?.toLowerCase() == 'office') && c.status != 'resolved' && c.status != 'rejected').toList();
                final processedComplaints = complaints.where((c) => (c.status == 'resolved' || c.status == 'rejected') && (c.assignedTo == userName || c.assignedTo?.toLowerCase() == 'office' || c.assignedToId == user?.id.toString())).toList();

                return TabBarView(
                  controller: _tabController,
                  children: [
                    ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: newComplaints.length,
                      itemBuilder: (context, index) {
                        final c = newComplaints[index];
                        return StaffComplaintCard(
                          studentName: c.studentName,
                          batch: c.studentBatch ?? 'N/A',
                          title: c.title,
                status: c.status,
                assignedTo: c.assignedTo,
                          date: 'Just now',
                          onForward: () {
                             context.push('/select_recipient', extra: c);
                          },
                          onResolve: () {
                            ref.read(submitComplaintProvider.notifier).updateStatus(c.id, 'resolved', 'Task Completed by Office');
                          },
                          onReject: () {
                            ref.read(submitComplaintProvider.notifier).updateStatus(c.id, 'rejected', 'Invalid');
                          },
                        );
                      },
                    ),
                    ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: processedComplaints.length,
                      itemBuilder: (context, index) {
                        final c = processedComplaints[index];
                        return StaffComplaintCard(
                          studentName: c.studentName,
                          batch: c.studentBatch ?? 'N/A',
                          title: c.title,
                status: c.status,
                assignedTo: c.assignedTo,
                          date: 'Processed',
                          onForward: () {},
                          onResolve: () {},
                          onReject: () {},
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ) : Expanded(
            child: _bottomNavIndex == 1
                ? const StaffNoticeBoardPage()
                : const UserProfilePage(isSubPage: false),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomNavIndex,
        onTap: (index) {
          setState(() {
            _bottomNavIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: theme.primaryColor,
        unselectedItemColor: Colors.grey.shade400,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.campaign), label: 'Notices'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
