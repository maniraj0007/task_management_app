import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/strings.dart';
import '../../../../core/enums/team_enums.dart';
import '../../../../core/utils/validators.dart';
import '../../controllers/team_controller.dart';
import '../widgets/team_form_fields.dart';
import '../widgets/visibility_selector.dart';

/// Create Team Screen
/// Complete team creation form with validation and integration
class CreateTeamScreen extends StatefulWidget {
  const CreateTeamScreen({super.key});

  @override
  State<CreateTeamScreen> createState() => _CreateTeamScreenState();
}

class _CreateTeamScreenState extends State<CreateTeamScreen> {
  final _formKey = GlobalKey<FormState>();
  final _teamController = Get.find<TeamController>();
  
  // Form controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _websiteController = TextEditingController();
  final _locationController = TextEditingController();
  
  // Form state
  TeamVisibility _selectedVisibility = TeamVisibility.private;
  int _maxMembers = 50;
  final List<String> _tags = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Initialize form with controller state
    _nameController.text = _teamController.teamName;
    _descriptionController.text = _teamController.teamDescription;
    _selectedVisibility = _teamController.teamVisibility;
    _websiteController.text = _teamController.teamWebsite;
    _locationController.text = _teamController.teamLocation;
    _maxMembers = _teamController.maxMembers;
    _tags.addAll(_teamController.teamTags);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _websiteController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Progress indicator
            Obx(() => _teamController.isCreatingTeam
                ? const LinearProgressIndicator()
                : const SizedBox.shrink()),
            
            // Form content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    _buildHeader(),
                    const SizedBox(height: AppDimensions.paddingLarge),
                    
                    // Basic Information
                    _buildBasicInfoSection(),
                    const SizedBox(height: AppDimensions.paddingLarge),
                    
                    // Team Settings
                    _buildTeamSettingsSection(),
                    const SizedBox(height: AppDimensions.paddingLarge),
                    
                    // Optional Information
                    _buildOptionalInfoSection(),
                    const SizedBox(height: AppDimensions.paddingLarge),
                    
                    // Tags Section
                    _buildTagsSection(),
                    const SizedBox(height: AppDimensions.paddingExtraLarge),
                  ],
                ),
              ),
            ),
            
            // Bottom action bar
            _buildBottomActionBar(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(AppStrings.createTeam),
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      elevation: 0,
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : _handleSubmit,
          child: Text(
            'Create',
            style: TextStyle(
              color: _isSubmitting 
                  ? AppColors.onPrimary.withOpacity(0.5)
                  : AppColors.onPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.groups,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: AppDimensions.paddingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create New Team',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Set up your team for collaboration',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        
        // Error display
        Obx(() {
          if (_teamController.error.isNotEmpty) {
            return Container(
              margin: const EdgeInsets.only(top: AppDimensions.paddingMedium),
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                border: Border.all(color: AppColors.error.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: AppColors.error, size: 20),
                  const SizedBox(width: AppDimensions.paddingSmall),
                  Expanded(
                    child: Text(
                      _teamController.error,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  Widget _buildBasicInfoSection() {
    return TeamFormFields(
      nameController: _nameController,
      descriptionController: _descriptionController,
      onNameChanged: (value) => _teamController.setTeamName(value),
      onDescriptionChanged: (value) => _teamController.setTeamDescription(value),
    );
  }

  Widget _buildTeamSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Team Settings',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingMedium),
        
        // Visibility Selector
        VisibilitySelector(
          selectedVisibility: _selectedVisibility,
          onVisibilityChanged: (visibility) {
            setState(() {
              _selectedVisibility = visibility;
            });
            _teamController.setTeamVisibility(visibility);
          },
        ),
        
        const SizedBox(height: AppDimensions.paddingLarge),
        
        // Max Members Slider
        _buildMaxMembersSlider(),
      ],
    );
  }

  Widget _buildMaxMembersSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Maximum Members',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _maxMembers.toString(),
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.primary.withOpacity(0.3),
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withOpacity(0.2),
          ),
          child: Slider(
            value: _maxMembers.toDouble(),
            min: 5,
            max: 200,
            divisions: 39,
            onChanged: (value) {
              setState(() {
                _maxMembers = value.round();
              });
              _teamController.setMaxMembers(_maxMembers);
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '5 members',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '200 members',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOptionalInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Optional Information',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingMedium),
        
        // Website field
        TextFormField(
          controller: _websiteController,
          decoration: InputDecoration(
            labelText: 'Website',
            hintText: 'https://example.com',
            prefixIcon: const Icon(Icons.language),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            ),
          ),
          keyboardType: TextInputType.url,
          onChanged: _teamController.setTeamWebsite,
        ),
        
        const SizedBox(height: AppDimensions.paddingMedium),
        
        // Location field
        TextFormField(
          controller: _locationController,
          decoration: InputDecoration(
            labelText: 'Location',
            hintText: 'San Francisco, CA',
            prefixIcon: const Icon(Icons.location_on),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            ),
          ),
          onChanged: _teamController.setTeamLocation,
        ),
      ],
    );
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tags',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton.icon(
              onPressed: _showAddTagDialog,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Tag'),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        
        if (_tags.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.paddingLarge),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              border: Border.all(color: AppColors.outline.withOpacity(0.5)),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.label_outline,
                  color: AppColors.textSecondary,
                  size: 32,
                ),
                const SizedBox(height: AppDimensions.paddingSmall),
                Text(
                  'No tags added yet',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  'Add tags to help categorize your team',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          )
        else
          Wrap(
            spacing: AppDimensions.paddingSmall,
            runSpacing: AppDimensions.paddingSmall,
            children: _tags.map((tag) => _buildTagChip(tag)).toList(),
          ),
      ],
    );
  }

  Widget _buildTagChip(String tag) {
    return Chip(
      label: Text(tag),
      deleteIcon: const Icon(Icons.close, size: 18),
      onDeleted: () => _removeTag(tag),
      backgroundColor: AppColors.primary.withOpacity(0.1),
      labelStyle: TextStyle(color: AppColors.primary),
      deleteIconColor: AppColors.primary,
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: AppDimensions.paddingMedium),
            Expanded(
              flex: 2,
              child: Obx(() => ElevatedButton(
                onPressed: _teamController.isCreatingTeam ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _teamController.isCreatingTeam
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.onPrimary),
                        ),
                      )
                    : const Text('Create Team'),
              )),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTagDialog() {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Tag'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter tag name',
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.words,
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              _addTag(value.trim());
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                _addTag(controller.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addTag(String tag) {
    if (!_tags.contains(tag) && _tags.length < 10) {
      setState(() {
        _tags.add(tag);
      });
      _teamController.addTeamTag(tag);
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
    _teamController.removeTeamTag(tag);
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isSubmitting = true;
    });
    
    try {
      final success = await _teamController.createTeam();
      if (success) {
        Navigator.pop(context);
        Get.snackbar(
          'Success',
          'Team created successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: AppColors.onSuccess,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
