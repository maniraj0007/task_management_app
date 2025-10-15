import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';

/// Team Search Bar Widget
/// Provides search functionality for teams
class TeamSearchBar extends StatefulWidget {
  final Function(String) onSearch;
  final VoidCallback onClear;
  final String? hintText;

  const TeamSearchBar({
    super.key,
    required this.onSearch,
    required this.onClear,
    this.hintText,
  });

  @override
  State<TeamSearchBar> createState() => _TeamSearchBarState();
}

class _TeamSearchBarState extends State<TeamSearchBar> {
  final TextEditingController _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
    widget.onSearch(_controller.text);
  }

  void _clearSearch() {
    _controller.clear();
    widget.onClear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: widget.hintText ?? 'Search teams...',
          hintStyle: TextStyle(
            color: AppColors.textSecondary,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.textSecondary,
          ),
          suffixIcon: _hasText
              ? IconButton(
                  onPressed: _clearSearch,
                  icon: Icon(
                    Icons.clear,
                    color: AppColors.textSecondary,
                  ),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingLarge,
            vertical: AppDimensions.paddingMedium,
          ),
        ),
        style: Theme.of(context).textTheme.bodyMedium,
        textInputAction: TextInputAction.search,
        onSubmitted: widget.onSearch,
      ),
    );
  }
}
