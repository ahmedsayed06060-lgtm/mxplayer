import 'dart:io';
import 'dart:typed_data';

import 'package:media_kit/media_kit.dart';
import 'package:path_provider/path_provider.dart';

import '../data/models/video_item.dart';

class MediaProbeService {
  Future<VideoItem> enrich(VideoItem item) async {
    final player = Player();

    try {
      await player.open(Media(Uri.file(item.path).toString()), play: false);
      await Future.any<dynamic>([
        player.stream.duration.firstWhere((value) => value > Duration.zero),
        Future<dynamic>.delayed(const Duration(milliseconds: 900)),
      ]);

      final state = player.state;
      return item.copyWith(
        durationMs: state.duration == Duration.zero
            ? item.durationMs
            : state.duration.inMilliseconds,
        width: state.width,
        height: state.height,
      );
    } catch (_) {
      return item;
    } finally {
      await player.dispose();
    }
  }

  Future<String?> buildThumbnail(VideoItem item) async {
    final player = Player();

    try {
      await player.open(Media(Uri.file(item.path).toString()), play: false);
      await Future<dynamic>.delayed(const Duration(milliseconds: 300));
      final bytes = await player.screenshot(format: 'image/jpeg');
      if (bytes == null || bytes.isEmpty) {
        return null;
      }
      return _persistThumbnail(item.id, bytes);
    } catch (_) {
      return null;
    } finally {
      await player.dispose();
    }
  }

  Future<String> _persistThumbnail(String id, Uint8List bytes) async {
    final tempDir = await getTemporaryDirectory();
    final safeId = id.hashCode.abs();
    final file = File('${tempDir.path}${Platform.pathSeparator}thumb_$safeId.jpg');
    if (!file.existsSync()) {
      await file.writeAsBytes(bytes, flush: true);
    }
    return file.path;
  }
}
