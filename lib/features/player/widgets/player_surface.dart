import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../../localization/generated/app_localizations.dart';
import '../controllers/player_controller.dart';

class PlayerSurface extends ConsumerStatefulWidget {
  const PlayerSurface({
    super.key,
    this.showOverlay = true,
  });

  final bool showOverlay;

  @override
  ConsumerState<PlayerSurface> createState() => _PlayerSurfaceState();
}

class _PlayerSurfaceState extends ConsumerState<PlayerSurface> {
  double? _dragStartX;
  Duration? _dragStartPosition;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = ref.read(sharedPlayerControllerProvider.notifier);
    final state = ref.watch(sharedPlayerControllerProvider);

    if (!state.hasMedia) {
      return Center(child: Text(l10n.noMediaSelected));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth <= 0 ? 1.0 : constraints.maxWidth;
        final brightnessOverlay = ((1 - state.brightness) * 0.7).clamp(0.0, 0.7);
        return GestureDetector(
          onScaleUpdate: (details) {
            controller.setZoom(state.zoom * details.scale);
          },
          onHorizontalDragStart: (details) {
            _dragStartX = details.localPosition.dx;
            _dragStartPosition = state.position;
          },
          onHorizontalDragUpdate: (details) {
            final base = _dragStartPosition ?? state.position;
            final deltaFraction = (details.localPosition.dx - (_dragStartX ?? 0)) / width;
            final target = base + Duration(milliseconds: (state.duration.inMilliseconds * deltaFraction).round());
            controller.seekTo(target < Duration.zero ? Duration.zero : target);
          },
          onVerticalDragUpdate: (details) {
            final isLeft = details.localPosition.dx < width / 2;
            final delta = details.primaryDelta == null ? 0 : -details.primaryDelta! / 300;
            if (isLeft) {
              controller.setBrightness(state.brightness + delta);
            } else {
              controller.setVolume(state.volume + (delta * 100));
            }
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              ColoredBox(
                color: Colors.black,
                child: Transform.scale(
                  scale: state.zoom,
                  child: Video(
                    controller: controller.videoController,
                    controls: NoVideoControls,
                    fit: BoxFit.contain,
                    subtitleViewConfiguration: SubtitleViewConfiguration(
                      style: TextStyle(
                        fontSize: state.subtitleFontSize,
                        color: state.subtitleColor,
                        backgroundColor: Colors.black.withOpacity(0.4),
                      ),
                    ),
                  ),
                ),
              ),
              if (brightnessOverlay > 0)
                IgnorePointer(
                  child: ColoredBox(color: Colors.black.withOpacity(brightnessOverlay)),
                ),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onDoubleTap: () => controller.seekRelative(const Duration(seconds: -10)),
                      child: const ColoredBox(color: Colors.transparent),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onDoubleTap: () => controller.seekRelative(const Duration(seconds: 10)),
                      child: const ColoredBox(color: Colors.transparent),
                    ),
                  ),
                ],
              ),
              if (widget.showOverlay) _StatusOverlay(state: state),
            ],
          ),
        );
      },
    );
  }
}

class _StatusOverlay extends StatelessWidget {
  const _StatusOverlay({required this.state});

  final SharedPlayerState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return IgnorePointer(
      child: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              children: [
                _Pill(label: '${l10n.volume}: ${state.volume.round()}%'),
                _Pill(label: '${l10n.brightness}: ${(state.brightness * 100).round()}%'),
                _Pill(label: '${l10n.zoom}: ${state.zoom.toStringAsFixed(2)}x'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label),
    );
  }
}
