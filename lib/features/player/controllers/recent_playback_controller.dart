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

  Future<void> push(RecentPlaybackItem item) async {
    final next = [
      item,
      ...state.where((element) => element.id != item.id),
    ];
    state = next.take(12).toList(growable: false);
    await _ref.read(appDatabaseProvider).saveWatchProgress(
          id: item.id,
          title: item.title,
          path: item.path,
          isNetwork: item.isNetwork,
          positionMs: 0,
          durationMs: 0,
        );
  }
}
