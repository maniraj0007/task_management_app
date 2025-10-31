import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/admin_service.dart';

/// Admin Controller
/// Manages admin-related state and operations using GetX
class AdminController extends GetxController {
  final AdminService _adminService = AdminService();

  // Reactive variables
  final RxBool isLoading = false.obs;
  final RxBool isAdmin = false.obs;
  final RxBool isSuperAdmin = false.obs;
  final RxString error = ''.obs;

  // System overview data
  final RxMap<String, dynamic> systemOverview = <String, dynamic>{}.obs;
  final RxBool isLoadingOverview = false.obs;

  // Recent activity
  final RxList<Map<String, dynamic>> recentActivity = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _checkAdminStatus();
    _loadSystemOverview();
  }

  /// Check if current user has admin privileges
  Future<void> _checkAdminStatus() async {
    try {
      isLoading.value = true;
      error.value = '';

      final adminStatus = await _adminService.isCurrentUserAdmin();
      final superAdminStatus = await _adminService.isCurrentUserSuperAdmin();

      isAdmin.value = adminStatus;
      isSuperAdmin.value = superAdminStatus;
    } catch (e) {
      error.value = 'Failed to check admin status: $e';
      print('Error checking admin status: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Load system overview data
  Future<void> loadSystemOverview() async {
    await _loadSystemOverview();
  }

  Future<void> _loadSystemOverview() async {
    try {
      isLoadingOverview.value = true;
      error.value = '';

      final overview = await _adminService.getSystemOverview();
      systemOverview.value = overview;
      
      // Extract recent activity
      if (overview['recentActivity'] != null) {
        recentActivity.value = List<Map<String, dynamic>>.from(overview['recentActivity']);
      }
    } catch (e) {
      error.value = 'Failed to load system overview: $e';
      print('Error loading system overview: $e');
    } finally {
      isLoadingOverview.value = false;
    }
  }

  /// Refresh all admin data
  Future<void> refreshAdminData() async {
    await Future.wait([
      _checkAdminStatus(),
      _loadSystemOverview(),
    ]);
  }

  /// Get system statistics
  Map<String, dynamic> get systemStats {
    return systemOverview['overview'] ?? {};
  }

  /// Get role distribution data
  Map<String, int> get roleDistribution {
    final distribution = systemOverview['roleDistribution'] as Map<String, dynamic>?;
    if (distribution == null) return {};
    
    return distribution.map((key, value) => MapEntry(key, value as int));
  }

  /// Get task status distribution data
  Map<String, int> get taskStatusDistribution {
    final distribution = systemOverview['taskStatusDistribution'] as Map<String, dynamic>?;
    if (distribution == null) return {};
    
    return distribution.map((key, value) => MapEntry(key, value as int));
  }

  /// Get formatted system stats for display
  List<Map<String, dynamic>> get formattedSystemStats {
    final stats = systemStats;
    if (stats.isEmpty) return [];

    return [
      {
        'title': 'Total Users',
        'value': stats['totalUsers'] ?? 0,
        'subtitle': '${stats['activeUsers'] ?? 0} active',
        'icon': 'people',
        'color': 'primary',
      },
      {
        'title': 'Total Teams',
        'value': stats['totalTeams'] ?? 0,
        'subtitle': '${stats['activeTeams'] ?? 0} active',
        'icon': 'groups',
        'color': 'success',
      },
      {
        'title': 'Total Tasks',
        'value': stats['totalTasks'] ?? 0,
        'subtitle': '${stats['completedTasks'] ?? 0} completed',
        'icon': 'task',
        'color': 'info',
      },
      {
        'title': 'Total Projects',
        'value': stats['totalProjects'] ?? 0,
        'subtitle': '${stats['activeProjects'] ?? 0} active',
        'icon': 'folder',
        'color': 'warning',
      },
    ];
  }

  /// Get formatted role distribution for charts
  List<Map<String, dynamic>> get formattedRoleDistribution {
    final distribution = roleDistribution;
    if (distribution.isEmpty) return [];

    return distribution.entries.map((entry) {
      return {
        'label': _formatRoleName(entry.key),
        'value': entry.value.toDouble(),
        'color': _getRoleColor(entry.key),
      };
    }).toList();
  }

  /// Get formatted task status distribution for charts
  List<Map<String, dynamic>> get formattedTaskStatusDistribution {
    final distribution = taskStatusDistribution;
    if (distribution.isEmpty) return [];

    return distribution.entries.map((entry) {
      return {
        'label': _formatStatusName(entry.key),
        'value': entry.value.toDouble(),
        'color': _getStatusColor(entry.key),
      };
    }).toList();
  }

  /// Format role name for display
  String _formatRoleName(String role) {
    switch (role) {
      case 'super_admin':
        return 'Super Admin';
      case 'admin':
        return 'Admin';
      case 'team_member':
        return 'Team Member';
      case 'viewer':
        return 'Viewer';
      default:
        return role.replaceAll('_', ' ').toUpperCase();
    }
  }

  /// Format status name for display
  String _formatStatusName(String status) {
    switch (status) {
      case 'todo':
        return 'To Do';
      case 'in_progress':
        return 'In Progress';
      case 'review':
        return 'Review';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status.replaceAll('_', ' ').toUpperCase();
    }
  }

  /// Get role color
  String _getRoleColor(String role) {
    switch (role) {
      case 'super_admin':
        return '#9C27B0'; // Purple
      case 'admin':
        return '#3F51B5'; // Indigo
      case 'team_member':
        return '#2196F3'; // Blue
      case 'viewer':
        return '#607D8B'; // Blue Grey
      default:
        return '#9E9E9E'; // Grey
    }
  }

  /// Get status color
  String _getStatusColor(String status) {
    switch (status) {
      case 'todo':
        return '#9E9E9E'; // Grey
      case 'in_progress':
        return '#2196F3'; // Blue
      case 'review':
        return '#FF9800'; // Orange
      case 'completed':
        return '#4CAF50'; // Green
      case 'cancelled':
        return '#F44336'; // Red
      default:
        return '#9E9E9E'; // Grey
    }
  }

  /// Get recent activity with formatted data
  List<Map<String, dynamic>> get formattedRecentActivity {
    return recentActivity.map((activity) {
      return {
        ...activity,
        'formattedAction': _formatActionName(activity['action'] ?? ''),
        'formattedTime': _formatTimestamp(activity['timestamp']),
        'actionIcon': _getActionIcon(activity['action'] ?? ''),
        'actionColor': _getActionColor(activity['action'] ?? ''),
      };
    }).toList();
  }

  /// Format action name for display
  String _formatActionName(String action) {
    switch (action) {
      case 'update_user_role':
        return 'Updated user role';
      case 'activate_user':
        return 'Activated user';
      case 'deactivate_user':
        return 'Deactivated user';
      case 'delete_user':
        return 'Deleted user';
      case 'update_system_settings':
        return 'Updated system settings';
      case 'bulk_update_user_roles':
        return 'Bulk updated user roles';
      case 'bulk_activate_users':
        return 'Bulk activated users';
      case 'bulk_deactivate_users':
        return 'Bulk deactivated users';
      default:
        return action.replaceAll('_', ' ').toUpperCase();
    }
  }

  /// Format timestamp for display
  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'Unknown';
    
    try {
      DateTime dateTime;
      if (timestamp is Timestamp) {
        dateTime = timestamp.toDate();
      } else if (timestamp is String) {
        dateTime = DateTime.parse(timestamp);
      } else {
        return 'Unknown';
      }

      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      }
    } catch (e) {
      return 'Unknown';
    }
  }

  /// Get action icon
  String _getActionIcon(String action) {
    switch (action) {
      case 'update_user_role':
        return 'admin_panel_settings';
      case 'activate_user':
        return 'person_add';
      case 'deactivate_user':
        return 'person_remove';
      case 'delete_user':
        return 'delete';
      case 'update_system_settings':
        return 'settings';
      case 'bulk_update_user_roles':
        return 'group';
      case 'bulk_activate_users':
        return 'group_add';
      case 'bulk_deactivate_users':
        return 'group_remove';
      default:
        return 'info';
    }
  }

  /// Get action color
  String _getActionColor(String action) {
    switch (action) {
      case 'update_user_role':
        return '#2196F3'; // Blue
      case 'activate_user':
        return '#4CAF50'; // Green
      case 'deactivate_user':
        return '#FF9800'; // Orange
      case 'delete_user':
        return '#F44336'; // Red
      case 'update_system_settings':
        return '#9C27B0'; // Purple
      case 'bulk_update_user_roles':
        return '#3F51B5'; // Indigo
      case 'bulk_activate_users':
        return '#4CAF50'; // Green
      case 'bulk_deactivate_users':
        return '#FF9800'; // Orange
      default:
        return '#9E9E9E'; // Grey
    }
  }

  /// Clear error message
  void clearError() {
    error.value = '';
  }

  /// Check if user has admin access
  bool get hasAdminAccess => isAdmin.value;

  /// Check if user has super admin access
  bool get hasSuperAdminAccess => isSuperAdmin.value;

  /// Get system health score based on various metrics
  double get systemHealthScore {
    final stats = systemStats;
    if (stats.isEmpty) return 0.0;

    double score = 0.0;
    int factors = 0;

    // Factor 1: User activity (active users / total users)
    final totalUsers = stats['totalUsers'] as int? ?? 0;
    final activeUsers = stats['activeUsers'] as int? ?? 0;
    if (totalUsers > 0) {
      score += (activeUsers / totalUsers) * 25; // 25% weight
      factors++;
    }

    // Factor 2: Team activity (active teams / total teams)
    final totalTeams = stats['totalTeams'] as int? ?? 0;
    final activeTeams = stats['activeTeams'] as int? ?? 0;
    if (totalTeams > 0) {
      score += (activeTeams / totalTeams) * 25; // 25% weight
      factors++;
    }

    // Factor 3: Task completion rate (completed tasks / total tasks)
    final totalTasks = stats['totalTasks'] as int? ?? 0;
    final completedTasks = stats['completedTasks'] as int? ?? 0;
    if (totalTasks > 0) {
      score += (completedTasks / totalTasks) * 25; // 25% weight
      factors++;
    }

    // Factor 4: Project activity (active projects / total projects)
    final totalProjects = stats['totalProjects'] as int? ?? 0;
    final activeProjects = stats['activeProjects'] as int? ?? 0;
    if (totalProjects > 0) {
      score += (activeProjects / totalProjects) * 25; // 25% weight
      factors++;
    }

    return factors > 0 ? score / factors * 4 : 0.0; // Normalize to 0-100
  }

  /// Get system health status
  String get systemHealthStatus {
    final score = systemHealthScore;
    if (score >= 80) return 'Excellent';
    if (score >= 60) return 'Good';
    if (score >= 40) return 'Fair';
    if (score >= 20) return 'Poor';
    return 'Critical';
  }

  /// Get system health color
  String get systemHealthColor {
    final score = systemHealthScore;
    if (score >= 80) return '#4CAF50'; // Green
    if (score >= 60) return '#8BC34A'; // Light Green
    if (score >= 40) return '#FF9800'; // Orange
    if (score >= 20) return '#FF5722'; // Deep Orange
    return '#F44336'; // Red
  }
}
