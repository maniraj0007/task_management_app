import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../models/search_models.dart';

/// Search Result Card Widget
/// Displays individual search results with rich information
class SearchResultCard extends StatelessWidget {
  final SearchResultModel result;
  final VoidCallback? onTap;

  const SearchResultCard({
    super.key,
    required this.result,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with type and relevance
                _buildHeader(),
                
                const SizedBox(height: AppDimensions.spacingSmall),
                
                // Title
                _buildTitle(),
                
                // Description
                if (result.description.isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.spacingSmall),
                  _buildDescription(),
                ],
                
                // Metadata
                if (result.metadata.isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.spacingSmall),
                  _buildMetadata(),
                ],
                
                // Tags
                if (result.tags.isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.spacingSmall),
                  _buildTags(),
                ],
                
                // Footer with timestamp and actions
                const SizedBox(height: AppDimensions.spacingSmall),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build header
  Widget _buildHeader() {
    return Row(
      children: [
        // Type icon
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: _getTypeColor().withOpacity(0.2),
            borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          ),
          child: Icon(
            _getTypeIcon(),
            color: _getTypeColor(),
            size: 16,
          ),
        ),
        
        const SizedBox(width: 8),
        
        // Type label
        Text(
          result.type.displayName,
          style: Get.textTheme.bodySmall?.copyWith(
            color: _getTypeColor(),
            fontWeight: FontWeight.w600,
          ),
        ),
        
        const Spacer(),
        
        // Relevance score
        if (result.relevanceScore > 0) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: _getRelevanceColor().withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.star,
                  size: 12,
                  color: _getRelevanceColor(),
                ),
                const SizedBox(width: 2),
                Text(
                  '${(result.relevanceScore * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: _getRelevanceColor(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// Build title
  Widget _buildTitle() {
    return Text(
      result.title,
      style: Get.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Build description
  Widget _buildDescription() {
    return Text(
      result.description,
      style: Get.textTheme.bodyMedium?.copyWith(
        color: AppColors.textSecondary,
        height: 1.4,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Build metadata
  Widget _buildMetadata() {
    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children: result.metadata.entries.map((entry) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getMetadataIcon(entry.key),
              size: 14,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              '${_formatMetadataKey(entry.key)}: ${entry.value}',
              style: Get.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  /// Build tags
  Widget _buildTags() {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: result.tags.take(5).map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            tag,
            style: TextStyle(
              fontSize: 10,
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Build footer
  Widget _buildFooter() {
    return Row(
      children: [
        // Timestamp
        if (result.lastModified != null) ...[
          Icon(
            Icons.schedule,
            size: 14,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            _formatTimestamp(result.lastModified!),
            style: Get.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
        
        const Spacer(),
        
        // Action button
        if (result.actionUrl != null) ...[
          Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: AppColors.textSecondary,
          ),
        ],
      ],
    );
  }

  /// Get type icon
  IconData _getTypeIcon() {
    switch (result.type) {
      case SearchResultType.task:
        return Icons.task_alt;
      case SearchResultType.team:
        return Icons.group;
      case SearchResultType.project:
        return Icons.folder;
      case SearchResultType.user:
        return Icons.person;
      case SearchResultType.notification:
        return Icons.notifications;
      case SearchResultType.comment:
        return Icons.comment;
      case SearchResultType.file:
        return Icons.insert_drive_file;
      case SearchResultType.other:
        return Icons.help_outline;
    }
  }

  /// Get type color
  Color _getTypeColor() {
    switch (result.type) {
      case SearchResultType.task:
        return Colors.blue;
      case SearchResultType.team:
        return Colors.purple;
      case SearchResultType.project:
        return Colors.orange;
      case SearchResultType.user:
        return Colors.green;
      case SearchResultType.notification:
        return Colors.red;
      case SearchResultType.comment:
        return Colors.teal;
      case SearchResultType.file:
        return Colors.indigo;
      case SearchResultType.other:
        return Colors.grey;
    }
  }

  /// Get relevance color
  Color _getRelevanceColor() {
    if (result.relevanceScore >= 0.8) {
      return Colors.green;
    } else if (result.relevanceScore >= 0.6) {
      return Colors.orange;
    } else {
      return Colors.grey;
    }
  }

  /// Get metadata icon
  IconData _getMetadataIcon(String key) {
    switch (key.toLowerCase()) {
      case 'status':
        return Icons.info;
      case 'priority':
        return Icons.flag;
      case 'assignee':
      case 'owner':
        return Icons.person;
      case 'team':
        return Icons.group;
      case 'project':
        return Icons.folder;
      case 'due_date':
      case 'created_date':
        return Icons.calendar_today;
      case 'size':
        return Icons.straighten;
      default:
        return Icons.label;
    }
  }

  /// Format metadata key
  String _formatMetadataKey(String key) {
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  /// Format timestamp
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 7) {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
