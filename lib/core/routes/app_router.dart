import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/admin/presentation/pages/admin_panel_page.dart';
import '../../features/admin/presentation/pages/archives_page.dart';
import '../../features/auth/presentation/pages/complete_profile_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/verify_email_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/batch/presentation/pages/adviser_request_page.dart';
import '../../features/batch/presentation/pages/batch_management_page.dart';
import '../../features/complaints/presentation/pages/complaint_detail_page.dart';
import '../../features/complaints/presentation/pages/complaint_tracking_page.dart';
import '../../features/complaints/presentation/pages/complaints_list_page.dart';
import '../../features/complaints/presentation/pages/submit_complaint_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/notice_board/presentation/pages/create_notice_page.dart';
import '../../features/notice_board/presentation/pages/notice_board_page.dart';
import '../../features/notice_board/presentation/pages/notice_detail_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/profile/presentation/pages/change_password_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/users/presentation/pages/users_list_page.dart';
import 'route_names.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: authState.isAuthenticated ? RouteNames.dashboard : RouteNames.login,
    routes: [
      // Auth Routes
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: RouteNames.register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: RouteNames.verifyEmail,
        builder: (context, state) => const VerifyEmailPage(),
      ),
      GoRoute(
        path: RouteNames.completeProfile,
        builder: (context, state) => const CompleteProfilePage(),
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),

      // Dashboard
      GoRoute(
        path: RouteNames.dashboard,
        builder: (context, state) => const DashboardPage(),
      ),

      // Complaints
      GoRoute(
        path: RouteNames.complaintsList,
        builder: (context, state) => const ComplaintsListPage(),
      ),
      GoRoute(
        path: RouteNames.submitComplaint,
        builder: (context, state) => const SubmitComplaintPage(),
      ),
      GoRoute(
        path: '/complaints/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return ComplaintDetailPage(complaintId: id);
        },
      ),
      GoRoute(
        path: '/complaints/:id/tracking',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return ComplaintTrackingPage(complaintId: id);
        },
      ),

      // Notice Board
      GoRoute(
        path: RouteNames.noticeBoard,
        builder: (context, state) => const NoticeBoardPage(),
      ),
      GoRoute(
        path: RouteNames.createNotice,
        builder: (context, state) => const CreateNoticePage(),
      ),
      GoRoute(
        path: '/notices/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return NoticeDetailPage(noticeId: id);
        },
      ),

      // Notifications
      GoRoute(
        path: RouteNames.notifications,
        builder: (context, state) => const NotificationsPage(),
      ),

      // Batch & Advisers
      GoRoute(
        path: RouteNames.batchManagement,
        builder: (context, state) => const BatchManagementPage(),
      ),
      GoRoute(
        path: RouteNames.adviserRequest,
        builder: (context, state) => const AdviserRequestPage(),
      ),

      // Users
      GoRoute(
        path: RouteNames.usersList,
        builder: (context, state) => const UsersListPage(),
      ),

      // Admin & Archives
      GoRoute(
        path: RouteNames.adminPanel,
        builder: (context, state) => const AdminPanelPage(),
      ),
      GoRoute(
        path: RouteNames.archives,
        builder: (context, state) => const ArchivesPage(),
      ),

      // Profile
      GoRoute(
        path: RouteNames.profile,
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: RouteNames.editProfile,
        builder: (context, state) => const EditProfilePage(),
      ),
      GoRoute(
        path: RouteNames.changePassword,
        builder: (context, state) => const ChangePasswordPage(),
      ),
    ],
  );
});
