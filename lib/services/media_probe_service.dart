import 'dart:io';
import 'dart:typed_data';

import 'package:media_kit/media_kit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

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
    File? target;
    try {
      final Directory tempDir = await getTemporaryDirectory();
      final int safeId = item.id.hashCode.abs();
      target = File('${tempDir.path}${Platform.pathSeparator}thumb_$safeId.jpg');
      if (target.existsSync() && target.lengthSync() > 0) {
        return target.path;
      }
    } catch (_) {
      target = null;
    }

    // On mobile the platform extractor is much faster than spinning up a player.
    if ((Platform.isAndroid || Platform.isIOS) && target != null) {
      try {
        final String? file = await VideoThumbnail.thumbnailFile(
          video: item.path,
          thumbnailPath: target.path,
          imageFormat: ImageFormat.JPEG,
          maxHeight: 240,
          timeMs: 1000,
          quality: 72,
        );
        if (file != null && File(file).existsSync() && File(file).lengthSync() > 0) {
          return file;
        }
      } catch (_) {
        // Fall through to the media_kit screenshot below.
      }
    }

    final player = Player();

    try {
      await player.open(Media(Uri.file(item.path).toString()), play: false);
      await Future<dynamic>.delayed(const Duration(milliseconds: 400));
      final Uint8List? bytes = await player.screenshot(format: 'image/jpeg');
      if (bytes == null || bytes.isEmpty) {
        return null;
      }
      if (target != null) {
        await target.writeAsBytes(bytes, flush: true);
        return target.path;
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
