import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/themes/app_theme.dart';
import '../../../../core/widgets/mx_common.dart';
import '../../../../data/models/video_folder.dart';
import '../../../../data/models/video_item.dart';
import '../../../../localization/generated/app_localizations.dart';
import '../../../favorites/controllers/favorites_controller.dart';
import '../../../player/controllers/recent_playback_controller.dart';
import '../../../player/models/recent_playback_item.dart';
import '../../widgets/video_actions.dart';
import '../../widgets/video_tile.dart';

class FolderVideosScreen extends ConsumerWidget {
  const FolderVideosScreen({
    super.key,
    required this.folder,
    required this.videos,
  });

  final VideoFolder folder;
  final List<VideoItem> videos;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final Set<String> favorites = ref.watch(favoritesControllerProvider);
    final List<RecentPlaybackItem> recent = ref.watch(recentPlaybackProvider);
    final Map<String, double> progressById = <String, double>{
      for (final RecentPlaybackItem item in recent)
        if (item.progress > 0.01) item.id: item.progress,
    };

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(folder.name, maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(
              '${videos.length} ${l10n.videosCount}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
            ),
          ],
        ),
        actions: <Widget>[
          if (videos.isNotEmpty)
            IconButton(
              tooltip: l10n.playAll,
              onPressed: () => playVideoQueue(context, ref, videos, 0),
              icon: const Icon(Icons.play_circle_outline_rounded),
            ),
          const SizedBox(width: 6),
        ],
      ),
      body: videos.isEmpty
          ? MxEmptyState(
              icon: Icons.videocam_off_outlined,
              title: l10n.noVideosFound,
              message: folder.path,
            )
          : ListView.builder(
              padding: const EdgeInsets.only(top: 6, bottom: 32),
              itemCount: videos.length,
              itemBuilder: (BuildContext context, int index) {
                final VideoItem video = videos[index];
                return VideoListTile(
                  video: video,
                  progress: progressById[video.id],
                  isFavorite: favorites.contains(video.id),
                  onTap: () => playVideoQueue(context, ref, videos, index),
                  onMore: () => showVideoActions(
                    context,
                    ref,
                    video,
                    queue: videos,
                    index: index,
                  ),
                );
              },
            ),
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? MxColors.background
          : MxColors.lightBackground,
    );
  }
}
