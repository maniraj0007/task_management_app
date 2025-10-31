import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

/// Create Team FAB Widget
/// Floating action button for creating new teams
class CreateTeamFAB extends StatelessWidget {
  final VoidCallback onPressed;

  const CreateTeamFAB({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      icon: const Icon(Icons.add),
      label: const Text('Create Team'),
      elevation: 4,
      extendedPadding: const EdgeInsets.symmetric(horizontal: 20),
    );
  }
}
