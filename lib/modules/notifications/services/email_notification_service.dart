import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../core/services/auth_service.dart';
import '../../../core/services/performance_service.dart';

/// Email Notification Service
/// Handles automated email notifications with templates
class EmailNotificationService extends GetxService {
  final AuthService _authService = Get.find<AuthService>();
  final PerformanceService _performanceService = Get.find<PerformanceService>();

  // Email configuration
  static const String _emailApiUrl = 'https://api.emailservice.com/v1/send'; // Replace with actual service
  static const String _apiKey = 'your-email-api-key'; // Replace with actual API key

  // Email state
  final RxBool _isInitialized = false.obs;
  final RxString _error = ''.obs;
  final RxList<EmailNotification> _sentEmails = <EmailNotification>[].obs;

  // Getters
  bool get isInitialized => _isInitialized.value;
  String get error => _error.value;
  List<EmailNotification> get sentEmails => _sentEmails;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeEmailService();
  }

  /// Initialize email service
  Future<void> _initializeEmailService() async {
    try {
      _isInitialized.value = true;
    } catch (e) {
      _error.value = 'Failed to initialize email service: $e';
    }
  }

  // ==================== EMAIL SENDING ====================

  /// Send email to single recipient
  Future<bool> sendEmail({
    required String to,
    required String subject,
    required String htmlBody,
    String? textBody,
    List<EmailAttachment>? attachments,
  }) async {
    return await _performanceService.timeOperation('send_email', () async {
      try {
        final emailData = {
          'to': to,
          'subject': subject,
          'html': htmlBody,
          'text': textBody ?? _stripHtml(htmlBody),
          'attachments': attachments?.map((a) => a.toJson()).toList() ?? [],
        };

        final response = await http.post(
          Uri.parse(_emailApiUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_apiKey',
          },
          body: jsonEncode(emailData),
        );

        if (response.statusCode == 200) {
          _sentEmails.add(EmailNotification(
            to: to,
            subject: subject,
            body: htmlBody,
            sentAt: DateTime.now(),
            status: 'sent',
          ));
          return true;
        } else {
          _error.value = 'Failed to send email: ${response.body}';
          return false;
        }
      } catch (e) {
        _error.value = 'Failed to send email: $e';
        return false;
      }
    });
  }

  /// Send email to multiple recipients
  Future<bool> sendBulkEmail({
    required List<String> recipients,
    required String subject,
    required String htmlBody,
    String? textBody,
  }) async {
    return await _performanceService.timeOperation('send_bulk_email', () async {
      try {
        final emailData = {
          'to': recipients,
          'subject': subject,
          'html': htmlBody,
          'text': textBody ?? _stripHtml(htmlBody),
        };

        final response = await http.post(
          Uri.parse('$_emailApiUrl/bulk'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_apiKey',
          },
          body: jsonEncode(emailData),
        );

        if (response.statusCode == 200) {
          for (final recipient in recipients) {
            _sentEmails.add(EmailNotification(
              to: recipient,
              subject: subject,
              body: htmlBody,
              sentAt: DateTime.now(),
              status: 'sent',
            ));
          }
          return true;
        } else {
          _error.value = 'Failed to send bulk email: ${response.body}';
          return false;
        }
      } catch (e) {
        _error.value = 'Failed to send bulk email: $e';
        return false;
      }
    });
  }

  // ==================== TASK-RELATED EMAIL NOTIFICATIONS ====================

  /// Send task assignment email
  Future<void> sendTaskAssignmentEmail({
    required String assigneeEmail,
    required String assigneeName,
    required String taskTitle,
    required String taskDescription,
    required String assignerName,
    required String taskUrl,
    DateTime? dueDate,
  }) async {
    final subject = 'New Task Assigned: $taskTitle';
    final htmlBody = _buildTaskAssignmentTemplate(
      assigneeName: assigneeName,
      taskTitle: taskTitle,
      taskDescription: taskDescription,
      assignerName: assignerName,
      taskUrl: taskUrl,
      dueDate: dueDate,
    );

    await sendEmail(
      to: assigneeEmail,
      subject: subject,
      htmlBody: htmlBody,
    );
  }

  /// Send task completion email
  Future<void> sendTaskCompletionEmail({
    required List<String> recipientEmails,
    required String taskTitle,
    required String completerName,
    required String taskUrl,
    DateTime? completedAt,
  }) async {
    final subject = 'Task Completed: $taskTitle';
    final htmlBody = _buildTaskCompletionTemplate(
      taskTitle: taskTitle,
      completerName: completerName,
      taskUrl: taskUrl,
      completedAt: completedAt ?? DateTime.now(),
    );

    await sendBulkEmail(
      recipients: recipientEmails,
      subject: subject,
      htmlBody: htmlBody,
    );
  }

  /// Send task due date reminder email
  Future<void> sendTaskDueDateReminderEmail({
    required List<String> recipientEmails,
    required String taskTitle,
    required String taskUrl,
    required DateTime dueDate,
    required String timeFrame,
  }) async {
    final subject = 'Task Due Soon: $taskTitle';
    final htmlBody = _buildTaskDueDateReminderTemplate(
      taskTitle: taskTitle,
      taskUrl: taskUrl,
      dueDate: dueDate,
      timeFrame: timeFrame,
    );

    await sendBulkEmail(
      recipients: recipientEmails,
      subject: subject,
      htmlBody: htmlBody,
    );
  }

  /// Send task comment notification email
  Future<void> sendTaskCommentEmail({
    required List<String> recipientEmails,
    required String taskTitle,
    required String commenterName,
    required String commentText,
    required String taskUrl,
  }) async {
    final subject = 'New Comment on: $taskTitle';
    final htmlBody = _buildTaskCommentTemplate(
      taskTitle: taskTitle,
      commenterName: commenterName,
      commentText: commentText,
      taskUrl: taskUrl,
    );

    await sendBulkEmail(
      recipients: recipientEmails,
      subject: subject,
      htmlBody: htmlBody,
    );
  }

  /// Send mention notification email
  Future<void> sendMentionEmail({
    required String recipientEmail,
    required String recipientName,
    required String taskTitle,
    required String mentionerName,
    required String commentText,
    required String taskUrl,
  }) async {
    final subject = 'You were mentioned in: $taskTitle';
    final htmlBody = _buildMentionTemplate(
      recipientName: recipientName,
      taskTitle: taskTitle,
      mentionerName: mentionerName,
      commentText: commentText,
      taskUrl: taskUrl,
    );

    await sendEmail(
      to: recipientEmail,
      subject: subject,
      htmlBody: htmlBody,
    );
  }

  // ==================== PROJECT-RELATED EMAIL NOTIFICATIONS ====================

  /// Send project milestone completion email
  Future<void> sendMilestoneCompletionEmail({
    required List<String> recipientEmails,
    required String projectTitle,
    required String milestoneTitle,
    required String completerName,
    required String projectUrl,
  }) async {
    final subject = 'Milestone Completed: $milestoneTitle';
    final htmlBody = _buildMilestoneCompletionTemplate(
      projectTitle: projectTitle,
      milestoneTitle: milestoneTitle,
      completerName: completerName,
      projectUrl: projectUrl,
    );

    await sendBulkEmail(
      recipients: recipientEmails,
      subject: subject,
      htmlBody: htmlBody,
    );
  }

  /// Send weekly project summary email
  Future<void> sendWeeklyProjectSummaryEmail({
    required List<String> recipientEmails,
    required String projectTitle,
    required Map<String, dynamic> summaryData,
    required String projectUrl,
  }) async {
    final subject = 'Weekly Summary: $projectTitle';
    final htmlBody = _buildWeeklyProjectSummaryTemplate(
      projectTitle: projectTitle,
      summaryData: summaryData,
      projectUrl: projectUrl,
    );

    await sendBulkEmail(
      recipients: recipientEmails,
      subject: subject,
      htmlBody: htmlBody,
    );
  }

  // ==================== EMAIL TEMPLATES ====================

  /// Build task assignment email template
  String _buildTaskAssignmentTemplate({
    required String assigneeName,
    required String taskTitle,
    required String taskDescription,
    required String assignerName,
    required String taskUrl,
    DateTime? dueDate,
  }) {
    final dueDateText = dueDate != null 
        ? '<p><strong>Due Date:</strong> ${_formatDate(dueDate)}</p>'
        : '';

    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="utf-8">
        <title>New Task Assigned</title>
        <style>
            body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
            .container { max-width: 600px; margin: 0 auto; padding: 20px; }
            .header { background-color: #2196F3; color: white; padding: 20px; text-align: center; }
            .content { padding: 20px; background-color: #f9f9f9; }
            .button { display: inline-block; padding: 12px 24px; background-color: #2196F3; color: white; text-decoration: none; border-radius: 4px; margin: 10px 0; }
            .footer { text-align: center; padding: 20px; color: #666; font-size: 12px; }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>New Task Assigned</h1>
            </div>
            <div class="content">
                <p>Hi $assigneeName,</p>
                <p>You have been assigned a new task by $assignerName:</p>
                <h2>$taskTitle</h2>
                <p>$taskDescription</p>
                $dueDateText
                <a href="$taskUrl" class="button">View Task</a>
            </div>
            <div class="footer">
                <p>This is an automated message from Task Management App</p>
            </div>
        </div>
    </body>
    </html>
    ''';
  }

  /// Build task completion email template
  String _buildTaskCompletionTemplate({
    required String taskTitle,
    required String completerName,
    required String taskUrl,
    required DateTime completedAt,
  }) {
    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="utf-8">
        <title>Task Completed</title>
        <style>
            body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
            .container { max-width: 600px; margin: 0 auto; padding: 20px; }
            .header { background-color: #4CAF50; color: white; padding: 20px; text-align: center; }
            .content { padding: 20px; background-color: #f9f9f9; }
            .button { display: inline-block; padding: 12px 24px; background-color: #4CAF50; color: white; text-decoration: none; border-radius: 4px; margin: 10px 0; }
            .footer { text-align: center; padding: 20px; color: #666; font-size: 12px; }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>✅ Task Completed</h1>
            </div>
            <div class="content">
                <p>Great news! A task has been completed:</p>
                <h2>$taskTitle</h2>
                <p><strong>Completed by:</strong> $completerName</p>
                <p><strong>Completed at:</strong> ${_formatDateTime(completedAt)}</p>
                <a href="$taskUrl" class="button">View Task</a>
            </div>
            <div class="footer">
                <p>This is an automated message from Task Management App</p>
            </div>
        </div>
    </body>
    </html>
    ''';
  }

  /// Build task due date reminder email template
  String _buildTaskDueDateReminderTemplate({
    required String taskTitle,
    required String taskUrl,
    required DateTime dueDate,
    required String timeFrame,
  }) {
    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="utf-8">
        <title>Task Due Soon</title>
        <style>
            body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
            .container { max-width: 600px; margin: 0 auto; padding: 20px; }
            .header { background-color: #FF9800; color: white; padding: 20px; text-align: center; }
            .content { padding: 20px; background-color: #f9f9f9; }
            .button { display: inline-block; padding: 12px 24px; background-color: #FF9800; color: white; text-decoration: none; border-radius: 4px; margin: 10px 0; }
            .footer { text-align: center; padding: 20px; color: #666; font-size: 12px; }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>⏰ Task Due Soon</h1>
            </div>
            <div class="content">
                <p>This is a reminder that a task is due soon:</p>
                <h2>$taskTitle</h2>
                <p><strong>Due:</strong> $timeFrame (${_formatDateTime(dueDate)})</p>
                <a href="$taskUrl" class="button">View Task</a>
            </div>
            <div class="footer">
                <p>This is an automated message from Task Management App</p>
            </div>
        </div>
    </body>
    </html>
    ''';
  }

  /// Build task comment email template
  String _buildTaskCommentTemplate({
    required String taskTitle,
    required String commenterName,
    required String commentText,
    required String taskUrl,
  }) {
    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="utf-8">
        <title>New Comment</title>
        <style>
            body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
            .container { max-width: 600px; margin: 0 auto; padding: 20px; }
            .header { background-color: #9C27B0; color: white; padding: 20px; text-align: center; }
            .content { padding: 20px; background-color: #f9f9f9; }
            .comment { background-color: white; padding: 15px; border-left: 4px solid #9C27B0; margin: 15px 0; }
            .button { display: inline-block; padding: 12px 24px; background-color: #9C27B0; color: white; text-decoration: none; border-radius: 4px; margin: 10px 0; }
            .footer { text-align: center; padding: 20px; color: #666; font-size: 12px; }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>💬 New Comment</h1>
            </div>
            <div class="content">
                <p>A new comment has been added to:</p>
                <h2>$taskTitle</h2>
                <div class="comment">
                    <p><strong>$commenterName</strong> commented:</p>
                    <p>$commentText</p>
                </div>
                <a href="$taskUrl" class="button">View Task</a>
            </div>
            <div class="footer">
                <p>This is an automated message from Task Management App</p>
            </div>
        </div>
    </body>
    </html>
    ''';
  }

  /// Build mention email template
  String _buildMentionTemplate({
    required String recipientName,
    required String taskTitle,
    required String mentionerName,
    required String commentText,
    required String taskUrl,
  }) {
    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="utf-8">
        <title>You were mentioned</title>
        <style>
            body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
            .container { max-width: 600px; margin: 0 auto; padding: 20px; }
            .header { background-color: #E91E63; color: white; padding: 20px; text-align: center; }
            .content { padding: 20px; background-color: #f9f9f9; }
            .mention { background-color: white; padding: 15px; border-left: 4px solid #E91E63; margin: 15px 0; }
            .button { display: inline-block; padding: 12px 24px; background-color: #E91E63; color: white; text-decoration: none; border-radius: 4px; margin: 10px 0; }
            .footer { text-align: center; padding: 20px; color: #666; font-size: 12px; }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>👋 You were mentioned</h1>
            </div>
            <div class="content">
                <p>Hi $recipientName,</p>
                <p>You were mentioned in a comment on:</p>
                <h2>$taskTitle</h2>
                <div class="mention">
                    <p><strong>$mentionerName</strong> mentioned you:</p>
                    <p>$commentText</p>
                </div>
                <a href="$taskUrl" class="button">View Task</a>
            </div>
            <div class="footer">
                <p>This is an automated message from Task Management App</p>
            </div>
        </div>
    </body>
    </html>
    ''';
  }

  /// Build milestone completion email template
  String _buildMilestoneCompletionTemplate({
    required String projectTitle,
    required String milestoneTitle,
    required String completerName,
    required String projectUrl,
  }) {
    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="utf-8">
        <title>Milestone Completed</title>
        <style>
            body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
            .container { max-width: 600px; margin: 0 auto; padding: 20px; }
            .header { background-color: #4CAF50; color: white; padding: 20px; text-align: center; }
            .content { padding: 20px; background-color: #f9f9f9; }
            .button { display: inline-block; padding: 12px 24px; background-color: #4CAF50; color: white; text-decoration: none; border-radius: 4px; margin: 10px 0; }
            .footer { text-align: center; padding: 20px; color: #666; font-size: 12px; }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>🎯 Milestone Completed</h1>
            </div>
            <div class="content">
                <p>Congratulations! A project milestone has been completed:</p>
                <h2>$milestoneTitle</h2>
                <p><strong>Project:</strong> $projectTitle</p>
                <p><strong>Completed by:</strong> $completerName</p>
                <a href="$projectUrl" class="button">View Project</a>
            </div>
            <div class="footer">
                <p>This is an automated message from Task Management App</p>
            </div>
        </div>
    </body>
    </html>
    ''';
  }

  /// Build weekly project summary email template
  String _buildWeeklyProjectSummaryTemplate({
    required String projectTitle,
    required Map<String, dynamic> summaryData,
    required String projectUrl,
  }) {
    final completedTasks = summaryData['completedTasks'] ?? 0;
    final totalTasks = summaryData['totalTasks'] ?? 0;
    final overdueTasks = summaryData['overdueTasks'] ?? 0;
    final newTasks = summaryData['newTasks'] ?? 0;

    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="utf-8">
        <title>Weekly Project Summary</title>
        <style>
            body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
            .container { max-width: 600px; margin: 0 auto; padding: 20px; }
            .header { background-color: #607D8B; color: white; padding: 20px; text-align: center; }
            .content { padding: 20px; background-color: #f9f9f9; }
            .stats { display: flex; justify-content: space-around; margin: 20px 0; }
            .stat { text-align: center; padding: 15px; background-color: white; border-radius: 8px; margin: 0 5px; }
            .stat-number { font-size: 24px; font-weight: bold; color: #607D8B; }
            .button { display: inline-block; padding: 12px 24px; background-color: #607D8B; color: white; text-decoration: none; border-radius: 4px; margin: 10px 0; }
            .footer { text-align: center; padding: 20px; color: #666; font-size: 12px; }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>📊 Weekly Summary</h1>
            </div>
            <div class="content">
                <h2>$projectTitle</h2>
                <p>Here's your weekly project summary:</p>
                <div class="stats">
                    <div class="stat">
                        <div class="stat-number">$completedTasks</div>
                        <div>Completed</div>
                    </div>
                    <div class="stat">
                        <div class="stat-number">$newTasks</div>
                        <div>New Tasks</div>
                    </div>
                    <div class="stat">
                        <div class="stat-number">$overdueTasks</div>
                        <div>Overdue</div>
                    </div>
                    <div class="stat">
                        <div class="stat-number">$totalTasks</div>
                        <div>Total Tasks</div>
                    </div>
                </div>
                <a href="$projectUrl" class="button">View Project</a>
            </div>
            <div class="footer">
                <p>This is an automated message from Task Management App</p>
            </div>
        </div>
    </body>
    </html>
    ''';
  }

  // ==================== HELPER METHODS ====================

  /// Strip HTML tags from text
  String _stripHtml(String html) {
    return html.replaceAll(RegExp(r'<[^>]*>'), '');
  }

  /// Format date
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Format date and time
  String _formatDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  void onClose() {
    // Clean up resources
    super.onClose();
  }
}

/// Email Notification Model
class EmailNotification {
  final String to;
  final String subject;
  final String body;
  final DateTime sentAt;
  final String status;

  EmailNotification({
    required this.to,
    required this.subject,
    required this.body,
    required this.sentAt,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'to': to,
      'subject': subject,
      'body': body,
      'sentAt': sentAt.toIso8601String(),
      'status': status,
    };
  }
}

/// Email Attachment Model
class EmailAttachment {
  final String filename;
  final String content; // Base64 encoded
  final String contentType;

  EmailAttachment({
    required this.filename,
    required this.content,
    required this.contentType,
  });

  Map<String, dynamic> toJson() {
    return {
      'filename': filename,
      'content': content,
      'contentType': contentType,
    };
  }
}
