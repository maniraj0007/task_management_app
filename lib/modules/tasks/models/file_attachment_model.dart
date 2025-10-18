import 'package:cloud_firestore/cloud_firestore.dart';

/// File Attachment Model
/// Represents file attachments for tasks with metadata and version control
class FileAttachmentModel {
  final String id;
  final String taskId;
  final String fileName;
  final String originalFileName;
  final String fileExtension;
  final String mimeType;
  final int fileSizeBytes;
  final String downloadUrl;
  final String? thumbnailUrl;
  final String uploadedBy;
  final String uploaderName;
  final DateTime uploadedAt;
  final DateTime updatedAt;
  final String version; // Version string like "1.0", "1.1", etc.
  final String? description;
  final List<String> tags;
  final Map<String, dynamic> metadata;
  final bool isDeleted;

  FileAttachmentModel({
    required this.id,
    required this.taskId,
    required this.fileName,
    required this.originalFileName,
    required this.fileExtension,
    required this.mimeType,
    required this.fileSizeBytes,
    required this.downloadUrl,
    this.thumbnailUrl,
    required this.uploadedBy,
    required this.uploaderName,
    required this.uploadedAt,
    required this.updatedAt,
    this.version = '1.0',
    this.description,
    this.tags = const [],
    this.metadata = const {},
    this.isDeleted = false,
  });

  /// Create FileAttachmentModel from Firestore document
  factory FileAttachmentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return FileAttachmentModel(
      id: doc.id,
      taskId: data['taskId'] ?? '',
      fileName: data['fileName'] ?? '',
      originalFileName: data['originalFileName'] ?? '',
      fileExtension: data['fileExtension'] ?? '',
      mimeType: data['mimeType'] ?? '',
      fileSizeBytes: data['fileSizeBytes'] ?? 0,
      downloadUrl: data['downloadUrl'] ?? '',
      thumbnailUrl: data['thumbnailUrl'],
      uploadedBy: data['uploadedBy'] ?? '',
      uploaderName: data['uploaderName'] ?? '',
      uploadedAt: (data['uploadedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      version: data['version'] ?? '1.0',
      description: data['description'],
      tags: List<String>.from(data['tags'] ?? []),
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
      isDeleted: data['isDeleted'] ?? false,
    );
  }

  /// Create FileAttachmentModel from JSON
  factory FileAttachmentModel.fromJson(Map<String, dynamic> json) {
    return FileAttachmentModel(
      id: json['id'] ?? '',
      taskId: json['taskId'] ?? '',
      fileName: json['fileName'] ?? '',
      originalFileName: json['originalFileName'] ?? '',
      fileExtension: json['fileExtension'] ?? '',
      mimeType: json['mimeType'] ?? '',
      fileSizeBytes: json['fileSizeBytes'] ?? 0,
      downloadUrl: json['downloadUrl'] ?? '',
      thumbnailUrl: json['thumbnailUrl'],
      uploadedBy: json['uploadedBy'] ?? '',
      uploaderName: json['uploaderName'] ?? '',
      uploadedAt: json['uploadedAt'] != null 
          ? DateTime.parse(json['uploadedAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : DateTime.now(),
      version: json['version'] ?? '1.0',
      description: json['description'],
      tags: List<String>.from(json['tags'] ?? []),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      isDeleted: json['isDeleted'] ?? false,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'taskId': taskId,
      'fileName': fileName,
      'originalFileName': originalFileName,
      'fileExtension': fileExtension,
      'mimeType': mimeType,
      'fileSizeBytes': fileSizeBytes,
      'downloadUrl': downloadUrl,
      'thumbnailUrl': thumbnailUrl,
      'uploadedBy': uploadedBy,
      'uploaderName': uploaderName,
      'uploadedAt': uploadedAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'version': version,
      'description': description,
      'tags': tags,
      'metadata': metadata,
      'isDeleted': isDeleted,
    };
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'taskId': taskId,
      'fileName': fileName,
      'originalFileName': originalFileName,
      'fileExtension': fileExtension,
      'mimeType': mimeType,
      'fileSizeBytes': fileSizeBytes,
      'downloadUrl': downloadUrl,
      'thumbnailUrl': thumbnailUrl,
      'uploadedBy': uploadedBy,
      'uploaderName': uploaderName,
      'uploadedAt': Timestamp.fromDate(uploadedAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'version': version,
      'description': description,
      'tags': tags,
      'metadata': metadata,
      'isDeleted': isDeleted,
    };
  }

  /// Create a copy with updated fields
  FileAttachmentModel copyWith({
    String? id,
    String? taskId,
    String? fileName,
    String? originalFileName,
    String? fileExtension,
    String? mimeType,
    int? fileSizeBytes,
    String? downloadUrl,
    String? thumbnailUrl,
    String? uploadedBy,
    String? uploaderName,
    DateTime? uploadedAt,
    DateTime? updatedAt,
    String? version,
    String? description,
    List<String>? tags,
    Map<String, dynamic>? metadata,
    bool? isDeleted,
  }) {
    return FileAttachmentModel(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      fileName: fileName ?? this.fileName,
      originalFileName: originalFileName ?? this.originalFileName,
      fileExtension: fileExtension ?? this.fileExtension,
      mimeType: mimeType ?? this.mimeType,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      uploaderName: uploaderName ?? this.uploaderName,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  /// Get file type category
  String get fileTypeCategory {
    switch (fileExtension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'bmp':
      case 'webp':
        return 'image';
      case 'pdf':
        return 'pdf';
      case 'doc':
      case 'docx':
        return 'document';
      case 'xls':
      case 'xlsx':
        return 'spreadsheet';
      case 'ppt':
      case 'pptx':
        return 'presentation';
      case 'txt':
      case 'md':
        return 'text';
      case 'mp4':
      case 'avi':
      case 'mov':
      case 'wmv':
        return 'video';
      case 'mp3':
      case 'wav':
      case 'flac':
        return 'audio';
      case 'zip':
      case 'rar':
      case '7z':
        return 'archive';
      default:
        return 'other';
    }
  }

  /// Get file icon based on type
  String get fileIcon {
    switch (fileTypeCategory) {
      case 'image':
        return '🖼️';
      case 'pdf':
        return '📄';
      case 'document':
        return '📝';
      case 'spreadsheet':
        return '📊';
      case 'presentation':
        return '📽️';
      case 'text':
        return '📃';
      case 'video':
        return '🎥';
      case 'audio':
        return '🎵';
      case 'archive':
        return '📦';
      default:
        return '📎';
    }
  }

  /// Get formatted file size
  String get formattedFileSize {
    if (fileSizeBytes < 1024) {
      return '$fileSizeBytes B';
    } else if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    } else if (fileSizeBytes < 1024 * 1024 * 1024) {
      return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(fileSizeBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  /// Get formatted upload date
  String get formattedUploadDate {
    final now = DateTime.now();
    final difference = now.difference(uploadedAt);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${uploadedAt.day}/${uploadedAt.month}/${uploadedAt.year}';
    }
  }

  /// Check if file is an image
  bool get isImage => fileTypeCategory == 'image';

  /// Check if file is a document
  bool get isDocument => ['pdf', 'document', 'spreadsheet', 'presentation', 'text'].contains(fileTypeCategory);

  /// Check if file is a video
  bool get isVideo => fileTypeCategory == 'video';

  /// Check if file is an audio file
  bool get isAudio => fileTypeCategory == 'audio';

  /// Check if file can be previewed
  bool get canPreview => isImage || fileTypeCategory == 'pdf' || fileTypeCategory == 'text';

  /// Get display name (truncated if too long)
  String get displayName {
    if (originalFileName.length <= 30) {
      return originalFileName;
    }
    return '${originalFileName.substring(0, 27)}...';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is FileAttachmentModel &&
        other.id == id &&
        other.taskId == taskId &&
        other.fileName == fileName &&
        other.version == version;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        taskId.hashCode ^
        fileName.hashCode ^
        version.hashCode;
  }

  @override
  String toString() {
    return 'FileAttachmentModel(id: $id, taskId: $taskId, fileName: $fileName, version: $version)';
  }
}

/// File Upload Progress Model
/// Tracks file upload progress for UI feedback
class FileUploadProgress {
  final String fileName;
  final int totalBytes;
  final int uploadedBytes;
  final double progress;
  final String status; // uploading, completed, error
  final String? error;

  FileUploadProgress({
    required this.fileName,
    required this.totalBytes,
    required this.uploadedBytes,
    required this.progress,
    required this.status,
    this.error,
  });

  FileUploadProgress copyWith({
    String? fileName,
    int? totalBytes,
    int? uploadedBytes,
    double? progress,
    String? status,
    String? error,
  }) {
    return FileUploadProgress(
      fileName: fileName ?? this.fileName,
      totalBytes: totalBytes ?? this.totalBytes,
      uploadedBytes: uploadedBytes ?? this.uploadedBytes,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }

  bool get isCompleted => status == 'completed';
  bool get isError => status == 'error';
  bool get isUploading => status == 'uploading';

  String get formattedProgress => '${(progress * 100).toInt()}%';

  @override
  String toString() {
    return 'FileUploadProgress(fileName: $fileName, progress: $progress, status: $status)';
  }
}
