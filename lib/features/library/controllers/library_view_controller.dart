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
}
