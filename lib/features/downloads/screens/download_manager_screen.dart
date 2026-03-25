import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/download_item.dart';
import '../../../localization/generated/app_localizations.dart';
import '../controllers/download_controller.dart';

class DownloadManagerScreen extends ConsumerStatefulWidget {
  const DownloadManagerScreen({super.key});

  static const String routeName = '/downloads';

  @override
  ConsumerState<DownloadManagerScreen> createState() => _DownloadManagerScreenState();
}

class _DownloadManagerScreenState extends ConsumerState<DownloadManagerScreen> {
  late final TextEditingController _urlController;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController();
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final downloads = ref.watch(downloadControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.downloadManager)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          TextField(
            controller: _urlController,
            decoration: InputDecoration(
              labelText: l10n.downloadUrl,
              hintText: l10n.downloadHint,
              suffixIcon: IconButton(
                onPressed: () {
                  final url = _urlController.text.trim();
                  if (url.isEmpty) {
                    return;
                  }
                  ref.read(downloadControllerProvider.notifier).add(url);
                  _urlController.clear();
                },
                icon: const Icon(Icons.download_rounded),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (downloads.isEmpty)
            Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(l10n.downloadHistory)))
          else
            ...downloads.map((item) => _DownloadTile(item: item)),
        ],
      ),
    );
  }
}

class _DownloadTile extends ConsumerWidget {
  const _DownloadTile({required this.item});

  final DownloadItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    String statusLabel;
    switch (item.status) {
      case DownloadStatus.queued:
        statusLabel = l10n.downloadQueued;
        break;
      case DownloadStatus.running:
        statusLabel = l10n.downloadRunning;
        break;
      case DownloadStatus.paused:
        statusLabel = l10n.downloadPaused;
        break;
      case DownloadStatus.completed:
        statusLabel = l10n.downloadComplete;
        break;
      case DownloadStatus.failed:
        statusLabel = l10n.downloadFailed;
        break;
      case DownloadStatus.canceled:
        statusLabel = l10n.cancel;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(item.fileName),
        subtitle: Text('$statusLabel • ${item.url}'),
        trailing: Wrap(
          spacing: 8,
          children: [
            if (item.status == DownloadStatus.running)
              IconButton(
                onPressed: () => ref.read(downloadControllerProvider.notifier).pause(item),
                icon: const Icon(Icons.pause_rounded),
              ),
            if (item.status == DownloadStatus.paused)
              IconButton(
                onPressed: () => ref.read(downloadControllerProvider.notifier).resume(item),
                icon: const Icon(Icons.play_arrow_rounded),
              ),
            IconButton(
              onPressed: () => ref.read(downloadControllerProvider.notifier).cancel(item),
              icon: const Icon(Icons.close_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
