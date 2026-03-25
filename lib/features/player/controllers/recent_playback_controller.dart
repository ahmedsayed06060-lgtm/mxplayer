import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/recent_playback_item.dart';

final recentPlaybackProvider =
    StateNotifierProvider<RecentPlaybackController, List<RecentPlaybackItem>>(
  (ref) => RecentPlaybackController(),
);

class RecentPlaybackController extends StateNotifier<List<RecentPlaybackItem>> {
  RecentPlaybackController() : super(const []);

  void push(RecentPlaybackItem item) {
    final next = [
      item,
      ...state.where((element) => element.id != item.id),
    ];
    state = next.take(12).toList(growable: false);
  }
}
