import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_constants.dart';
import '../../auth/models/user_model.dart';
import '../../teams/models/team_model.dart';
import '../../tasks/models/task_model.dart';

/// Admin Service
/// Handles all administrative operations including user management,
/// system analytics, and administrative controls
class AdminService {
  static final AdminService _instance = AdminService._internal();
  factory AdminService() => _instance;
  AdminService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collections
  CollectionReference get _usersCollection => _firestore.collection(AppConstants.usersCollection);
  CollectionReference get _teamsCollection => _firestore.collection(AppConstants.teamsCollection);
  CollectionReference get _tasksCollection => _firestore.collection(AppConstants.tasksCollection);
  CollectionReference get _projectsCollection => _firestore.collection(AppConstants.projectsCollection);
  CollectionReference get _auditLogsCollection => _firestore.collection(AppConstants.auditLogsCollection);

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Check if current user is admin
  Future<bool> isCurrentUserAdmin() async {
    if (currentUser == null) return false;
    
    try {
      final userDoc = await _usersCollection.doc(currentUser!.uid).get();
      if (!userDoc.exists) return false;
      
      final userData = userDoc.data() as Map<String, dynamic>;
      final role = userData['role'] as String?;
      
      return role == AppConstants.superAdminRole || role == AppConstants.adminRole;
    } catch (e) {
      print('Error checking admin status: $e');
      return false;
    }
  }

  /// Check if current user is super admin
  Future<bool> isCurrentUserSuperAdmin() async {
    if (currentUser == null) return false;
    
    try {
      final userDoc = await _usersCollection.doc(currentUser!.uid).get();
      if (!userDoc.exists) return false;
      
      final userData = userDoc.data() as Map<String, dynamic>;
      final role = userData['role'] as String?;
      
      return role == AppConstants.superAdminRole;
    } catch (e) {
      print('Error checking super admin status: $e');
      return false;
    }
  }

  // ==================== USER MANAGEMENT ====================

  /// Get all users with pagination
  Future<Map<String, dynamic>> getAllUsers({
    int limit = 20,
    DocumentSnapshot? startAfter,
    String? searchQuery,
    String? roleFilter,
    bool? isActiveFilter,
  }) async {
    try {
      Query query = _usersCollection.orderBy('createdAt', descending: true);

      // Apply filters
      if (roleFilter != null && roleFilter.isNotEmpty) {
        query = query.where('role', isEqualTo: roleFilter);
      }

      if (isActiveFilter != null) {
        query = query.where('isActive', isEqualTo: isActiveFilter);
      }

      // Apply pagination
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      query = query.limit(limit);

      final querySnapshot = await query.get();
      final users = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return UserModel.fromMap(data, doc.id);
      }).toList();

      // Apply search filter (client-side for now)
      List<UserModel> filteredUsers = users;
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final searchLower = searchQuery.toLowerCase();
        filteredUsers = users.where((user) {
          return user.firstName.toLowerCase().contains(searchLower) ||
                 user.lastName.toLowerCase().contains(searchLower) ||
                 user.email.toLowerCase().contains(searchLower);
        }).toList();
      }

      return {
        'users': filteredUsers,
        'lastDocument': querySnapshot.docs.isNotEmpty ? querySnapshot.docs.last : null,
        'hasMore': querySnapshot.docs.length == limit,
      };
    } catch (e) {
      print('Error getting users: $e');
      throw Exception('Failed to get users: $e');
    }
  }

  /// Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();
      if (!doc.exists) return null;
      
      final data = doc.data() as Map<String, dynamic>;
      return UserModel.fromMap(data, doc.id);
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  /// Update user role
  Future<void> updateUserRole(String userId, String newRole) async {
    try {
      // Check if current user has permission
      final isSuperAdmin = await isCurrentUserSuperAdmin();
      if (!isSuperAdmin) {
        throw Exception('Only super admins can change user roles');
      }

      await _usersCollection.doc(userId).update({
        'role': newRole,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Log the action
      await _logAdminAction(
        action: 'update_user_role',
        targetUserId: userId,
        details: {'newRole': newRole},
      );
    } catch (e) {
      print('Error updating user role: $e');
      throw Exception('Failed to update user role: $e');
    }
  }

  /// Activate/Deactivate user
  Future<void> updateUserStatus(String userId, bool isActive) async {
    try {
      // Check if current user has permission
      final isAdmin = await isCurrentUserAdmin();
      if (!isAdmin) {
        throw Exception('Admin privileges required');
      }

      await _usersCollection.doc(userId).update({
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Log the action
      await _logAdminAction(
        action: isActive ? 'activate_user' : 'deactivate_user',
        targetUserId: userId,
        details: {'isActive': isActive},
      );
    } catch (e) {
      print('Error updating user status: $e');
      throw Exception('Failed to update user status: $e');
    }
  }

  /// Delete user (soft delete)
  Future<void> deleteUser(String userId) async {
    try {
      // Check if current user has permission
      final isSuperAdmin = await isCurrentUserSuperAdmin();
      if (!isSuperAdmin) {
        throw Exception('Only super admins can delete users');
      }

      // Soft delete - mark as deleted instead of actually deleting
      await _usersCollection.doc(userId).update({
        'isDeleted': true,
        'deletedAt': FieldValue.serverTimestamp(),
        'deletedBy': currentUser!.uid,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Log the action
      await _logAdminAction(
        action: 'delete_user',
        targetUserId: userId,
        details: {'softDelete': true},
      );
    } catch (e) {
      print('Error deleting user: $e');
      throw Exception('Failed to delete user: $e');
    }
  }

  // ==================== SYSTEM ANALYTICS ====================

  /// Get system overview statistics
  Future<Map<String, dynamic>> getSystemOverview() async {
    try {
      final batch = _firestore.batch();
      
      // Get counts
      final usersCount = await _getUsersCount();
      final teamsCount = await _getTeamsCount();
      final tasksCount = await _getTasksCount();
      final projectsCount = await _getProjectsCount();
      
      // Get recent activity
      final recentActivity = await _getRecentActivity();
      
      // Get user role distribution
      final roleDistribution = await _getUserRoleDistribution();
      
      // Get task status distribution
      final taskStatusDistribution = await _getTaskStatusDistribution();

      return {
        'overview': {
          'totalUsers': usersCount['total'],
          'activeUsers': usersCount['active'],
          'totalTeams': teamsCount['total'],
          'activeTeams': teamsCount['active'],
          'totalTasks': tasksCount['total'],
          'completedTasks': tasksCount['completed'],
          'totalProjects': projectsCount['total'],
          'activeProjects': projectsCount['active'],
        },
        'recentActivity': recentActivity,
        'roleDistribution': roleDistribution,
        'taskStatusDistribution': taskStatusDistribution,
        'generatedAt': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('Error getting system overview: $e');
      throw Exception('Failed to get system overview: $e');
    }
  }

  /// Get users count statistics
  Future<Map<String, int>> _getUsersCount() async {
    try {
      final totalQuery = await _usersCollection
          .where('isDeleted', isEqualTo: false)
          .get();
      
      final activeQuery = await _usersCollection
          .where('isDeleted', isEqualTo: false)
          .where('isActive', isEqualTo: true)
          .get();

      return {
        'total': totalQuery.docs.length,
        'active': activeQuery.docs.length,
      };
    } catch (e) {
      print('Error getting users count: $e');
      return {'total': 0, 'active': 0};
    }
  }

  /// Get teams count statistics
  Future<Map<String, int>> _getTeamsCount() async {
    try {
      final totalQuery = await _teamsCollection
          .where('isDeleted', isEqualTo: false)
          .get();
      
      final activeQuery = await _teamsCollection
          .where('isDeleted', isEqualTo: false)
          .where('isActive', isEqualTo: true)
          .get();

      return {
        'total': totalQuery.docs.length,
        'active': activeQuery.docs.length,
      };
    } catch (e) {
      print('Error getting teams count: $e');
      return {'total': 0, 'active': 0};
    }
  }

  /// Get tasks count statistics
  Future<Map<String, int>> _getTasksCount() async {
    try {
      final totalQuery = await _tasksCollection
          .where('isDeleted', isEqualTo: false)
          .get();
      
      final completedQuery = await _tasksCollection
          .where('isDeleted', isEqualTo: false)
          .where('status', isEqualTo: AppConstants.completedStatus)
          .get();

      return {
        'total': totalQuery.docs.length,
        'completed': completedQuery.docs.length,
      };
    } catch (e) {
      print('Error getting tasks count: $e');
      return {'total': 0, 'completed': 0};
    }
  }

  /// Get projects count statistics
  Future<Map<String, int>> _getProjectsCount() async {
    try {
      final totalQuery = await _projectsCollection
          .where('isDeleted', isEqualTo: false)
          .get();
      
      final activeQuery = await _projectsCollection
          .where('isDeleted', isEqualTo: false)
          .where('status', isEqualTo: 'active')
          .get();

      return {
        'total': totalQuery.docs.length,
        'active': activeQuery.docs.length,
      };
    } catch (e) {
      print('Error getting projects count: $e');
      return {'total': 0, 'active': 0};
    }
  }

  /// Get recent activity from audit logs
  Future<List<Map<String, dynamic>>> _getRecentActivity({int limit = 10}) async {
    try {
      final query = await _auditLogsCollection
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return query.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      print('Error getting recent activity: $e');
      return [];
    }
  }

  /// Get user role distribution
  Future<Map<String, int>> _getUserRoleDistribution() async {
    try {
      final query = await _usersCollection
          .where('isDeleted', isEqualTo: false)
          .get();

      final distribution = <String, int>{};
      
      for (final doc in query.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final role = data['role'] as String? ?? 'unknown';
        distribution[role] = (distribution[role] ?? 0) + 1;
      }

      return distribution;
    } catch (e) {
      print('Error getting role distribution: $e');
      return {};
    }
  }

  /// Get task status distribution
  Future<Map<String, int>> _getTaskStatusDistribution() async {
    try {
      final query = await _tasksCollection
          .where('isDeleted', isEqualTo: false)
          .get();

      final distribution = <String, int>{};
      
      for (final doc in query.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final status = data['status'] as String? ?? 'unknown';
        distribution[status] = (distribution[status] ?? 0) + 1;
      }

      return distribution;
    } catch (e) {
      print('Error getting task status distribution: $e');
      return {};
    }
  }

  // ==================== AUDIT LOGGING ====================

  /// Log admin action for audit trail
  Future<void> _logAdminAction({
    required String action,
    String? targetUserId,
    Map<String, dynamic>? details,
  }) async {
    try {
      await _auditLogsCollection.add({
        'action': action,
        'adminUserId': currentUser!.uid,
        'targetUserId': targetUserId,
        'details': details ?? {},
        'timestamp': FieldValue.serverTimestamp(),
        'ipAddress': null, // Could be implemented with additional setup
        'userAgent': null, // Could be implemented with additional setup
      });
    } catch (e) {
      print('Error logging admin action: $e');
      // Don't throw here as this is logging - shouldn't break main functionality
    }
  }

  /// Get audit logs with pagination
  Future<Map<String, dynamic>> getAuditLogs({
    int limit = 20,
    DocumentSnapshot? startAfter,
    String? actionFilter,
    String? adminUserIdFilter,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _auditLogsCollection.orderBy('timestamp', descending: true);

      // Apply filters
      if (actionFilter != null && actionFilter.isNotEmpty) {
        query = query.where('action', isEqualTo: actionFilter);
      }

      if (adminUserIdFilter != null && adminUserIdFilter.isNotEmpty) {
        query = query.where('adminUserId', isEqualTo: adminUserIdFilter);
      }

      if (startDate != null) {
        query = query.where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      // Apply pagination
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      query = query.limit(limit);

      final querySnapshot = await query.get();
      final logs = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();

      return {
        'logs': logs,
        'lastDocument': querySnapshot.docs.isNotEmpty ? querySnapshot.docs.last : null,
        'hasMore': querySnapshot.docs.length == limit,
      };
    } catch (e) {
      print('Error getting audit logs: $e');
      throw Exception('Failed to get audit logs: $e');
    }
  }

  // ==================== SYSTEM SETTINGS ====================

  /// Get system settings
  Future<Map<String, dynamic>> getSystemSettings() async {
    try {
      final doc = await _firestore.collection('system_settings').doc('global').get();
      
      if (!doc.exists) {
        // Return default settings
        return {
          'appName': AppConstants.appName,
          'maxFileSize': AppConstants.maxFileSize,
          'tasksPerPage': AppConstants.tasksPerPage,
          'allowedImageTypes': AppConstants.allowedImageTypes,
          'allowedDocumentTypes': AppConstants.allowedDocumentTypes,
          'maintenanceMode': false,
          'registrationEnabled': true,
          'emailVerificationRequired': true,
        };
      }

      return doc.data() as Map<String, dynamic>;
    } catch (e) {
      print('Error getting system settings: $e');
      throw Exception('Failed to get system settings: $e');
    }
  }

  /// Update system settings
  Future<void> updateSystemSettings(Map<String, dynamic> settings) async {
    try {
      // Check if current user has permission
      final isSuperAdmin = await isCurrentUserSuperAdmin();
      if (!isSuperAdmin) {
        throw Exception('Only super admins can update system settings');
      }

      await _firestore.collection('system_settings').doc('global').set({
        ...settings,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': currentUser!.uid,
      }, SetOptions(merge: true));

      // Log the action
      await _logAdminAction(
        action: 'update_system_settings',
        details: {'settings': settings},
      );
    } catch (e) {
      print('Error updating system settings: $e');
      throw Exception('Failed to update system settings: $e');
    }
  }

  // ==================== BULK OPERATIONS ====================

  /// Bulk update user roles
  Future<void> bulkUpdateUserRoles(List<String> userIds, String newRole) async {
    try {
      // Check if current user has permission
      final isSuperAdmin = await isCurrentUserSuperAdmin();
      if (!isSuperAdmin) {
        throw Exception('Only super admins can bulk update user roles');
      }

      final batch = _firestore.batch();
      
      for (final userId in userIds) {
        final userRef = _usersCollection.doc(userId);
        batch.update(userRef, {
          'role': newRole,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();

      // Log the action
      await _logAdminAction(
        action: 'bulk_update_user_roles',
        details: {
          'userIds': userIds,
          'newRole': newRole,
          'count': userIds.length,
        },
      );
    } catch (e) {
      print('Error bulk updating user roles: $e');
      throw Exception('Failed to bulk update user roles: $e');
    }
  }

  /// Bulk activate/deactivate users
  Future<void> bulkUpdateUserStatus(List<String> userIds, bool isActive) async {
    try {
      // Check if current user has permission
      final isAdmin = await isCurrentUserAdmin();
      if (!isAdmin) {
        throw Exception('Admin privileges required');
      }

      final batch = _firestore.batch();
      
      for (final userId in userIds) {
        final userRef = _usersCollection.doc(userId);
        batch.update(userRef, {
          'isActive': isActive,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();

      // Log the action
      await _logAdminAction(
        action: isActive ? 'bulk_activate_users' : 'bulk_deactivate_users',
        details: {
          'userIds': userIds,
          'isActive': isActive,
          'count': userIds.length,
        },
      );
    } catch (e) {
      print('Error bulk updating user status: $e');
      throw Exception('Failed to bulk update user status: $e');
    }
  }
}
