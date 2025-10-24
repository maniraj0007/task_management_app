import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/utils/validators.dart';

/// Team Form Fields Widget
/// Reusable form fields for team creation and editing
class TeamFormFields extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final Function(String) onNameChanged;
  final Function(String) onDescriptionChanged;
  final bool isEditing;

  const TeamFormFields({
    super.key,
    required this.nameController,
    required this.descriptionController,
    required this.onNameChanged,
    required this.onDescriptionChanged,
    this.isEditing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Basic Information',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingMedium),
        
        // Team Name Field
        TextFormField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: 'Team Name *',
            hintText: 'Enter your team name',
            prefixIcon: const Icon(Icons.groups),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
          validator: Validators.validateTeamName,
          textCapitalization: TextCapitalization.words,
          onChanged: onNameChanged,
        ),
        
        const SizedBox(height: AppDimensions.paddingMedium),
        
        // Team Description Field
        TextFormField(
          controller: descriptionController,
          decoration: InputDecoration(
            labelText: 'Team Description *',
            hintText: 'Describe what your team does',
            prefixIcon: const Icon(Icons.description),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            alignLabelWithHint: true,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Team description is required';
            }
            if (value.trim().length < 10) {
              return 'Description must be at least 10 characters long';
            }
            if (value.trim().length > 500) {
              return 'Description must be less than 500 characters';
            }
            return null;
          },
          maxLines: 3,
          maxLength: 500,
          textCapitalization: TextCapitalization.sentences,
          onChanged: onDescriptionChanged,
        ),
        
        // Helper text
        Padding(
          padding: const EdgeInsets.only(top: AppDimensions.paddingSmall),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppDimensions.paddingSmall),
              Expanded(
                child: Text(
                  'Choose a clear name and description to help others understand your team\'s purpose.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
