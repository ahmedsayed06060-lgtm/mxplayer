import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../data/models/video_item.dart';
import '../../../../localization/generated/app_localizations.dart';
import '../../../favorites/controllers/favorites_controller.dart';
import '../../../player/controllers/player_controller.dart';
import '../../../player/controllers/recent_playback_controller.dart';
import '../../../player/screens/player_screen.dart';
import '../../../playlists/controllers/playlist_controller.dart';
import '../../controllers/library_controller.dart';
import '../../controllers/library_view_controller.dart';
import '../../models/library_view_state.dart';

class VideoListScreen extends ConsumerWidget {
  const VideoListScreen({super.key, required this.videos});

  final List<VideoItem> videos;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final viewState = ref.watch(libraryViewControllerProvider);
    final recent = ref.watch(recentPlaybackProvider);
    final recentOrder = <String, int>{
      for (var index = 0; index < recent.length; index++) recent[index].id: index,
    };

    final filtered = videos.where((video) {
      final filter = viewState.extensionFilter;
      return filter == null || filter.isEmpty || video.extension.toLowerCase() == filter.toLowerCase();
    }).toList();

    filtered.sort((a, b) {
      switch (viewState.sortMode) {
        case LibrarySortMode.name:
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
        case LibrarySortMode.fileSize:
          return b.fileSizeBytes.compareTo(a.fileSizeBytes);
        case LibrarySortMode.duration:
          return (b.durationMs ?? 0).compareTo(a.durationMs ?? 0);
        case LibrarySortMode.recentlyPlayed:
          final aIndex = recentOrder[a.id] ?? 999999;
          final bIndex = recentOrder[b.id] ?? 999999;
          return aIndex.compareTo(bIndex);
        case LibrarySortMode.recentlyAdded:
          return b.lastModifiedEpochMs.compareTo(a.lastModifiedEpochMs);
      }
    });

    return Column(
      children: [
        _VideoToolbar(viewState: viewState),
        Expanded(
          child: filtered.isEmpty
              ? Center(child: Text(l10n.noVideosFound))
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final video = filtered[index];
                    return _VideoTile(
                      video: video,
                      queue: filtered,
                      queueIndex: index,
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _VideoToolbar extends ConsumerWidget {
  const _VideoToolbar({required this.viewState});

  final LibraryViewState viewState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final controller = ref.read(libraryViewControllerProvider.notifier);
    const extensions = <String?>[null, 'mp4', 'mkv', 'avi', 'webm'];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: extensions
                .map(
                  (extension) => ChoiceChip(
                    label: Text(extension == null ? l10n.videos : extension.toUpperCase()),
                    selected: viewState.extensionFilter == extension,
                    onSelected: (_) => controller.setExtensionFilter(extension),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _SortChip(
                label: 'Recent Added',
                selected: viewState.sortMode == LibrarySortMode.recentlyAdded,
                onTap: () => controller.setSortMode(LibrarySortMode.recentlyAdded),
              ),
              _SortChip(
                label: 'Recent Played',
                selected: viewState.sortMode == LibrarySortMode.recentlyPlayed,
                onTap: () => controller.setSortMode(LibrarySortMode.recentlyPlayed),
              ),
              _SortChip(
                label: 'Name',
                selected: viewState.sortMode == LibrarySortMode.name,
                onTap: () => controller.setSortMode(LibrarySortMode.name),
              ),
              _SortChip(
                label: 'Size',
                selected: viewState.sortMode == LibrarySortMode.fileSize,
                onTap: () => controller.setSortMode(LibrarySortMode.fileSize),
              ),
              _SortChip(
                label: 'Duration',
                selected: viewState.sortMode == LibrarySortMode.duration,
                onTap: () => controller.setSortMode(LibrarySortMode.duration),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  const _SortChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}

class _VideoTile extends ConsumerWidget {
  const _VideoTile({
    required this.video,
    required this.queue,
    required this.queueIndex,
  });

  final VideoItem video;
  final List<VideoItem> queue;
  final int queueIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlists = ref.watch(playlistControllerProvider).playlists;
    final favorites = ref.watch(favoritesControllerProvider);
    final isFavorite = favorites.contains(video.id);

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: _VideoThumbnail(video: video),
        title: Text(video.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            '${video.folderName} • ${Formatters.duration(video.duration)} • ${Formatters.resolution(video.width, video.height)} • ${Formatters.fileSize(video.fileSizeBytes)}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'favorite') {
              ref.read(favoritesControllerProvider.notifier).toggle(video.id);
              return;
            }
            if (value == 'new_playlist') {
              await _createPlaylistDialog(context, ref, video);
              return;
            }
            final playlistId = int.tryParse(value);
            if (playlistId != null) {
              await ref.read(playlistControllerProvider.notifier).addVideo(
                    playlistId: playlistId,
                    videoId: video.id,
                    title: video.title,
                    path: video.path,
                  );
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem<String>(
              value: 'favorite',
              child: Text(isFavorite ? 'Unfavorite' : 'Favorite'),
            ),
            const PopupMenuItem<String>(
              value: 'new_playlist',
              child: Text('New playlist'),
            ),
            ...playlists.map(
              (playlist) => PopupMenuItem<String>(
                value: playlist.id.toString(),
                child: Text('Add to ${playlist.name}'),
              ),
            ),
          ],
        ),
        onTap: () async {
          await ref.read(sharedPlayerControllerProvider.notifier).openVideoQueue(queue, startIndex: queueIndex);
          if (context.mounted) {
            Navigator.of(context).pushNamed(PlayerScreen.routeName);
          }
        },
      ),
    );
  }

  Future<void> _createPlaylistDialog(BuildContext context, WidgetRef ref, VideoItem video) async {
    final controller = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create playlist'),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) {
                return;
              }
              await ref.read(playlistControllerProvider.notifier).createPlaylist(name);
              final playlists = ref.read(playlistControllerProvider).playlists;
              final created = playlists.where((playlist) => playlist.name == name).toList();
              if (created.isNotEmpty) {
                await ref.read(playlistControllerProvider.notifier).addVideo(
                      playlistId: created.first.id,
                      videoId: video.id,
                      title: video.title,
                      path: video.path,
                    );
              }
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _VideoThumbnail extends ConsumerWidget {
  const _VideoThumbnail({required this.video});

  final VideoItem video;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final thumbnail = ref.watch(videoThumbnailProvider(video));

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 92,
        height: 68,
        color: const Color(0xFF111827),
        child: thumbnail.when(
          data: (path) {
            if (path != null && File(path).existsSync()) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(File(path), fit: BoxFit.cover),
                  const Align(
                    alignment: Alignment.center,
                    child: Icon(Icons.play_circle_fill_rounded, color: Colors.white70, size: 28),
                  ),
                ],
              );
            }
            return const Icon(Icons.movie_creation_outlined, color: Colors.white70);
          },
          loading: () => const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
          error: (_, __) => const Icon(Icons.broken_image_outlined, color: Colors.white70),
        ),
      ),
    );
  }
}
