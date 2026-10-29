import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/themes/app_theme.dart';
import '../../../core/widgets/mx_common.dart';
import '../../../data/database/app_database.dart';
import '../../../data/models/library_snapshot.dart';
import '../../../data/models/video_item.dart';
import '../../../localization/generated/app_localizations.dart';
import '../../favorites/controllers/favorites_controller.dart';
import '../../library/controllers/library_controller.dart';
import '../../library/widgets/video_actions.dart';
import '../../library/widgets/video_tile.dart';
import '../../player/controllers/player_controller.dart';
import '../../player/controllers/recent_playback_controller.dart';
import '../../player/models/playback_item.dart';
import '../../player/models/recent_playback_item.dart';
import '../../player/screens/player_screen.dart';
import '../../playlists/controllers/playlist_controller.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final Set<String> favoriteIds = ref.watch(favoritesControllerProvider);
    final LibrarySnapshot? snapshot = ref.watch(libraryControllerProvider).valueOrNull;
    final List<RecentPlaybackItem> recent = ref.watch(recentPlaybackProvider);
    final PlaylistState playlists = ref.watch(playlistControllerProvider);

    final List<VideoItem> favorites = snapshot?.videos
            .where((VideoItem video) => favoriteIds.contains(video.id))
            .toList() ??
        <VideoItem>[];
    final Map<String, double> progressById = <String, double>{
      for (final RecentPlaybackItem item in recent)
        if (item.progress > 0.01) item.id: item.progress,
    };
    final Map<String, VideoItem> byPath = <String, VideoItem>{
      for (final VideoItem video in snapshot?.videos ?? <VideoItem>[]) video.path: video,
    };

    return ListView(
      padding: const EdgeInsets.only(bottom: 140),
      children: <Widget>[
        MxSectionHeader(
          title: '${l10n.favorites} • ${favorites.length}',
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
        ),
        if (favorites.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: MxSurface(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: <Widget>[
                  const Icon(Icons.favorite_border_rounded, color: MxColors.brand),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.noFavoritesYet,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          for (final VideoItem video in favorites)
            VideoListTile(
              video: video,
              progress: progressById[video.id],
              isFavorite: true,
              onTap: () => playVideoQueue(context, ref, favorites, favorites.indexOf(video)),
              onMore: () => showVideoActions(
                context,
                ref,
                video,
                queue: favorites,
                index: favorites.indexOf(video),
              ),
            ),
        MxSectionHeader(
          title: '${l10n.playlists} • ${playlists.playlists.length}',
          padding: const EdgeInsets.fromLTRB(16, 22, 16, 10),
        ),
        if (playlists.playlists.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: MxSurface(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: <Widget>[
                  const Icon(Icons.queue_music_rounded, color: MxColors.brand),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.noPlaylists,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          for (final PlaylistRecord playlist in playlists.playlists)
            _PlaylistCard(
              name: playlist.name,
              items: playlists.items[playlist.id] ?? const <PlaylistVideoRecord>[],
            ),
        MxSectionHeader(
          title: l10n.recentlyPlayed,
          padding: const EdgeInsets.fromLTRB(16, 22, 16, 10),
        ),
        if (recent.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: MxSurface(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: <Widget>[
                  const Icon(Icons.history_rounded, color: MxColors.brand),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.noRecentYet,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          for (final RecentPlaybackItem item in recent.take(6))
            _RecentRow(
              item: item,
              video: byPath[item.path],
            ),
      ],
    );
  }
}

class _PlaylistCard extends ConsumerWidget {
  const _PlaylistCard({required this.name, required this.items});

  final String name;
  final List<PlaylistVideoRecord> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: MxSurface(
        radius: 14,
        padding: const EdgeInsets.fromLTRB(14, 6, 8, 6),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: const EdgeInsets.only(bottom: 8),
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: MxColors.brand.withOpacity(0.14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.playlist_play_rounded, color: MxColors.brand, size: 21),
            ),
            title: Text(name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14)),
            subtitle: Text('${items.length} ${l10n.items}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11)),
            trailing: items.isEmpty
                ? null
                : IconButton(
                    tooltip: l10n.playAll,
                    disabledColor: MxColors.textTertiary,
                    onPressed: () async {
                      await ref
                          .read(sharedPlayerControllerProvider.notifier)
                          .openPlaylistQueue(items, startIndex: 0);
                      if (context.mounted) {
                        await Navigator.of(context).pushNamed(PlayerScreen.routeName);
                      }
                    },
                    icon: const Icon(Icons.play_circle_fill_rounded, color: MxColors.brand),
                  ),
            children: <Widget>[
              if (items.isEmpty)
                ListTile(
                  dense: true,
                  title: Text(l10n.playlistEmpty, style: Theme.of(context).textTheme.bodySmall),
                )
              else
                for (int index = 0; index < items.length; index++)
                  ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    leading: const Icon(Icons.movie_outlined, size: 18),
                    title: Text(
                      items[index].title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12.5),
                    ),
                    onTap: () async {
                      await ref
                          .read(sharedPlayerControllerProvider.notifier)
                          .openPlaylistQueue(items, startIndex: index);
                      if (context.mounted) {
                        await Navigator.of(context).pushNamed(PlayerScreen.routeName);
                      }
                    },
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentRow extends ConsumerWidget {
  const _RecentRow({required this.item, required this.video});

  final RecentPlaybackItem item;
  final VideoItem? video;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: MxSurface(
        radius: 14,
        border: false,
        onTap: () async {
          final SharedPlayerController controller = ref.read(sharedPlayerControllerProvider.notifier);
          if (video != null) {
            await controller.openVideoItem(video!);
          } else {
            await controller.openNetwork(
              id: item.id,
              title: item.title,
              url: item.path,
              type: item.isNetwork ? PlaybackSourceType.network : PlaybackSourceType.local,
            );
          }
          if (context.mounted) {
            await Navigator.of(context).pushNamed(PlayerScreen.routeName);
          }
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 11, 12, 11),
          child: Row(
            children: <Widget>[
              const Icon(Icons.history_rounded, size: 19, color: MxColors.brand),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    if (item.progress > 0.01) ...<Widget>[
                      const SizedBox(height: 6),
                      SizedBox(
                        width: 150,
                        child: MxProgressLine(value: item.progress, height: 2.5),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.play_arrow_rounded, size: 20, color: MxColors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}
