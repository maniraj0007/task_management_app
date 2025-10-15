import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/strings.dart';

/// Create Team Screen
/// Screen for creating new teams
class CreateTeamScreen extends StatelessWidget {
  const CreateTeamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.createTeam),
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
              'Create Team Screen',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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
