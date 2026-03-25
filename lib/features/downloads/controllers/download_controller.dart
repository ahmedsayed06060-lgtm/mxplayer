import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/database_provider.dart';
import '../../../data/models/download_item.dart';
import '../../../services/download_service.dart';

final downloadControllerProvider =
    StateNotifierProvider<DownloadController, List<DownloadItem>>(
  (ref) => DownloadController(ref, DownloadService()),
);

class DownloadController extends StateNotifier<List<DownloadItem>> {
  DownloadController(this._ref, this._service) : super(const []) {
    _hydrate();
  }

  final Ref _ref;
  final DownloadService _service;

  Future<void> _hydrate() async {
    state = await _ref.read(appDatabaseProvider).loadDownloads();
  }

  Future<void> add(String url) async {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final segments = Uri.tryParse(url)?.pathSegments ?? const <String>[];
    final fileName = segments.isEmpty ? 'download_$id.mp4' : segments.last;
    final queued = DownloadItem(
      id: id,
      url: url,
      fileName: fileName,
      status: DownloadStatus.queued,
      progress: 0,
    );
    state = [queued, ...state];
    await _ref.read(appDatabaseProvider).saveDownloadHistory(queued);
    final result = await _service.enqueue(id: id, url: url);
    await _replace(result);
  }

  Future<void> pause(DownloadItem item) async {
    await _service.pause(item.platformTaskId);
    await _replace(item.copyWith(status: DownloadStatus.paused));
  }

  Future<void> resume(DownloadItem item) async {
    await _service.resume(item.platformTaskId);
    await _replace(item.copyWith(status: DownloadStatus.running));
  }

  Future<void> cancel(DownloadItem item) async {
    await _service.cancel(item.platformTaskId);
    await _replace(item.copyWith(status: DownloadStatus.canceled));
  }

  Future<void> _replace(DownloadItem item) async {
    state = [
      for (final existing in state)
        if (existing.id == item.id) item else existing,
    ];
    await _ref.read(appDatabaseProvider).saveDownloadHistory(item);
  }
}
