import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';

/// Task Form Field Widget
/// Reusable form field for task creation and editing
class TaskFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? Function(String?)? validator;
  final bool required;
  final bool enabled;
  final int maxLines;
  final int? maxLength;
  final TextInputType keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final bool readOnly;

  const TaskFormField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.validator,
    this.required = false,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.onTap,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        RichText(
          text: TextSpan(
            text: label,
            style: Get.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            children: [
              if (required)
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: Colors.red[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
        
        const SizedBox(height: AppDimensions.paddingSmall),
        
        // Text field
        TextFormField(
          controller: controller,
          validator: validator,
          enabled: enabled,
          maxLines: maxLines,
          maxLength: maxLength,
          keyboardType: keyboardType,
          onTap: onTap,
          readOnly: readOnly,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
              borderSide: BorderSide(color: Colors.red[600]!, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
              borderSide: BorderSide(color: Colors.red[600]!, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            filled: true,
            fillColor: enabled ? Colors.white : Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingMedium,
              vertical: AppDimensions.paddingMedium,
            ),
            counterStyle: Get.textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          style: Get.textTheme.bodyMedium,
        ),
      ],
    );
  }
}

