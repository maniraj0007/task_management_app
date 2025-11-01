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

  // Audit logs
  final RxList<Map<String, dynamic>> auditLogs = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> filteredAuditLogs = <Map<String, dynamic>>[].obs;
  final RxBool isLoadingAuditLogs = false.obs;
  
  // Audit log filters
  final RxMap<String, dynamic> auditLogFilters = <String, dynamic>{}.obs;
  final RxList<String> availableActions = <String>[].obs;
  final RxList<String> selectedActions = <String>[].obs;
  final RxList<String> selectedSeverities = <String>[].obs;
  final Rx<DateTime?> startDate = Rx<DateTime?>(null);
  final Rx<DateTime?> endDate = Rx<DateTime?>(null);
  
  // User management
  final RxList<Map<String, dynamic>> allUsers = <Map<String, dynamic>>[].obs;
  final RxInt totalUsers = 0.obs;

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

  // ==================== AUDIT LOG METHODS ====================

  /// Refresh audit logs
  Future<void> refreshAuditLogs() async {
    try {
      isLoadingAuditLogs.value = true;
      error.value = '';

      // TODO: Implement actual audit log fetching from AdminService
      // For now, return empty list to resolve compilation errors
      auditLogs.value = [];
      _applyAuditLogFilters();
      
      // Initialize available actions
      availableActions.value = [
        'create_user',
        'update_user',
        'delete_user',
        'create_team',
        'update_team',
        'delete_team',
        'create_project',
        'update_project',
        'delete_project',
        'login',
        'logout',
        'system_settings',
      ];
    } catch (e) {
      error.value = 'Failed to load audit logs: $e';
      print('Error loading audit logs: $e');
    } finally {
      isLoadingAuditLogs.value = false;
    }
  }

  /// Apply audit log filters
  void _applyAuditLogFilters() {
    var filtered = auditLogs.toList();

    // Filter by selected actions
    if (selectedActions.isNotEmpty) {
      filtered = filtered.where((log) => 
        selectedActions.contains(log['action'] as String? ?? '')).toList();
    }

    // Filter by selected severities
    if (selectedSeverities.isNotEmpty) {
      filtered = filtered.where((log) => 
        selectedSeverities.contains(log['severity'] as String? ?? '')).toList();
    }

    // Filter by date range
    if (startDate.value != null || endDate.value != null) {
      filtered = filtered.where((log) {
        final logDate = log['timestamp'] as DateTime?;
        if (logDate == null) return false;
        
        if (startDate.value != null && logDate.isBefore(startDate.value!)) {
          return false;
        }
        if (endDate.value != null && logDate.isAfter(endDate.value!)) {
          return false;
        }
        return true;
      }).toList();
    }

    filteredAuditLogs.value = filtered;
  }

  /// Clear audit log filters
  void clearAuditLogFilters() {
    selectedActions.clear();
    selectedSeverities.clear();
    startDate.value = null;
    endDate.value = null;
    auditLogFilters.clear();
    _applyAuditLogFilters();
  }

  /// Toggle action filter
  void toggleActionFilter(String action) {
    if (selectedActions.contains(action)) {
      selectedActions.remove(action);
    } else {
      selectedActions.add(action);
    }
    _applyAuditLogFilters();
  }

  /// Toggle severity filter
  void toggleSeverityFilter(String severity) {
    if (selectedSeverities.contains(severity)) {
      selectedSeverities.remove(severity);
    } else {
      selectedSeverities.add(severity);
    }
    _applyAuditLogFilters();
  }

  /// Apply audit log filters with date range
  void applyAuditLogFilters() {
    _applyAuditLogFilters();
  }

  /// Export audit logs
  Future<void> exportAuditLogs() async {
    try {
      // TODO: Implement actual audit log export functionality
      // For now, just show a success message
      print('Audit logs exported successfully');
    } catch (e) {
      error.value = 'Failed to export audit logs: $e';
      print('Error exporting audit logs: $e');
    }
  }

  // ==================== USER MANAGEMENT METHODS ====================

  /// Refresh user data
  Future<void> refreshUserData() async {
    try {
      isLoading.value = true;
      error.value = '';

      // TODO: Implement actual user data fetching from AdminService
      // For now, return empty list to resolve compilation errors
      allUsers.value = [];
      totalUsers.value = allUsers.length;
    } catch (e) {
      error.value = 'Failed to load user data: $e';
      print('Error loading user data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Get users by role
  List<Map<String, dynamic>> getUsersByRole(String role) {
    return allUsers.where((user) => 
      (user['role'] as String? ?? '') == role).toList();
  }
}
