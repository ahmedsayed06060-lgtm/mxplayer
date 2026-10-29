import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../controllers/player_controller.dart';

/// Raw video output (no controls) with aspect fitting, zoom, night mode and a
/// brightness overlay — the gesture/UI layer lives in [PlayerScreen].
class PlayerSurface extends ConsumerWidget {
  const PlayerSurface({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SharedPlayerState state = ref.watch(sharedPlayerControllerProvider);
    final SharedPlayerController controller = ref.read(sharedPlayerControllerProvider.notifier);

    if (!state.hasMedia) {
      return const ColoredBox(color: Colors.black);
    }

    final BoxFit fit;
    switch (state.aspectMode) {
      case PlayerAspectMode.fit:
        fit = BoxFit.contain;
        break;
      case PlayerAspectMode.crop:
        fit = BoxFit.cover;
        break;
      case PlayerAspectMode.stretch:
        fit = BoxFit.fill;
        break;
      case PlayerAspectMode.original:
        fit = BoxFit.scaleDown;
        break;
    }

    final double brightnessOverlay = ((1 - state.brightness) * 0.75).clamp(0.0, 0.8).toDouble();

    return ColoredBox(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Transform.scale(
            scale: state.zoom,
            child: Video(
              controller: controller.videoController,
              controls: NoVideoControls,
              fit: fit,
              subtitleViewConfiguration: SubtitleViewConfiguration(
                style: TextStyle(
                  fontSize: state.subtitleFontSize,
                  color: state.subtitleColor,
                  fontWeight: FontWeight.w600,
                  backgroundColor: Colors.black.withOpacity(0.35),
                  height: 1.35,
                ),
              ),
            ),
          ),
          if (state.nightMode)
            const IgnorePointer(
              child: ColoredBox(color: Color(0x33FF9E3D)),
            ),
          if (brightnessOverlay > 0.01)
            IgnorePointer(
              child: ColoredBox(color: Colors.black.withOpacity(brightnessOverlay)),
            ),
        ],
      ),
    );
  }
}
