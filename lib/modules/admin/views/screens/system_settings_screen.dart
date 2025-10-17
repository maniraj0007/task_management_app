import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/enums/user_roles.dart';
import '../../controllers/admin_controller.dart';

/// System Settings Screen
/// Comprehensive system configuration interface for Super Admins
class SystemSettingsScreen extends GetView<AdminController> {
  const SystemSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'System Settings',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _saveSettings,
            icon: const Icon(Icons.save),
            tooltip: 'Save Settings',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // General Settings
              _buildSettingsSection(
                title: 'General Settings',
                children: [
                  _buildSettingsTile(
                    title: 'Application Name',
                    subtitle: 'Change the application display name',
                    trailing: TextButton(
                      onPressed: () => _showEditDialog(
                        'Application Name',
                        controller.appName.value,
                        (value) => controller.updateAppName(value),
                      ),
                      child: Text(controller.appName.value),
                    ),
                  ),
                  _buildSettingsTile(
                    title: 'Default Theme',
                    subtitle: 'Set the default theme for new users',
                    trailing: DropdownButton<String>(
                      value: controller.defaultTheme.value,
                      onChanged: (value) => controller.updateDefaultTheme(value!),
                      items: const [
                        DropdownMenuItem(value: 'light', child: Text('Light')),
                        DropdownMenuItem(value: 'dark', child: Text('Dark')),
                        DropdownMenuItem(value: 'system', child: Text('System')),
                      ],
                    ),
                  ),
                  _buildSettingsTile(
                    title: 'Default Language',
                    subtitle: 'Set the default language for new users',
                    trailing: DropdownButton<String>(
                      value: controller.defaultLanguage.value,
                      onChanged: (value) => controller.updateDefaultLanguage(value!),
                      items: const [
                        DropdownMenuItem(value: 'en', child: Text('English')),
                        DropdownMenuItem(value: 'es', child: Text('Spanish')),
                        DropdownMenuItem(value: 'fr', child: Text('French')),
                        DropdownMenuItem(value: 'de', child: Text('German')),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppDimensions.spacingLarge),

              // User Management Settings
              _buildSettingsSection(
                title: 'User Management',
                children: [
                  _buildSettingsTile(
                    title: 'Allow User Registration',
                    subtitle: 'Allow new users to register themselves',
                    trailing: Switch(
                      value: controller.allowUserRegistration.value,
                      onChanged: controller.toggleUserRegistration,
                    ),
                  ),
                  _buildSettingsTile(
                    title: 'Default User Role',
                    subtitle: 'Default role assigned to new users',
                    trailing: DropdownButton<UserRole>(
                      value: controller.defaultUserRole.value,
                      onChanged: (value) => controller.updateDefaultUserRole(value!),
                      items: UserRole.values.map((role) {
                        return DropdownMenuItem(
                          value: role,
                          child: Text(role.displayName),
                        );
                      }).toList(),
                    ),
                  ),
                  _buildSettingsTile(
                    title: 'Require Email Verification',
                    subtitle: 'Require users to verify their email address',
                    trailing: Switch(
                      value: controller.requireEmailVerification.value,
                      onChanged: controller.toggleEmailVerification,
                    ),
                  ),
                  _buildSettingsTile(
                    title: 'Maximum Team Size',
                    subtitle: 'Maximum number of members per team',
                    trailing: TextButton(
                      onPressed: () => _showNumberDialog(
                        'Maximum Team Size',
                        controller.maxTeamSize.value,
                        (value) => controller.updateMaxTeamSize(value),
                      ),
                      child: Text(controller.maxTeamSize.value.toString()),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppDimensions.spacingLarge),

              // Task Management Settings
              _buildSettingsSection(
                title: 'Task Management',
                children: [
                  _buildSettingsTile(
                    title: 'Auto-assign Tasks',
                    subtitle: 'Automatically assign tasks based on workload',
                    trailing: Switch(
                      value: controller.autoAssignTasks.value,
                      onChanged: controller.toggleAutoAssignTasks,
                    ),
                  ),
                  _buildSettingsTile(
                    title: 'Task Due Date Reminders',
                    subtitle: 'Send reminders before task due dates',
                    trailing: Switch(
                      value: controller.taskDueDateReminders.value,
                      onChanged: controller.toggleTaskDueDateReminders,
                    ),
                  ),
                  _buildSettingsTile(
                    title: 'Default Task Priority',
                    subtitle: 'Default priority for new tasks',
                    trailing: DropdownButton<String>(
                      value: controller.defaultTaskPriority.value,
                      onChanged: (value) => controller.updateDefaultTaskPriority(value!),
                      items: const [
                        DropdownMenuItem(value: 'low', child: Text('Low')),
                        DropdownMenuItem(value: 'medium', child: Text('Medium')),
                        DropdownMenuItem(value: 'high', child: Text('High')),
                        DropdownMenuItem(value: 'urgent', child: Text('Urgent')),
                      ],
                    ),
                  ),
                  _buildSettingsTile(
                    title: 'Task Archive Period',
                    subtitle: 'Days after completion to archive tasks',
                    trailing: TextButton(
                      onPressed: () => _showNumberDialog(
                        'Task Archive Period (Days)',
                        controller.taskArchivePeriod.value,
                        (value) => controller.updateTaskArchivePeriod(value),
                      ),
                      child: Text('${controller.taskArchivePeriod.value} days'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppDimensions.spacingLarge),

              // Notification Settings
              _buildSettingsSection(
                title: 'Notifications',
                children: [
                  _buildSettingsTile(
                    title: 'Push Notifications',
                    subtitle: 'Enable push notifications for all users',
                    trailing: Switch(
                      value: controller.pushNotificationsEnabled.value,
                      onChanged: controller.togglePushNotifications,
                    ),
                  ),
                  _buildSettingsTile(
                    title: 'Email Notifications',
                    subtitle: 'Enable email notifications for all users',
                    trailing: Switch(
                      value: controller.emailNotificationsEnabled.value,
                      onChanged: controller.toggleEmailNotifications,
                    ),
                  ),
                  _buildSettingsTile(
                    title: 'Notification Frequency',
                    subtitle: 'How often to send digest notifications',
                    trailing: DropdownButton<String>(
                      value: controller.notificationFrequency.value,
                      onChanged: (value) => controller.updateNotificationFrequency(value!),
                      items: const [
                        DropdownMenuItem(value: 'immediate', child: Text('Immediate')),
                        DropdownMenuItem(value: 'hourly', child: Text('Hourly')),
                        DropdownMenuItem(value: 'daily', child: Text('Daily')),
                        DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppDimensions.spacingLarge),

              // Security Settings
              _buildSettingsSection(
                title: 'Security',
                children: [
                  _buildSettingsTile(
                    title: 'Two-Factor Authentication',
                    subtitle: 'Require 2FA for admin accounts',
                    trailing: Switch(
                      value: controller.require2FA.value,
                      onChanged: controller.toggle2FA,
                    ),
                  ),
                  _buildSettingsTile(
                    title: 'Session Timeout',
                    subtitle: 'Automatic logout after inactivity (minutes)',
                    trailing: TextButton(
                      onPressed: () => _showNumberDialog(
                        'Session Timeout (Minutes)',
                        controller.sessionTimeout.value,
                        (value) => controller.updateSessionTimeout(value),
                      ),
                      child: Text('${controller.sessionTimeout.value} min'),
                    ),
                  ),
                  _buildSettingsTile(
                    title: 'Password Policy',
                    subtitle: 'Enforce strong password requirements',
                    trailing: Switch(
                      value: controller.enforcePasswordPolicy.value,
                      onChanged: controller.togglePasswordPolicy,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppDimensions.spacingLarge),

              // Data Management
              _buildSettingsSection(
                title: 'Data Management',
                children: [
                  _buildSettingsTile(
                    title: 'Data Backup',
                    subtitle: 'Automatic daily backups',
                    trailing: Switch(
                      value: controller.dataBackupEnabled.value,
                      onChanged: controller.toggleDataBackup,
                    ),
                  ),
                  _buildSettingsTile(
                    title: 'Data Retention Period',
                    subtitle: 'Days to keep deleted data before permanent removal',
                    trailing: TextButton(
                      onPressed: () => _showNumberDialog(
                        'Data Retention Period (Days)',
                        controller.dataRetentionPeriod.value,
                        (value) => controller.updateDataRetentionPeriod(value),
                      ),
                      child: Text('${controller.dataRetentionPeriod.value} days'),
                    ),
                  ),
                  _buildSettingsTile(
                    title: 'Export Data',
                    subtitle: 'Export all system data',
                    trailing: ElevatedButton(
                      onPressed: controller.exportSystemData,
                      child: const Text('Export'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppDimensions.spacingXLarge),
            ],
          ),
        );
      }),
    );
  }

  /// Build a settings section with title and children
  Widget _buildSettingsSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: Text(
              title,
              style: Get.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  /// Build a settings tile
  Widget _buildSettingsTile({
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(subtitle),
      trailing: trailing,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
        vertical: AppDimensions.paddingSmall,
      ),
    );
  }

  /// Show edit dialog for text settings
  void _showEditDialog(
    String title,
    String currentValue,
    Function(String) onSave,
  ) {
    final textController = TextEditingController(text: currentValue);

    Get.dialog(
      AlertDialog(
        title: Text(title),
        content: TextField(
          controller: textController,
          decoration: InputDecoration(
            labelText: title,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              onSave(textController.text);
              Get.back();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  /// Show number dialog for numeric settings
  void _showNumberDialog(
    String title,
    int currentValue,
    Function(int) onSave,
  ) {
    final textController = TextEditingController(text: currentValue.toString());

    Get.dialog(
      AlertDialog(
        title: Text(title),
        content: TextField(
          controller: textController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: title,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = int.tryParse(textController.text);
              if (value != null && value > 0) {
                onSave(value);
                Get.back();
              } else {
                Get.snackbar(
                  'Error',
                  'Please enter a valid positive number',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  /// Save all settings
  void _saveSettings() {
    controller.saveSystemSettings();
    Get.snackbar(
      'Success',
      'System settings saved successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.success,
      colorText: Colors.white,
    );
  }
}
