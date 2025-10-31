import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/models/user_model.dart';
import '../models/task_comment_model.dart';
import '../services/task_comments_service.dart';

/// Task Comments Widget
/// Displays and manages task comments with threading and real-time updates
class TaskCommentsWidget extends StatefulWidget {
  final String taskId;
  final bool showHeader;
  final int maxHeight;

  const TaskCommentsWidget({
    Key? key,
    required this.taskId,
    this.showHeader = true,
    this.maxHeight = 400,
  }) : super(key: key);

  @override
  State<TaskCommentsWidget> createState() => _TaskCommentsWidgetState();
}

class _TaskCommentsWidgetState extends State<TaskCommentsWidget> {
  final TaskCommentsService _commentsService = Get.find<TaskCommentsService>();
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  String? _replyingToCommentId;
  String? _editingCommentId;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: widget.maxHeight.toDouble()),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          if (widget.showHeader) _buildHeader(),
          
          // Comments list
          Expanded(child: _buildCommentsList()),
          
          // Comment input
          _buildCommentInput(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.comment,
            color: Theme.of(context).primaryColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Comments',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const Spacer(),
          Obx(() {
            final comments = _commentsService.getTaskCommentsStream(widget.taskId);
            return Text(
              '${comments.length}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCommentsList() {
    return Obx(() {
      final comments = _commentsService.getTaskCommentsStream(widget.taskId);
      
      if (_commentsService.isLoading && comments.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      if (comments.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.comment_outlined,
                size: 48,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 16),
              Text(
                'No comments yet',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Be the first to comment on this task',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        );
      }

      // Get threaded comments
      final threadedComments = _commentsService.getThreadedComments(comments);

      return ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: threadedComments.length,
        itemBuilder: (context, index) {
          final comment = threadedComments[index];
          return Padding(
            padding: EdgeInsets.only(
              bottom: 12,
              left: comment.isReply ? 32 : 0,
            ),
            child: _buildCommentCard(comment),
          );
        },
      );
    });
  }

  Widget _buildCommentCard(TaskCommentModel comment) {
    final isEditing = _editingCommentId == comment.id;
    
    return Card(
      elevation: comment.isReply ? 1 : 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: comment.isReply 
            ? BorderSide(color: Colors.grey.shade200)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Comment header
            Row(
              children: [
                // Author avatar
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Theme.of(context).primaryColor,
                  backgroundImage: comment.authorAvatar != null 
                      ? NetworkImage(comment.authorAvatar!)
                      : null,
                  child: comment.authorAvatar == null
                      ? Text(
                          comment.authorName.isNotEmpty 
                              ? comment.authorName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 8),
                
                // Author name and timestamp
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            comment.authorName,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (comment.isEdited) ...[
                            const SizedBox(width: 4),
                            Text(
                              '(edited)',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        comment.formattedCreatedAt,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Actions menu
                PopupMenuButton<String>(
                  onSelected: (value) => _handleCommentAction(value, comment),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'reply',
                      child: ListTile(
                        leading: Icon(Icons.reply, size: 20),
                        title: Text('Reply'),
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                    ),
                    if (_canEditComment(comment))
                      const PopupMenuItem(
                        value: 'edit',
                        child: ListTile(
                          leading: Icon(Icons.edit, size: 20),
                          title: Text('Edit'),
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                        ),
                      ),
                    if (_canDeleteComment(comment))
                      const PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete, color: Colors.red, size: 20),
                          title: Text('Delete', style: TextStyle(color: Colors.red)),
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                        ),
                      ),
                  ],
                  child: Icon(
                    Icons.more_vert,
                    size: 18,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Comment content
            if (isEditing)
              _buildEditCommentField(comment)
            else
              _buildCommentContent(comment),
            
            // Attachments
            if (comment.hasAttachments && !isEditing) ...[
              const SizedBox(height: 8),
              _buildAttachments(comment.attachments),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCommentContent(TaskCommentModel comment) {
    return SelectableText(
      comment.content,
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }

  Widget _buildEditCommentField(TaskCommentModel comment) {
    final controller = TextEditingController(text: comment.content);
    
    return Column(
      children: [
        TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Edit your comment...',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.all(12),
          ),
          maxLines: 3,
          autofocus: true,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {
                setState(() {
                  _editingCommentId = null;
                });
                controller.dispose();
              },
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => _updateComment(comment.id, controller.text),
              child: const Text('Save'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAttachments(List<String> attachments) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: attachments.map((attachment) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.attachment,
                size: 16,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 4),
              Text(
                'Attachment',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reply indicator
          if (_replyingToCommentId != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.reply,
                    size: 16,
                    color: Colors.blue.shade600,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Replying to comment',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _replyingToCommentId = null;
                      });
                    },
                    child: Icon(
                      Icons.close,
                      size: 16,
                      color: Colors.blue.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
          
          // Comment input field
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: _replyingToCommentId != null 
                        ? 'Write a reply...' 
                        : 'Write a comment...',
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.all(12),
                    suffixIcon: _isSubmitting
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : null,
                  ),
                  maxLines: 3,
                  minLines: 1,
                  textInputAction: TextInputAction.newline,
                  onSubmitted: (_) => _submitComment(),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitComment,
                child: const Text('Send'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleCommentAction(String action, TaskCommentModel comment) {
    switch (action) {
      case 'reply':
        setState(() {
          _replyingToCommentId = comment.isReply ? comment.parentCommentId : comment.id;
        });
        break;
      case 'edit':
        setState(() {
          _editingCommentId = comment.id;
        });
        break;
      case 'delete':
        _deleteComment(comment.id);
        break;
    }
  }

  Future<void> _submitComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty || _isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final success = await _commentsService.createComment(
        taskId: widget.taskId,
        content: content,
        parentCommentId: _replyingToCommentId,
      );

      if (success != null) {
        _commentController.clear();
        setState(() {
          _replyingToCommentId = null;
        });
        
        // Scroll to bottom to show new comment
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Future<void> _updateComment(String commentId, String content) async {
    if (content.trim().isEmpty) return;

    final success = await _commentsService.updateComment(
      commentId: commentId,
      content: content.trim(),
    );

    if (success != null) {
      setState(() {
        _editingCommentId = null;
      });
    }
  }

  Future<void> _deleteComment(String commentId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Comment'),
        content: const Text('Are you sure you want to delete this comment? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _commentsService.deleteComment(commentId);
    }
  }

  bool _canEditComment(TaskCommentModel comment) {
    // Users can edit their own comments
    // In a real app, you'd check against the current user ID
    return true; // Simplified for demo
  }

  bool _canDeleteComment(TaskCommentModel comment) {
    // Users can delete their own comments
    // In a real app, you'd check against the current user ID
    return true; // Simplified for demo
  }
}
