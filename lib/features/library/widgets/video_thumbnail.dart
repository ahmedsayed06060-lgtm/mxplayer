import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/themes/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/mx_common.dart';
import '../../../data/models/video_item.dart';
import '../controllers/library_controller.dart';

/// 16:9 thumbnail with a duration badge and an optional watch progress line.
class VideoThumbnail extends ConsumerWidget {
  const VideoThumbnail({
    super.key,
    required this.video,
    this.width,
    this.height,
    this.radius = 10,
    this.progress,
    this.showDuration = true,
    this.showPlayBadge = false,
    this.fit = BoxFit.cover,
  });

  final VideoItem video;
  final double? width;
  final double? height;
  final double radius;
  final double? progress;
  final bool showDuration;
  final bool showPlayBadge;
  final BoxFit fit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<String?> thumbnail = ref.watch(videoThumbnailProvider(video));
    final double? value = (progress ?? 0) > 0.01 ? progress : null;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[Color(0xFF23262D), Color(0xFF14161A)],
                ),
              ),
            ),
            thumbnail.when(
              data: (String? path) {
                if (path == null || !File(path).existsSync()) {
                  return const _ThumbFallback();
                }
                return Image.file(
                  File(path),
                  fit: fit,
                  gaplessPlayback: true,
                  errorBuilder: (_, __, ___) => const _ThumbFallback(),
                );
              },
              loading: () => const _ThumbFallback(),
              error: (_, __) => const _ThumbFallback(),
            ),
            if (showPlayBadge)
              Center(
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.45),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 22),
                ),
              ),
            if (showDuration && video.duration != null)
              Positioned(
                right: 5,
                bottom: 5,
                child: MxBadge(label: Formatters.duration(video.duration), dense: true),
              ),
            if (video.width != null && video.height != null)
              Positioned(
                left: 5,
                top: 5,
                child: MxBadge(
                  label: _qualityLabel(video.width!, video.height!),
                  dense: true,
                  background: Colors.black.withOpacity(0.55),
                  foreground: MxColors.brand,
                ),
              ),
            if (value != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: MxProgressLine(value: value, height: 3),
              ),
          ],
        ),
      ),
    );
  }

  static String _qualityLabel(int width, int height) {
    final int shortest = width < height ? width : height;
    if (shortest >= 2160) {
      return '4K';
    }
    if (shortest >= 1080) {
      return 'FHD';
    }
    if (shortest >= 720) {
      return 'HD';
    }
    return 'SD';
  }
}

class _ThumbFallback extends StatelessWidget {
  const _ThumbFallback();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        Icons.movie_creation_outlined,
        color: Colors.white.withOpacity(0.32),
        size: 24,
      ),
    );
  }
}
