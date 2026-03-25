import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/models/video_folder.dart';
import '../../../../localization/generated/app_localizations.dart';
import '../../../library/controllers/library_controller.dart';
import '../../../player/controllers/player_controller.dart';
import '../../../player/screens/player_screen.dart';
import '../../../../core/utils/formatters.dart';

class FolderListScreen extends ConsumerWidget {
  const FolderListScreen({super.key, required this.folders});

  final List<VideoFolder> folders;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final snapshot = ref.watch(libraryControllerProvider).valueOrNull;
    if (folders.isEmpty) {
      return Center(child: Text(l10n.noFoldersFound));
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      itemCount: folders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final folder = folders[index];
        return Card(
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            leading: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.4),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.folder_open_rounded),
            ),
            title: Text(folder.name),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                '${folder.videoCount} ${l10n.items} • ${Formatters.fileSize(folder.totalSizeBytes)}\n${folder.path}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            trailing: const Icon(Icons.play_arrow_rounded),
            onTap: () async {
              final matches = snapshot?.videos.where((video) => video.folderPath == folder.path).toList() ?? const [];
              if (matches.isEmpty) {
                return;
              }
              await ref.read(sharedPlayerControllerProvider.notifier).openVideoItem(matches.first);
              if (context.mounted) {
                Navigator.of(context).pushNamed(PlayerScreen.routeName);
              }
            },
          ),
        );
      },
    );
  }
}
