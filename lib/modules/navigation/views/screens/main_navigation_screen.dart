import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../controllers/navigation_controller.dart';
import '../../../dashboard/views/screens/dashboard_screen.dart';
import '../../../tasks/views/screens/task_list_screen.dart';
import '../../../teams/views/screens/team_list_screen.dart';
import '../../../projects/views/screens/project_list_screen.dart';
import '../../../search/views/screens/global_search_screen.dart';
import '../../../analytics/views/screens/analytics_dashboard_screen.dart';
import '../../../notifications/views/screens/notification_list_screen.dart';
import '../../../profile/views/screens/profile_screen.dart';

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
      const DashboardScreen(),
      const TaskListScreen(),
      const TeamListScreen(),
      const ProjectListScreen(),
      const GlobalSearchScreen(),
      const AnalyticsDashboardScreen(),
      const NotificationListScreen(),
      const ProfileScreen(),
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

/// Placeholder screens for navigation (will be replaced with actual implementations)
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            onPressed: () => Get.toNamed('/notifications'),
            icon: const Icon(Icons.notifications),
          ),
          IconButton(
            onPressed: () => Get.toNamed('/settings'),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.dashboard, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Dashboard Screen',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Welcome to your task management dashboard',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          IconButton(
            onPressed: () => Get.toNamed('/tasks/filters'),
            icon: const Icon(Icons.filter_list),
          ),
          IconButton(
            onPressed: () => Get.toNamed('/search'),
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.task_alt, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Tasks Screen',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Manage your personal and team tasks',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class TeamListScreen extends StatelessWidget {
  const TeamListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teams'),
        actions: [
          IconButton(
            onPressed: () => Get.toNamed('/teams/invitations'),
            icon: const Icon(Icons.mail),
          ),
          IconButton(
            onPressed: () => Get.toNamed('/search'),
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Teams Screen',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Collaborate with your teams',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class ProjectListScreen extends StatelessWidget {
  const ProjectListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
        actions: [
          IconButton(
            onPressed: () => Get.toNamed('/projects/templates'),
            icon: const Icon(Icons.template_outlined),
          ),
          IconButton(
            onPressed: () => Get.toNamed('/search'),
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Projects Screen',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Manage your projects and milestones',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationListScreen extends StatelessWidget {
  const NotificationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            onPressed: () => Get.toNamed('/notifications/settings'),
            icon: const Icon(Icons.settings),
          ),
          IconButton(
            onPressed: () {}, // Mark all as read
            icon: const Icon(Icons.done_all),
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Notifications Screen',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Stay updated with your notifications',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: () => Get.toNamed('/settings'),
            icon: const Icon(Icons.settings),
          ),
          IconButton(
            onPressed: () => Get.toNamed('/profile/edit'),
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Profile Screen',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Manage your profile and preferences',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
