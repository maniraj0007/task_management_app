import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../../core/services/error_handler_service.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/enums/user_roles.dart';
import '../models/user_model.dart';

/// User Service for Firestore operations
/// Handles all user-related database operations
class UserService extends GetxService {
  static UserService get instance => Get.find<UserService>();
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final CollectionReference<Map<String, dynamic>> _usersCollection;
  
  @override
  Future<void> onInit() async {
    super.onInit();
    _initializeUserService();
  }
  
  /// Initialize user service
  void _initializeUserService() {
    try {
      _usersCollection = _firestore.collection(AppConstants.usersCollection);
      ErrorHandlerService.instance.logInfo('User service initialized successfully');
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'User Service Initialization',
        severity: ErrorSeverity.critical,
      );
    }
  }
  
  // ==================== USER CRUD OPERATIONS ====================
  
  /// Create a new user in Firestore
  Future<void> createUser(UserModel user) async {
    try {
      await _usersCollection.doc(user.id).set(user.toJson());
      ErrorHandlerService.instance.logInfo('User created successfully: ${user.email}');
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Create User',
        severity: ErrorSeverity.high,
      );
      rethrow;
    }
  }
  
  /// Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();
      
      if (!doc.exists) {
        ErrorHandlerService.instance.logWarning('User not found: $userId');
        return null;
      }
      
      return UserModel.fromJson(doc.data()!);
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Get User By ID',
        severity: ErrorSeverity.medium,
      );
      return null;
    }
  }
  
  /// Get user by email
  Future<UserModel?> getUserByEmail(String email) async {
    try {
      final query = await _usersCollection
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      
      if (query.docs.isEmpty) {
        ErrorHandlerService.instance.logWarning('User not found with email: $email');
        return null;
      }
      
      return UserModel.fromJson(query.docs.first.data());
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Get User By Email',
        severity: ErrorSeverity.medium,
      );
      return null;
    }
  }
  
  /// Update user data
  Future<void> updateUser(String userId, Map<String, dynamic> updates) async {
    try {
      // Add updated timestamp
      updates['updatedAt'] = FieldValue.serverTimestamp();
      
      await _usersCollection.doc(userId).update(updates);
      ErrorHandlerService.instance.logInfo('User updated successfully: $userId');
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Update User',
        severity: ErrorSeverity.medium,
      );
      rethrow;
    }
  }
  
  /// Delete user
  Future<void> deleteUser(String userId) async {
    try {
      await _usersCollection.doc(userId).delete();
      ErrorHandlerService.instance.logInfo('User deleted successfully: $userId');
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Delete User',
        severity: ErrorSeverity.high,
      );
      rethrow;
    }
  }
  
  // ==================== USER QUERIES ====================
  
  /// Get all users with pagination
  Future<List<UserModel>> getAllUsers({
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _usersCollection
          .orderBy('createdAt', descending: true)
          .limit(limit);
      
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }
      
      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => UserModel.fromJson(doc.data()))
          .toList();
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Get All Users',
        severity: ErrorSeverity.medium,
      );
      return [];
    }
  }
  
  /// Get users by role
  Future<List<UserModel>> getUsersByRole(UserRole role) async {
    try {
      final snapshot = await _usersCollection
          .where('role', isEqualTo: role.value)
          .where('isActive', isEqualTo: true)
          .get();
      
      return snapshot.docs
          .map((doc) => UserModel.fromJson(doc.data()))
          .toList();
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Get Users By Role',
        severity: ErrorSeverity.medium,
      );
      return [];
    }
  }
  
  /// Search users by name or email
  Future<List<UserModel>> searchUsers(String searchTerm) async {
    try {
      final searchTermLower = searchTerm.toLowerCase();
      
      // Search by email
      final emailQuery = await _usersCollection
          .where('email', isGreaterThanOrEqualTo: searchTermLower)
          .where('email', isLessThanOrEqualTo: '$searchTermLower\uf8ff')
          .limit(10)
          .get();
      
      // Search by first name
      final firstNameQuery = await _usersCollection
          .where('firstName', isGreaterThanOrEqualTo: searchTermLower)
          .where('firstName', isLessThanOrEqualTo: '$searchTermLower\uf8ff')
          .limit(10)
          .get();
      
      // Search by last name
      final lastNameQuery = await _usersCollection
          .where('lastName', isGreaterThanOrEqualTo: searchTermLower)
          .where('lastName', isLessThanOrEqualTo: '$searchTermLower\uf8ff')
          .limit(10)
          .get();
      
      // Combine results and remove duplicates
      final allDocs = <QueryDocumentSnapshot<Map<String, dynamic>>>[
        ...emailQuery.docs,
        ...firstNameQuery.docs,
        ...lastNameQuery.docs,
      ];
      
      final uniqueUsers = <String, UserModel>{};
      for (final doc in allDocs) {
        final user = UserModel.fromJson(doc.data());
        uniqueUsers[user.id] = user;
      }
      
      return uniqueUsers.values.toList();
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Search Users',
        severity: ErrorSeverity.medium,
      );
      return [];
    }
  }
  
  /// Get users by team ID
  Future<List<UserModel>> getUsersByTeamId(String teamId) async {
    try {
      final snapshot = await _usersCollection
          .where('teamIds', arrayContains: teamId)
          .where('isActive', isEqualTo: true)
          .get();
      
      return snapshot.docs
          .map((doc) => UserModel.fromJson(doc.data()))
          .toList();
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Get Users By Team ID',
        severity: ErrorSeverity.medium,
      );
      return [];
    }
  }
  
  /// Get users by project ID
  Future<List<UserModel>> getUsersByProjectId(String projectId) async {
    try {
      final snapshot = await _usersCollection
          .where('projectIds', arrayContains: projectId)
          .where('isActive', isEqualTo: true)
          .get();
      
      return snapshot.docs
          .map((doc) => UserModel.fromJson(doc.data()))
          .toList();
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Get Users By Project ID',
        severity: ErrorSeverity.medium,
      );
      return [];
    }
  }
  
  // ==================== USER ROLE MANAGEMENT ====================
  
  /// Update user role
  Future<void> updateUserRole(String userId, UserRole newRole) async {
    try {
      await updateUser(userId, {
        'role': newRole.value,
      });
      ErrorHandlerService.instance.logInfo('User role updated: $userId -> ${newRole.displayName}');
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Update User Role',
        severity: ErrorSeverity.medium,
      );
      rethrow;
    }
  }
  
  /// Activate/Deactivate user
  Future<void> setUserActiveStatus(String userId, bool isActive) async {
    try {
      await updateUser(userId, {
        'isActive': isActive,
      });
      ErrorHandlerService.instance.logInfo('User active status updated: $userId -> $isActive');
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Set User Active Status',
        severity: ErrorSeverity.medium,
      );
      rethrow;
    }
  }
  
  // ==================== USER TEAM/PROJECT MANAGEMENT ====================
  
  /// Add user to team
  Future<void> addUserToTeam(String userId, String teamId) async {
    try {
      await updateUser(userId, {
        'teamIds': FieldValue.arrayUnion([teamId]),
      });
      ErrorHandlerService.instance.logInfo('User added to team: $userId -> $teamId');
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Add User To Team',
        severity: ErrorSeverity.medium,
      );
      rethrow;
    }
  }
  
  /// Remove user from team
  Future<void> removeUserFromTeam(String userId, String teamId) async {
    try {
      await updateUser(userId, {
        'teamIds': FieldValue.arrayRemove([teamId]),
      });
      ErrorHandlerService.instance.logInfo('User removed from team: $userId -> $teamId');
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Remove User From Team',
        severity: ErrorSeverity.medium,
      );
      rethrow;
    }
  }
  
  /// Add user to project
  Future<void> addUserToProject(String userId, String projectId) async {
    try {
      await updateUser(userId, {
        'projectIds': FieldValue.arrayUnion([projectId]),
      });
      ErrorHandlerService.instance.logInfo('User added to project: $userId -> $projectId');
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Add User To Project',
        severity: ErrorSeverity.medium,
      );
      rethrow;
    }
  }
  
  /// Remove user from project
  Future<void> removeUserFromProject(String userId, String projectId) async {
    try {
      await updateUser(userId, {
        'projectIds': FieldValue.arrayRemove([projectId]),
      });
      ErrorHandlerService.instance.logInfo('User removed from project: $userId -> $projectId');
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Remove User From Project',
        severity: ErrorSeverity.medium,
      );
      rethrow;
    }
  }
  
  // ==================== USER PREFERENCES ====================
  
  /// Update user preferences
  Future<void> updateUserPreferences(String userId, UserPreferences preferences) async {
    try {
      await updateUser(userId, {
        'preferences': preferences.toJson(),
      });
      ErrorHandlerService.instance.logInfo('User preferences updated: $userId');
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Update User Preferences',
        severity: ErrorSeverity.medium,
      );
      rethrow;
    }
  }
  
  /// Update user statistics
  Future<void> updateUserStats(String userId, UserStats stats) async {
    try {
      await updateUser(userId, {
        'stats': stats.toJson(),
      });
      ErrorHandlerService.instance.logInfo('User stats updated: $userId');
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Update User Stats',
        severity: ErrorSeverity.low,
      );
      rethrow;
    }
  }
  
  // ==================== REAL-TIME LISTENERS ====================
  
  /// Listen to user changes
  Stream<UserModel?> listenToUser(String userId) {
    try {
      return _usersCollection
          .doc(userId)
          .snapshots()
          .map((snapshot) {
        if (!snapshot.exists) return null;
        return UserModel.fromJson(snapshot.data()!);
      });
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Listen To User',
        severity: ErrorSeverity.medium,
      );
      return Stream.value(null);
    }
  }
  
  /// Listen to users by role
  Stream<List<UserModel>> listenToUsersByRole(UserRole role) {
    try {
      return _usersCollection
          .where('role', isEqualTo: role.value)
          .where('isActive', isEqualTo: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => UserModel.fromJson(doc.data()))
              .toList());
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Listen To Users By Role',
        severity: ErrorSeverity.medium,
      );
      return Stream.value([]);
    }
  }
  
  // ==================== UTILITY METHODS ====================
  
  /// Check if user exists
  Future<bool> userExists(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();
      return doc.exists;
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Check User Exists',
        severity: ErrorSeverity.low,
      );
      return false;
    }
  }
  
  /// Check if email is already in use
  Future<bool> emailExists(String email) async {
    try {
      final query = await _usersCollection
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      
      return query.docs.isNotEmpty;
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Check Email Exists',
        severity: ErrorSeverity.low,
      );
      return false;
    }
  }
  
  /// Get user count by role
  Future<int> getUserCountByRole(UserRole role) async {
    try {
      final snapshot = await _usersCollection
          .where('role', isEqualTo: role.value)
          .where('isActive', isEqualTo: true)
          .count()
          .get();
      
      return snapshot.count ?? 0;
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Get User Count By Role',
        severity: ErrorSeverity.low,
      );
      return 0;
    }
  }
  
  /// Get total active users count
  Future<int> getActiveUsersCount() async {
    try {
      final snapshot = await _usersCollection
          .where('isActive', isEqualTo: true)
          .count()
          .get();
      
      return snapshot.count ?? 0;
    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Get Active Users Count',
        severity: ErrorSeverity.low,
      );
      return 0;
    }
  }
}
