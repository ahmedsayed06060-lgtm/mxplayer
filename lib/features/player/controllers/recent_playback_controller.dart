import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/database_provider.dart';
import '../models/recent_playback_item.dart';

final recentPlaybackProvider =
    StateNotifierProvider<RecentPlaybackController, List<RecentPlaybackItem>>(
  (ref) => RecentPlaybackController(ref),
);

class RecentPlaybackController extends StateNotifier<List<RecentPlaybackItem>> {
  RecentPlaybackController(this._ref) : super(const []) {
    _hydrate();
  }

  final Ref _ref;

  Future<void> _hydrate() async {
    state = await _ref.read(appDatabaseProvider).loadRecentPlayback(limit: 12);
  }

  /// Moves [item] to the front of the recently played list.
  ///
  /// Watch progress itself is persisted by the player controller, so this must
  /// not overwrite the stored position.
  Future<void> push(RecentPlaybackItem item) async {
    final existing = state.where((element) => element.id == item.id);
    final merged = item.copyWith(
      positionMs: existing.isEmpty ? item.positionMs : existing.first.positionMs,
      durationMs: existing.isEmpty ? item.durationMs : existing.first.durationMs,
    );
    state = <RecentPlaybackItem>[
      merged,
      ...state.where((element) => element.id != item.id),
    ].take(12).toList(growable: false);
  }

  /// Keeps the in-memory progress badges in sync with the player.
  void updateProgress(String id, {required int positionMs, required int durationMs}) {
    if (!state.any((element) => element.id == id)) {
      return;
    }
    state = <RecentPlaybackItem>[
      for (final element in state)
        if (element.id == id)
          element.copyWith(positionMs: positionMs, durationMs: durationMs)
        else
          element,
    ];
  }

  Future<void> reload() async {
    await _hydrate();
  }
}
