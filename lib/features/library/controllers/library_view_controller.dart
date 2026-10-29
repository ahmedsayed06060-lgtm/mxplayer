import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/library_view_state.dart';

final libraryViewControllerProvider =
    StateNotifierProvider<LibraryViewController, LibraryViewState>(
  (ref) => LibraryViewController(),
);

class LibraryViewController extends StateNotifier<LibraryViewState> {
  LibraryViewController() : super(const LibraryViewState());

  void setSortMode(LibrarySortMode mode) {
    state = state.copyWith(sortMode: mode);
  }

  void setExtensionFilter(String? extension) {
    state = extension == null || extension.isEmpty
        ? state.copyWith(clearExtensionFilter: true)
        : state.copyWith(extensionFilter: extension);
  }

  void setViewMode(LibraryViewMode mode) {
    state = state.copyWith(viewMode: mode);
  }

  void toggleViewMode() {
    state = state.copyWith(
      viewMode: state.viewMode == LibraryViewMode.list ? LibraryViewMode.grid : LibraryViewMode.list,
    );
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void clearSearch() {
    state = state.copyWith(searchQuery: '');
  }

  void setFavoritesOnly(bool value) {
    state = state.copyWith(favoritesOnly: value);
  }

  void toggleFavoritesOnly() {
    state = state.copyWith(favoritesOnly: !state.favoritesOnly);
  }
}
