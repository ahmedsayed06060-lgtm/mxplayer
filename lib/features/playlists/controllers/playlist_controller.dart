import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/database_provider.dart';
import '../../../data/database/app_database.dart';

final playlistControllerProvider =
    StateNotifierProvider<PlaylistController, PlaylistState>(
  (ref) => PlaylistController(ref),
);

class PlaylistState {
  const PlaylistState({
    this.playlists = const [],
    this.items = const {},
  });

  final List<PlaylistRecord> playlists;
  final Map<int, List<PlaylistVideoRecord>> items;

  PlaylistState copyWith({
    List<PlaylistRecord>? playlists,
    Map<int, List<PlaylistVideoRecord>>? items,
  }) {
    return PlaylistState(
      playlists: playlists ?? this.playlists,
      items: items ?? this.items,
    );
  }
}

class PlaylistController extends StateNotifier<PlaylistState> {
  PlaylistController(this._ref) : super(const PlaylistState()) {
    _hydrate();
  }

  final Ref _ref;

  Future<void> _hydrate() async {
    final database = _ref.read(appDatabaseProvider);
    final playlists = await database.loadPlaylists();
    final items = <int, List<PlaylistVideoRecord>>{};
    for (final playlist in playlists) {
      items[playlist.id] = await database.loadPlaylistVideos(playlist.id);
    }
    state = state.copyWith(playlists: playlists, items: items);
  }

  Future<void> createPlaylist(String name) async {
    if (name.trim().isEmpty) {
      return;
    }
    await _ref.read(appDatabaseProvider).createPlaylist(name.trim());
    await _hydrate();
  }

  Future<void> addVideo({
    required int playlistId,
    required String videoId,
    required String title,
    required String path,
  }) async {
    await _ref.read(appDatabaseProvider).addVideoToPlaylist(
          playlistId: playlistId,
          videoId: videoId,
          title: title,
          path: path,
        );
    await _hydrate();
  }
}
