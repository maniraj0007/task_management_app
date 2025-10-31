import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/admin_service.dart';
import '../../auth/models/user_model.dart';
import '../../../core/constants/app_constants.dart';

/// User Management Controller
/// Manages user-related admin operations using GetX
class UserManagementController extends GetxController {
  final AdminService _adminService = AdminService();

  // Reactive variables
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxString successMessage = ''.obs;

  // User list management
  final RxList<UserModel> users = <UserModel>[].obs;
  final RxBool isLoadingUsers = false.obs;
  final RxBool hasMoreUsers = true.obs;
  DocumentSnapshot? _lastUserDocument;

  // Search and filters
  final RxString searchQuery = ''.obs;
  final RxString roleFilter = ''.obs;
  final RxnBool isActiveFilter = RxnBool();

  // Selection management
  final RxList<String> selectedUserIds = <String>[].obs;
  final RxBool isSelectionMode = false.obs;

  // User details
  final Rxn<UserModel> selectedUser = Rxn<UserModel>();
  final RxBool isLoadingUserDetails = false.obs;

  // Available roles
  final List<String> availableRoles = [
    AppConstants.superAdminRole,
    AppConstants.adminRole,
    AppConstants.teamMemberRole,
    AppConstants.viewerRole,
  ];

  @override
  void onInit() {
    super.onInit();
    loadUsers();
    
    // Set up search debouncing
    debounce(searchQuery, (_) => _refreshUsers(), time: const Duration(milliseconds: 500));
    debounce(roleFilter, (_) => _refreshUsers(), time: const Duration(milliseconds: 300));
    debounce(isActiveFilter, (_) => _refreshUsers(), time: const Duration(milliseconds: 300));
  }

  /// Load users with current filters
  Future<void> loadUsers({bool refresh = false}) async {
    if (refresh) {
      _lastUserDocument = null;
      users.clear();
      hasMoreUsers.value = true;
    }

    if (!hasMoreUsers.value || isLoadingUsers.value) return;

    try {
      isLoadingUsers.value = true;
      error.value = '';

      final result = await _adminService.getAllUsers(
        limit: 20,
        startAfter: _lastUserDocument,
        searchQuery: searchQuery.value.isEmpty ? null : searchQuery.value,
        roleFilter: roleFilter.value.isEmpty ? null : roleFilter.value,
        isActiveFilter: isActiveFilter.value,
      );

      final newUsers = result['users'] as List<UserModel>;
      _lastUserDocument = result['lastDocument'] as DocumentSnapshot?;
      hasMoreUsers.value = result['hasMore'] as bool;

      if (refresh) {
        users.value = newUsers;
      } else {
        users.addAll(newUsers);
      }
    } catch (e) {
      error.value = 'Failed to load users: $e';
      print('Error loading users: $e');
    } finally {
      isLoadingUsers.value = false;
    }
  }

  /// Refresh users list
  Future<void> refreshUsers() async {
    await loadUsers(refresh: true);
  }

  /// Load more users (pagination)
  Future<void> loadMoreUsers() async {
    await loadUsers();
  }

  /// Refresh users when filters change
  Future<void> _refreshUsers() async {
    await loadUsers(refresh: true);
  }

  /// Get user by ID
  Future<void> getUserById(String userId) async {
    try {
      isLoadingUserDetails.value = true;
      error.value = '';

      final user = await _adminService.getUserById(userId);
      selectedUser.value = user;
    } catch (e) {
      error.value = 'Failed to load user details: $e';
      print('Error loading user details: $e');
    } finally {
      isLoadingUserDetails.value = false;
    }
  }

  /// Update user role
  Future<bool> updateUserRole(String userId, String newRole) async {
    try {
      isLoading.value = true;
      error.value = '';
      successMessage.value = '';

      await _adminService.updateUserRole(userId, newRole);
      
      // Update local user data
      final userIndex = users.indexWhere((user) => user.id == userId);
      if (userIndex != -1) {
        final updatedUser = users[userIndex].copyWith(role: newRole);
        users[userIndex] = updatedUser;
      }

      // Update selected user if it's the same
      if (selectedUser.value?.id == userId) {
        selectedUser.value = selectedUser.value?.copyWith(role: newRole);
      }

      successMessage.value = 'User role updated successfully';
      return true;
    } catch (e) {
      error.value = 'Failed to update user role: $e';
      print('Error updating user role: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Update user status (activate/deactivate)
  Future<bool> updateUserStatus(String userId, bool isActive) async {
    try {
      isLoading.value = true;
      error.value = '';
      successMessage.value = '';

      await _adminService.updateUserStatus(userId, isActive);
      
      // Update local user data
      final userIndex = users.indexWhere((user) => user.id == userId);
      if (userIndex != -1) {
        final updatedUser = users[userIndex].copyWith(isActive: isActive);
        users[userIndex] = updatedUser;
      }

      // Update selected user if it's the same
      if (selectedUser.value?.id == userId) {
        selectedUser.value = selectedUser.value?.copyWith(isActive: isActive);
      }

      successMessage.value = isActive ? 'User activated successfully' : 'User deactivated successfully';
      return true;
    } catch (e) {
      error.value = 'Failed to update user status: $e';
      print('Error updating user status: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Delete user
  Future<bool> deleteUser(String userId) async {
    try {
      isLoading.value = true;
      error.value = '';
      successMessage.value = '';

      await _adminService.deleteUser(userId);
      
      // Remove from local list
      users.removeWhere((user) => user.id == userId);
      
      // Clear selected user if it's the same
      if (selectedUser.value?.id == userId) {
        selectedUser.value = null;
      }

      // Remove from selection if selected
      selectedUserIds.remove(userId);

      successMessage.value = 'User deleted successfully';
      return true;
    } catch (e) {
      error.value = 'Failed to delete user: $e';
      print('Error deleting user: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== SELECTION MANAGEMENT ====================

  /// Toggle selection mode
  void toggleSelectionMode() {
    isSelectionMode.value = !isSelectionMode.value;
    if (!isSelectionMode.value) {
      selectedUserIds.clear();
    }
  }

  /// Select/deselect user
  void toggleUserSelection(String userId) {
    if (selectedUserIds.contains(userId)) {
      selectedUserIds.remove(userId);
    } else {
      selectedUserIds.add(userId);
    }

    // Exit selection mode if no users selected
    if (selectedUserIds.isEmpty) {
      isSelectionMode.value = false;
    }
  }

  /// Select all visible users
  void selectAllUsers() {
    selectedUserIds.clear();
    selectedUserIds.addAll(users.map((user) => user.id));
    isSelectionMode.value = true;
  }

  /// Clear all selections
  void clearSelection() {
    selectedUserIds.clear();
    isSelectionMode.value = false;
  }

  /// Check if user is selected
  bool isUserSelected(String userId) {
    return selectedUserIds.contains(userId);
  }

  // ==================== BULK OPERATIONS ====================

  /// Bulk update user roles
  Future<bool> bulkUpdateUserRoles(String newRole) async {
    if (selectedUserIds.isEmpty) return false;

    try {
      isLoading.value = true;
      error.value = '';
      successMessage.value = '';

      await _adminService.bulkUpdateUserRoles(selectedUserIds.toList(), newRole);
      
      // Update local user data
      for (final userId in selectedUserIds) {
        final userIndex = users.indexWhere((user) => user.id == userId);
        if (userIndex != -1) {
          final updatedUser = users[userIndex].copyWith(role: newRole);
          users[userIndex] = updatedUser;
        }
      }

      successMessage.value = 'Updated ${selectedUserIds.length} user roles successfully';
      clearSelection();
      return true;
    } catch (e) {
      error.value = 'Failed to bulk update user roles: $e';
      print('Error bulk updating user roles: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Bulk update user status
  Future<bool> bulkUpdateUserStatus(bool isActive) async {
    if (selectedUserIds.isEmpty) return false;

    try {
      isLoading.value = true;
      error.value = '';
      successMessage.value = '';

      await _adminService.bulkUpdateUserStatus(selectedUserIds.toList(), isActive);
      
      // Update local user data
      for (final userId in selectedUserIds) {
        final userIndex = users.indexWhere((user) => user.id == userId);
        if (userIndex != -1) {
          final updatedUser = users[userIndex].copyWith(isActive: isActive);
          users[userIndex] = updatedUser;
        }
      }

      final action = isActive ? 'activated' : 'deactivated';
      successMessage.value = 'Successfully $action ${selectedUserIds.length} users';
      clearSelection();
      return true;
    } catch (e) {
      error.value = 'Failed to bulk update user status: $e';
      print('Error bulk updating user status: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== FILTER MANAGEMENT ====================

  /// Set search query
  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  /// Set role filter
  void setRoleFilter(String role) {
    roleFilter.value = role;
  }

  /// Set active status filter
  void setActiveFilter(bool? isActive) {
    isActiveFilter.value = isActive;
  }

  /// Clear all filters
  void clearFilters() {
    searchQuery.value = '';
    roleFilter.value = '';
    isActiveFilter.value = null;
  }

  /// Check if any filters are active
  bool get hasActiveFilters {
    return searchQuery.value.isNotEmpty ||
           roleFilter.value.isNotEmpty ||
           isActiveFilter.value != null;
  }

  // ==================== UTILITY METHODS ====================

  /// Get formatted role name
  String getFormattedRoleName(String role) {
    switch (role) {
      case AppConstants.superAdminRole:
        return 'Super Admin';
      case AppConstants.adminRole:
        return 'Admin';
      case AppConstants.teamMemberRole:
        return 'Team Member';
      case AppConstants.viewerRole:
        return 'Viewer';
      default:
        return role.replaceAll('_', ' ').toUpperCase();
    }
  }

  /// Get role color
  String getRoleColor(String role) {
    switch (role) {
      case AppConstants.superAdminRole:
        return '#9C27B0'; // Purple
      case AppConstants.adminRole:
        return '#3F51B5'; // Indigo
      case AppConstants.teamMemberRole:
        return '#2196F3'; // Blue
      case AppConstants.viewerRole:
        return '#607D8B'; // Blue Grey
      default:
        return '#9E9E9E'; // Grey
    }
  }

  /// Get user status color
  String getUserStatusColor(bool isActive) {
    return isActive ? '#4CAF50' : '#F44336'; // Green : Red
  }

  /// Get user status text
  String getUserStatusText(bool isActive) {
    return isActive ? 'Active' : 'Inactive';
  }

  /// Get filtered users count
  int get filteredUsersCount => users.length;

  /// Get selected users count
  int get selectedUsersCount => selectedUserIds.length;

  /// Clear messages
  void clearMessages() {
    error.value = '';
    successMessage.value = '';
  }

  /// Get users by role
  List<UserModel> getUsersByRole(String role) {
    return users.where((user) => user.role == role).toList();
  }

  /// Get active users count
  int get activeUsersCount {
    return users.where((user) => user.isActive).length;
  }

  /// Get inactive users count
  int get inactiveUsersCount {
    return users.where((user) => !user.isActive).length;
  }

  /// Get role distribution
  Map<String, int> get roleDistribution {
    final distribution = <String, int>{};
    for (final user in users) {
      distribution[user.role] = (distribution[user.role] ?? 0) + 1;
    }
    return distribution;
  }
}
