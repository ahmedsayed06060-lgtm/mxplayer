enum LibrarySortMode {
  recentlyAdded,
  recentlyPlayed,
  name,
  fileSize,
  duration,
}

class LibraryViewState {
  const LibraryViewState({
    this.sortMode = LibrarySortMode.recentlyAdded,
    this.extensionFilter,
  });

  final LibrarySortMode sortMode;
  final String? extensionFilter;

  LibraryViewState copyWith({
    LibrarySortMode? sortMode,
    String? extensionFilter,
    bool clearExtensionFilter = false,
  }) {
    return LibraryViewState(
      sortMode: sortMode ?? this.sortMode,
      extensionFilter: clearExtensionFilter ? null : (extensionFilter ?? this.extensionFilter),
    );
  }
}
