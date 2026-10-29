import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/themes/app_theme.dart';
import '../../../core/widgets/mx_common.dart';
import '../../../data/models/video_item.dart';
import '../../../localization/generated/app_localizations.dart';
import '../../library/controllers/library_controller.dart';
import '../../library/widgets/video_thumbnail.dart';
import '../../player/controllers/player_controller.dart';
import '../../player/models/playback_item.dart';
import '../../player/screens/player_screen.dart';

/// MX Player style mini player docked above the navigation bar.
class MiniPlayerBar extends ConsumerWidget {
  const MiniPlayerBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SharedPlayerState state = ref.watch(sharedPlayerControllerProvider);
    final SharedPlayerController controller = ref.read(sharedPlayerControllerProvider.notifier);
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    if (!state.hasMedia) {
      return const SizedBox.shrink();
    }

    final PlaybackItem item = state.current!;
    final VideoItem? video = _findVideo(ref, item);

    return Material(
      color: isDark ? const Color(0xFF171A1E) : MxColors.lightSurface,
      child: InkWell(
        onTap: () => Navigator.of(context).pushNamed(PlayerScreen.routeName),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Divider(
              height: 0.8,
              thickness: 0.8,
              color: isDark ? MxColors.divider : MxColors.lightDivider,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 6, 8),
              child: Row(
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 62,
                      height: 38,
                      child: video != null
                          ? VideoThumbnail(video: video, radius: 0, showDuration: false)
                          : const DecoratedBox(
                              decoration: BoxDecoration(gradient: MxColors.brandGradient),
                              child: Icon(Icons.play_arrow_rounded, color: Color(0xFF06210F), size: 22),
                            ),
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: <Widget>[
                            if (state.isPlaying)
                              const Padding(
                                padding: EdgeInsets.only(right: 6),
                                child: Icon(Icons.waves_rounded, size: 12, color: MxColors.brand),
                              ),
                            Text(
                              '${_format(state.position)} / ${_format(state.duration)}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10.5),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: controller.togglePlayPause,
                    visualDensity: VisualDensity.compact,
                    iconSize: 24,
                    tooltip: state.isPlaying ? l10n.pause : l10n.play,
                    icon: Icon(state.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded),
                  ),
                  IconButton(
                    onPressed: () => controller.stop(),
                    visualDensity: VisualDensity.compact,
                    iconSize: 20,
                    tooltip: l10n.close,
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            MxProgressLine(value: state.progress, height: 2.5, background: Colors.white10),
          ],
        ),
      ),
    );
  }

  VideoItem? _findVideo(WidgetRef ref, PlaybackItem item) {
    if (item.sourceType != PlaybackSourceType.local) {
      return null;
    }
    final snapshot = ref.watch(libraryControllerProvider).valueOrNull;
    if (snapshot == null) {
      return null;
    }
    final String path = Uri.parse(item.uri).toFilePath();
    for (final VideoItem video in snapshot.videos) {
      if (video.path == path) {
        return video;
      }
    }
    return null;
  }

  static String _format(Duration duration) {
    final int hours = duration.inHours;
    final String minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final String seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return hours > 0 ? '$hours:$minutes:$seconds' : '${duration.inMinutes}:$seconds';
  }
}
