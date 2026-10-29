import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/themes/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/mx_common.dart';
import '../../../../data/models/video_item.dart';
import '../../../../localization/generated/app_localizations.dart';
import '../../../favorites/controllers/favorites_controller.dart';
import '../../../player/controllers/player_controller.dart';
import '../../../player/controllers/recent_playback_controller.dart';
import '../../../player/models/playback_item.dart';
import '../../../player/models/recent_playback_item.dart';
import '../../../player/screens/player_screen.dart';
import '../../controllers/library_controller.dart';
import '../../controllers/library_view_controller.dart';
import '../../models/library_view_state.dart';
import '../../widgets/video_actions.dart';
import '../../widgets/video_tile.dart';

class VideoListScreen extends ConsumerWidget {
  const VideoListScreen({super.key, required this.videos});

  final List<VideoItem> videos;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final LibraryViewState viewState = ref.watch(libraryViewControllerProvider);
    final Set<String> favorites = ref.watch(favoritesControllerProvider);
    final List<RecentPlaybackItem> recent = ref.watch(recentPlaybackProvider);

    final Map<String, double> progressById = <String, double>{
      for (final RecentPlaybackItem item in recent)
        if (item.progress > 0.01) item.id: item.progress,
    };
    final Map<String, VideoItem> videosByPath = <String, VideoItem>{
      for (final VideoItem video in videos) video.path: video,
    };

    final String query = viewState.searchQuery.trim().toLowerCase();
    final List<VideoItem> filtered = videos.where((VideoItem video) {
      final String? filter = viewState.extensionFilter;
      if (filter != null && filter.isNotEmpty && video.extension.toLowerCase() != filter.toLowerCase()) {
        return false;
      }
      if (viewState.favoritesOnly && !favorites.contains(video.id)) {
        return false;
      }
      if (query.isNotEmpty) {
        final bool matches = video.title.toLowerCase().contains(query) ||
            video.folderName.toLowerCase().contains(query) ||
            video.extension.toLowerCase().contains(query);
        if (!matches) {
          return false;
        }
      }
      return true;
    }).toList();

    filtered.sort((VideoItem a, VideoItem b) {
      switch (viewState.sortMode) {
        case LibrarySortMode.name:
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
        case LibrarySortMode.fileSize:
          return b.fileSizeBytes.compareTo(a.fileSizeBytes);
        case LibrarySortMode.duration:
          return (b.durationMs ?? 0).compareTo(a.durationMs ?? 0);
        case LibrarySortMode.recentlyPlayed:
          final int aIndex = recent.indexWhere((RecentPlaybackItem item) => item.id == a.id);
          final int bIndex = recent.indexWhere((RecentPlaybackItem item) => item.id == b.id);
          return (aIndex == -1 ? 9999 : aIndex).compareTo(bIndex == -1 ? 9999 : bIndex);
        case LibrarySortMode.recentlyAdded:
          return b.lastModifiedEpochMs.compareTo(a.lastModifiedEpochMs);
      }
    });

    if (videos.isEmpty) {
      return MxEmptyState(
        icon: Icons.video_library_outlined,
        title: l10n.noLibraryFound,
        message: l10n.noLibraryFoundMessage,
        actionLabel: l10n.selectFolder,
        onAction: () => ref.read(libraryControllerProvider.notifier).pickAndScanDirectory(),
      );
    }

    final bool showRail = !viewState.isSearching && !viewState.favoritesOnly && viewState.extensionFilter == null;

    return CustomScrollView(
      slivers: <Widget>[
        if (showRail)
          SliverToBoxAdapter(
            child: _ContinueWatchingRail(
              recent: recent,
              videosByPath: videosByPath,
            ),
          ),
        SliverToBoxAdapter(
          child: _FilterBar(
            viewState: viewState,
            favoriteCount: favorites.length,
            resultCount: filtered.length,
          ),
        ),
        if (filtered.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: MxEmptyState(
              compact: true,
              icon: Icons.search_off_rounded,
              title: viewState.isSearching ? l10n.noResults : l10n.noVideosFound,
              message: viewState.favoritesOnly ? l10n.noFavoritesYet : null,
              actionLabel: viewState.isSearching ? l10n.clear : null,
              onAction: viewState.isSearching
                  ? () => ref.read(libraryViewControllerProvider.notifier).clearSearch()
                  : null,
            ),
          )
        else if (viewState.viewMode == LibraryViewMode.grid)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 140),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 260,
                mainAxisSpacing: 18,
                crossAxisSpacing: 12,
                childAspectRatio: 1.24,
              ),
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  final VideoItem video = filtered[index];
                  return VideoGridCard(
                    video: video,
                    progress: progressById[video.id],
                    isFavorite: favorites.contains(video.id),
                    onTap: () => playVideoQueue(context, ref, filtered, index),
                    onMore: () => showVideoActions(
                      context,
                      ref,
                      video,
                      queue: filtered,
                      index: index,
                    ),
                  );
                },
                childCount: filtered.length,
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 140),
            sliver: SliverList.builder(
              itemCount: filtered.length,
              itemBuilder: (BuildContext context, int index) {
                final VideoItem video = filtered[index];
                return VideoListTile(
                  video: video,
                  progress: progressById[video.id],
                  isFavorite: favorites.contains(video.id),
                  onTap: () => playVideoQueue(context, ref, filtered, index),
                  onMore: () => showVideoActions(
                    context,
                    ref,
                    video,
                    queue: filtered,
                    index: index,
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _FilterBar extends ConsumerWidget {
  const _FilterBar({
    required this.viewState,
    required this.favoriteCount,
    required this.resultCount,
  });

  final LibraryViewState viewState;
  final int favoriteCount;
  final int resultCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final LibraryViewController controller = ref.read(libraryViewControllerProvider.notifier);
    const List<String?> extensions = <String?>[null, 'mp4', 'mkv', 'avi', 'webm'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: 46,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: <Widget>[
              for (final String? extension in extensions)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(extension == null ? l10n.all : extension.toUpperCase()),
                    selected: !viewState.favoritesOnly && viewState.extensionFilter == extension,
                    onSelected: (_) {
                      if (viewState.favoritesOnly) {
                        controller.setFavoritesOnly(false);
                      }
                      controller.setExtensionFilter(extension);
                    },
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  avatar: Icon(
                    viewState.favoritesOnly ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    size: 15,
                    color: viewState.favoritesOnly ? MxColors.brand : null,
                  ),
                  label: Text('${l10n.favoritesOnly}${favoriteCount > 0 ? ' $favoriteCount' : ''}'),
                  selected: viewState.favoritesOnly,
                  onSelected: (_) => controller.toggleFavoritesOnly(),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 8, 6),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  '$resultCount ${l10n.videosCount} • ${_sortLabel(viewState.sortMode, l10n)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11.5),
                ),
              ),
              PopupMenuButton<LibrarySortMode>(
                tooltip: l10n.sortBy,
                icon: const Icon(Icons.sort_rounded, size: 20),
                initialValue: viewState.sortMode,
                onSelected: controller.setSortMode,
                itemBuilder: (BuildContext context) => <PopupMenuEntry<LibrarySortMode>>[
                  _sortItem(LibrarySortMode.recentlyAdded, l10n.sortRecentAdded, Icons.schedule_rounded),
                  _sortItem(LibrarySortMode.recentlyPlayed, l10n.sortRecentPlayed, Icons.history_rounded),
                  _sortItem(LibrarySortMode.name, l10n.sortName, Icons.sort_by_alpha_rounded),
                  _sortItem(LibrarySortMode.fileSize, l10n.sortSize, Icons.sd_storage_outlined),
                  _sortItem(LibrarySortMode.duration, l10n.sortDuration, Icons.timer_outlined),
                ],
              ),
              IconButton(
                tooltip: viewState.viewMode == LibraryViewMode.grid ? l10n.listView : l10n.gridView,
                onPressed: controller.toggleViewMode,
                icon: Icon(
                  viewState.viewMode == LibraryViewMode.grid
                      ? Icons.view_list_rounded
                      : Icons.grid_view_rounded,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  PopupMenuItem<LibrarySortMode> _sortItem(LibrarySortMode mode, String label, IconData icon) {
    return PopupMenuItem<LibrarySortMode>(
      value: mode,
      child: Row(
        children: <Widget>[
          Icon(icon, size: 18),
          const SizedBox(width: 10),
          Text(label),
        ],
      ),
    );
  }

  static String _sortLabel(LibrarySortMode mode, AppLocalizations l10n) {
    switch (mode) {
      case LibrarySortMode.recentlyAdded:
        return l10n.sortRecentAdded;
      case LibrarySortMode.recentlyPlayed:
        return l10n.sortRecentPlayed;
      case LibrarySortMode.name:
        return l10n.sortName;
      case LibrarySortMode.fileSize:
        return l10n.sortSize;
      case LibrarySortMode.duration:
        return l10n.sortDuration;
    }
  }
}

class _ContinueWatchingRail extends ConsumerWidget {
  const _ContinueWatchingRail({required this.recent, required this.videosByPath});

  final List<RecentPlaybackItem> recent;
  final Map<String, VideoItem> videosByPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final List<RecentPlaybackItem> items = recent.take(10).toList();
    if (items.isEmpty) {
      return const SizedBox(height: 8);
    }
    final bool anyInProgress = items.any((RecentPlaybackItem item) => item.isInProgress);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        MxSectionHeader(title: anyInProgress ? l10n.continueWatching : l10n.recentlyPlayed),
        SizedBox(
          height: 138,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (BuildContext context, int index) {
              final RecentPlaybackItem item = items[index];
              final VideoItem? video = videosByPath[item.path];
              return _ContinueCard(
                item: item,
                video: video,
                onTap: () async {
                  final SharedPlayerController controller =
                      ref.read(sharedPlayerControllerProvider.notifier);
                  final List<VideoItem> queue = <VideoItem>[
                    for (final RecentPlaybackItem entry in items)
                      if (videosByPath[entry.path] != null) videosByPath[entry.path]!,
                  ];
                  final int startIndex = video == null
                      ? -1
                      : queue.indexWhere((VideoItem candidate) => candidate.id == video.id);
                  if (startIndex >= 0) {
                    await controller.openVideoQueue(queue, startIndex: startIndex);
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
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ContinueCard extends StatelessWidget {
  const _ContinueCard({required this.item, required this.video, required this.onTap});

  final RecentPlaybackItem item;
  final VideoItem? video;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String remaining = item.durationMs > 0
        ? Formatters.duration(
            Duration(milliseconds: (item.durationMs - item.positionMs).clamp(0, item.durationMs).toInt()),
          )
        : '';

    return SizedBox(
      width: 188,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    if (video != null)
                      VideoThumbnail(video: video!, radius: 0, showDuration: false)
                    else
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: <Color>[Color(0xFF2A2E35), Color(0xFF15171B)],
                          ),
                        ),
                        child: Icon(Icons.play_circle_outline_rounded, color: Colors.white38),
                      ),
                    const Center(
                      child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 32),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: MxProgressLine(value: item.progress, height: 3),
                    ),
                    if (remaining.isNotEmpty)
                      Positioned(
                        right: 5,
                        bottom: 6,
                        child: MxBadge(label: remaining, dense: true),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 7),
            Text(
              item.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12.5, height: 1.25, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
