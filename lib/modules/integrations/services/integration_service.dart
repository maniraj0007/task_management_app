import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../core/services/auth_service.dart';
import '../../../core/services/performance_service.dart';

/// Integration Service
/// Handles third-party integrations including Slack, Teams, Calendar, and Webhooks
class IntegrationService extends GetxService {
  final AuthService _authService = Get.find<AuthService>();
  final PerformanceService _performanceService = Get.find<PerformanceService>();

  // Integration state
  final RxBool _isInitialized = false.obs;
  final RxString _error = ''.obs;
  final RxMap<String, bool> _integrationStatus = <String, bool>{}.obs;
  final RxList<WebhookEndpoint> _webhooks = <WebhookEndpoint>[].obs;

  // Getters
  bool get isInitialized => _isInitialized.value;
  String get error => _error.value;
  Map<String, bool> get integrationStatus => _integrationStatus;
  List<WebhookEndpoint> get webhooks => _webhooks;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeIntegrationService();
  }

  /// Initialize integration service
  Future<void> _initializeIntegrationService() async {
    try {
      // Initialize integration status
      _integrationStatus.addAll({
        'slack': false,
        'teams': false,
        'google_calendar': false,
        'outlook_calendar': false,
        'webhooks': true,
      });

      _isInitialized.value = true;
    } catch (e) {
      _error.value = 'Failed to initialize integration service: $e';
    }
  }

  // ==================== SLACK INTEGRATION ====================

  /// Send message to Slack channel
  Future<bool> sendSlackMessage({
    required String webhookUrl,
    required String message,
    String? channel,
    String? username,
    String? iconEmoji,
    List<SlackAttachment>? attachments,
  }) async {
    return await _performanceService.timeOperation('send_slack_message', () async {
      try {
        final payload = {
          'text': message,
          if (channel != null) 'channel': channel,
          if (username != null) 'username': username,
          if (iconEmoji != null) 'icon_emoji': iconEmoji,
          if (attachments != null) 'attachments': attachments.map((a) => a.toJson()).toList(),
        };

        final response = await http.post(
          Uri.parse(webhookUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        );

        return response.statusCode == 200;
      } catch (e) {
        _error.value = 'Failed to send Slack message: $e';
        return false;
      }
    });
  }

  /// Send task assignment notification to Slack
  Future<void> sendSlackTaskAssignment({
    required String webhookUrl,
    required String taskTitle,
    required String assigneeName,
    required String assignerName,
    required String taskUrl,
    DateTime? dueDate,
  }) async {
    final dueDateText = dueDate != null ? ' (Due: ${_formatDate(dueDate)})' : '';
    
    final attachment = SlackAttachment(
      color: '#2196F3',
      title: 'New Task Assignment',
      titleLink: taskUrl,
      text: '$assignerName assigned "$taskTitle" to $assigneeName$dueDateText',
      fields: [
        SlackField(title: 'Task', value: taskTitle, short: true),
        SlackField(title: 'Assignee', value: assigneeName, short: true),
        if (dueDate != null) SlackField(title: 'Due Date', value: _formatDate(dueDate), short: true),
      ],
      actions: [
        SlackAction(
          type: 'button',
          text: 'View Task',
          url: taskUrl,
          style: 'primary',
        ),
      ],
    );

    await sendSlackMessage(
      webhookUrl: webhookUrl,
      message: '📋 New task assignment',
      attachments: [attachment],
    );
  }

  /// Send task completion notification to Slack
  Future<void> sendSlackTaskCompletion({
    required String webhookUrl,
    required String taskTitle,
    required String completerName,
    required String taskUrl,
  }) async {
    final attachment = SlackAttachment(
      color: '#4CAF50',
      title: 'Task Completed',
      titleLink: taskUrl,
      text: '$completerName completed "$taskTitle" ✅',
      fields: [
        SlackField(title: 'Task', value: taskTitle, short: true),
        SlackField(title: 'Completed by', value: completerName, short: true),
      ],
      actions: [
        SlackAction(
          type: 'button',
          text: 'View Task',
          url: taskUrl,
          style: 'primary',
        ),
      ],
    );

    await sendSlackMessage(
      webhookUrl: webhookUrl,
      message: '✅ Task completed!',
      attachments: [attachment],
    );
  }

  // ==================== MICROSOFT TEAMS INTEGRATION ====================

  /// Send message to Microsoft Teams
  Future<bool> sendTeamsMessage({
    required String webhookUrl,
    required String title,
    required String text,
    String? themeColor,
    List<TeamsSection>? sections,
    List<TeamsAction>? actions,
  }) async {
    return await _performanceService.timeOperation('send_teams_message', () async {
      try {
        final payload = {
          '@type': 'MessageCard',
          '@context': 'https://schema.org/extensions',
          'title': title,
          'text': text,
          if (themeColor != null) 'themeColor': themeColor,
          if (sections != null) 'sections': sections.map((s) => s.toJson()).toList(),
          if (actions != null) 'potentialAction': actions.map((a) => a.toJson()).toList(),
        };

        final response = await http.post(
          Uri.parse(webhookUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        );

        return response.statusCode == 200;
      } catch (e) {
        _error.value = 'Failed to send Teams message: $e';
        return false;
      }
    });
  }

  /// Send task assignment notification to Teams
  Future<void> sendTeamsTaskAssignment({
    required String webhookUrl,
    required String taskTitle,
    required String assigneeName,
    required String assignerName,
    required String taskUrl,
    DateTime? dueDate,
  }) async {
    final dueDateText = dueDate != null ? _formatDate(dueDate) : 'Not set';
    
    final section = TeamsSection(
      activityTitle: 'New Task Assignment',
      activitySubtitle: 'by $assignerName',
      facts: [
        TeamsFact(name: 'Task', value: taskTitle),
        TeamsFact(name: 'Assignee', value: assigneeName),
        TeamsFact(name: 'Due Date', value: dueDateText),
      ],
    );

    final action = TeamsAction(
      type: 'OpenUri',
      name: 'View Task',
      targets: [
        TeamsTarget(os: 'default', uri: taskUrl),
      ],
    );

    await sendTeamsMessage(
      webhookUrl: webhookUrl,
      title: '📋 New Task Assignment',
      text: '$assignerName assigned "$taskTitle" to $assigneeName',
      themeColor: '2196F3',
      sections: [section],
      actions: [action],
    );
  }

  // ==================== CALENDAR INTEGRATION ====================

  /// Create Google Calendar event
  Future<bool> createGoogleCalendarEvent({
    required String accessToken,
    required String calendarId,
    required String title,
    required String description,
    required DateTime startTime,
    required DateTime endTime,
    List<String>? attendees,
  }) async {
    return await _performanceService.timeOperation('create_google_calendar_event', () async {
      try {
        final event = {
          'summary': title,
          'description': description,
          'start': {
            'dateTime': startTime.toIso8601String(),
            'timeZone': 'UTC',
          },
          'end': {
            'dateTime': endTime.toIso8601String(),
            'timeZone': 'UTC',
          },
          if (attendees != null)
            'attendees': attendees.map((email) => {'email': email}).toList(),
        };

        final response = await http.post(
          Uri.parse('https://www.googleapis.com/calendar/v3/calendars/$calendarId/events'),
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(event),
        );

        return response.statusCode == 200;
      } catch (e) {
        _error.value = 'Failed to create Google Calendar event: $e';
        return false;
      }
    });
  }

  /// Create Outlook Calendar event
  Future<bool> createOutlookCalendarEvent({
    required String accessToken,
    required String title,
    required String description,
    required DateTime startTime,
    required DateTime endTime,
    List<String>? attendees,
  }) async {
    return await _performanceService.timeOperation('create_outlook_calendar_event', () async {
      try {
        final event = {
          'subject': title,
          'body': {
            'contentType': 'HTML',
            'content': description,
          },
          'start': {
            'dateTime': startTime.toIso8601String(),
            'timeZone': 'UTC',
          },
          'end': {
            'dateTime': endTime.toIso8601String(),
            'timeZone': 'UTC',
          },
          if (attendees != null)
            'attendees': attendees.map((email) => {
              'emailAddress': {'address': email, 'name': email}
            }).toList(),
        };

        final response = await http.post(
          Uri.parse('https://graph.microsoft.com/v1.0/me/events'),
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(event),
        );

        return response.statusCode == 201;
      } catch (e) {
        _error.value = 'Failed to create Outlook Calendar event: $e';
        return false;
      }
    });
  }

  // ==================== WEBHOOK SYSTEM ====================

  /// Register a webhook endpoint
  Future<bool> registerWebhook({
    required String url,
    required List<String> events,
    String? secret,
    Map<String, String>? headers,
  }) async {
    return await _performanceService.timeOperation('register_webhook', () async {
      try {
        final webhook = WebhookEndpoint(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          url: url,
          events: events,
          secret: secret,
          headers: headers ?? {},
          isActive: true,
          createdAt: DateTime.now(),
        );

        _webhooks.add(webhook);
        return true;
      } catch (e) {
        _error.value = 'Failed to register webhook: $e';
        return false;
      }
    });
  }

  /// Send webhook notification
  Future<bool> sendWebhookNotification({
    required String event,
    required Map<String, dynamic> data,
  }) async {
    return await _performanceService.timeOperation('send_webhook_notification', () async {
      try {
        final relevantWebhooks = _webhooks.where((webhook) => 
            webhook.isActive && webhook.events.contains(event)).toList();

        for (final webhook in relevantWebhooks) {
          await _sendWebhookPayload(webhook, event, data);
        }

        return true;
      } catch (e) {
        _error.value = 'Failed to send webhook notifications: $e';
        return false;
      }
    });
  }

  /// Send webhook payload to endpoint
  Future<bool> _sendWebhookPayload(
    WebhookEndpoint webhook,
    String event,
    Map<String, dynamic> data,
  ) async {
    try {
      final payload = {
        'event': event,
        'timestamp': DateTime.now().toIso8601String(),
        'data': data,
      };

      final headers = <String, String>{
        'Content-Type': 'application/json',
        'User-Agent': 'TaskManagement-Webhook/1.0',
        ...webhook.headers,
      };

      // Add signature if secret is provided
      if (webhook.secret != null) {
        final signature = _generateWebhookSignature(jsonEncode(payload), webhook.secret!);
        headers['X-Webhook-Signature'] = signature;
      }

      final response = await http.post(
        Uri.parse(webhook.url),
        headers: headers,
        body: jsonEncode(payload),
      );

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      print('Failed to send webhook to ${webhook.url}: $e');
      return false;
    }
  }

  /// Generate webhook signature
  String _generateWebhookSignature(String payload, String secret) {
    // In a real implementation, you would use HMAC-SHA256
    // For now, return a simple hash
    return 'sha256=${payload.hashCode}';
  }

  // ==================== INTEGRATION MANAGEMENT ====================

  /// Enable integration
  Future<bool> enableIntegration(String integrationType) async {
    try {
      _integrationStatus[integrationType] = true;
      return true;
    } catch (e) {
      _error.value = 'Failed to enable $integrationType integration: $e';
      return false;
    }
  }

  /// Disable integration
  Future<bool> disableIntegration(String integrationType) async {
    try {
      _integrationStatus[integrationType] = false;
      return true;
    } catch (e) {
      _error.value = 'Failed to disable $integrationType integration: $e';
      return false;
    }
  }

  /// Check if integration is enabled
  bool isIntegrationEnabled(String integrationType) {
    return _integrationStatus[integrationType] ?? false;
  }

  /// Remove webhook
  bool removeWebhook(String webhookId) {
    try {
      _webhooks.removeWhere((webhook) => webhook.id == webhookId);
      return true;
    } catch (e) {
      _error.value = 'Failed to remove webhook: $e';
      return false;
    }
  }

  // ==================== HELPER METHODS ====================

  /// Format date
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  void onClose() {
    // Clean up resources
    super.onClose();
  }
}

// ==================== SLACK MODELS ====================

class SlackAttachment {
  final String? color;
  final String? title;
  final String? titleLink;
  final String? text;
  final List<SlackField>? fields;
  final List<SlackAction>? actions;

  SlackAttachment({
    this.color,
    this.title,
    this.titleLink,
    this.text,
    this.fields,
    this.actions,
  });

  Map<String, dynamic> toJson() {
    return {
      if (color != null) 'color': color,
      if (title != null) 'title': title,
      if (titleLink != null) 'title_link': titleLink,
      if (text != null) 'text': text,
      if (fields != null) 'fields': fields!.map((f) => f.toJson()).toList(),
      if (actions != null) 'actions': actions!.map((a) => a.toJson()).toList(),
    };
  }
}

class SlackField {
  final String title;
  final String value;
  final bool short;

  SlackField({
    required this.title,
    required this.value,
    this.short = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'value': value,
      'short': short,
    };
  }
}

class SlackAction {
  final String type;
  final String text;
  final String? url;
  final String? style;

  SlackAction({
    required this.type,
    required this.text,
    this.url,
    this.style,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'text': text,
      if (url != null) 'url': url,
      if (style != null) 'style': style,
    };
  }
}

// ==================== TEAMS MODELS ====================

class TeamsSection {
  final String? activityTitle;
  final String? activitySubtitle;
  final List<TeamsFact>? facts;

  TeamsSection({
    this.activityTitle,
    this.activitySubtitle,
    this.facts,
  });

  Map<String, dynamic> toJson() {
    return {
      if (activityTitle != null) 'activityTitle': activityTitle,
      if (activitySubtitle != null) 'activitySubtitle': activitySubtitle,
      if (facts != null) 'facts': facts!.map((f) => f.toJson()).toList(),
    };
  }
}

class TeamsFact {
  final String name;
  final String value;

  TeamsFact({
    required this.name,
    required this.value,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
    };
  }
}

class TeamsAction {
  final String type;
  final String name;
  final List<TeamsTarget>? targets;

  TeamsAction({
    required this.type,
    required this.name,
    this.targets,
  });

  Map<String, dynamic> toJson() {
    return {
      '@type': type,
      'name': name,
      if (targets != null) 'targets': targets!.map((t) => t.toJson()).toList(),
    };
  }
}

class TeamsTarget {
  final String os;
  final String uri;

  TeamsTarget({
    required this.os,
    required this.uri,
  });

  Map<String, dynamic> toJson() {
    return {
      'os': os,
      'uri': uri,
    };
  }
}

// ==================== WEBHOOK MODELS ====================

class WebhookEndpoint {
  final String id;
  final String url;
  final List<String> events;
  final String? secret;
  final Map<String, String> headers;
  final bool isActive;
  final DateTime createdAt;

  WebhookEndpoint({
    required this.id,
    required this.url,
    required this.events,
    this.secret,
    required this.headers,
    required this.isActive,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'events': events,
      'secret': secret,
      'headers': headers,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
