import 'package:flutter_riverpod/flutter_riverpod.dart';

final favoritesControllerProvider =
    StateNotifierProvider<FavoritesController, Set<String>>(
  (ref) => FavoritesController(),
);

class FavoritesController extends StateNotifier<Set<String>> {
  FavoritesController() : super(<String>{});

  bool contains(String id) => state.contains(id);

  void toggle(String id) {
    final next = <String>{...state};
    if (!next.add(id)) {
      next.remove(id);
    }
    state = next;
  }
}
