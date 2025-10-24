import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'app_routes.dart';

// Import bindings
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/onboarding/bindings/onboarding_binding.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/navigation/bindings/navigation_binding.dart';
import '../modules/tasks/bindings/task_binding.dart';
import '../modules/tasks/bindings/create_task_binding.dart';
import '../modules/tasks/bindings/task_detail_binding.dart';

// Import views
import '../modules/splash/views/splash_screen.dart';
import '../modules/onboarding/views/screens/onboarding_screen.dart';
import '../modules/navigation/views/screens/main_navigation_screen.dart';

// Import actual screen implementations
import '../modules/auth/views/screens/login_screen.dart';
import '../modules/auth/views/screens/register_screen.dart';
import '../modules/auth/views/screens/forgot_password_screen.dart';
import '../modules/auth/controllers/auth_controller.dart';
import '../modules/dashboard/views/screens/dashboard_screen.dart';
import '../modules/dashboard/controllers/dashboard_controller.dart';
import '../modules/tasks/views/screens/task_list_screen.dart';
import '../modules/tasks/controllers/task_list_controller.dart';
import '../modules/tasks/views/screens/create_task_screen.dart';
import '../modules/tasks/controllers/create_task_controller.dart';
import '../modules/tasks/views/screens/task_detail_screen.dart';
import '../modules/tasks/controllers/task_detail_controller.dart';

/// GetX page configuration and routing setup
/// Defines all application pages and their bindings
class AppPages {
  // Private constructor to prevent instantiation
  AppPages._();
  
  /// Initial route
  static const String initial = AppRoutes.initial;
  
  /// All application pages with their routes and bindings
  static final List<GetPage> pages = [
    // ==================== AUTHENTICATION PAGES ====================
    
    GetPage(
      name: AppRoutes.initial,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
      transition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterScreen(),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordScreen(),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    
    GetPage(
      name: AppRoutes.emailVerification,
      page: () => const EmailVerificationView(),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    
    // ==================== MAIN APP PAGES ====================
    
    GetPage(
      name: AppRoutes.mainNavigation,
      page: () => const MainNavigationScreen(),
      binding: NavigationBinding(),
      transition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware()],
    ),
    
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardScreen(),
      binding: DashboardBinding(),
      transition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware()],
    ),
    
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware()],
    ),
    
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware()],
    ),
    
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationsView(),
      binding: NotificationsBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware()],
    ),
    
    // ==================== TASK MANAGEMENT PAGES ====================
    
    GetPage(
      name: AppRoutes.tasks,
      page: () => const TaskListScreen(),
      binding: TaskBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware()],
    ),
    
    GetPage(
      name: AppRoutes.createTask,
      page: () => const CreateTaskScreen(),
      binding: CreateTaskBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware()],
    ),
    
    GetPage(
      name: '${AppRoutes.editTask}/:taskId',
      page: () => const CreateTaskScreen(),
      binding: CreateTaskBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware()],
    ),
    
    GetPage(
      name: '${AppRoutes.taskDetails}/:taskId',
      page: () => const TaskDetailScreen(),
      binding: TaskDetailBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware()],
    ),
    
    GetPage(
      name: AppRoutes.personalTasks,
      page: () => const TaskListScreen(),
      binding: TaskBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware()],
    ),
    
    GetPage(
      name: AppRoutes.teamTasks,
      page: () => const TaskListScreen(),
      binding: TaskBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware()],
    ),
    
    GetPage(
      name: AppRoutes.projectTasks,
      page: () => const TaskListScreen(),
      binding: TaskBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware()],
    ),
    
    // ==================== TEAM MANAGEMENT PAGES ====================
    
    GetPage(
      name: AppRoutes.teams,
      page: () => const TeamsView(),
      binding: TeamsBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware()],
    ),
    
    GetPage(
      name: AppRoutes.createTeam,
      page: () => const CreateTeamView(),
      binding: TeamsBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware()],
    ),
    
    GetPage(
      name: '${AppRoutes.editTeam}/:teamId',
      page: () => const EditTeamView(),
      binding: TeamsBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware()],
    ),
    
    GetPage(
      name: '${AppRoutes.teamDetails}/:teamId',
      page: () => const TeamDetailsView(),
      binding: TeamsBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware()],
    ),
    
    GetPage(
      name: '${AppRoutes.teamMembers}/:teamId',
      page: () => const TeamMembersView(),
      binding: TeamsBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware()],
    ),
    
    GetPage(
      name: AppRoutes.joinTeam,
      page: () => const JoinTeamView(),
      binding: TeamsBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware()],
    ),
    
    // ==================== PROJECT MANAGEMENT PAGES ====================
    
    GetPage(
      name: AppRoutes.projects,
      page: () => const ProjectsView(),
      binding: ProjectsBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware()],
    ),
    
    GetPage(
      name: AppRoutes.createProject,
      page: () => const CreateProjectView(),
      binding: ProjectsBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware()],
    ),
    
    GetPage(
      name: '${AppRoutes.editProject}/:projectId',
      page: () => const EditProjectView(),
      binding: ProjectsBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware()],
    ),
    
    GetPage(
      name: '${AppRoutes.projectDetails}/:projectId',
      page: () => const ProjectDetailsView(),
      binding: ProjectsBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware()],
    ),
    
    GetPage(
      name: '${AppRoutes.projectTimeline}/:projectId',
      page: () => const ProjectTimelineView(),
      binding: ProjectsBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware()],
    ),
    
    GetPage(
      name: '${AppRoutes.projectMilestones}/:projectId',
      page: () => const ProjectMilestonesView(),
      binding: ProjectsBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware()],
    ),
    
    // ==================== ADMIN PAGES ====================
    
    GetPage(
      name: AppRoutes.adminDashboard,
      page: () => const AdminDashboardView(),
      binding: AdminBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware(), AdminMiddleware()],
    ),
    
    GetPage(
      name: AppRoutes.userManagement,
      page: () => const UserManagementView(),
      binding: AdminBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware(), SuperAdminMiddleware()],
    ),
    
    GetPage(
      name: AppRoutes.roleManagement,
      page: () => const RoleManagementView(),
      binding: AdminBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware(), SuperAdminMiddleware()],
    ),
    
    GetPage(
      name: AppRoutes.systemSettings,
      page: () => const SystemSettingsView(),
      binding: AdminBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware(), SuperAdminMiddleware()],
    ),
    
    GetPage(
      name: AppRoutes.analytics,
      page: () => const AnalyticsView(),
      binding: AdminBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware(), AdminMiddleware()],
    ),
    
    GetPage(
      name: AppRoutes.auditLogs,
      page: () => const AuditLogsView(),
      binding: AdminBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware(), SuperAdminMiddleware()],
    ),
    
    GetPage(
      name: AppRoutes.reports,
      page: () => const ReportsView(),
      binding: AdminBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware(), AdminMiddleware()],
    ),
    
    // ==================== SETTINGS PAGES ====================
    
    GetPage(
      name: AppRoutes.accountSettings,
      page: () => const AccountSettingsView(),
      binding: SettingsBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware()],
    ),
    
    GetPage(
      name: AppRoutes.privacySettings,
      page: () => const PrivacySettingsView(),
      binding: SettingsBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware()],
    ),
    
    GetPage(
      name: AppRoutes.notificationSettings,
      page: () => const NotificationSettingsView(),
      binding: SettingsBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware()],
    ),
    
    GetPage(
      name: AppRoutes.themeSettings,
      page: () => const ThemeSettingsView(),
      binding: SettingsBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware()],
    ),
    
    GetPage(
      name: AppRoutes.languageSettings,
      page: () => const LanguageSettingsView(),
      binding: SettingsBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware()],
    ),
    
    GetPage(
      name: AppRoutes.securitySettings,
      page: () => const SecuritySettingsView(),
      binding: SettingsBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware()],
    ),
    
    GetPage(
      name: AppRoutes.changePassword,
      page: () => const ChangePasswordView(),
      binding: SettingsBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware()],
    ),
    
    // ==================== UTILITY PAGES ====================
    
    GetPage(
      name: AppRoutes.search,
      page: () => const SearchView(),
      binding: SearchBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware()],
    ),
    
    GetPage(
      name: AppRoutes.help,
      page: () => const HelpView(),
      binding: HelpBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    
    GetPage(
      name: AppRoutes.about,
      page: () => const AboutView(),
      binding: AboutBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    
    GetPage(
      name: AppRoutes.termsOfService,
      page: () => const TermsOfServiceView(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    
    GetPage(
      name: AppRoutes.privacyPolicy,
      page: () => const PrivacyPolicyView(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    
    // ==================== ERROR PAGES ====================
    
    GetPage(
      name: AppRoutes.notFound,
      page: () => const NotFoundView(),
      transition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    
    GetPage(
      name: AppRoutes.unauthorized,
      page: () => const UnauthorizedView(),
      transition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    
    GetPage(
      name: AppRoutes.noInternet,
      page: () => const NoInternetView(),
      transition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 300),
    ),
  ];
}

// ==================== PLACEHOLDER VIEWS ====================
// These will be replaced with actual implementations in future phases

class SplashView extends StatelessWidget {
  const SplashView({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Splash View')));
}

class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Onboarding View')));
}

// Placeholder views for screens not yet implemented
class ForgotPasswordView extends StatelessWidget {
  const ForgotPasswordView({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Forgot Password View')));
}

class EmailVerificationView extends StatelessWidget {
  const EmailVerificationView({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Email Verification View')));
}

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Profile View')));
}

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Settings View')));
}

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Notifications View')));
}

class TeamsView extends StatelessWidget {
  const TeamsView({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Teams View')));
}

class ProjectsView extends StatelessWidget {
  const ProjectsView({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Projects View')));
}

// Settings sub-views
class SystemSettingsView extends StatelessWidget {
  const SystemSettingsView({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('System Settings View')));
}

class AccountSettingsView extends StatelessWidget {
  const AccountSettingsView({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Account Settings View')));
}

class PrivacySettingsView extends StatelessWidget {
  const PrivacySettingsView({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Privacy Settings View')));
}

class NotificationSettingsView extends StatelessWidget {
  const NotificationSettingsView({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Notification Settings View')));
}

class ThemeSettingsView extends StatelessWidget {
  const ThemeSettingsView({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Theme Settings View')));
}

class LanguageSettingsView extends StatelessWidget {
  const LanguageSettingsView({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Language Settings View')));
}

class SecuritySettingsView extends StatelessWidget {
  const SecuritySettingsView({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Security Settings View')));
}

// ==================== PLACEHOLDER BINDINGS ====================
// These will be replaced with actual implementations in future phases

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    // Get.lazyPut(() => SplashController());
  }
}

class OnboardingBinding extends Bindings {
  @override
  void dependencies() {
    // Get.lazyPut(() => OnboardingController());
  }
}

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AuthController());
  }
}

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DashboardController());
  }
}



// Placeholder bindings for modules not yet fully implemented
class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    // TODO: Implement ProfileController
    // Get.lazyPut(() => ProfileController());
  }
}

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    // TODO: Implement SettingsController
    // Get.lazyPut(() => SettingsController());
  }
}

class NotificationsBinding extends Bindings {
  @override
  void dependencies() {
    // TODO: Implement NotificationsController
    // Get.lazyPut(() => NotificationsController());
  }
}

class TeamsBinding extends Bindings {
  @override
  void dependencies() {
    // TODO: Implement TeamsController
    // Get.lazyPut(() => TeamsController());
  }
}

class ProjectsBinding extends Bindings {
  @override
  void dependencies() {
    // TODO: Implement ProjectsController
    // Get.lazyPut(() => ProjectsController());
  }
}

// ==================== PLACEHOLDER MIDDLEWARES ====================
// These will be replaced with actual implementations in future phases

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    // TODO: Implement authentication check
    return null;
  }
}

class AdminMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    // TODO: Implement admin role check
    return null;
  }
}

class SuperAdminMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    // TODO: Implement super admin role check
    return null;
  }
}
