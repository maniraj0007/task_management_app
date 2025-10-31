import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/enums/team_enums.dart';

/// Team invitation model for the multi-admin task management system
/// Represents an invitation to join a team with status tracking and expiration
class TeamInvitationModel {
  final String id;
  final String teamId;
  final String teamName;
  final String invitedBy;
  final String invitedByName;
  final String? invitedByPhotoUrl;
  final String inviteeEmail;
  final String? inviteeUserId; // Set when user accepts
  final TeamRole proposedRole;
  final InvitationStatus status;
  final DateTime createdAt;
  final DateTime expiresAt;
  final DateTime? respondedAt;
  final DateTime? acceptedAt;
  final DateTime? declinedAt;
  final DateTime? cancelledAt;
  
  // Invitation details
  final String? message;
  final String? welcomeMessage;
  final Map<String, dynamic> metadata;
  final List<String> permissions;
  final Map<String, dynamic> customFields;
  
  // Response tracking
  final String? responseMessage;
  final String? declineReason;
  final String? cancellationReason;
  final int remindersSent;
  final DateTime? lastReminderAt;
  
  // Security and validation
  final String invitationToken;
  final String? verificationCode;
  final bool requiresVerification;
  final Map<String, dynamic> securitySettings;

  const TeamInvitationModel({
    required this.id,
    required this.teamId,
    required this.teamName,
    required this.invitedBy,
    required this.invitedByName,
    this.invitedByPhotoUrl,
    required this.inviteeEmail,
    this.inviteeUserId,
    required this.proposedRole,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
    this.respondedAt,
    this.acceptedAt,
    this.declinedAt,
    this.cancelledAt,
    this.message,
    this.welcomeMessage,
    this.metadata = const {},
    this.permissions = const [],
    this.customFields = const {},
    this.responseMessage,
    this.declineReason,
    this.cancellationReason,
    this.remindersSent = 0,
    this.lastReminderAt,
    required this.invitationToken,
    this.verificationCode,
    this.requiresVerification = false,
    this.securitySettings = const {},
  });

  /// Check if invitation is still pending
  bool get isPending => status.isActive;

  /// Check if invitation was accepted
  bool get isAccepted => status.isAccepted;

  /// Check if invitation was declined
  bool get isDeclined => status.isDeclined;

  /// Check if invitation is expired
  bool get isExpired => 
      status == InvitationStatus.expired || 
      DateTime.now().isAfter(expiresAt);

  /// Check if invitation can be responded to
  bool get canRespond => isPending && !isExpired;

  /// Check if invitation can be cancelled
  bool get canCancel => isPending && !isExpired;

  /// Check if invitation can have reminders sent
  bool get canSendReminder => 
      isPending && 
      !isExpired && 
      remindersSent < 3 && // Max 3 reminders
      (lastReminderAt == null || 
       DateTime.now().difference(lastReminderAt!).inDays >= 3);

  /// Get days until expiration
  int get daysUntilExpiration {
    if (isExpired) return 0;
    return expiresAt.difference(DateTime.now()).inDays;
  }

  /// Get hours until expiration
  int get hoursUntilExpiration {
    if (isExpired) return 0;
    return expiresAt.difference(DateTime.now()).inHours;
  }

  /// Check if invitation expires soon (within 24 hours)
  bool get expiresSoon => 
      !isExpired && hoursUntilExpiration <= 24;

  /// Get invitation age in days
  int get ageInDays {
    return DateTime.now().difference(createdAt).inDays;
  }

  /// Get response time in hours (if responded)
  int? get responseTimeInHours {
    if (respondedAt == null) return null;
    return respondedAt!.difference(createdAt).inHours;
  }

  /// Check if invitation was responded to quickly (within 24 hours)
  bool get wasQuickResponse {
    final responseTime = responseTimeInHours;
    return responseTime != null && responseTime <= 24;
  }

  /// Get invitation status color
  String get statusColor => status.colorHex;

  /// Get invitation status icon
  String get statusIcon => status.iconName;

  /// Get proposed role color
  String get roleColor => proposedRole.colorHex;

  /// Get proposed role icon
  String get roleIcon => proposedRole.iconName;

  /// Get proposed role description
  String get roleDescription => proposedRole.description;

  /// Get invitation urgency level
  String get urgencyLevel {
    if (isExpired) return 'Expired';
    if (expiresSoon) return 'Urgent';
    if (daysUntilExpiration <= 3) return 'High';
    if (daysUntilExpiration <= 7) return 'Medium';
    return 'Low';
  }

  /// Get invitation summary for display
  String get summary {
    return '$invitedByName invited you to join $teamName as ${proposedRole.displayName}';
  }

  /// Get detailed invitation message
  String get detailedMessage {
    final baseMessage = summary;
    if (message != null && message!.isNotEmpty) {
      return '$baseMessage\n\nMessage: $message';
    }
    return baseMessage;
  }

  /// Check if invitation has custom permissions
  bool get hasCustomPermissions => permissions.isNotEmpty;

  /// Check if invitation requires verification
  bool get needsVerification => 
      requiresVerification && verificationCode != null;

  /// Validate invitation token
  bool validateToken(String token) {
    return invitationToken == token;
  }

  /// Validate verification code
  bool validateVerificationCode(String code) {
    if (!requiresVerification) return true;
    return verificationCode == code;
  }

  /// Create a copy with updated fields
  TeamInvitationModel copyWith({
    String? id,
    String? teamId,
    String? teamName,
    String? invitedBy,
    String? invitedByName,
    String? invitedByPhotoUrl,
    String? inviteeEmail,
    String? inviteeUserId,
    TeamRole? proposedRole,
    InvitationStatus? status,
    DateTime? createdAt,
    DateTime? expiresAt,
    DateTime? respondedAt,
    DateTime? acceptedAt,
    DateTime? declinedAt,
    DateTime? cancelledAt,
    String? message,
    String? welcomeMessage,
    Map<String, dynamic>? metadata,
    List<String>? permissions,
    Map<String, dynamic>? customFields,
    String? responseMessage,
    String? declineReason,
    String? cancellationReason,
    int? remindersSent,
    DateTime? lastReminderAt,
    String? invitationToken,
    String? verificationCode,
    bool? requiresVerification,
    Map<String, dynamic>? securitySettings,
  }) {
    return TeamInvitationModel(
      id: id ?? this.id,
      teamId: teamId ?? this.teamId,
      teamName: teamName ?? this.teamName,
      invitedBy: invitedBy ?? this.invitedBy,
      invitedByName: invitedByName ?? this.invitedByName,
      invitedByPhotoUrl: invitedByPhotoUrl ?? this.invitedByPhotoUrl,
      inviteeEmail: inviteeEmail ?? this.inviteeEmail,
      inviteeUserId: inviteeUserId ?? this.inviteeUserId,
      proposedRole: proposedRole ?? this.proposedRole,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      respondedAt: respondedAt ?? this.respondedAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      declinedAt: declinedAt ?? this.declinedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      message: message ?? this.message,
      welcomeMessage: welcomeMessage ?? this.welcomeMessage,
      metadata: metadata ?? this.metadata,
      permissions: permissions ?? this.permissions,
      customFields: customFields ?? this.customFields,
      responseMessage: responseMessage ?? this.responseMessage,
      declineReason: declineReason ?? this.declineReason,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      remindersSent: remindersSent ?? this.remindersSent,
      lastReminderAt: lastReminderAt ?? this.lastReminderAt,
      invitationToken: invitationToken ?? this.invitationToken,
      verificationCode: verificationCode ?? this.verificationCode,
      requiresVerification: requiresVerification ?? this.requiresVerification,
      securitySettings: securitySettings ?? this.securitySettings,
    );
  }

  /// Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'teamId': teamId,
      'teamName': teamName,
      'invitedBy': invitedBy,
      'invitedByName': invitedByName,
      'invitedByPhotoUrl': invitedByPhotoUrl,
      'inviteeEmail': inviteeEmail,
      'inviteeUserId': inviteeUserId,
      'proposedRole': proposedRole.value,
      'status': status.value,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'respondedAt': respondedAt != null ? Timestamp.fromDate(respondedAt!) : null,
      'acceptedAt': acceptedAt != null ? Timestamp.fromDate(acceptedAt!) : null,
      'declinedAt': declinedAt != null ? Timestamp.fromDate(declinedAt!) : null,
      'cancelledAt': cancelledAt != null ? Timestamp.fromDate(cancelledAt!) : null,
      'message': message,
      'welcomeMessage': welcomeMessage,
      'metadata': metadata,
      'permissions': permissions,
      'customFields': customFields,
      'responseMessage': responseMessage,
      'declineReason': declineReason,
      'cancellationReason': cancellationReason,
      'remindersSent': remindersSent,
      'lastReminderAt': lastReminderAt != null ? Timestamp.fromDate(lastReminderAt!) : null,
      'invitationToken': invitationToken,
      'verificationCode': verificationCode,
      'requiresVerification': requiresVerification,
      'securitySettings': securitySettings,
    };
  }

  /// Create from JSON (Firestore document)
  factory TeamInvitationModel.fromJson(Map<String, dynamic> json) {
    return TeamInvitationModel(
      id: json['id'] ?? '',
      teamId: json['teamId'] ?? '',
      teamName: json['teamName'] ?? '',
      invitedBy: json['invitedBy'] ?? '',
      invitedByName: json['invitedByName'] ?? '',
      invitedByPhotoUrl: json['invitedByPhotoUrl'],
      inviteeEmail: json['inviteeEmail'] ?? '',
      inviteeUserId: json['inviteeUserId'],
      proposedRole: TeamRole.fromString(json['proposedRole'] ?? 'member'),
      status: InvitationStatus.fromString(json['status'] ?? 'pending'),
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expiresAt: (json['expiresAt'] as Timestamp?)?.toDate() ?? DateTime.now().add(const Duration(days: 7)),
      respondedAt: (json['respondedAt'] as Timestamp?)?.toDate(),
      acceptedAt: (json['acceptedAt'] as Timestamp?)?.toDate(),
      declinedAt: (json['declinedAt'] as Timestamp?)?.toDate(),
      cancelledAt: (json['cancelledAt'] as Timestamp?)?.toDate(),
      message: json['message'],
      welcomeMessage: json['welcomeMessage'],
      metadata: json['metadata']?.cast<String, dynamic>() ?? {},
      permissions: (json['permissions'] as List<dynamic>?)?.cast<String>() ?? [],
      customFields: json['customFields']?.cast<String, dynamic>() ?? {},
      responseMessage: json['responseMessage'],
      declineReason: json['declineReason'],
      cancellationReason: json['cancellationReason'],
      remindersSent: json['remindersSent'] ?? 0,
      lastReminderAt: (json['lastReminderAt'] as Timestamp?)?.toDate(),
      invitationToken: json['invitationToken'] ?? '',
      verificationCode: json['verificationCode'],
      requiresVerification: json['requiresVerification'] ?? false,
      securitySettings: json['securitySettings']?.cast<String, dynamic>() ?? {},
    );
  }

  /// Create a new team invitation with minimal required fields
  factory TeamInvitationModel.create({
    required String teamId,
    required String teamName,
    required String invitedBy,
    required String invitedByName,
    required String inviteeEmail,
    required TeamRole proposedRole,
    String? invitedByPhotoUrl,
    String? message,
    String? welcomeMessage,
    List<String>? permissions,
    Duration? expirationDuration,
    bool requiresVerification = false,
  }) {
    final now = DateTime.now();
    final expiration = expirationDuration ?? const Duration(days: 7);
    
    return TeamInvitationModel(
      id: '', // Will be set by Firestore
      teamId: teamId,
      teamName: teamName,
      invitedBy: invitedBy,
      invitedByName: invitedByName,
      invitedByPhotoUrl: invitedByPhotoUrl,
      inviteeEmail: inviteeEmail,
      proposedRole: proposedRole,
      status: InvitationStatus.pending,
      createdAt: now,
      expiresAt: now.add(expiration),
      message: message,
      welcomeMessage: welcomeMessage,
      permissions: permissions ?? [],
      invitationToken: _generateInvitationToken(),
      verificationCode: requiresVerification ? _generateVerificationCode() : null,
      requiresVerification: requiresVerification,
    );
  }

  /// Generate a secure invitation token
  static String _generateInvitationToken() {
    // In a real implementation, use a cryptographically secure random generator
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = timestamp.hashCode.abs();
    return 'inv_${timestamp}_$random';
  }

  /// Generate a verification code
  static String _generateVerificationCode() {
    // In a real implementation, use a cryptographically secure random generator
    final random = DateTime.now().millisecondsSinceEpoch % 1000000;
    return random.toString().padLeft(6, '0');
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TeamInvitationModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'TeamInvitationModel(id: $id, teamName: $teamName, inviteeEmail: $inviteeEmail, status: ${status.displayName})';
  }
}
