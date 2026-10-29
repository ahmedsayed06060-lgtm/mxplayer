import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/themes/app_theme.dart';
import '../../../core/widgets/mx_common.dart';
import '../../../data/models/download_item.dart';
import '../../../localization/generated/app_localizations.dart';
import '../../player/controllers/player_controller.dart';
import '../../player/models/playback_item.dart';
import '../../player/screens/player_screen.dart';
import '../controllers/download_controller.dart';

class DownloadManagerScreen extends ConsumerStatefulWidget {
  const DownloadManagerScreen({super.key});

  static const String routeName = '/downloads';

  @override
  ConsumerState<DownloadManagerScreen> createState() => _DownloadManagerScreenState();
}

class _DownloadManagerScreenState extends ConsumerState<DownloadManagerScreen> {
  final TextEditingController _urlController = TextEditingController();

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _submit() {
    final String url = _urlController.text.trim();
    if (url.isEmpty) {
      return;
    }
    ref.read(downloadControllerProvider.notifier).add(url);
    _urlController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final List<DownloadItem> downloads = ref.watch(downloadControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.downloadManager),
        actions: <Widget>[
          IconButton(
            tooltip: l10n.addDownload,
            onPressed: () => _showAddDialog(l10n),
            icon: const Icon(Icons.add_link_rounded),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: <Widget>[
          MxSurface(
            radius: 16,
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: MxColors.brand.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.download_rounded, color: MxColors.brand, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n.downloadHint,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11.5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: _urlController,
                        keyboardType: TextInputType.url,
                        decoration: InputDecoration(
                          hintText: l10n.downloadUrl,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                        onSubmitted: (_) => _submit(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: _submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: MxColors.brand,
                        foregroundColor: const Color(0xFF06210F),
                        minimumSize: const Size(0, 44),
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        l10n.addDownload,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: <Widget>[
              Container(width: 3, height: 15, decoration: BoxDecoration(
                color: MxColors.brand,
                borderRadius: BorderRadius.circular(2),
              )),
              const SizedBox(width: 9),
              Text(l10n.downloadHistory, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 15)),
              const Spacer(),
              Text('${downloads.length}', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 12),
          if (downloads.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: MxEmptyState(
                compact: true,
                icon: Icons.cloud_download_outlined,
                title: l10n.downloadsEmpty,
                message: l10n.downloadHint,
              ),
            )
          else
            for (final DownloadItem item in downloads)
              _DownloadTile(item: item),
        ],
      ),
    );
  }

  Future<void> _showAddDialog(AppLocalizations l10n) async {
    final TextEditingController controller = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(l10n.addDownload),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(labelText: l10n.downloadUrl, hintText: l10n.downloadHint),
          ),
          actions: <Widget>[
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: Text(l10n.cancel)),
            FilledButton(
              onPressed: () {
                final String url = controller.text.trim();
                if (url.isNotEmpty) {
                  ref.read(downloadControllerProvider.notifier).add(url);
                }
                Navigator.of(dialogContext).pop();
              },
              child: Text(l10n.addDownload),
            ),
          ],
        );
      },
    );
    controller.dispose();
  }
}

class _DownloadTile extends ConsumerWidget {
  const _DownloadTile({required this.item});

  final DownloadItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final DownloadController controller = ref.read(downloadControllerProvider.notifier);

    final String statusLabel;
    final Color statusColor;
    switch (item.status) {
      case DownloadStatus.queued:
        statusLabel = l10n.downloadQueued;
        statusColor = MxColors.textSecondary;
        break;
      case DownloadStatus.running:
        statusLabel = '${l10n.downloadRunning} • ${item.progress}%';
        statusColor = MxColors.brand;
        break;
      case DownloadStatus.paused:
        statusLabel = l10n.downloadPaused;
        statusColor = const Color(0xFFFFC107);
        break;
      case DownloadStatus.completed:
        statusLabel = l10n.downloadComplete;
        statusColor = MxColors.brand;
        break;
      case DownloadStatus.failed:
        statusLabel = l10n.downloadFailed;
        statusColor = MxColors.danger;
        break;
      case DownloadStatus.canceled:
        statusLabel = l10n.cancel;
        statusColor = MxColors.textTertiary;
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: MxSurface(
        radius: 14,
        padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(
                    item.status == DownloadStatus.completed
                        ? Icons.check_circle_outline_rounded
                        : Icons.downloading_rounded,
                    color: statusColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        item.fileName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 13.5),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        statusLabel,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 11,
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
                if (item.status == DownloadStatus.running)
                  IconButton(
                    onPressed: () => controller.pause(item),
                    icon: const Icon(Icons.pause_rounded, size: 20),
                    tooltip: l10n.downloadPaused,
                  ),
                if (item.status == DownloadStatus.paused)
                  IconButton(
                    onPressed: () => controller.resume(item),
                    icon: const Icon(Icons.play_arrow_rounded, size: 20),
                    tooltip: l10n.resume,
                  ),
                if (item.status == DownloadStatus.completed && item.localPath != null)
                  IconButton(
                    onPressed: () async {
                      await ref.read(sharedPlayerControllerProvider.notifier).openNetwork(
                            id: item.id,
                            title: item.fileName,
                            url: Uri.file(item.localPath!).toString(),
                            type: PlaybackSourceType.local,
                          );
                      if (context.mounted) {
                        await Navigator.of(context).pushNamed(PlayerScreen.routeName);
                      }
                    },
                    icon: const Icon(Icons.play_circle_outline_rounded, size: 21),
                  ),
                IconButton(
                  onPressed: () => controller.cancel(item),
                  icon: const Icon(Icons.close_rounded, size: 19),
                  tooltip: l10n.cancel,
                ),
              ],
            ),
            if (item.status == DownloadStatus.running || item.progress > 0) ...<Widget>[
              const SizedBox(height: 10),
              MxProgressLine(value: item.progress / 100, height: 3),
            ],
          ],
        ),
      ),
    );
  }
}
