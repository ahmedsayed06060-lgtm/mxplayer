import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/library_snapshot.dart';
import '../../../data/models/video_item.dart';
import '../../../data/repositories/library_repository.dart';

final libraryRepositoryProvider = Provider<LibraryRepository>((ref) {
  return LibraryRepository();
});

final libraryControllerProvider =
    AsyncNotifierProvider<LibraryController, LibrarySnapshot?>(
  LibraryController.new,
);

final videoThumbnailProvider = FutureProvider.family<String?, VideoItem>((ref, item) async {
  final repository = ref.watch(libraryRepositoryProvider);
  return repository.buildThumbnail(item);
});

class LibraryController extends AsyncNotifier<LibrarySnapshot?> {
  @override
  Future<LibrarySnapshot?> build() async {
    final repository = ref.read(libraryRepositoryProvider);
    final roots = await repository.resolveInitialRoots();
    if (roots.isEmpty) {
      return null;
    }
    return repository.scan(roots);
  }

  Future<void> refresh() async {
    final repository = ref.read(libraryRepositoryProvider);
    final current = state.valueOrNull;
    final roots = current?.scanRoots ?? await repository.resolveInitialRoots();
    if (roots.isEmpty) {
      state = const AsyncData(null);
      return;
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() => repository.scan(roots));
  }

  Future<void> pickAndScanDirectory() async {
    final repository = ref.read(libraryRepositoryProvider);
    final selected = await repository.pickDirectory();
    if (selected == null || selected.isEmpty) {
      return;
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() => repository.scan(<String>[selected]));
  }
}
