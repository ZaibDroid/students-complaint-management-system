import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/registration_page.dart';
import '../../features/admin/presentation/pages/admin_dashboard_page.dart';
import '../../features/admin/presentation/pages/admin_access_page.dart';
import '../../features/admin/presentation/pages/chairman_dashboard_page.dart';
import '../../features/admin/presentation/pages/adviser_dashboard_page.dart';
import '../../features/dashboard/presentation/pages/student_dashboard_page.dart';
import '../../features/dashboard/presentation/pages/analytics_dashboard_page.dart';
import '../../features/complaints/presentation/pages/submit_complaint_page.dart';
import '../../features/complaints/presentation/pages/complaint_timeline_page.dart';
import '../../features/complaints/presentation/pages/resolve_complaint_page.dart';
import '../../features/notice_board/presentation/pages/student_notice_board_page.dart';
import '../../features/notice_board/presentation/pages/staff_notice_board_page.dart';
import '../../features/notice_board/presentation/pages/notice_creator_page.dart';
import '../../features/profile/presentation/pages/user_profile_page.dart';
import '../../features/splash/presentation/pages/splash_screen_page.dart';
import '../../features/notifications/presentation/pages/notification_center_page.dart';
import '../../features/notifications/presentation/pages/notification_settings_page.dart';
import '../../features/settings/presentation/pages/system_settings_page.dart';
import '../../features/notice_board/presentation/pages/notice_details_page.dart';
import '../../features/notice_board/data/models/notice_model.dart';
import '../../features/users/presentation/pages/staff_management_portal_page.dart';
import '../../features/batch/presentation/pages/batch_management_portal_page.dart';
import '../../features/admin/presentation/pages/role_permission_editor_page.dart';
import '../../features/admin/presentation/pages/dean_dashboard_page.dart';
import '../../features/admin/presentation/pages/coordinator_dashboard_page.dart';
import '../../features/admin/presentation/pages/assign_adviser_page.dart';
import '../../features/admin/presentation/pages/office_dashboard_page.dart';
import '../../features/complaints/presentation/pages/select_recipient_page.dart';
import '../../features/users/presentation/pages/cr_directory_page.dart';
import '../../features/complaints/presentation/pages/complaint_archive_page.dart';
import '../../features/complaints/data/models/complaint_model.dart';
import '../../features/complaints/presentation/pages/complaint_details_page.dart';
import '../../shared/layouts/main_layout.dart';
import '../../shared/layouts/chairman_layout.dart';
import '../../shared/layouts/admin_layout.dart';
import '../../features/admin/presentation/pages/manage_coordinators_page.dart';
import '../../features/admin/presentation/pages/chairman_announcements_page.dart';
import '../../features/admin/presentation/pages/create_announcement_page.dart';
import '../../features/admin/presentation/pages/vc_dashboard_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final isFirstLaunchProvider = Provider<bool>((ref) => false);

final goRouterProvider = Provider<GoRouter>((ref) {
  final isFirstLaunch = ref.watch(isFirstLaunchProvider);
  return GoRouter(
    initialLocation: isFirstLaunch ? '/onboarding' : '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreenPage(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegistrationPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainLayout(child: child),
        routes: [
          GoRoute(
            path: '/dashboard/student',
            builder: (context, state) => const StudentDashboardPage(),
          ),
          GoRoute(
            path: '/student_notices',
            builder: (context, state) => const StudentNoticeBoardPage(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const UserProfilePage(),
          ),
          GoRoute(
            path: '/complaint_archive',
            builder: (context, state) {
              final filter = state.uri.queryParameters['filter'] ?? 'all';
              return ComplaintArchivePage(initialFilter: filter);
            },
          ),
        ]
      ),
      ShellRoute(
        builder: (context, state, child) => AdminLayout(child: child),
        routes: [
          GoRoute(
            path: '/dashboard/admin',
            builder: (context, state) => const AdminDashboardPage(),
          ),
          GoRoute(
            path: '/dashboard/admin/access',
            builder: (context, state) => const AdminAccessPage(),
          ),
          GoRoute(
            path: '/dashboard/admin/notices',
            builder: (context, state) => const StaffNoticeBoardPage(),
          ),
          GoRoute(
            path: '/dashboard/admin/profile',
            builder: (context, state) => const UserProfilePage(isSubPage: false),
          ),
        ],
      ),
      ShellRoute(
        builder: (context, state, child) => ChairmanLayout(child: child),
        routes: [
          GoRoute(
            path: '/dashboard/chairman',
            builder: (context, state) => const ChairmanDashboardPage(),
          ),
          GoRoute(
            path: '/dashboard/chairman/announcements',
            builder: (context, state) => const ChairmanAnnouncementsPage(),
          ),
          GoRoute(
            path: '/dashboard/chairman/create_announcement',
            builder: (context, state) => const CreateAnnouncementPage(),
          ),
          GoRoute(
            path: '/dashboard/chairman/coordinators',
            builder: (context, state) => const ManageCoordinatorsPage(),
          ),
          GoRoute(
            path: '/dashboard/chairman/profile',
            builder: (context, state) => const UserProfilePage(isSubPage: false),
          ),
        ]
      ),
      GoRoute(
        path: '/dashboard/adviser',
        builder: (context, state) => const AdviserDashboardPage(),
      ),
      GoRoute(
        path: '/submit_complaint',
        builder: (context, state) => const SubmitComplaintPage(),
      ),
      GoRoute(
        path: '/complaint_timeline',
        builder: (context, state) => const ComplaintTimelinePage(),
      ),
      GoRoute(
        path: '/resolve_complaint',
        builder: (context, state) => const ResolveComplaintPage(),
      ),
      GoRoute(
        path: '/create_notice',
        builder: (context, state) => const NoticeCreatorPage(),
      ),
      GoRoute(
        path: '/analytics',
        builder: (context, state) => const AnalyticsDashboardPage(),
      ),
      GoRoute(
        path: '/notification_center',
        builder: (context, state) => const NotificationCenterPage(),
      ),
      GoRoute(
        path: '/notification_settings',
        builder: (context, state) => const NotificationSettingsPage(),
      ),
      GoRoute(
        path: '/system_settings',
        builder: (context, state) => const SystemSettingsPage(),
      ),
      GoRoute(
        path: '/notice_details',
        builder: (context, state) {
          if (state.extra is! NoticeModel) {
            return Scaffold(
              appBar: AppBar(),
              body: const Center(child: Text("Notice details unavailable. Please go back and try again.")),
            );
          }
          final notice = state.extra as NoticeModel;
          return NoticeDetailsPage(notice: notice);
        },
      ),
      GoRoute(
        path: '/staff_management',
        builder: (context, state) => const StaffManagementPortalPage(),
      ),
      GoRoute(
        path: '/batch_management',
        builder: (context, state) => const BatchManagementPortalPage(),
      ),
      GoRoute(
        path: '/role_permission',
        builder: (context, state) => const RolePermissionEditorPage(),
      ),
      GoRoute(
        path: '/dashboard/dean',
        builder: (context, state) => const DeanDashboardPage(),
      ),
      GoRoute(
        path: '/dashboard/vc',
        builder: (context, state) => const VcDashboardPage(),
      ),
      GoRoute(
        path: '/dashboard/coordinator',
        builder: (context, state) => const CoordinatorDashboardPage(),
      ),
      GoRoute(
        path: '/assign_adviser',
        builder: (context, state) => const AssignAdviserPage(),
      ),
      GoRoute(
        path: '/dashboard/office',
        builder: (context, state) => const OfficeDashboardPage(),
      ),
      GoRoute(
        path: '/select_recipient',
        builder: (context, state) {
          final complaint = state.extra as ComplaintModel;
          return SelectRecipientPage(complaint: complaint);
        },
      ),
      GoRoute(
        path: '/complaint_details',
        builder: (context, state) {
          final complaint = state.extra as ComplaintModel;
          return ComplaintDetailsPage(complaint: complaint);
        },
      ),
      GoRoute(
        path: '/cr_directory',
        builder: (context, state) => const CRDirectoryPage(),
      ),
      GoRoute(
        path: '/staff_profile',
        builder: (context, state) => const UserProfilePage(),
      ),
    ],
  );
});

