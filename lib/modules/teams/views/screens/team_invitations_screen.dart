import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/strings.dart';
import '../../../../core/enums/team_enums.dart';
import '../../controllers/team_member_controller.dart';
import '../../models/team_invitation_model.dart';
import '../widgets/invitation_card.dart';
import '../widgets/invitation_actions.dart';

/// Team Invitations Screen
/// Complete invitation workflow interface for managing team invitations
class TeamInvitationsScreen extends StatefulWidget {
  const TeamInvitationsScreen({super.key});

  @override
  State<TeamInvitationsScreen> createState() => _TeamInvitationsScreenState();
}

class _TeamInvitationsScreenState extends State<TeamInvitationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _memberController = Get.find<TeamMemberController>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadInvitations();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadInvitations() async {
    await _memberController.loadUserInvitations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Stats Header
          _buildStatsHeader(),
          
          // Tab Bar
          _buildTabBar(),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPendingTab(),
                _buildSentTab(),
                _buildHistoryTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Team Invitations'),
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      elevation: 0,
      actions: [
        IconButton(
          onPressed: _loadInvitations,
          icon: const Icon(Icons.refresh),
        ),
      ],
    );
  }

  Widget _buildStatsHeader() {
    return Obx(() => Container(
      margin: const EdgeInsets.all(AppDimensions.paddingMedium),
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.secondary,
            AppColors.secondary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.mail,
                color: AppColors.onSecondary,
                size: 28,
              ),
              const SizedBox(width: AppDimensions.paddingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Invitation Overview',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.onSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Manage your team invitations',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSecondary.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppDimensions.paddingLarge),
          
          // Stats Grid
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Pending',
                  _memberController.pendingInvitationsCount.toString(),
                  Icons.schedule,
                  AppColors.warning,
                ),
              ),
              const SizedBox(width: AppDimensions.paddingMedium),
              Expanded(
                child: _buildStatCard(
                  'Sent',
                  _memberController.sentInvitationsCount.toString(),
                  Icons.send,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: AppDimensions.paddingMedium),
              Expanded(
                child: _buildStatCard(
                  'Total',
                  _memberController.totalInvitationsCount.toString(),
                  Icons.mail_outline,
                  AppColors.onSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    ));
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.onSecondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(
          color: AppColors.onSecondary.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.onSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.onSecondary.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppColors.surface,
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primary,
        tabs: [
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Pending'),
                const SizedBox(width: 4),
                Obx(() {
                  final count = _memberController.pendingInvitationsCount;
                  if (count > 0) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        count.toString(),
                        style: const TextStyle(
                          color: AppColors.onError,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ],
            ),
          ),
          const Tab(text: 'Sent'),
          const Tab(text: 'History'),
        ],
      ),
    );
  }

  Widget _buildPendingTab() {
    return Obx(() {
      final pendingInvitations = _memberController.pendingInvitations;
      
      if (_memberController.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }
      
      if (pendingInvitations.isEmpty) {
        return _buildEmptyState(
          'No Pending Invitations',
          'You have no pending team invitations',
          Icons.inbox_outlined,
        );
      }
      
      return RefreshIndicator(
        onRefresh: _loadInvitations,
        child: ListView.builder(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          itemCount: pendingInvitations.length,
          itemBuilder: (context, index) {
            final invitation = pendingInvitations[index];
            return InvitationCard(
              invitation: invitation,
              actions: InvitationActions(
                invitation: invitation,
                onAccept: () => _acceptInvitation(invitation),
                onDecline: () => _declineInvitation(invitation),
                showAcceptDecline: true,
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildSentTab() {
    return Obx(() {
      final sentInvitations = _memberController.sentInvitations;
      
      if (_memberController.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }
      
      if (sentInvitations.isEmpty) {
        return _buildEmptyState(
          'No Sent Invitations',
          'You haven\'t sent any team invitations yet',
          Icons.send_outlined,
        );
      }
      
      return RefreshIndicator(
        onRefresh: _loadInvitations,
        child: ListView.builder(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          itemCount: sentInvitations.length,
          itemBuilder: (context, index) {
            final invitation = sentInvitations[index];
            return InvitationCard(
              invitation: invitation,
              actions: InvitationActions(
                invitation: invitation,
                onCancel: () => _cancelInvitation(invitation),
                onResend: () => _resendInvitation(invitation),
                showCancelResend: true,
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildHistoryTab() {
    return Obx(() {
      final allInvitations = _memberController.allInvitations;
      
      if (_memberController.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }
      
      if (allInvitations.isEmpty) {
        return _buildEmptyState(
          'No Invitation History',
          'Your invitation history will appear here',
          Icons.history_outlined,
        );
      }
      
      return RefreshIndicator(
        onRefresh: _loadInvitations,
        child: ListView.builder(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          itemCount: allInvitations.length,
          itemBuilder: (context, index) {
            final invitation = allInvitations[index];
            return InvitationCard(
              invitation: invitation,
              actions: InvitationActions(
                invitation: invitation,
                showHistoryOnly: true,
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppDimensions.paddingLarge),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Action handlers
  Future<void> _acceptInvitation(TeamInvitationModel invitation) async {
    try {
      await _memberController.acceptInvitation(invitation.id);
      Get.snackbar(
        'Success',
        'Invitation accepted! Welcome to ${invitation.teamName}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: AppColors.onSuccess,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to accept invitation: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.onError,
      );
    }
  }

  Future<void> _declineInvitation(TeamInvitationModel invitation) async {
    final confirmed = await _showConfirmationDialog(
      'Decline Invitation',
      'Are you sure you want to decline the invitation to join "${invitation.teamName}"?',
      'Decline',
      AppColors.error,
    );
    
    if (confirmed) {
      try {
        await _memberController.declineInvitation(invitation.id);
        Get.snackbar(
          'Declined',
          'Invitation declined',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.warning,
          colorText: AppColors.onWarning,
        );
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to decline invitation: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: AppColors.onError,
        );
      }
    }
  }

  Future<void> _cancelInvitation(TeamInvitationModel invitation) async {
    final confirmed = await _showConfirmationDialog(
      'Cancel Invitation',
      'Are you sure you want to cancel the invitation sent to "${invitation.inviteeEmail}"?',
      'Cancel',
      AppColors.warning,
    );
    
    if (confirmed) {
      try {
        await _memberController.cancelInvitation(invitation.id);
        Get.snackbar(
          'Cancelled',
          'Invitation cancelled',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.warning,
          colorText: AppColors.onWarning,
        );
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to cancel invitation: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: AppColors.onError,
        );
      }
    }
  }

  Future<void> _resendInvitation(TeamInvitationModel invitation) async {
    try {
      await _memberController.resendInvitation(invitation.id);
      Get.snackbar(
        'Resent',
        'Invitation resent to ${invitation.inviteeEmail}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: AppColors.onSuccess,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to resend invitation: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.onError,
      );
    }
  }

  Future<bool> _showConfirmationDialog(
    String title,
    String content,
    String actionText,
    Color actionColor,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: actionColor,
              foregroundColor: actionColor == AppColors.warning 
                  ? AppColors.onWarning 
                  : AppColors.onError,
            ),
            child: Text(actionText),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }
}
