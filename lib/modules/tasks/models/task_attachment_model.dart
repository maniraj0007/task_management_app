import 'package:cloud_firestore/cloud_firestore.dart';

/// Task attachment model for the multi-admin task management system
/// Represents a file attachment on a task
class TaskAttachmentModel {
  final String id;
  final String taskId;
  final String fileName;
  final String originalFileName;
  final String fileExtension;
  final String mimeType;
  final int fileSize;
  final String downloadUrl;
  final String storagePath;
  final String uploadedBy;
  final String uploaderName;
  final String? uploaderPhotoUrl;
  final DateTime uploadedAt;
  final DateTime? updatedAt;
  final bool isDeleted;
  final DateTime? deletedAt;
  final String? deletedBy;
  final Map<String, dynamic> metadata;
  final String? description;
  final List<String> tags;
  final String? thumbnailUrl;
  final Map<String, dynamic>? imageMetadata;
  final bool isPublic;
  final DateTime? expiresAt;
  final int downloadCount;
  final DateTime? lastDownloadAt;
  final String? lastDownloadBy;

  const TaskAttachmentModel({
    required this.id,
    required this.taskId,
    required this.fileName,
    required this.originalFileName,
    required this.fileExtension,
    required this.mimeType,
    required this.fileSize,
    required this.downloadUrl,
    required this.storagePath,
    required this.uploadedBy,
    required this.uploaderName,
    this.uploaderPhotoUrl,
    required this.uploadedAt,
    this.updatedAt,
    this.isDeleted = false,
    this.deletedAt,
    this.deletedBy,
    this.metadata = const {},
    this.description,
    this.tags = const [],
    this.thumbnailUrl,
    this.imageMetadata,
    this.isPublic = false,
    this.expiresAt,
    this.downloadCount = 0,
    this.lastDownloadAt,
    this.lastDownloadBy,
  });

  /// Check if attachment is an image
  bool get isImage {
    return mimeType.startsWith('image/');
  }

  /// Check if attachment is a video
  bool get isVideo {
    return mimeType.startsWith('video/');
  }

  /// Check if attachment is an audio file
  bool get isAudio {
    return mimeType.startsWith('audio/');
  }

  /// Check if attachment is a document
  bool get isDocument {
    const documentTypes = [
      'application/pdf',
      'application/msword',
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'application/vnd.ms-excel',
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'application/vnd.ms-powerpoint',
      'application/vnd.openxmlformats-officedocument.presentationml.presentation',
      'text/plain',
      'text/csv',
    ];
    return documentTypes.contains(mimeType);
  }

  /// Check if attachment is an archive
  bool get isArchive {
    const archiveTypes = [
      'application/zip',
      'application/x-rar-compressed',
      'application/x-7z-compressed',
      'application/x-tar',
      'application/gzip',
    ];
    return archiveTypes.contains(mimeType);
  }

  /// Check if attachment has expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Check if attachment has thumbnail
  bool get hasThumbnail => thumbnailUrl != null;

  /// Get file size in human readable format
  String get fileSizeFormatted {
    if (fileSize < 1024) {
      return '$fileSize B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    } else if (fileSize < 1024 * 1024 * 1024) {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  /// Get file type category
  String get fileTypeCategory {
    if (isImage) return 'Image';
    if (isVideo) return 'Video';
    if (isAudio) return 'Audio';
    if (isDocument) return 'Document';
    if (isArchive) return 'Archive';
    return 'File';
  }

  /// Get file icon name based on type
  String get fileIconName {
    if (isImage) return 'image';
    if (isVideo) return 'video_file';
    if (isAudio) return 'audio_file';
    if (isDocument) {
      switch (fileExtension.toLowerCase()) {
        case 'pdf':
          return 'picture_as_pdf';
        case 'doc':
        case 'docx':
          return 'description';
        case 'xls':
        case 'xlsx':
          return 'table_chart';
        case 'ppt':
        case 'pptx':
          return 'slideshow';
        default:
          return 'description';
      }
    }
    if (isArchive) return 'folder_zip';
    return 'attach_file';
  }

  /// Get attachment age in days
  int get ageInDays {
    return DateTime.now().difference(uploadedAt).inDays;
  }

  /// Check if user can delete this attachment
  bool canBeDeletedByUser(String userId) {
    return uploadedBy == userId && !isDeleted;
  }

  /// Create a copy with updated fields
  TaskAttachmentModel copyWith({
    String? id,
    String? taskId,
    String? fileName,
    String? originalFileName,
    String? fileExtension,
    String? mimeType,
    int? fileSize,
    String? downloadUrl,
    String? storagePath,
    String? uploadedBy,
    String? uploaderName,
    String? uploaderPhotoUrl,
    DateTime? uploadedAt,
    DateTime? updatedAt,
    bool? isDeleted,
    DateTime? deletedAt,
    String? deletedBy,
    Map<String, dynamic>? metadata,
    String? description,
    List<String>? tags,
    String? thumbnailUrl,
    Map<String, dynamic>? imageMetadata,
    bool? isPublic,
    DateTime? expiresAt,
    int? downloadCount,
    DateTime? lastDownloadAt,
    String? lastDownloadBy,
  }) {
    return TaskAttachmentModel(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      fileName: fileName ?? this.fileName,
      originalFileName: originalFileName ?? this.originalFileName,
      fileExtension: fileExtension ?? this.fileExtension,
      mimeType: mimeType ?? this.mimeType,
      fileSize: fileSize ?? this.fileSize,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      storagePath: storagePath ?? this.storagePath,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      uploaderName: uploaderName ?? this.uploaderName,
      uploaderPhotoUrl: uploaderPhotoUrl ?? this.uploaderPhotoUrl,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      deletedBy: deletedBy ?? this.deletedBy,
      metadata: metadata ?? this.metadata,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      imageMetadata: imageMetadata ?? this.imageMetadata,
      isPublic: isPublic ?? this.isPublic,
      expiresAt: expiresAt ?? this.expiresAt,
      downloadCount: downloadCount ?? this.downloadCount,
      lastDownloadAt: lastDownloadAt ?? this.lastDownloadAt,
      lastDownloadBy: lastDownloadBy ?? this.lastDownloadBy,
    );
  }

  /// Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'taskId': taskId,
      'fileName': fileName,
      'originalFileName': originalFileName,
      'fileExtension': fileExtension,
      'mimeType': mimeType,
      'fileSize': fileSize,
      'downloadUrl': downloadUrl,
      'storagePath': storagePath,
      'uploadedBy': uploadedBy,
      'uploaderName': uploaderName,
      'uploaderPhotoUrl': uploaderPhotoUrl,
      'uploadedAt': Timestamp.fromDate(uploadedAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'isDeleted': isDeleted,
      'deletedAt': deletedAt != null ? Timestamp.fromDate(deletedAt!) : null,
      'deletedBy': deletedBy,
      'metadata': metadata,
      'description': description,
      'tags': tags,
      'thumbnailUrl': thumbnailUrl,
      'imageMetadata': imageMetadata,
      'isPublic': isPublic,
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
      'downloadCount': downloadCount,
      'lastDownloadAt': lastDownloadAt != null ? Timestamp.fromDate(lastDownloadAt!) : null,
      'lastDownloadBy': lastDownloadBy,
    };
  }

  /// Create from JSON (Firestore document)
  factory TaskAttachmentModel.fromJson(Map<String, dynamic> json) {
    return TaskAttachmentModel(
      id: json['id'] ?? '',
      taskId: json['taskId'] ?? '',
      fileName: json['fileName'] ?? '',
      originalFileName: json['originalFileName'] ?? '',
      fileExtension: json['fileExtension'] ?? '',
      mimeType: json['mimeType'] ?? '',
      fileSize: json['fileSize'] ?? 0,
      downloadUrl: json['downloadUrl'] ?? '',
      storagePath: json['storagePath'] ?? '',
      uploadedBy: json['uploadedBy'] ?? '',
      uploaderName: json['uploaderName'] ?? '',
      uploaderPhotoUrl: json['uploaderPhotoUrl'],
      uploadedAt: (json['uploadedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate(),
      isDeleted: json['isDeleted'] ?? false,
      deletedAt: (json['deletedAt'] as Timestamp?)?.toDate(),
      deletedBy: json['deletedBy'],
      metadata: json['metadata']?.cast<String, dynamic>() ?? {},
      description: json['description'],
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      thumbnailUrl: json['thumbnailUrl'],
      imageMetadata: json['imageMetadata']?.cast<String, dynamic>(),
      isPublic: json['isPublic'] ?? false,
      expiresAt: (json['expiresAt'] as Timestamp?)?.toDate(),
      downloadCount: json['downloadCount'] ?? 0,
      lastDownloadAt: (json['lastDownloadAt'] as Timestamp?)?.toDate(),
      lastDownloadBy: json['lastDownloadBy'],
    );
  }

  /// Create a new attachment
  factory TaskAttachmentModel.create({
    required String taskId,
    required String fileName,
    required String originalFileName,
    required String fileExtension,
    required String mimeType,
    required int fileSize,
    required String downloadUrl,
    required String storagePath,
    required String uploadedBy,
    required String uploaderName,
    String? uploaderPhotoUrl,
    String? description,
    List<String>? tags,
    String? thumbnailUrl,
    Map<String, dynamic>? imageMetadata,
    bool isPublic = false,
    DateTime? expiresAt,
  }) {
    final now = DateTime.now();
    return TaskAttachmentModel(
      id: '', // Will be set by Firestore
      taskId: taskId,
      fileName: fileName,
      originalFileName: originalFileName,
      fileExtension: fileExtension,
      mimeType: mimeType,
      fileSize: fileSize,
      downloadUrl: downloadUrl,
      storagePath: storagePath,
      uploadedBy: uploadedBy,
      uploaderName: uploaderName,
      uploaderPhotoUrl: uploaderPhotoUrl,
      uploadedAt: now,
      updatedAt: now,
      description: description,
      tags: tags ?? [],
      thumbnailUrl: thumbnailUrl,
      imageMetadata: imageMetadata,
      isPublic: isPublic,
      expiresAt: expiresAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaskAttachmentModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'TaskAttachmentModel(id: $id, fileName: $fileName, fileSize: $fileSizeFormatted, type: $fileTypeCategory)';
  }
}
