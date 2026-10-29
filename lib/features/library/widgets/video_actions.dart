import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/themes/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/mx_common.dart';
import '../../../data/models/video_item.dart';
import '../../../localization/generated/app_localizations.dart';
import '../../favorites/controllers/favorites_controller.dart';
import '../../player/controllers/player_controller.dart';
import '../../player/screens/player_screen.dart';
import '../../playlists/controllers/playlist_controller.dart';

Future<void> playVideoQueue(
  BuildContext context,
  WidgetRef ref,
  List<VideoItem> queue,
  int index,
) async {
  await ref.read(sharedPlayerControllerProvider.notifier).openVideoQueue(queue, startIndex: index);
  if (context.mounted) {
    await Navigator.of(context).pushNamed(PlayerScreen.routeName);
  }
}

/// MX Player style "long press / ⋮" sheet for a single video.
Future<void> showVideoActions(
  BuildContext context,
  WidgetRef ref,
  VideoItem video, {
  List<VideoItem>? queue,
  int index = 0,
}) async {
  final AppLocalizations l10n = AppLocalizations.of(context)!;
  final bool isFavorite = ref.read(favoritesControllerProvider).contains(video.id);

  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (BuildContext sheetContext) {
      return SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 56,
                    height: 56,
                    color: MxColors.surfaceHigh,
                    child: const Icon(Icons.movie_outlined, color: Colors.white54),
                  ),
                ),
                title: Text(video.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                subtitle: Text(
                  '${video.extension.toUpperCase()} • ${Formatters.fileSize(video.fileSizeBytes)}',
                ),
              ),
              const Divider(height: 12),
              _ActionRow(
                icon: Icons.play_arrow_rounded,
                label: l10n.play,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  playVideoQueue(context, ref, queue ?? <VideoItem>[video], queue == null ? 0 : index);
                },
              ),
              _ActionRow(
                icon: isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                label: isFavorite ? l10n.unfavorite : l10n.favorite,
                highlighted: isFavorite,
                onTap: () {
                  ref.read(favoritesControllerProvider.notifier).toggle(video.id);
                  Navigator.of(sheetContext).pop();
                },
              ),
              _ActionRow(
                icon: Icons.playlist_add_rounded,
                label: l10n.playlists,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _showPlaylistPicker(context, ref, video);
                },
              ),
              _ActionRow(
                icon: Icons.info_outline_rounded,
                label: l10n.videoInfo,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _showVideoInfo(context, video);
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.highlighted = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      leading: Icon(icon, color: highlighted ? MxColors.brand : null),
      title: Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14.5)),
      onTap: onTap,
    );
  }
}

Future<void> _showPlaylistPicker(BuildContext context, WidgetRef ref, VideoItem video) async {
  final AppLocalizations l10n = AppLocalizations.of(context)!;
  final PlaylistState playlists = ref.read(playlistControllerProvider);

  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (BuildContext sheetContext) {
      return SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            MxSheetHeader(title: l10n.playlists),
            ListTile(
              leading: const Icon(Icons.add_rounded, color: MxColors.brand),
              title: Text(l10n.createPlaylist),
              onTap: () async {
                Navigator.of(sheetContext).pop();
                final String? name = await _askPlaylistName(context);
                if (name == null || name.trim().isEmpty) {
                  return;
                }
                await ref.read(playlistControllerProvider.notifier).createPlaylist(name.trim());
                final PlaylistState updated = ref.read(playlistControllerProvider);
                final match = updated.playlists.where((p) => p.name == name.trim()).toList();
                if (match.isNotEmpty) {
                  await ref.read(playlistControllerProvider.notifier).addVideo(
                        playlistId: match.first.id,
                        videoId: video.id,
                        title: video.title,
                        path: video.path,
                      );
                }
              },
            ),
            if (playlists.playlists.isEmpty)
              ListTile(
                title: Text(l10n.noPlaylists, style: Theme.of(context).textTheme.bodySmall),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 320),
                child: ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    for (final playlist in playlists.playlists)
                      ListTile(
                        leading: const Icon(Icons.queue_music_rounded),
                        title: Text(playlist.name),
                        subtitle: Text('${(playlists.items[playlist.id] ?? const []).length} ${l10n.items}'),
                        onTap: () async {
                          Navigator.of(sheetContext).pop();
                          await ref.read(playlistControllerProvider.notifier).addVideo(
                                playlistId: playlist.id,
                                videoId: video.id,
                                title: video.title,
                                path: video.path,
                              );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${playlist.name} • ${l10n.save}')),
                            );
                          }
                        },
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}

Future<String?> _askPlaylistName(BuildContext context) async {
  final AppLocalizations l10n = AppLocalizations.of(context)!;
  final TextEditingController controller = TextEditingController();
  final String? result = await showDialog<String>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: Text(l10n.createPlaylist),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(labelText: l10n.playlistName),
          onSubmitted: (String value) => Navigator.of(dialogContext).pop(value),
        ),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text),
            child: Text(l10n.save),
          ),
        ],
      );
    },
  );
  controller.dispose();
  return result;
}

void _showVideoInfo(BuildContext context, VideoItem video) {
  final AppLocalizations l10n = AppLocalizations.of(context)!;
  final List<List<String>> rows = <List<String>>[
    <String>[l10n.pathLabel, video.path],
    <String>[l10n.folderPath, video.folderPath],
    <String>[l10n.fileSize, Formatters.fileSize(video.fileSizeBytes)],
    <String>[l10n.durationLabel, Formatters.duration(video.duration)],
    <String>[l10n.resolution, Formatters.resolution(video.width, video.height)],
    <String>[l10n.encoding, video.extension.toUpperCase()],
  ];

  showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: Text(l10n.videoInfo),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for (final List<String> row in rows)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(row[0], style: Theme.of(dialogContext).textTheme.labelSmall),
                      const SizedBox(height: 2),
                      Text(row[1], style: Theme.of(dialogContext).textTheme.bodyMedium),
                    ],
                  ),
                ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.close),
          ),
        ],
      );
    },
  );
}
