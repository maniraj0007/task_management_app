import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/models/task_model.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/services/validation_service.dart';
import '../../controllers/task_controller.dart';

/// Task Form Widget
/// Comprehensive form for creating and editing tasks
class TaskFormWidget extends StatefulWidget {
  final TaskModel? task;
  final String? teamId;
  final String? projectId;
  final VoidCallback? onSaved;
  final VoidCallback? onCancelled;

  const TaskFormWidget({
    Key? key,
    this.task,
    this.teamId,
    this.projectId,
    this.onSaved,
    this.onCancelled,
  }) : super(key: key);

  @override
  State<TaskFormWidget> createState() => _TaskFormWidgetState();
}

class _TaskFormWidgetState extends State<TaskFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final TaskController _taskController = Get.find<TaskController>();
  
  // Form controllers
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _tagController;
  
  // Form state
  String _selectedPriority = 'medium';
  String _selectedStatus = 'todo';
  DateTime? _selectedDueDate;
  TimeOfDay? _selectedDueTime;
  final List<String> _selectedAssignees = [];
  final List<String> _tags = [];
  
  // UI state
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _tagController = TextEditingController();

    // Load existing task data if editing
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description ?? '';
      _selectedPriority = widget.task!.priority;
      _selectedStatus = widget.task!.status;
      _selectedDueDate = widget.task!.dueDate;
      _selectedAssignees.addAll(widget.task!.assignees);
      _tags.addAll(widget.task!.tags);
      
      if (_selectedDueDate != null) {
        _selectedDueTime = TimeOfDay.fromDateTime(_selectedDueDate!);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    widget.task == null ? Icons.add_task : Icons.edit_note,
                    size: 28,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.task == null ? 'Create New Task' : 'Edit Task',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: widget.onCancelled,
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Error message
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade600),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Title field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Task Title *',
                  hintText: 'Enter task title',
                  prefixIcon: Icon(Icons.title),
                  border: OutlineInputBorder(),
                ),
                validator: ValidationService.validateTaskTitle,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Description field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter task description',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
                validator: ValidationService.validateTaskDescription,
                maxLines: 3,
                textInputAction: TextInputAction.newline,
              ),
              const SizedBox(height: 16),

              // Priority and Status row
              Row(
                children: [
                  // Priority dropdown
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedPriority,
                      decoration: const InputDecoration(
                        labelText: 'Priority',
                        prefixIcon: Icon(Icons.flag),
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'low', child: Text('Low')),
                        DropdownMenuItem(value: 'medium', child: Text('Medium')),
                        DropdownMenuItem(value: 'high', child: Text('High')),
                        DropdownMenuItem(value: 'urgent', child: Text('Urgent')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedPriority = value);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Status dropdown
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedStatus,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        prefixIcon: Icon(Icons.radio_button_checked),
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'todo', child: Text('To Do')),
                        DropdownMenuItem(value: 'in_progress', child: Text('In Progress')),
                        DropdownMenuItem(value: 'review', child: Text('Review')),
                        DropdownMenuItem(value: 'completed', child: Text('Completed')),
                        DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedStatus = value);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Due date and time
              Row(
                children: [
                  // Due date
                  Expanded(
                    child: InkWell(
                      onTap: _selectDueDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Due Date',
                          prefixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          _selectedDueDate != null
                              ? '${_selectedDueDate!.day}/${_selectedDueDate!.month}/${_selectedDueDate!.year}'
                              : 'Select date',
                          style: TextStyle(
                            color: _selectedDueDate != null
                                ? Theme.of(context).textTheme.bodyLarge?.color
                                : Theme.of(context).hintColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Due time
                  Expanded(
                    child: InkWell(
                      onTap: _selectedDueDate != null ? _selectDueTime : null,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Due Time',
                          prefixIcon: const Icon(Icons.access_time),
                          border: const OutlineInputBorder(),
                          enabled: _selectedDueDate != null,
                        ),
                        child: Text(
                          _selectedDueTime != null
                              ? _selectedDueTime!.format(context)
                              : 'Select time',
                          style: TextStyle(
                            color: _selectedDueTime != null && _selectedDueDate != null
                                ? Theme.of(context).textTheme.bodyLarge?.color
                                : Theme.of(context).hintColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Assignees section
              _buildAssigneesSection(),
              const SizedBox(height: 16),

              // Tags section
              _buildTagsSection(),
              const SizedBox(height: 24),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading ? null : widget.onCancelled,
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveTask,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(widget.task == null ? 'Create Task' : 'Update Task'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAssigneesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.people, size: 20),
            const SizedBox(width: 8),
            Text(
              'Assignees',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _showAssigneeSelector,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_selectedAssignees.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'No assignees selected',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedAssignees.map((userId) {
              return Chip(
                avatar: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text(
                    userId.substring(0, 1).toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                label: Text(userId), // In real app, would show user name
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () {
                  setState(() => _selectedAssignees.remove(userId));
                },
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.label, size: 20),
            const SizedBox(width: 8),
            Text(
              'Tags',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _tagController,
                decoration: const InputDecoration(
                  hintText: 'Add a tag',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onFieldSubmitted: _addTag,
                textInputAction: TextInputAction.done,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => _addTag(_tagController.text),
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_tags.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _tags.map((tag) {
              return Chip(
                label: Text(tag),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () {
                  setState(() => _tags.remove(tag));
                },
              );
            }).toList(),
          ),
      ],
    );
  }

  Future<void> _selectDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        _selectedDueDate = date;
        if (_selectedDueTime != null) {
          _selectedDueDate = DateTime(
            date.year,
            date.month,
            date.day,
            _selectedDueTime!.hour,
            _selectedDueTime!.minute,
          );
        }
      });
    }
  }

  Future<void> _selectDueTime() async {
    if (_selectedDueDate == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: _selectedDueTime ?? TimeOfDay.now(),
    );

    if (time != null) {
      setState(() {
        _selectedDueTime = time;
        _selectedDueDate = DateTime(
          _selectedDueDate!.year,
          _selectedDueDate!.month,
          _selectedDueDate!.day,
          time.hour,
          time.minute,
        );
      });
    }
  }

  void _showAssigneeSelector() {
    // In a real app, this would show a user selection dialog
    // For now, we'll show a simple input dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Assignee'),
        content: const TextField(
          decoration: InputDecoration(
            hintText: 'Enter user ID or email',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Add assignee logic here
              Navigator.of(context).pop();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addTag(String tag) {
    final trimmedTag = tag.trim();
    if (trimmedTag.isNotEmpty && !_tags.contains(trimmedTag)) {
      setState(() {
        _tags.add(trimmedTag);
        _tagController.clear();
      });
    }
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final task = TaskModel(
        id: widget.task?.id ?? '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        status: _selectedStatus,
        priority: _selectedPriority,
        dueDate: _selectedDueDate,
        assignees: _selectedAssignees,
        tags: _tags,
        teamId: widget.teamId,
        projectId: widget.projectId,
        createdAt: widget.task?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: widget.task?.createdBy ?? 'current-user-id', // Get from auth service
      );

      bool success;
      if (widget.task == null) {
        success = await _taskController.createTask();
      } else {
        success = await _taskController.updateTask(widget.task!.id);
      }

      if (success) {
        widget.onSaved?.call();
      } else {
        setState(() {
          _errorMessage = _taskController.error;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
