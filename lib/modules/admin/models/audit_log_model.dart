import 'package:cloud_firestore/cloud_firestore.dart';

/// Audit Log Model
/// Represents a system audit log entry for tracking user activities
class AuditLogModel {
  final String id;
  final String userId;
  final String userEmail;
  final String action;
  final String description;
  final String severity; // low, medium, high, critical
  final DateTime timestamp;
  final String? ipAddress;
  final String? userAgent;
  final String? resourceType; // user, task, team, project, etc.
  final String? resourceId;
  final Map<String, dynamic> metadata;

  const AuditLogModel({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.action,
    required this.description,
    required this.severity,
    required this.timestamp,
    this.ipAddress,
    this.userAgent,
    this.resourceType,
    this.resourceId,
    this.metadata = const {},
  });

  /// Create AuditLogModel from Firestore document
  factory AuditLogModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return AuditLogModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      userEmail: data['userEmail'] ?? '',
      action: data['action'] ?? '',
      description: data['description'] ?? '',
      severity: data['severity'] ?? 'low',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      ipAddress: data['ipAddress'],
      userAgent: data['userAgent'],
      resourceType: data['resourceType'],
      resourceId: data['resourceId'],
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
    );
  }

  /// Create AuditLogModel from JSON
  factory AuditLogModel.fromJson(Map<String, dynamic> json) {
    return AuditLogModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      userEmail: json['userEmail'] ?? '',
      action: json['action'] ?? '',
      description: json['description'] ?? '',
      severity: json['severity'] ?? 'low',
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      ipAddress: json['ipAddress'],
      userAgent: json['userAgent'],
      resourceType: json['resourceType'],
      resourceId: json['resourceId'],
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userEmail': userEmail,
      'action': action,
      'description': description,
      'severity': severity,
      'timestamp': timestamp.toIso8601String(),
      'ipAddress': ipAddress,
      'userAgent': userAgent,
      'resourceType': resourceType,
      'resourceId': resourceId,
      'metadata': metadata,
    };
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userEmail': userEmail,
      'action': action,
      'description': description,
      'severity': severity,
      'timestamp': Timestamp.fromDate(timestamp),
      'ipAddress': ipAddress,
      'userAgent': userAgent,
      'resourceType': resourceType,
      'resourceId': resourceId,
      'metadata': metadata,
    };
  }

  /// Create a copy with updated fields
  AuditLogModel copyWith({
    String? id,
    String? userId,
    String? userEmail,
    String? action,
    String? description,
    String? severity,
    DateTime? timestamp,
    String? ipAddress,
    String? userAgent,
    String? resourceType,
    String? resourceId,
    Map<String, dynamic>? metadata,
  }) {
    return AuditLogModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
      action: action ?? this.action,
      description: description ?? this.description,
      severity: severity ?? this.severity,
      timestamp: timestamp ?? this.timestamp,
      ipAddress: ipAddress ?? this.ipAddress,
      userAgent: userAgent ?? this.userAgent,
      resourceType: resourceType ?? this.resourceType,
      resourceId: resourceId ?? this.resourceId,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is AuditLogModel &&
        other.id == id &&
        other.userId == userId &&
        other.userEmail == userEmail &&
        other.action == action &&
        other.description == description &&
        other.severity == severity &&
        other.timestamp == timestamp &&
        other.ipAddress == ipAddress &&
        other.userAgent == userAgent &&
        other.resourceType == resourceType &&
        other.resourceId == resourceId;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      userId,
      userEmail,
      action,
      description,
      severity,
      timestamp,
      ipAddress,
      userAgent,
      resourceType,
      resourceId,
    );
  }

  @override
  String toString() {
    return 'AuditLogModel(id: $id, userId: $userId, userEmail: $userEmail, action: $action, description: $description, severity: $severity, timestamp: $timestamp, ipAddress: $ipAddress, userAgent: $userAgent, resourceType: $resourceType, resourceId: $resourceId, metadata: $metadata)';
  }

  /// Static methods for creating common audit log entries

  /// Create user login audit log
  static AuditLogModel userLogin({
    required String userId,
    required String userEmail,
    String? ipAddress,
    String? userAgent,
  }) {
    return AuditLogModel(
      id: '',
      userId: userId,
      userEmail: userEmail,
      action: 'User Login',
      description: 'User logged into the system',
      severity: 'low',
      timestamp: DateTime.now(),
      ipAddress: ipAddress,
      userAgent: userAgent,
      resourceType: 'user',
      resourceId: userId,
    );
  }

  /// Create user logout audit log
  static AuditLogModel userLogout({
    required String userId,
    required String userEmail,
    String? ipAddress,
    String? userAgent,
  }) {
    return AuditLogModel(
      id: '',
      userId: userId,
      userEmail: userEmail,
      action: 'User Logout',
      description: 'User logged out of the system',
      severity: 'low',
      timestamp: DateTime.now(),
      ipAddress: ipAddress,
      userAgent: userAgent,
      resourceType: 'user',
      resourceId: userId,
    );
  }

  /// Create role change audit log
  static AuditLogModel roleChange({
    required String adminUserId,
    required String adminUserEmail,
    required String targetUserId,
    required String targetUserEmail,
    required String oldRole,
    required String newRole,
    String? ipAddress,
    String? userAgent,
  }) {
    return AuditLogModel(
      id: '',
      userId: adminUserId,
      userEmail: adminUserEmail,
      action: 'Role Change',
      description: 'Changed user role from $oldRole to $newRole for $targetUserEmail',
      severity: 'high',
      timestamp: DateTime.now(),
      ipAddress: ipAddress,
      userAgent: userAgent,
      resourceType: 'user',
      resourceId: targetUserId,
      metadata: {
        'targetUserId': targetUserId,
        'targetUserEmail': targetUserEmail,
        'oldRole': oldRole,
        'newRole': newRole,
      },
    );
  }

  /// Create task creation audit log
  static AuditLogModel taskCreated({
    required String userId,
    required String userEmail,
    required String taskId,
    required String taskTitle,
    String? ipAddress,
    String? userAgent,
  }) {
    return AuditLogModel(
      id: '',
      userId: userId,
      userEmail: userEmail,
      action: 'Task Created',
      description: 'Created new task: $taskTitle',
      severity: 'low',
      timestamp: DateTime.now(),
      ipAddress: ipAddress,
      userAgent: userAgent,
      resourceType: 'task',
      resourceId: taskId,
      metadata: {
        'taskTitle': taskTitle,
      },
    );
  }

  /// Create task deletion audit log
  static AuditLogModel taskDeleted({
    required String userId,
    required String userEmail,
    required String taskId,
    required String taskTitle,
    String? ipAddress,
    String? userAgent,
  }) {
    return AuditLogModel(
      id: '',
      userId: userId,
      userEmail: userEmail,
      action: 'Task Deleted',
      description: 'Deleted task: $taskTitle',
      severity: 'medium',
      timestamp: DateTime.now(),
      ipAddress: ipAddress,
      userAgent: userAgent,
      resourceType: 'task',
      resourceId: taskId,
      metadata: {
        'taskTitle': taskTitle,
      },
    );
  }

  /// Create team creation audit log
  static AuditLogModel teamCreated({
    required String userId,
    required String userEmail,
    required String teamId,
    required String teamName,
    String? ipAddress,
    String? userAgent,
  }) {
    return AuditLogModel(
      id: '',
      userId: userId,
      userEmail: userEmail,
      action: 'Team Created',
      description: 'Created new team: $teamName',
      severity: 'medium',
      timestamp: DateTime.now(),
      ipAddress: ipAddress,
      userAgent: userAgent,
      resourceType: 'team',
      resourceId: teamId,
      metadata: {
        'teamName': teamName,
      },
    );
  }

  /// Create system settings change audit log
  static AuditLogModel systemSettingsChanged({
    required String userId,
    required String userEmail,
    required String settingName,
    required String oldValue,
    required String newValue,
    String? ipAddress,
    String? userAgent,
  }) {
    return AuditLogModel(
      id: '',
      userId: userId,
      userEmail: userEmail,
      action: 'System Settings Changed',
      description: 'Changed $settingName from "$oldValue" to "$newValue"',
      severity: 'high',
      timestamp: DateTime.now(),
      ipAddress: ipAddress,
      userAgent: userAgent,
      resourceType: 'system',
      resourceId: 'settings',
      metadata: {
        'settingName': settingName,
        'oldValue': oldValue,
        'newValue': newValue,
      },
    );
  }

  /// Create security event audit log
  static AuditLogModel securityEvent({
    required String userId,
    required String userEmail,
    required String eventType,
    required String description,
    String? ipAddress,
    String? userAgent,
    Map<String, dynamic>? additionalMetadata,
  }) {
    return AuditLogModel(
      id: '',
      userId: userId,
      userEmail: userEmail,
      action: 'Security Event',
      description: description,
      severity: 'critical',
      timestamp: DateTime.now(),
      ipAddress: ipAddress,
      userAgent: userAgent,
      resourceType: 'security',
      resourceId: eventType,
      metadata: {
        'eventType': eventType,
        ...?additionalMetadata,
      },
    );
  }
}
