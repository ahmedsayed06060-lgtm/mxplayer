import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/themes/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/mx_common.dart';
import '../../../../data/models/library_snapshot.dart';
import '../../../../data/models/video_folder.dart';
import '../../../../data/models/video_item.dart';
import '../../../../localization/generated/app_localizations.dart';
import '../../../library/controllers/library_controller.dart';
import 'folder_videos_screen.dart';

class FolderListScreen extends ConsumerWidget {
  const FolderListScreen({super.key, required this.folders});

  final List<VideoFolder> folders;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final LibrarySnapshot? snapshot = ref.watch(libraryControllerProvider).valueOrNull;

    if (folders.isEmpty) {
      return MxEmptyState(
        icon: Icons.folder_off_outlined,
        title: l10n.noFoldersFound,
        message: l10n.noLibraryFoundMessage,
        actionLabel: l10n.selectFolder,
        onAction: () => ref.read(libraryControllerProvider.notifier).pickAndScanDirectory(),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 140),
      itemCount: folders.length,
      itemBuilder: (BuildContext context, int index) {
        final VideoFolder folder = folders[index];
        final List<VideoItem> videos = snapshot?.videos
                .where((VideoItem video) => video.folderPath == folder.path)
                .toList() ??
            <VideoItem>[];

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: MxSurface(
            radius: 14,
            border: false,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => FolderVideosScreen(folder: folder, videos: videos),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 11, 10, 11),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: MxColors.brand.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.folder_rounded, color: MxColors.brand, size: 23),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          folder.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14.5),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${folder.videoCount} ${l10n.videosCount} • ${Formatters.fileSize(folder.totalSizeBytes)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11.5),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, size: 20, color: MxColors.textTertiary),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
