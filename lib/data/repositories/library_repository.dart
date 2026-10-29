import 'package:flutter/foundation.dart';

import '../models/library_snapshot.dart';
import '../models/video_folder.dart';
import '../models/video_item.dart';
import '../../services/media_probe_service.dart';
import '../../services/media_scan_service.dart';

class LibraryRepository {
  LibraryRepository({
    MediaScanService? scanService,
    MediaProbeService? probeService,
  })  : _scanService = scanService ?? MediaScanService(),
        _probeService = probeService ?? MediaProbeService();

  final MediaScanService _scanService;
  final MediaProbeService _probeService;

  Future<List<String>> resolveInitialRoots() => _scanService.resolveInitialRoots();

  Future<String?> pickDirectory() => _scanService.pickDirectory();

  Future<LibrarySnapshot> scan(List<String> roots) async {
    final rawItems = await _scanService.scanRoots(roots);
    final baseItems = rawItems
        .map(
          (raw) => VideoItem(
            id: raw.path,
            title: raw.title,
            path: raw.path,
            folderPath: raw.folderPath,
            folderName: raw.folderName,
            extension: raw.extension,
            fileSizeBytes: raw.fileSizeBytes,
            lastModifiedEpochMs: raw.lastModifiedEpochMs,
          ),
        )
        .toList();

    final enriched = await _enrich(baseItems);
    final folders = _groupFolders(enriched);

    return LibrarySnapshot(
      scanRoots: roots,
      videos: enriched,
      folders: folders,
      scannedAt: DateTime.now(),
    );
  }

  Future<VideoItem> enrichSingle(VideoItem item) => _probeService.enrich(item);

  Future<String?> buildThumbnail(VideoItem item) => _probeService.buildThumbnail(item);

  /// Probes metadata in small parallel batches to keep the first paint fast.
  ///
  /// Very large libraries are capped so the scan never blocks the UI for
  /// minutes; unchecked files still play, they simply show no duration badge.
  static const int _maxProbedItems = 120;
  static const int _probeConcurrency = 3;

  Future<List<VideoItem>> _enrich(List<VideoItem> items) async {
    if (items.isEmpty) {
      return items;
    }
    final List<VideoItem> results = List<VideoItem>.of(items);
    final int limit = items.length < _maxProbedItems ? items.length : _maxProbedItems;

    for (int start = 0; start < limit; start += _probeConcurrency) {
      final int end = (start + _probeConcurrency) > limit ? limit : start + _probeConcurrency;
      final List<VideoItem> batch = await Future.wait<VideoItem>(<Future<VideoItem>>[
        for (int index = start; index < end; index++) _probeService.enrich(items[index]),
      ]);
      for (int index = start; index < end; index++) {
        results[index] = batch[index - start];
      }
    }

    return results;
  }

  List<VideoFolder> _groupFolders(List<VideoItem> videos) {
    final grouped = <String, List<VideoItem>>{};
    for (final video in videos) {
      grouped.putIfAbsent(video.folderPath, () => <VideoItem>[]).add(video);
    }

    final folders = grouped.entries.map((entry) {
      final items = entry.value;
      final latest = items.fold<int>(0, (prev, item) => item.lastModifiedEpochMs > prev ? item.lastModifiedEpochMs : prev);
      final totalSize = items.fold<int>(0, (sum, item) => sum + item.fileSizeBytes);
      return VideoFolder(
        path: entry.key,
        name: items.first.folderName,
        videoCount: items.length,
        totalSizeBytes: totalSize,
        lastModifiedEpochMs: latest,
      );
    }).toList();

    folders.sort((a, b) => b.lastModifiedEpochMs.compareTo(a.lastModifiedEpochMs));
    return folders;
  }
}

