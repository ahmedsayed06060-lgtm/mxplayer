enum LibrarySortMode {
  recentlyAdded,
  recentlyPlayed,
  name,
  fileSize,
  duration,
}

enum LibraryViewMode {
  list,
  grid,
}

class LibraryViewState {
  const LibraryViewState({
    this.sortMode = LibrarySortMode.recentlyAdded,
    this.extensionFilter,
    this.viewMode = LibraryViewMode.list,
    this.searchQuery = '',
    this.favoritesOnly = false,
  });

  final LibrarySortMode sortMode;
  final String? extensionFilter;
  final LibraryViewMode viewMode;
  final String searchQuery;
  final bool favoritesOnly;

  bool get isSearching => searchQuery.trim().isNotEmpty;

  LibraryViewState copyWith({
    LibrarySortMode? sortMode,
    String? extensionFilter,
    bool clearExtensionFilter = false,
    LibraryViewMode? viewMode,
    String? searchQuery,
    bool? favoritesOnly,
  }) {
    return LibraryViewState(
      sortMode: sortMode ?? this.sortMode,
      extensionFilter: clearExtensionFilter ? null : (extensionFilter ?? this.extensionFilter),
      viewMode: viewMode ?? this.viewMode,
      searchQuery: searchQuery ?? this.searchQuery,
      favoritesOnly: favoritesOnly ?? this.favoritesOnly,
    );
  }
}
