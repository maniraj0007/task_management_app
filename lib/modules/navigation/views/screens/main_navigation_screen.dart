import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../controllers/navigation_controller.dart';
// Import actual screen implementations
import '../../../dashboard/views/screens/dashboard_screen.dart' as dashboard;
import '../../../tasks/views/screens/task_list_screen.dart' as tasks;
import '../../../teams/views/screens/team_list_screen.dart';
import '../../../projects/views/screens/project_list_screen.dart';
import '../../../search/views/screens/global_search_screen.dart' as search;
import '../../../analytics/views/screens/analytics_dashboard_screen.dart' as analytics;
import '../../../notifications/views/screens/notification_list_screen.dart' as notifications;
import '../../../profile/views/screens/profile_screen.dart' as profile;

/// Main Navigation Screen
/// Provides bottom navigation and manages main app screens
class MainNavigationScreen extends GetView<NavigationController> {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => IndexedStack(
        index: controller.currentIndex,
        children: _getScreens(),
      )),
      bottomNavigationBar: Obx(() => _buildBottomNavigationBar()),
      floatingActionButton: Obx(() => _buildFloatingActionButton()),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  /// Get screens for navigation
  List<Widget> _getScreens() {
    return [
      const dashboard.DashboardScreen(),
      const tasks.TaskListScreen(),
      const TeamListScreen(),
      const ProjectListScreen(),
      const search.GlobalSearchScreen(),
      const analytics.AnalyticsDashboardScreen(),
      const notifications.NotificationListScreen(),
      const profile.ProfileScreen(),
    ];
  }

  /// Build bottom navigation bar
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomAppBar(
        color: AppColors.surface,
        elevation: 0,
        notchMargin: 8,
        shape: const CircularNotchedRectangle(),
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Left side navigation items
              _buildNavItem(0, Icons.dashboard, 'Dashboard'),
              _buildNavItem(1, Icons.task_alt, 'Tasks'),
              _buildNavItem(2, Icons.group, 'Teams'),
              _buildNavItem(3, Icons.folder, 'Projects'),
              
              // Space for FAB
              const SizedBox(width: 40),
              
              // Right side navigation items
              _buildNavItem(4, Icons.search, 'Search'),
              _buildNavItem(5, Icons.analytics, 'Analytics'),
              _buildNavItem(6, Icons.notifications, 'Notifications'),
              _buildNavItem(7, Icons.person, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  /// Build navigation item
  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = controller.currentIndex == index;
    
    return GestureDetector(
      onTap: () => controller.changePage(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build floating action button
  Widget? _buildFloatingActionButton() {
    // Show FAB only on specific screens
    if (controller.currentIndex == 1) { // Tasks screen
      return FloatingActionButton(
        onPressed: controller.createNewTask,
        child: const Icon(Icons.add),
        tooltip: 'Create New Task',
      );
    } else if (controller.currentIndex == 2) { // Teams screen
      return FloatingActionButton(
        onPressed: controller.createNewTeam,
        child: const Icon(Icons.group_add),
        tooltip: 'Create New Team',
      );
    } else if (controller.currentIndex == 3) { // Projects screen
      return FloatingActionButton(
        onPressed: controller.createNewProject,
        child: const Icon(Icons.create_new_folder),
        tooltip: 'Create New Project',
      );
    }
    
    return null;
  }
}


