import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../data/models/video_folder.dart';
import '../../../../data/models/video_item.dart';
import '../../../../localization/generated/app_localizations.dart';
import '../../controllers/library_controller.dart';
import '../../../player/controllers/player_controller.dart';
import '../../../player/screens/player_screen.dart';

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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(folder.name)),
      body: videos.isEmpty
          ? Center(child: Text(l10n.noVideosFound))
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: videos.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final video = videos[index];
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    leading: _FolderVideoThumbnail(video: video),
                    title: Text(video.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '${Formatters.duration(video.duration)} • ${Formatters.resolution(video.width, video.height)} • ${Formatters.fileSize(video.fileSizeBytes)}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () async {
                      await ref.read(sharedPlayerControllerProvider.notifier).openVideoQueue(videos, startIndex: index);
                      if (context.mounted) {
                        Navigator.of(context).pushNamed(PlayerScreen.routeName);
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}

class _FolderVideoThumbnail extends ConsumerWidget {
  const _FolderVideoThumbnail({required this.video});

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
              return Image.file(File(path), fit: BoxFit.cover);
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
