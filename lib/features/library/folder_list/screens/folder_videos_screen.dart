import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../data/models/video_folder.dart';
import '../../../../data/models/video_item.dart';
import '../../../../localization/generated/app_localizations.dart';
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
                    leading: Container(
                      width: 72,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1F2A37), Color(0xFF111827)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Icon(Icons.play_circle_fill_rounded),
                    ),
                    title: Text(video.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '${Formatters.duration(video.duration)} • ${Formatters.resolution(video.width, video.height)} • ${Formatters.fileSize(video.fileSizeBytes)}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
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
