import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../models/team_invitation_model.dart';

/// Invitation Actions Widget
/// Provides action buttons for team invitations based on context
class InvitationActions extends StatelessWidget {
  final TeamInvitationModel invitation;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;
  final VoidCallback? onCancel;
  final VoidCallback? onResend;
  final bool showAcceptDecline;
  final bool showCancelResend;
  final bool showHistoryOnly;

  const InvitationActions({
    super.key,
    required this.invitation,
    this.onAccept,
    this.onDecline,
    this.onCancel,
    this.onResend,
    this.showAcceptDecline = false,
    this.showCancelResend = false,
    this.showHistoryOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    if (showHistoryOnly) {
      return _buildHistoryActions(context);
    }
    
    if (showAcceptDecline) {
      return _buildAcceptDeclineActions(context);
    }
    
    if (showCancelResend) {
      return _buildCancelResendActions(context);
    }
    
    return const SizedBox.shrink();
  }

  Widget _buildAcceptDeclineActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onDecline,
            icon: const Icon(Icons.close, size: 18),
            label: const Text('Decline'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: BorderSide(color: AppColors.error),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.paddingMedium),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: onAccept,
            icon: const Icon(Icons.check, size: 18),
            label: const Text('Accept'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: AppColors.onSuccess,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCancelResendActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onCancel,
            icon: const Icon(Icons.cancel, size: 18),
            label: const Text('Cancel'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.warning,
              side: BorderSide(color: AppColors.warning),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.paddingMedium),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onResend,
            icon: const Icon(Icons.send, size: 18),
            label: const Text('Resend'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.outline.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            _getStatusIcon(),
            size: 16,
            color: _getStatusColor(),
          ),
          const SizedBox(width: AppDimensions.paddingSmall),
          Expanded(
            child: Text(
              _getStatusMessage(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: _getStatusColor(),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            _getFormattedDate(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon() {
    switch (invitation.status) {
      case InvitationStatus.accepted:
        return Icons.check_circle;
      case InvitationStatus.declined:
        return Icons.cancel;
      case InvitationStatus.cancelled:
        return Icons.block;
      case InvitationStatus.expired:
        return Icons.access_time;
      case InvitationStatus.pending:
        return Icons.schedule;
    }
  }

  Color _getStatusColor() {
    switch (invitation.status) {
      case InvitationStatus.accepted:
        return AppColors.success;
      case InvitationStatus.declined:
      case InvitationStatus.expired:
        return AppColors.error;
      case InvitationStatus.cancelled:
        return AppColors.textSecondary;
      case InvitationStatus.pending:
        return AppColors.warning;
    }
  }

  String _getStatusMessage() {
    switch (invitation.status) {
      case InvitationStatus.accepted:
        return 'Invitation was accepted';
      case InvitationStatus.declined:
        return 'Invitation was declined';
      case InvitationStatus.cancelled:
        return 'Invitation was cancelled';
      case InvitationStatus.expired:
        return 'Invitation expired';
      case InvitationStatus.pending:
        return 'Invitation is pending';
    }
  }

  String _getFormattedDate() {
    final date = invitation.updatedAt ?? invitation.createdAt;
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
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

  bool get hasActions {
    return showAcceptDecline || showCancelResend || showHistoryOnly;
  }
}
