import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../../core/services/error_handler_service.dart';
import '../../auth/services/auth_service.dart';
import '../models/search_models.dart';

/// Search Service
/// Handles global search functionality across all modules
class SearchService extends GetxService {
  static SearchService get instance => Get.find<SearchService>();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = Get.find<AuthService>();

  // Collections
  late final CollectionReference _tasksCollection;
  late final CollectionReference _teamsCollection;
  late final CollectionReference _projectsCollection;
  late final CollectionReference _usersCollection;
  late final CollectionReference _searchHistoryCollection;

  // Reactive state
  final RxList<SearchResultModel> _searchResults = <SearchResultModel>[].obs;
  final RxList<SearchHistoryModel> _searchHistory = <SearchHistoryModel>[].obs;
  final RxList<SearchSuggestionModel> _suggestions = <SearchSuggestionModel>[].obs;
  final RxBool _isSearching = false.obs;
  final RxString _lastQuery = ''.obs;

  // Getters
  List<SearchResultModel> get searchResults => _searchResults;
  List<SearchHistoryModel> get searchHistory => _searchHistory;
  List<SearchSuggestionModel> get suggestions => _suggestions;
  bool get isSearching => _isSearching.value;
  String get lastQuery => _lastQuery.value;

  @override
  void onInit() {
    super.onInit();
    _initializeCollections();
    _loadSearchHistory();
    _loadSuggestions();
  }

  /// Initialize Firestore collections
  void _initializeCollections() {
    _tasksCollection = _firestore.collection('tasks');
    _teamsCollection = _firestore.collection('teams');
    _projectsCollection = _firestore.collection('projects');
    _usersCollection = _firestore.collection('users');
    _searchHistoryCollection = _firestore.collection('searchHistory');
  }

  // ==================== GLOBAL SEARCH ====================

  /// Perform global search across all modules
  Future<List<SearchResultModel>> globalSearch(
    String query, {
    SearchFilterModel? filters,
    int limit = 50,
  }) async {
    if (query.trim().isEmpty) {
      _searchResults.clear();
      return [];
    }

    try {
      _isSearching.value = true;
      _lastQuery.value = query;

      final results = <SearchResultModel>[];
      final searchFilters = filters ?? const SearchFilterModel();

      // Search across different collections based on filters
      if (searchFilters.types.isEmpty || searchFilters.types.contains(SearchResultType.task)) {
        final taskResults = await _searchTasks(query, searchFilters, limit ~/ 4);
        results.addAll(taskResults);
      }

      if (searchFilters.types.isEmpty || searchFilters.types.contains(SearchResultType.team)) {
        final teamResults = await _searchTeams(query, searchFilters, limit ~/ 4);
        results.addAll(teamResults);
      }

      if (searchFilters.types.isEmpty || searchFilters.types.contains(SearchResultType.project)) {
        final projectResults = await _searchProjects(query, searchFilters, limit ~/ 4);
        results.addAll(projectResults);
      }

      if (searchFilters.types.isEmpty || searchFilters.types.contains(SearchResultType.user)) {
        final userResults = await _searchUsers(query, searchFilters, limit ~/ 4);
        results.addAll(userResults);
      }

      // Sort results by relevance score
      results.sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));

      // Apply additional sorting if specified
      _applySorting(results, searchFilters.sortBy, searchFilters.sortAscending);

      // Limit results
      final limitedResults = results.take(limit).toList();

      _searchResults.value = limitedResults;

      // Save search to history
      await _saveSearchToHistory(query, searchFilters, limitedResults.length);

      return limitedResults;

    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Global Search',
        severity: ErrorSeverity.medium,
      );
      return [];
    } finally {
      _isSearching.value = false;
    }
  }

  /// Search tasks
  Future<List<SearchResultModel>> _searchTasks(
    String query,
    SearchFilterModel filters,
    int limit,
  ) async {
    try {
      final results = <SearchResultModel>[];
      final queryLower = query.toLowerCase();

      // Search by title
      final titleQuery = await _tasksCollection
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThan: query + '\uf8ff')
          .limit(limit)
          .get();

      for (final doc in titleQuery.docs) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        
        if (_passesFilters(data, filters)) {
          final relevanceScore = _calculateTaskRelevanceScore(data, queryLower);
          results.add(SearchResultModel.fromTask(data, relevanceScore));
        }
      }

      // Search by description if not enough results
      if (results.length < limit) {
        final descQuery = await _tasksCollection
            .where('description', isGreaterThanOrEqualTo: query)
            .where('description', isLessThan: query + '\uf8ff')
            .limit(limit - results.length)
            .get();

        for (final doc in descQuery.docs) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          
          // Avoid duplicates
          if (!results.any((r) => r.id == doc.id) && _passesFilters(data, filters)) {
            final relevanceScore = _calculateTaskRelevanceScore(data, queryLower);
            results.add(SearchResultModel.fromTask(data, relevanceScore));
          }
        }
      }

      // Search by tags
      if (results.length < limit) {
        final tagQuery = await _tasksCollection
            .where('tags', arrayContains: queryLower)
            .limit(limit - results.length)
            .get();

        for (final doc in tagQuery.docs) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          
          // Avoid duplicates
          if (!results.any((r) => r.id == doc.id) && _passesFilters(data, filters)) {
            final relevanceScore = _calculateTaskRelevanceScore(data, queryLower);
            results.add(SearchResultModel.fromTask(data, relevanceScore));
          }
        }
      }

      return results;

    } catch (e) {
      return [];
    }
  }

  /// Search teams
  Future<List<SearchResultModel>> _searchTeams(
    String query,
    SearchFilterModel filters,
    int limit,
  ) async {
    try {
      final results = <SearchResultModel>[];
      final queryLower = query.toLowerCase();

      // Search by name
      final nameQuery = await _teamsCollection
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: query + '\uf8ff')
          .limit(limit)
          .get();

      for (final doc in nameQuery.docs) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        
        if (_passesFilters(data, filters)) {
          final relevanceScore = _calculateTeamRelevanceScore(data, queryLower);
          results.add(SearchResultModel.fromTeam(data, relevanceScore));
        }
      }

      // Search by description
      if (results.length < limit) {
        final descQuery = await _teamsCollection
            .where('description', isGreaterThanOrEqualTo: query)
            .where('description', isLessThan: query + '\uf8ff')
            .limit(limit - results.length)
            .get();

        for (final doc in descQuery.docs) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          
          // Avoid duplicates
          if (!results.any((r) => r.id == doc.id) && _passesFilters(data, filters)) {
            final relevanceScore = _calculateTeamRelevanceScore(data, queryLower);
            results.add(SearchResultModel.fromTeam(data, relevanceScore));
          }
        }
      }

      return results;

    } catch (e) {
      return [];
    }
  }

  /// Search projects
  Future<List<SearchResultModel>> _searchProjects(
    String query,
    SearchFilterModel filters,
    int limit,
  ) async {
    try {
      final results = <SearchResultModel>[];
      final queryLower = query.toLowerCase();

      // Search by name
      final nameQuery = await _projectsCollection
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: query + '\uf8ff')
          .limit(limit)
          .get();

      for (final doc in nameQuery.docs) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        
        if (_passesFilters(data, filters)) {
          final relevanceScore = _calculateProjectRelevanceScore(data, queryLower);
          results.add(SearchResultModel.fromProject(data, relevanceScore));
        }
      }

      // Search by description
      if (results.length < limit) {
        final descQuery = await _projectsCollection
            .where('description', isGreaterThanOrEqualTo: query)
            .where('description', isLessThan: query + '\uf8ff')
            .limit(limit - results.length)
            .get();

        for (final doc in descQuery.docs) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          
          // Avoid duplicates
          if (!results.any((r) => r.id == doc.id) && _passesFilters(data, filters)) {
            final relevanceScore = _calculateProjectRelevanceScore(data, queryLower);
            results.add(SearchResultModel.fromProject(data, relevanceScore));
          }
        }
      }

      return results;

    } catch (e) {
      return [];
    }
  }

  /// Search users
  Future<List<SearchResultModel>> _searchUsers(
    String query,
    SearchFilterModel filters,
    int limit,
  ) async {
    try {
      final results = <SearchResultModel>[];
      final queryLower = query.toLowerCase();

      // Search by display name
      final nameQuery = await _usersCollection
          .where('displayName', isGreaterThanOrEqualTo: query)
          .where('displayName', isLessThan: query + '\uf8ff')
          .limit(limit)
          .get();

      for (final doc in nameQuery.docs) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        
        if (_passesFilters(data, filters)) {
          final relevanceScore = _calculateUserRelevanceScore(data, queryLower);
          results.add(SearchResultModel.fromUser(data, relevanceScore));
        }
      }

      // Search by email
      if (results.length < limit) {
        final emailQuery = await _usersCollection
            .where('email', isGreaterThanOrEqualTo: query)
            .where('email', isLessThan: query + '\uf8ff')
            .limit(limit - results.length)
            .get();

        for (final doc in emailQuery.docs) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          
          // Avoid duplicates
          if (!results.any((r) => r.id == doc.id) && _passesFilters(data, filters)) {
            final relevanceScore = _calculateUserRelevanceScore(data, queryLower);
            results.add(SearchResultModel.fromUser(data, relevanceScore));
          }
        }
      }

      return results;

    } catch (e) {
      return [];
    }
  }

  // ==================== RELEVANCE SCORING ====================

  /// Calculate task relevance score
  double _calculateTaskRelevanceScore(Map<String, dynamic> data, String query) {
    double score = 0.0;
    final title = (data['title'] ?? '').toString().toLowerCase();
    final description = (data['description'] ?? '').toString().toLowerCase();
    final tags = List<String>.from(data['tags'] ?? []);

    // Title match (highest weight)
    if (title.contains(query)) {
      score += title.startsWith(query) ? 100.0 : 80.0;
    }

    // Description match
    if (description.contains(query)) {
      score += 40.0;
    }

    // Tag match
    for (final tag in tags) {
      if (tag.toLowerCase().contains(query)) {
        score += 60.0;
        break;
      }
    }

    // Priority boost
    final priority = data['priority'] ?? 'medium';
    switch (priority) {
      case 'urgent':
        score += 20.0;
        break;
      case 'high':
        score += 15.0;
        break;
      case 'medium':
        score += 10.0;
        break;
      case 'low':
        score += 5.0;
        break;
    }

    // Recent activity boost
    final updatedAt = (data['updatedAt'] as Timestamp?)?.toDate();
    if (updatedAt != null) {
      final daysSinceUpdate = DateTime.now().difference(updatedAt).inDays;
      if (daysSinceUpdate < 7) {
        score += 10.0;
      }
    }

    return score;
  }

  /// Calculate team relevance score
  double _calculateTeamRelevanceScore(Map<String, dynamic> data, String query) {
    double score = 0.0;
    final name = (data['name'] ?? '').toString().toLowerCase();
    final description = (data['description'] ?? '').toString().toLowerCase();

    // Name match (highest weight)
    if (name.contains(query)) {
      score += name.startsWith(query) ? 100.0 : 80.0;
    }

    // Description match
    if (description.contains(query)) {
      score += 40.0;
    }

    // Active team boost
    if (data['isActive'] == true) {
      score += 20.0;
    }

    // Member count boost (more active teams)
    final memberCount = (data['members'] as List?)?.length ?? 0;
    score += memberCount * 2.0;

    return score;
  }

  /// Calculate project relevance score
  double _calculateProjectRelevanceScore(Map<String, dynamic> data, String query) {
    double score = 0.0;
    final name = (data['name'] ?? '').toString().toLowerCase();
    final description = (data['description'] ?? '').toString().toLowerCase();

    // Name match (highest weight)
    if (name.contains(query)) {
      score += name.startsWith(query) ? 100.0 : 80.0;
    }

    // Description match
    if (description.contains(query)) {
      score += 40.0;
    }

    // Status boost
    final status = data['status'] ?? 'planning';
    switch (status) {
      case 'active':
        score += 30.0;
        break;
      case 'planning':
        score += 20.0;
        break;
      case 'completed':
        score += 10.0;
        break;
    }

    // Progress boost
    final progress = (data['progress'] ?? 0).toDouble();
    score += progress * 0.2;

    return score;
  }

  /// Calculate user relevance score
  double _calculateUserRelevanceScore(Map<String, dynamic> data, String query) {
    double score = 0.0;
    final displayName = (data['displayName'] ?? '').toString().toLowerCase();
    final email = (data['email'] ?? '').toString().toLowerCase();

    // Display name match (highest weight)
    if (displayName.contains(query)) {
      score += displayName.startsWith(query) ? 100.0 : 80.0;
    }

    // Email match
    if (email.contains(query)) {
      score += email.startsWith(query) ? 90.0 : 60.0;
    }

    // Active user boost
    if (data['isActive'] == true) {
      score += 20.0;
    }

    // Role boost
    final role = data['role'] ?? 'team_member';
    switch (role) {
      case 'super_admin':
        score += 15.0;
        break;
      case 'admin':
        score += 12.0;
        break;
      case 'team_member':
        score += 8.0;
        break;
      case 'viewer':
        score += 5.0;
        break;
    }

    return score;
  }

  // ==================== FILTERING ====================

  /// Check if data passes filters
  bool _passesFilters(Map<String, dynamic> data, SearchFilterModel filters) {
    // Date range filter
    if (filters.dateRange != null) {
      final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
      if (createdAt != null && !filters.dateRange!.contains(createdAt)) {
        return false;
      }
    }

    // Tag filter
    if (filters.tags.isNotEmpty) {
      final tags = List<String>.from(data['tags'] ?? []);
      final hasMatchingTag = filters.tags.any((filterTag) => 
          tags.any((tag) => tag.toLowerCase().contains(filterTag.toLowerCase())));
      if (!hasMatchingTag) {
        return false;
      }
    }

    // Custom filters
    for (final entry in filters.customFilters.entries) {
      final key = entry.key;
      final value = entry.value;
      
      if (data[key] != value) {
        return false;
      }
    }

    return true;
  }

  /// Apply sorting to results
  void _applySorting(
    List<SearchResultModel> results,
    SearchSortOption sortBy,
    bool ascending,
  ) {
    switch (sortBy) {
      case SearchSortOption.relevance:
        // Already sorted by relevance
        break;
      case SearchSortOption.dateCreated:
        results.sort((a, b) {
          final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return ascending ? aDate.compareTo(bDate) : bDate.compareTo(aDate);
        });
        break;
      case SearchSortOption.dateUpdated:
        results.sort((a, b) {
          final aDate = a.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bDate = b.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return ascending ? aDate.compareTo(bDate) : bDate.compareTo(aDate);
        });
        break;
      case SearchSortOption.alphabetical:
        results.sort((a, b) {
          return ascending 
              ? a.title.compareTo(b.title)
              : b.title.compareTo(a.title);
        });
        break;
      case SearchSortOption.priority:
        results.sort((a, b) {
          final aPriority = _getPriorityValue(a.metadata['priority']);
          final bPriority = _getPriorityValue(b.metadata['priority']);
          return ascending 
              ? aPriority.compareTo(bPriority)
              : bPriority.compareTo(aPriority);
        });
        break;
    }
  }

  /// Get priority value for sorting
  int _getPriorityValue(dynamic priority) {
    switch (priority) {
      case 'urgent':
        return 4;
      case 'high':
        return 3;
      case 'medium':
        return 2;
      case 'low':
        return 1;
      default:
        return 0;
    }
  }

  // ==================== SEARCH HISTORY ====================

  /// Load search history
  Future<void> _loadSearchHistory() async {
    try {
      final currentUser = _authService.currentUser.value;
      if (currentUser == null) return;

      final historyQuery = await _searchHistoryCollection
          .where('userId', isEqualTo: currentUser.id)
          .orderBy('timestamp', descending: true)
          .limit(20)
          .get();

      final history = historyQuery.docs
          .map((doc) => SearchHistoryModel.fromFirestore(doc))
          .toList();

      _searchHistory.value = history;

    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Load Search History',
        severity: ErrorSeverity.low,
      );
    }
  }

  /// Save search to history
  Future<void> _saveSearchToHistory(
    String query,
    SearchFilterModel filters,
    int resultCount,
  ) async {
    try {
      final currentUser = _authService.currentUser.value;
      if (currentUser == null) return;

      final historyEntry = SearchHistoryModel(
        id: '',
        query: query,
        filters: filters,
        timestamp: DateTime.now(),
        resultCount: resultCount,
        userId: currentUser.id,
      );

      await _searchHistoryCollection.add(historyEntry.toFirestore());
      
      // Reload history
      await _loadSearchHistory();

    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Save Search History',
        severity: ErrorSeverity.low,
      );
    }
  }

  /// Clear search history
  Future<void> clearSearchHistory() async {
    try {
      final currentUser = _authService.currentUser.value;
      if (currentUser == null) return;

      final batch = _firestore.batch();
      
      for (final history in _searchHistory) {
        batch.delete(_searchHistoryCollection.doc(history.id));
      }
      
      await batch.commit();
      _searchHistory.clear();

    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Clear Search History',
        severity: ErrorSeverity.low,
      );
    }
  }

  // ==================== SUGGESTIONS ====================

  /// Load search suggestions
  Future<void> _loadSuggestions() async {
    try {
      // Generate suggestions based on search history and popular terms
      final suggestions = <SearchSuggestionModel>[];
      
      // Add recent queries as suggestions
      for (final history in _searchHistory.take(5)) {
        suggestions.add(SearchSuggestionModel(
          text: history.query,
          type: SearchSuggestionType.query,
          frequency: 1,
          lastUsed: history.timestamp,
        ));
      }

      // Add popular tags (mock data for now)
      final popularTags = ['urgent', 'bug', 'feature', 'design', 'backend'];
      for (final tag in popularTags) {
        suggestions.add(SearchSuggestionModel(
          text: tag,
          type: SearchSuggestionType.tag,
          frequency: 10,
          lastUsed: DateTime.now(),
        ));
      }

      _suggestions.value = suggestions;

    } catch (e, stackTrace) {
      ErrorHandlerService.instance.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Load Suggestions',
        severity: ErrorSeverity.low,
      );
    }
  }

  /// Get suggestions for query
  List<SearchSuggestionModel> getSuggestionsForQuery(String query) {
    if (query.trim().isEmpty) {
      return _suggestions.take(10).toList();
    }

    final queryLower = query.toLowerCase();
    return _suggestions
        .where((suggestion) => 
            suggestion.text.toLowerCase().contains(queryLower))
        .take(10)
        .toList();
  }

  // ==================== UTILITY METHODS ====================

  /// Clear search results
  void clearSearchResults() {
    _searchResults.clear();
    _lastQuery.value = '';
  }

  /// Get search result count by type
  Map<SearchResultType, int> getResultCountsByType() {
    final counts = <SearchResultType, int>{};
    
    for (final result in _searchResults) {
      counts[result.type] = (counts[result.type] ?? 0) + 1;
    }
    
    return counts;
  }

  /// Check if has results
  bool get hasResults => _searchResults.isNotEmpty;

  /// Get total result count
  int get totalResultCount => _searchResults.length;
}
