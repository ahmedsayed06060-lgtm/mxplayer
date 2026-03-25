import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/download_item.dart';
import '../../../services/download_service.dart';

final downloadControllerProvider =
    StateNotifierProvider<DownloadController, List<DownloadItem>>(
  (ref) => DownloadController(DownloadService()),
);

class DownloadController extends StateNotifier<List<DownloadItem>> {
  DownloadController(this._service) : super(const []);

  final DownloadService _service;

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
    final result = await _service.enqueue(id: id, url: url);
    _replace(result);
  }

  Future<void> pause(DownloadItem item) async {
    await _service.pause(item.platformTaskId);
    _replace(item.copyWith(status: DownloadStatus.paused));
  }

  Future<void> resume(DownloadItem item) async {
    await _service.resume(item.platformTaskId);
    _replace(item.copyWith(status: DownloadStatus.running));
  }

  Future<void> cancel(DownloadItem item) async {
    await _service.cancel(item.platformTaskId);
    _replace(item.copyWith(status: DownloadStatus.canceled));
  }

  void _replace(DownloadItem item) {
    state = [
      for (final existing in state)
        if (existing.id == item.id) item else existing,
    ];
  }
}
