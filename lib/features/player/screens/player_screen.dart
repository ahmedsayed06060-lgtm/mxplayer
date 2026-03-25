import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/formatters.dart';
import '../../../localization/generated/app_localizations.dart';
import '../../favorites/controllers/favorites_controller.dart';
import '../controllers/player_controller.dart';
import '../widgets/player_surface.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  const PlayerScreen({super.key});

  static const String routeName = '/player';

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  bool _fullscreen = false;

  @override
  void dispose() {
    if (_fullscreen) {
      _exitFullscreen();
    }
    super.dispose();
  }

  Future<void> _enterFullscreen() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    setState(() => _fullscreen = true);
  }

  Future<void> _exitFullscreen() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    await SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    setState(() => _fullscreen = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(sharedPlayerControllerProvider);
    final controller = ref.read(sharedPlayerControllerProvider.notifier);
    final isFavorite = state.current != null && ref.watch(favoritesControllerProvider).contains(state.current!.id);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _fullscreen
          ? null
          : AppBar(
              title: Text(state.current?.title ?? l10n.player),
              actions: [
                IconButton(
                  onPressed: state.current == null ? null : controller.toggleFavoriteCurrent,
                  icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
                ),
                IconButton(
                  onPressed: state.current == null ? null : () => _fullscreen ? _exitFullscreen() : _enterFullscreen(),
                  icon: const Icon(Icons.fullscreen),
                ),
              ],
            ),
      body: state.current == null
          ? Center(child: Text(l10n.noMediaSelected))
          : Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      const Positioned.fill(child: PlayerSurface()),
                      if (state.locked)
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.65),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(l10n.playerLocked),
                          ),
                        ),
                      SafeArea(
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: IconButton.filledTonal(
                              onPressed: controller.toggleLock,
                              icon: Icon(state.locked ? Icons.lock : Icons.lock_open),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!state.locked)
                  _PlayerControls(
                    fullscreen: _fullscreen,
                    onFullscreenToggle: () => _fullscreen ? _exitFullscreen() : _enterFullscreen(),
                  ),
              ],
            ),
    );
  }
}

class _PlayerControls extends ConsumerWidget {
  const _PlayerControls({
    required this.fullscreen,
    required this.onFullscreenToggle,
  });

  final bool fullscreen;
  final VoidCallback onFullscreenToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(sharedPlayerControllerProvider);
    final controller = ref.read(sharedPlayerControllerProvider.notifier);

    return Material(
      color: const Color(0xFF111317),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(Formatters.duration(state.position)),
                  Expanded(
                    child: Slider(
                      value: state.duration.inMilliseconds == 0
                          ? 0
                          : state.position.inMilliseconds.clamp(0, state.duration.inMilliseconds).toDouble(),
                      max: state.duration.inMilliseconds == 0 ? 1 : state.duration.inMilliseconds.toDouble(),
                      onChanged: (value) {
                        controller.seekTo(Duration(milliseconds: value.round()));
                      },
                    ),
                  ),
                  Text(Formatters.duration(state.duration)),
                ],
              ),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  IconButton.filled(
                    onPressed: () => controller.seekRelative(const Duration(seconds: -10)),
                    icon: const Icon(Icons.replay_10_rounded),
                  ),
                  IconButton.filled(
                    onPressed: controller.togglePlayPause,
                    icon: Icon(state.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded),
                  ),
                  IconButton.filled(
                    onPressed: () => controller.seekRelative(const Duration(seconds: 10)),
                    icon: const Icon(Icons.forward_10_rounded),
                  ),
                  PopupMenuButton<double>(
                    tooltip: l10n.playbackSpeed,
                    initialValue: state.playbackSpeed,
                    onSelected: controller.setPlaybackSpeed,
                    itemBuilder: (context) => const [0.5, 0.75, 1.0, 1.25, 1.5, 2.0]
                        .map((speed) => PopupMenuItem<double>(value: speed, child: Text('${speed}x')))
                        .toList(),
                    child: _ControlChip(label: '${state.playbackSpeed}x', icon: Icons.speed_rounded),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'auto') {
                        await controller.autoDetectSubtitle();
                      } else if (value == 'load') {
                        await controller.pickSubtitleFile();
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem<String>(value: 'auto', child: Text(l10n.autoDetectSubtitles)),
                      PopupMenuItem<String>(value: 'load', child: Text(l10n.loadSubtitle)),
                    ],
                    child: _ControlChip(label: l10n.subtitles, icon: Icons.subtitles_outlined),
                  ),
                  _RepeatChip(
                    enabled: state.repeatCurrent,
                    hasNext: state.hasNextInQueue,
                    onTap: controller.toggleRepeatCurrent,
                  ),
                  IconButton.outlined(
                    onPressed: onFullscreenToggle,
                    icon: Icon(fullscreen ? Icons.fullscreen_exit : Icons.fullscreen),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _SettingSlider(
                      label: l10n.subtitleDelay,
                      value: state.subtitleDelayMs.toDouble(),
                      min: -3000,
                      max: 3000,
                      onChanged: (value) => controller.setSubtitleDelay(value.round()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SettingSlider(
                      label: l10n.subtitleSize,
                      value: state.subtitleFontSize,
                      min: 12,
                      max: 36,
                      onChanged: controller.setSubtitleFontSize,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ControlChip extends StatelessWidget {
  const _ControlChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}

class _RepeatChip extends StatelessWidget {
  const _RepeatChip({
    required this.enabled,
    required this.hasNext,
    required this.onTap,
  });

  final bool enabled;
  final bool hasNext;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = enabled ? 'Repeat 1' : (hasNext ? 'Autoplay Next' : 'Single');
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: enabled ? const Color(0xFF7CE0CC).withOpacity(0.2) : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: enabled ? const Color(0xFF7CE0CC) : Colors.white24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(enabled ? Icons.repeat_one_rounded : Icons.queue_play_next_rounded, size: 18),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
      ),
    );
  }
}

class _SettingSlider extends StatelessWidget {
  const _SettingSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Slider(value: value.clamp(min, max), min: min, max: max, onChanged: onChanged),
      ],
    );
  }
}
