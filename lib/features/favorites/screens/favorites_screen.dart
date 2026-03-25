import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/video_item.dart';
import '../../../localization/generated/app_localizations.dart';
import '../../favorites/controllers/favorites_controller.dart';
import '../../library/controllers/library_controller.dart';
import '../../player/controllers/player_controller.dart';
import '../../player/controllers/recent_playback_controller.dart';
import '../../player/screens/player_screen.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final favoriteIds = ref.watch(favoritesControllerProvider);
    final snapshot = ref.watch(libraryControllerProvider).valueOrNull;
    final recent = ref.watch(recentPlaybackProvider);
    final videos = snapshot?.videos.where((video) => favoriteIds.contains(video.id)).toList() ?? const <VideoItem>[];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      children: [
        Text(l10n.favorites, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        if (videos.isEmpty)
          Card(child: ListTile(title: Text(l10n.noFavoritesYet)))
        else
          ...videos.map(
            (video) => Card(
              child: ListTile(
                title: Text(video.title),
                subtitle: Text(video.folderName),
                trailing: const Icon(Icons.play_circle_outline_rounded),
                onTap: () async {
                  await ref.read(sharedPlayerControllerProvider.notifier).openVideoItem(video);
                  if (context.mounted) {
                    Navigator.of(context).pushNamed(PlayerScreen.routeName);
                  }
                },
              ),
            ),
          ),
        const SizedBox(height: 20),
        Text(l10n.recentlyPlayed, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        if (recent.isEmpty)
          Card(child: ListTile(title: Text(l10n.noRecentYet)))
        else
          ...recent.map(
            (item) => Card(
              child: ListTile(
                title: Text(item.title),
                subtitle: Text(item.path),
                trailing: const Icon(Icons.history_rounded),
              ),
            ),
          ),
      ],
    );
  }
}
