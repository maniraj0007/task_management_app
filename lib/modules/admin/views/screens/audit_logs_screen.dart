import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../controllers/admin_controller.dart';
import '../../models/audit_log_model.dart';

/// Audit Logs Screen
/// Comprehensive audit trail for system activities (Super Admin only)
class AuditLogsScreen extends GetView<AdminController> {
  const AuditLogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Audit Logs',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _showFilterDialog,
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter Logs',
          ),
          IconButton(
            onPressed: _exportLogs,
            icon: const Icon(Icons.download),
            tooltip: 'Export Logs',
          ),
          IconButton(
            onPressed: controller.refreshAuditLogs,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Summary
          _buildFilterSummary(),
          
          // Logs List
          Expanded(
            child: Obx(() {
              if (controller.isLoadingAuditLogs.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final logs = controller.filteredAuditLogs;
              
              if (logs.isEmpty) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                onRefresh: controller.refreshAuditLogs,
                child: ListView.builder(
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    final log = logs[index];
                    return _buildAuditLogCard(log);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  /// Build filter summary bar
  Widget _buildFilterSummary() {
    return Obx(() {
      final hasFilters = controller.auditLogFilters.isNotEmpty;
      
      if (!hasFilters) return const SizedBox.shrink();

      return Container(
        margin: const EdgeInsets.all(AppDimensions.paddingMedium),
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        decoration: BoxDecoration(
          color: AppColors.info.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: Border.all(color: AppColors.info.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.filter_list,
              color: AppColors.info,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Filters applied: ${controller.auditLogFilters.length}',
                style: TextStyle(
                  color: AppColors.info,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: controller.clearAuditLogFilters,
              child: const Text('Clear All'),
            ),
          ],
        ),
      );
    });
  }

  /// Build audit log card
  Widget _buildAuditLogCard(AuditLogModel log) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingMedium),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getActionColor(log.action).withOpacity(0.2),
          child: Icon(
            _getActionIcon(log.action),
            color: _getActionColor(log.action),
            size: 20,
          ),
        ),
        title: Text(
          log.action,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(log.description),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.person,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  log.userEmail,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  DateFormat('MMM dd, yyyy HH:mm').format(log.timestamp),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getSeverityColor(log.severity).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            log.severity.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: _getSeverityColor(log.severity),
            ),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                _buildDetailRow('User ID', log.userId),
                _buildDetailRow('IP Address', log.ipAddress ?? 'Unknown'),
                _buildDetailRow('User Agent', log.userAgent ?? 'Unknown'),
                _buildDetailRow('Resource Type', log.resourceType ?? 'N/A'),
                _buildDetailRow('Resource ID', log.resourceId ?? 'N/A'),
                if (log.metadata.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Additional Details:',
                    style: Get.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...log.metadata.entries.map((entry) {
                    return _buildDetailRow(entry.key, entry.value.toString());
                  }).toList(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build detail row
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  /// Build empty state
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: AppDimensions.spacingMedium),
          Text(
            'No audit logs found',
            style: Get.textTheme.titleMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSmall),
          Text(
            'System activities will appear here',
            style: Get.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Show filter dialog
  void _showFilterDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Filter Audit Logs'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Action Filter
              Text(
                'Action',
                style: Get.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Obx(() => Wrap(
                spacing: 8,
                children: controller.availableActions.map((action) {
                  final isSelected = controller.selectedActions.contains(action);
                  return FilterChip(
                    label: Text(action),
                    selected: isSelected,
                    onSelected: (selected) {
                      controller.toggleActionFilter(action);
                    },
                  );
                }).toList(),
              )),
              
              const SizedBox(height: 16),
              
              // Severity Filter
              Text(
                'Severity',
                style: Get.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Obx(() => Wrap(
                spacing: 8,
                children: ['low', 'medium', 'high', 'critical'].map((severity) {
                  final isSelected = controller.selectedSeverities.contains(severity);
                  return FilterChip(
                    label: Text(severity.toUpperCase()),
                    selected: isSelected,
                    onSelected: (selected) {
                      controller.toggleSeverityFilter(severity);
                    },
                  );
                }).toList(),
              )),
              
              const SizedBox(height: 16),
              
              // Date Range Filter
              Text(
                'Date Range',
                style: Get.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => _selectStartDate(),
                      child: Obx(() => Text(
                        controller.startDate.value != null
                            ? DateFormat('MMM dd, yyyy').format(controller.startDate.value!)
                            : 'Start Date',
                      )),
                    ),
                  ),
                  const Text(' - '),
                  Expanded(
                    child: TextButton(
                      onPressed: () => _selectEndDate(),
                      child: Obx(() => Text(
                        controller.endDate.value != null
                            ? DateFormat('MMM dd, yyyy').format(controller.endDate.value!)
                            : 'End Date',
                      )),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.applyAuditLogFilters();
              Get.back();
            },
            child: const Text('Apply Filters'),
          ),
        ],
      ),
    );
  }

  /// Select start date
  void _selectStartDate() async {
    final date = await showDatePicker(
      context: Get.context!,
      initialDate: controller.startDate.value ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      controller.startDate.value = date;
    }
  }

  /// Select end date
  void _selectEndDate() async {
    final date = await showDatePicker(
      context: Get.context!,
      initialDate: controller.endDate.value ?? DateTime.now(),
      firstDate: controller.startDate.value ?? DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      controller.endDate.value = date;
    }
  }

  /// Export logs
  void _exportLogs() {
    Get.dialog(
      AlertDialog(
        title: const Text('Export Audit Logs'),
        content: const Text(
          'Export audit logs to CSV file. This may take a few moments for large datasets.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.exportAuditLogs();
              Get.back();
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  /// Get action color
  Color _getActionColor(String action) {
    switch (action.toLowerCase()) {
      case 'create':
      case 'register':
        return AppColors.success;
      case 'update':
      case 'edit':
        return AppColors.info;
      case 'delete':
      case 'remove':
        return AppColors.error;
      case 'login':
      case 'logout':
        return AppColors.warning;
      default:
        return AppColors.primary;
    }
  }

  /// Get action icon
  IconData _getActionIcon(String action) {
    switch (action.toLowerCase()) {
      case 'create':
      case 'register':
        return Icons.add_circle;
      case 'update':
      case 'edit':
        return Icons.edit;
      case 'delete':
      case 'remove':
        return Icons.delete;
      case 'login':
        return Icons.login;
      case 'logout':
        return Icons.logout;
      case 'view':
        return Icons.visibility;
      default:
        return Icons.info;
    }
  }

  /// Get severity color
  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'low':
        return AppColors.success;
      case 'medium':
        return AppColors.warning;
      case 'high':
        return AppColors.error;
      case 'critical':
        return Colors.red.shade800;
      default:
        return AppColors.textSecondary;
    }
  }
}
