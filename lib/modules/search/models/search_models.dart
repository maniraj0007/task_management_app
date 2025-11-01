import 'package:cloud_firestore/cloud_firestore.dart';

/// Search Result Model
/// Represents a search result item with relevance scoring
class SearchResultModel {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final SearchResultType type;
  final double relevanceScore;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic> metadata;
  final List<String> tags;
  final String? imageUrl;
  final String? actionUrl;

  const SearchResultModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.type,
    required this.relevanceScore,
    this.createdAt,
    this.updatedAt,
    this.metadata = const {},
    this.tags = const [],
    this.imageUrl,
    this.actionUrl,
  });

  /// Create from JSON
  factory SearchResultModel.fromJson(Map<String, dynamic> json) {
    return SearchResultModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      description: json['description'] ?? '',
      type: SearchResultType.fromString(json['type'] ?? 'other'),
      relevanceScore: (json['relevanceScore'] ?? 0.0).toDouble(),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'])
          : null,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      tags: List<String>.from(json['tags'] ?? []),
      imageUrl: json['imageUrl'],
      actionUrl: json['actionUrl'],
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'type': type.value,
      'relevanceScore': relevanceScore,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'metadata': metadata,
      'tags': tags,
      'imageUrl': imageUrl,
      'actionUrl': actionUrl,
    };
  }

  /// Create copy with updated fields
  SearchResultModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? description,
    SearchResultType? type,
    double? relevanceScore,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
    List<String>? tags,
    String? imageUrl,
    String? actionUrl,
  }) {
    return SearchResultModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      description: description ?? this.description,
      type: type ?? this.type,
      relevanceScore: relevanceScore ?? this.relevanceScore,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
      tags: tags ?? this.tags,
      imageUrl: imageUrl ?? this.imageUrl,
      actionUrl: actionUrl ?? this.actionUrl,
    );
  }

  /// Backward compatibility getter for lastModified
  DateTime? get lastModified => updatedAt;

  /// Factory methods for different result types

  /// Create task search result
  static SearchResultModel fromTask(Map<String, dynamic> taskData, double relevanceScore) {
    return SearchResultModel(
      id: taskData['id'] ?? '',
      title: taskData['title'] ?? 'Untitled Task',
      subtitle: 'Task • ${taskData['status'] ?? 'Unknown'}',
      description: taskData['description'] ?? '',
      type: SearchResultType.task,
      relevanceScore: relevanceScore,
      createdAt: (taskData['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (taskData['updatedAt'] as Timestamp?)?.toDate(),
      metadata: {
        'priority': taskData['priority'],
        'status': taskData['status'],
        'assignedTo': taskData['assignedTo'],
        'teamId': taskData['teamId'],
        'projectId': taskData['projectId'],
      },
      tags: List<String>.from(taskData['tags'] ?? []),
      actionUrl: '/tasks/${taskData['id']}',
    );
  }

  /// Create team search result
  static SearchResultModel fromTeam(Map<String, dynamic> teamData, double relevanceScore) {
    final memberCount = (teamData['members'] as List?)?.length ?? 0;
    return SearchResultModel(
      id: teamData['id'] ?? '',
      title: teamData['name'] ?? 'Untitled Team',
      subtitle: 'Team • $memberCount members',
      description: teamData['description'] ?? '',
      type: SearchResultType.team,
      relevanceScore: relevanceScore,
      createdAt: (teamData['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (teamData['updatedAt'] as Timestamp?)?.toDate(),
      metadata: {
        'memberCount': memberCount,
        'isActive': teamData['isActive'],
        'ownerId': teamData['ownerId'],
      },
      imageUrl: teamData['imageUrl'],
      actionUrl: '/teams/${teamData['id']}',
    );
  }

  /// Create project search result
  static SearchResultModel fromProject(Map<String, dynamic> projectData, double relevanceScore) {
    return SearchResultModel(
      id: projectData['id'] ?? '',
      title: projectData['name'] ?? 'Untitled Project',
      subtitle: 'Project • ${projectData['status'] ?? 'Unknown'}',
      description: projectData['description'] ?? '',
      type: SearchResultType.project,
      relevanceScore: relevanceScore,
      createdAt: (projectData['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (projectData['updatedAt'] as Timestamp?)?.toDate(),
      metadata: {
        'status': projectData['status'],
        'progress': projectData['progress'],
        'teamId': projectData['teamId'],
        'ownerId': projectData['ownerId'],
      },
      imageUrl: projectData['imageUrl'],
      actionUrl: '/projects/${projectData['id']}',
    );
  }

  /// Create user search result
  static SearchResultModel fromUser(Map<String, dynamic> userData, double relevanceScore) {
    return SearchResultModel(
      id: userData['id'] ?? '',
      title: userData['displayName'] ?? userData['email'] ?? 'Unknown User',
      subtitle: 'User • ${userData['role'] ?? 'Unknown'}',
      description: userData['bio'] ?? '',
      type: SearchResultType.user,
      relevanceScore: relevanceScore,
      createdAt: (userData['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (userData['updatedAt'] as Timestamp?)?.toDate(),
      metadata: {
        'email': userData['email'],
        'role': userData['role'],
        'isActive': userData['isActive'],
      },
      imageUrl: userData['photoURL'],
      actionUrl: '/users/${userData['id']}',
    );
  }
}

/// Search Result Type Enum
enum SearchResultType {
  task('task', 'Task'),
  team('team', 'Team'),
  project('project', 'Project'),
  user('user', 'User'),
  notification('notification', 'Notification'),
  comment('comment', 'Comment'),
  file('file', 'File'),
  other('other', 'Other');

  const SearchResultType(this.value, this.displayName);

  final String value;
  final String displayName;

  static SearchResultType fromString(String value) {
    return SearchResultType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => SearchResultType.other,
    );
  }
}

/// Search Filter Model
/// Represents search filters and criteria
class SearchFilterModel {
  final List<SearchResultType> types;
  final DateTimeRange? dateRange;
  final List<String> tags;
  final Map<String, dynamic> customFilters;
  final SearchSortOption sortBy;
  final bool sortAscending;

  const SearchFilterModel({
    this.types = const [],
    this.dateRange,
    this.tags = const [],
    this.customFilters = const {},
    this.sortBy = SearchSortOption.relevance,
    this.sortAscending = false,
  });

  /// Create copy with updated fields
  SearchFilterModel copyWith({
    List<SearchResultType>? types,
    DateTimeRange? dateRange,
    List<String>? tags,
    Map<String, dynamic>? customFilters,
    SearchSortOption? sortBy,
    bool? sortAscending,
  }) {
    return SearchFilterModel(
      types: types ?? this.types,
      dateRange: dateRange ?? this.dateRange,
      tags: tags ?? this.tags,
      customFilters: customFilters ?? this.customFilters,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
    );
  }

  /// Check if filters are active
  bool get hasActiveFilters {
    return types.isNotEmpty ||
           dateRange != null ||
           tags.isNotEmpty ||
           customFilters.isNotEmpty;
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'types': types.map((t) => t.value).toList(),
      'dateRange': dateRange != null ? {
        'start': dateRange!.start.toIso8601String(),
        'end': dateRange!.end.toIso8601String(),
      } : null,
      'tags': tags,
      'customFilters': customFilters,
      'sortBy': sortBy.value,
      'sortAscending': sortAscending,
    };
  }

  /// Create from JSON
  factory SearchFilterModel.fromJson(Map<String, dynamic> json) {
    return SearchFilterModel(
      types: (json['types'] as List<dynamic>?)
          ?.map((t) => SearchResultType.fromString(t))
          .toList() ?? [],
      dateRange: json['dateRange'] != null ? DateTimeRange(
        start: DateTime.parse(json['dateRange']['start']),
        end: DateTime.parse(json['dateRange']['end']),
      ) : null,
      tags: List<String>.from(json['tags'] ?? []),
      customFilters: Map<String, dynamic>.from(json['customFilters'] ?? {}),
      sortBy: SearchSortOption.fromString(json['sortBy'] ?? 'relevance'),
      sortAscending: json['sortAscending'] ?? false,
    );
  }
}

/// Search Sort Option Enum
enum SearchSortOption {
  relevance('relevance', 'Relevance'),
  dateCreated('date_created', 'Date Created'),
  dateUpdated('date_updated', 'Date Updated'),
  alphabetical('alphabetical', 'Alphabetical'),
  priority('priority', 'Priority');

  const SearchSortOption(this.value, this.displayName);

  final String value;
  final String displayName;

  static SearchSortOption fromString(String value) {
    return SearchSortOption.values.firstWhere(
      (option) => option.value == value,
      orElse: () => SearchSortOption.relevance,
    );
  }
}

/// Search History Model
/// Represents a search history entry
class SearchHistoryModel {
  final String id;
  final String query;
  final SearchFilterModel filters;
  final DateTime timestamp;
  final int resultCount;
  final String userId;

  const SearchHistoryModel({
    required this.id,
    required this.query,
    required this.filters,
    required this.timestamp,
    required this.resultCount,
    required this.userId,
  });

  /// Create from Firestore document
  factory SearchHistoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return SearchHistoryModel(
      id: doc.id,
      query: data['query'] ?? '',
      filters: SearchFilterModel.fromJson(data['filters'] ?? {}),
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      resultCount: data['resultCount'] ?? 0,
      userId: data['userId'] ?? '',
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'query': query,
      'filters': filters.toJson(),
      'timestamp': Timestamp.fromDate(timestamp),
      'resultCount': resultCount,
      'userId': userId,
    };
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'query': query,
      'filters': filters.toJson(),
      'timestamp': timestamp.toIso8601String(),
      'resultCount': resultCount,
      'userId': userId,
    };
  }
}

/// Search Suggestion Model
/// Represents a search suggestion
class SearchSuggestionModel {
  final String text;
  final SearchSuggestionType type;
  final int frequency;
  final DateTime lastUsed;

  const SearchSuggestionModel({
    required this.text,
    required this.type,
    required this.frequency,
    required this.lastUsed,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'type': type.value,
      'frequency': frequency,
      'lastUsed': lastUsed.toIso8601String(),
    };
  }

  /// Create from JSON
  factory SearchSuggestionModel.fromJson(Map<String, dynamic> json) {
    return SearchSuggestionModel(
      text: json['text'] ?? '',
      type: SearchSuggestionType.fromString(json['type'] ?? 'query'),
      frequency: json['frequency'] ?? 0,
      lastUsed: json['lastUsed'] != null 
          ? DateTime.parse(json['lastUsed'])
          : DateTime.now(),
    );
  }
}

/// Search Suggestion Type Enum
enum SearchSuggestionType {
  query('query', 'Search Query'),
  tag('tag', 'Tag'),
  user('user', 'User'),
  team('team', 'Team'),
  project('project', 'Project');

  const SearchSuggestionType(this.value, this.displayName);

  final String value;
  final String displayName;

  static SearchSuggestionType fromString(String value) {
    return SearchSuggestionType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => SearchSuggestionType.query,
    );
  }
}

/// Date Time Range helper class
class DateTimeRange {
  final DateTime start;
  final DateTime end;

  const DateTimeRange({
    required this.start,
    required this.end,
  });

  /// Check if date is within range
  bool contains(DateTime date) {
    return date.isAfter(start) && date.isBefore(end);
  }

  /// Get duration of the range
  Duration get duration => end.difference(start);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DateTimeRange &&
        other.start == start &&
        other.end == end;
  }

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() => 'DateTimeRange(start: $start, end: $end)';
}
