import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/search_models.dart';
import '../services/search_service.dart';

/// Search Controller
/// Manages search state and user interactions
class SearchController extends GetxController {
  final SearchService _searchService = Get.find<SearchService>();

  // Text editing controller
  final TextEditingController searchTextController = TextEditingController();

  // Reactive state
  final RxString _query = ''.obs;
  final RxList<SearchResultModel> _searchResults = <SearchResultModel>[].obs;
  final RxList<SearchSuggestionModel> _suggestions = <SearchSuggestionModel>[].obs;
  final Rx<SearchFilterModel> _filters = const SearchFilterModel().obs;
  final RxBool _isSearching = false.obs;
  final RxBool _showFilters = false.obs;
  final RxBool _showSuggestions = false.obs;

  // Getters
  String get query => _query.value;
  List<SearchResultModel> get searchResults => _searchResults;
  List<SearchSuggestionModel> get suggestions => _suggestions;
  SearchFilterModel get filters => _filters.value;
  bool get isSearching => _isSearching.value || _searchService.isSearching;
  bool get showFilters => _showFilters.value;
  bool get showSuggestions => _showSuggestions.value;
  bool get hasResults => _searchResults.isNotEmpty;
  bool get hasQuery => _query.value.trim().isNotEmpty;

  // Search history
  List<SearchHistoryModel> get searchHistory => _searchService.searchHistory;

  @override
  void onInit() {
    super.onInit();
    _setupServiceListeners();
    _setupTextControllerListener();
    _loadSuggestions();
  }

  @override
  void onClose() {
    searchTextController.dispose();
    super.onClose();
  }

  /// Setup service listeners
  void _setupServiceListeners() {
    // Listen to search service changes
    ever(_searchService._searchResults, (results) {
      _searchResults.value = List<SearchResultModel>.from(results);
    });

    ever(_searchService._isSearching, (searching) {
      _isSearching.value = searching;
    });
  }

  /// Setup text controller listener
  void _setupTextControllerListener() {
    searchTextController.addListener(() {
      final newQuery = searchTextController.text;
      if (_query.value != newQuery) {
        _query.value = newQuery;
        _onQueryChanged(newQuery);
      }
    });
  }

  /// Handle query changes
  void _onQueryChanged(String query) {
    if (query.trim().isEmpty) {
      _clearSearch();
      _loadSuggestions();
      _showSuggestions.value = true;
    } else {
      _showSuggestions.value = false;
      _loadSuggestionsForQuery(query);
      
      // Debounce search
      _debounceSearch(query);
    }
  }

  /// Debounce search to avoid too many API calls
  void _debounceSearch(String query) {
    // Cancel previous timer if exists
    if (_debounceTimer != null) {
      _debounceTimer!.cancel();
    }
    
    // Start new timer
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (query.trim().isNotEmpty) {
        performSearch(query);
      }
    });
  }

  Timer? _debounceTimer;

  // ==================== SEARCH OPERATIONS ====================

  /// Perform search
  Future<void> performSearch(String query) async {
    if (query.trim().isEmpty) {
      _clearSearch();
      return;
    }

    _query.value = query;
    _showSuggestions.value = false;
    
    try {
      final results = await _searchService.globalSearch(
        query,
        filters: _filters.value,
      );
      
      _searchResults.value = results;
      
    } catch (e) {
      Get.snackbar(
        'Search Error',
        'Failed to perform search. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Clear search
  void _clearSearch() {
    _searchResults.clear();
    _searchService.clearSearchResults();
  }

  /// Clear all search data
  void clearAll() {
    searchTextController.clear();
    _query.value = '';
    _clearSearch();
    _filters.value = const SearchFilterModel();
    _showFilters.value = false;
    _showSuggestions.value = false;
  }

  // ==================== SUGGESTIONS ====================

  /// Load suggestions
  void _loadSuggestions() {
    _suggestions.value = _searchService.suggestions.take(10).toList();
  }

  /// Load suggestions for query
  void _loadSuggestionsForQuery(String query) {
    _suggestions.value = _searchService.getSuggestionsForQuery(query);
  }

  /// Select suggestion
  void selectSuggestion(SearchSuggestionModel suggestion) {
    searchTextController.text = suggestion.text;
    _query.value = suggestion.text;
    _showSuggestions.value = false;
    performSearch(suggestion.text);
  }

  /// Toggle suggestions visibility
  void toggleSuggestions() {
    _showSuggestions.value = !_showSuggestions.value;
    if (_showSuggestions.value) {
      _loadSuggestionsForQuery(_query.value);
    }
  }

  // ==================== FILTERING ====================

  /// Toggle filters visibility
  void toggleFilters() {
    _showFilters.value = !_showFilters.value;
  }

  /// Update filters
  void updateFilters(SearchFilterModel newFilters) {
    _filters.value = newFilters;
    
    // Re-search with new filters if we have a query
    if (_query.value.trim().isNotEmpty) {
      performSearch(_query.value);
    }
  }

  /// Add type filter
  void addTypeFilter(SearchResultType type) {
    final currentTypes = List<SearchResultType>.from(_filters.value.types);
    if (!currentTypes.contains(type)) {
      currentTypes.add(type);
      _filters.value = _filters.value.copyWith(types: currentTypes);
      
      if (_query.value.trim().isNotEmpty) {
        performSearch(_query.value);
      }
    }
  }

  /// Remove type filter
  void removeTypeFilter(SearchResultType type) {
    final currentTypes = List<SearchResultType>.from(_filters.value.types);
    currentTypes.remove(type);
    _filters.value = _filters.value.copyWith(types: currentTypes);
    
    if (_query.value.trim().isNotEmpty) {
      performSearch(_query.value);
    }
  }

  /// Set date range filter
  void setDateRangeFilter(DateTimeRange? dateRange) {
    _filters.value = _filters.value.copyWith(dateRange: dateRange);
    
    if (_query.value.trim().isNotEmpty) {
      performSearch(_query.value);
    }
  }

  /// Add tag filter
  void addTagFilter(String tag) {
    final currentTags = List<String>.from(_filters.value.tags);
    if (!currentTags.contains(tag)) {
      currentTags.add(tag);
      _filters.value = _filters.value.copyWith(tags: currentTags);
      
      if (_query.value.trim().isNotEmpty) {
        performSearch(_query.value);
      }
    }
  }

  /// Remove tag filter
  void removeTagFilter(String tag) {
    final currentTags = List<String>.from(_filters.value.tags);
    currentTags.remove(tag);
    _filters.value = _filters.value.copyWith(tags: currentTags);
    
    if (_query.value.trim().isNotEmpty) {
      performSearch(_query.value);
    }
  }

  /// Set sort option
  void setSortOption(SearchSortOption sortBy, bool ascending) {
    _filters.value = _filters.value.copyWith(
      sortBy: sortBy,
      sortAscending: ascending,
    );
    
    if (_query.value.trim().isNotEmpty) {
      performSearch(_query.value);
    }
  }

  /// Clear filters
  void clearFilters() {
    _filters.value = const SearchFilterModel();
    
    if (_query.value.trim().isNotEmpty) {
      performSearch(_query.value);
    }
  }

  // ==================== SEARCH HISTORY ====================

  /// Select search from history
  void selectFromHistory(SearchHistoryModel history) {
    searchTextController.text = history.query;
    _query.value = history.query;
    _filters.value = history.filters;
    _showSuggestions.value = false;
    performSearch(history.query);
  }

  /// Clear search history
  Future<void> clearSearchHistory() async {
    await _searchService.clearSearchHistory();
    Get.snackbar(
      'Success',
      'Search history cleared',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // ==================== RESULT ACTIONS ====================

  /// Handle result tap
  void onResultTap(SearchResultModel result) {
    // Navigate to the result's action URL if available
    if (result.actionUrl != null) {
      Get.toNamed(result.actionUrl!);
    }
  }

  /// Get result count by type
  Map<SearchResultType, int> get resultCountsByType {
    return _searchService.getResultCountsByType();
  }

  /// Get filtered results by type
  List<SearchResultModel> getResultsByType(SearchResultType type) {
    return _searchResults.where((result) => result.type == type).toList();
  }

  // ==================== UI HELPERS ====================

  /// Get search placeholder text
  String get searchPlaceholder {
    if (_filters.value.types.isNotEmpty) {
      final typeNames = _filters.value.types
          .map((type) => type.displayName.toLowerCase())
          .join(', ');
      return 'Search $typeNames...';
    }
    return 'Search tasks, teams, projects, users...';
  }

  /// Get filter summary text
  String get filterSummary {
    final parts = <String>[];
    
    if (_filters.value.types.isNotEmpty) {
      parts.add('${_filters.value.types.length} types');
    }
    
    if (_filters.value.dateRange != null) {
      parts.add('date range');
    }
    
    if (_filters.value.tags.isNotEmpty) {
      parts.add('${_filters.value.tags.length} tags');
    }
    
    if (_filters.value.customFilters.isNotEmpty) {
      parts.add('${_filters.value.customFilters.length} custom');
    }
    
    if (parts.isEmpty) {
      return 'No filters applied';
    }
    
    return 'Filtered by: ${parts.join(', ')}';
  }

  /// Check if has active filters
  bool get hasActiveFilters => _filters.value.hasActiveFilters;

  /// Get result summary text
  String get resultSummary {
    if (_searchResults.isEmpty && _query.value.trim().isNotEmpty) {
      return 'No results found for "${_query.value}"';
    }
    
    if (_searchResults.isEmpty) {
      return '';
    }
    
    final count = _searchResults.length;
    final query = _query.value.trim().isNotEmpty ? ' for "${_query.value}"' : '';
    
    return '$count result${count == 1 ? '' : 's'}$query';
  }

  /// Focus search field
  void focusSearchField() {
    // This would be called from the UI to focus the search field
    _showSuggestions.value = true;
    if (_query.value.trim().isEmpty) {
      _loadSuggestions();
    }
  }

  /// Unfocus search field
  void unfocusSearchField() {
    // Hide suggestions when search field loses focus
    Future.delayed(const Duration(milliseconds: 200), () {
      _showSuggestions.value = false;
    });
  }

  // ==================== DATA UPDATE METHODS ====================
  
  /// Update task search data
  void updateTaskSearchData(List<dynamic> tasks) {
    // Update search index with new task data
    // This method is called by StateManagementService
    _searchService.updateTaskIndex(tasks);
  }
  
  /// Update team search data
  void updateTeamSearchData(List<dynamic> teams) {
    // Update search index with new team data
    // This method is called by StateManagementService
    _searchService.updateTeamIndex(teams);
  }
  
  /// Update project search data
  void updateProjectSearchData(List<dynamic> projects) {
    // Update search index with new project data
    // This method is called by StateManagementService
    _searchService.updateProjectIndex(projects);
  }
}
