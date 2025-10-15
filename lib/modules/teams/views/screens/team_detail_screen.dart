import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/strings.dart';

/// Team Detail Screen
/// Displays detailed information about a specific team
class TeamDetailScreen extends StatelessWidget {
  final String teamId;

  const TeamDetailScreen({
    super.key,
    required this.teamId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Team Details'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 80,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 20),
            Text(
              'Team Detail Screen',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Team ID: $teamId',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Coming Soon!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
