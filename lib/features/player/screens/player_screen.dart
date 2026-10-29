import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/mx_common.dart';
import '../../../localization/generated/app_localizations.dart';
import '../../favorites/controllers/favorites_controller.dart';
import '../../settings/controllers/playback_preferences.dart';
import '../controllers/player_controller.dart';
import '../models/playback_item.dart';
import '../widgets/player_surface.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  const PlayerScreen({super.key});

  static const String routeName = '/player';

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

enum _HudKind { volume, brightness, seek }

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  static const Duration _autoHideDelay = Duration(seconds: 4);

  bool _fullscreen = true;
  bool _controlsVisible = true;
  Timer? _hideTimer;
  Timer? _hudTimer;

  _HudKind? _hudKind;
  String _hudLabel = '';
  double _hudValue = 0;

  double? _scrubMs;
  Duration? _seekPreview;
  double? _dragStartX;
  Duration? _dragStartPosition;
  Offset? _doubleTapPosition;
  bool _seekPulseForward = true;
  bool _seekPulseVisible = false;

  @override
  void initState() {
    super.initState();
    unawaited(_applyImmersive(true));
    _scheduleAutoHide();
    _enableWakelock();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _hudTimer?.cancel();
    unawaited(_applyImmersive(false));
    unawaited(WakelockPlus.disable());
    super.dispose();
  }

  Future<void> _enableWakelock() async {
    final PlaybackPreferences prefs = ref.read(playbackPreferencesProvider);
    if (!prefs.keepScreenOn) {
      return;
    }
    try {
      await WakelockPlus.enable();
    } catch (_) {
      // Not supported on this platform, ignore.
    }
  }

  Future<void> _applyImmersive(bool immersive) async {
    try {
      await SystemChrome.setEnabledSystemUIMode(
        immersive ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge,
      );
      await SystemChrome.setPreferredOrientations(
        immersive
            ? const <DeviceOrientation>[DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]
            : DeviceOrientation.values,
      );
    } catch (_) {
      // Desktop platforms do not implement system chrome.
    }
  }

  void _scheduleAutoHide() {
    _hideTimer?.cancel();
    if (!_controlsVisible) {
      return;
    }
    _hideTimer = Timer(_autoHideDelay, () {
      if (!mounted) {
        return;
      }
      if (_scrubMs != null || _hudKind != null) {
        _scheduleAutoHide();
        return;
      }
      setState(() => _controlsVisible = false);
    });
  }

  void _handleTap() {
    if (ref.read(sharedPlayerControllerProvider).locked) {
      setState(() => _controlsVisible = !_controlsVisible);
      if (_controlsVisible) {
        _scheduleAutoHide();
      } else {
        _hideTimer?.cancel();
      }
      return;
    }
    _toggleControls();
  }

  void _toggleControls() {
    setState(() => _controlsVisible = !_controlsVisible);
    if (_controlsVisible) {
      _scheduleAutoHide();
    } else {
      _hideTimer?.cancel();
    }
  }

  void _showHud(_HudKind kind, String label, double value) {
    _hudTimer?.cancel();
    setState(() {
      _hudKind = kind;
      _hudLabel = label;
      _hudValue = value.clamp(0, 1).toDouble();
    });
    _hudTimer = Timer(const Duration(milliseconds: 900), () {
      if (!mounted) {
        return;
      }
      setState(() => _hudKind = null);
    });
  }

  Future<void> _minimize() async {
    if (_fullscreen) {
      await _applyImmersive(false);
    }
    if (!mounted) {
      return;
    }
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _toggleFullscreen() async {
    final bool next = !_fullscreen;
    setState(() => _fullscreen = next);
    await _applyImmersive(next);
    if (mounted) {
      setState(_controlsVisible = true);
      _scheduleAutoHide();
    }
  }

  Future<void> _handleDoubleTap() async {
    final SharedPlayerController controller = ref.read(sharedPlayerControllerProvider.notifier);
    final double width = context.size?.width ?? MediaQuery.of(context).size.width;
    final double x = _doubleTapPosition?.dx ?? width / 2;
    final bool forward = x >= width / 2;
    await controller.seekRelative(Duration(seconds: forward ? 10 : -10));
    if (!mounted) {
      return;
    }
    setState(() {
      _seekPulseForward = forward;
      _seekPulseVisible = true;
    });
    await Future<void>.delayed(const Duration(milliseconds: 520));
    if (mounted) {
      setState(() => _seekPulseVisible = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final SharedPlayerState state = ref.watch(sharedPlayerControllerProvider);
    final SharedPlayerController controller = ref.read(sharedPlayerControllerProvider.notifier);

    if (!state.hasMedia) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            children: <Widget>[
              Align(
                alignment: Alignment.centerLeft,
                child: MxIconButton(
                  icon: Icons.arrow_back_rounded,
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ),
              Expanded(
                child: MxEmptyState(
                  icon: Icons.play_circle_outline_rounded,
                  title: l10n.noMediaSelected,
                  message: l10n.noVideosFound,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final bool isFavorite = ref.watch(favoritesControllerProvider).contains(state.current!.id);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _handleTap,
              onDoubleTapDown: (TapDownDetails details) => _doubleTapPosition = details.localPosition,
              onDoubleTap: state.locked ? null : _handleDoubleTap,
              onLongPressStart: state.locked
                  ? null
                  : (_) {
                      unawaited(controller.startSpeedBoost());
                      _showHud(_HudKind.seek, '2x', 1);
                    },
              onLongPressEnd: state.locked
                  ? null
                  : (_) => unawaited(controller.endSpeedBoost()),
              onHorizontalDragStart: state.locked
                  ? null
                  : (DragStartDetails details) {
                      _dragStartX = details.localPosition.dx;
                      _dragStartPosition = ref.read(sharedPlayerControllerProvider).position;
                      _hideTimer?.cancel();
                    },
              onHorizontalDragUpdate: state.locked
                  ? null
                  : (DragUpdateDetails details) {
                      final SharedPlayerState current = ref.read(sharedPlayerControllerProvider);
                      final double width =
                          context.size?.width ?? MediaQuery.of(context).size.width;
                      if (current.duration.inMilliseconds <= 0 || width <= 0) {
                        return;
                      }
                      final double fraction =
                          (details.localPosition.dx - (_dragStartX ?? details.localPosition.dx)) / width;
                      Duration target = (_dragStartPosition ?? current.position) +
                          current.duration * fraction;
                      if (target < Duration.zero) {
                        target = Duration.zero;
                      }
                      if (target > current.duration) {
                        target = current.duration;
                      }
                      setState(() => _seekPreview = target);
                    },
              onHorizontalDragEnd: state.locked
                  ? null
                  : (_) async {
                      final Duration? target = _seekPreview;
                      if (target != null) {
                        await controller.seekTo(target);
                      }
                      if (!mounted) {
                        return;
                      }
                      setState(() => _seekPreview = null);
                      _scheduleAutoHide();
                    },
              onHorizontalDragCancel: state.locked
                  ? null
                  : () {
                      if (mounted) {
                        setState(() => _seekPreview = null);
                      }
                    },
              onVerticalDragStart: state.locked
                  ? null
                  : (DragStartDetails details) {
                      _hideTimer?.cancel();
                      final double width =
                          context.size?.width ?? MediaQuery.of(context).size.width;
                      final bool isLeft = details.localPosition.dx < width / 2;
                      final SharedPlayerState current = ref.read(sharedPlayerControllerProvider);
                      _showHud(
                        isLeft ? _HudKind.brightness : _HudKind.volume,
                        isLeft ? l10n.brightness : l10n.volume,
                        isLeft ? current.brightness : current.volume / 100,
                      );
                    },
              onVerticalDragUpdate: state.locked
                  ? null
                  : (DragUpdateDetails details) {
                      final double width =
                          context.size?.width ?? MediaQuery.of(context).size.width;
                      final bool isLeft = details.localPosition.dx < width / 2;
                      final double delta = -(details.primaryDelta ?? 0);
                      final SharedPlayerController player = ref.read(sharedPlayerControllerProvider.notifier);
                      final SharedPlayerState current = ref.read(sharedPlayerControllerProvider);
                      if (isLeft) {
                        player.setBrightness(current.brightness + delta / 320);
                        _showHud(
                          _HudKind.brightness,
                          l10n.brightness,
                          ref.read(sharedPlayerControllerProvider).brightness,
                        );
                      } else {
                        player.setVolume(current.volume + delta / 3);
                        _showHud(
                          _HudKind.volume,
                          l10n.volume,
                          ref.read(sharedPlayerControllerProvider).volume / 100,
                        );
                      }
                    },
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  const PlayerSurface(),
                  if (state.isBuffering)
                    const Center(
                      child: SizedBox(
                        width: 44,
                        height: 44,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: MxColors.brand),
                      ),
                    ),
                  _SeekPulse(
                    visible: _seekPulseVisible,
                    forward: _seekPulseForward,
                    seconds: 10,
                  ),
                  if (_seekPreview != null)
                    Center(
                      child: _SeekPreviewChip(
                        position: _seekPreview!,
                        duration: state.duration,
                      ),
                    ),
                  if (_hudKind != null && _seekPreview == null)
                    Align(
                      alignment: Alignment.center,
                      child: _HudChip(
                        label: _hudLabel,
                        value: _hudValue,
                        kind: _hudKind!,
                      ),
                    ),
                ],
              ),
            ),
          ),
          _buildTopBar(context, state, isFavorite, l10n),
          if (!state.locked)
            Center(
              child: IgnorePointer(
                ignoring: !_controlsVisible,
                child: AnimatedOpacity(
                  opacity: _controlsVisible ? 1 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: _buildCenterControls(context, state, controller, l10n),
                ),
              ),
            ),
          if (!state.locked && _seekPreview == null)
            Align(
              alignment: Alignment.bottomCenter,
              child: IgnorePointer(
                ignoring: !_controlsVisible,
                child: AnimatedOpacity(
                  opacity: _controlsVisible ? 1 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: _buildBottomControls(context, state, controller, l10n),
                ),
              ),
            ),
          if (state.locked) _buildLockedOverlay(context, controller, l10n),
        ],
      ),
    );
  }

  Widget _buildTopBar(
    BuildContext context,
    SharedPlayerState state,
    bool isFavorite,
    AppLocalizations l10n,
  ) {
    final SharedPlayerController controller = ref.read(sharedPlayerControllerProvider.notifier);
    final String subtitle = _subtitleFor(state);

    return Align(
      alignment: Alignment.topCenter,
      child: IgnorePointer(
        ignoring: !_controlsVisible,
        child: AnimatedOpacity(
          opacity: _controlsVisible ? 1 : 0,
          duration: const Duration(milliseconds: 180),
          child: Container(
            decoration: const BoxDecoration(gradient: MxColors.darkScrim),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(6, 6, 6, 26),
                child: Row(
                  children: <Widget>[
                    IconButton(
                      onPressed: _minimize,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 28),
                      tooltip: l10n.handoff,
                    ),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            state.current!.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14.5),
                          ),
                          if (subtitle.isNotEmpty) ...<Widget>[
                            const SizedBox(height: 2),
                            Text(
                              subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontSize: 11,
                                    color: Colors.white60,
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: controller.toggleFavoriteCurrent,
                      tooltip: isFavorite ? l10n.unfavorite : l10n.favorite,
                      icon: Icon(
                        isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: isFavorite ? MxColors.brand : Colors.white,
                        size: 21,
                      ),
                    ),
                    IconButton(
                      onPressed: () => _showMoreMenu(context, state, l10n),
                      tooltip: l10n.more,
                      icon: const Icon(Icons.more_vert_rounded, size: 22),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _subtitleFor(SharedPlayerState state) {
    final List<String> parts = <String>[];
    if (state.videoWidth != null && state.videoHeight != null) {
      parts.add('${state.videoWidth}x${state.videoHeight}');
    }
    if (state.queue.length > 1 && state.currentQueueIndex != null) {
      parts.add('${state.currentQueueIndex! + 1} / ${state.queue.length}');
    }
    final PlaybackItem? item = state.current;
    if (item != null && item.sourceType != PlaybackSourceType.local) {
      parts.add(item.sourceType == PlaybackSourceType.iptv ? 'LIVE' : 'NETWORK');
    }
    return parts.join(' • ');
  }

  Widget _buildCenterControls(
    BuildContext context,
    SharedPlayerState state,
    SharedPlayerController controller,
    AppLocalizations l10n,
  ) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _CircleAction(
          icon: Icons.skip_previous_rounded,
          size: 46,
          iconSize: 26,
          onPressed: state.hasPreviousInQueue ? controller.playPreviousInQueue : null,
          tooltip: l10n.previous,
        ),
        const SizedBox(width: 10),
        _CircleAction(
          icon: Icons.replay_10_rounded,
          size: 52,
          iconSize: 28,
          onPressed: () => controller.seekRelative(const Duration(seconds: -10)),
          tooltip: l10n.rewind,
        ),
        const SizedBox(width: 16),
        _CircleAction(
          icon: state.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
          size: 72,
          iconSize: 40,
          filled: true,
          onPressed: () {
            controller.togglePlayPause();
            _scheduleAutoHide();
          },
          tooltip: state.isPlaying ? l10n.pause : l10n.play,
        ),
        const SizedBox(width: 16),
        _CircleAction(
          icon: Icons.forward_10_rounded,
          size: 52,
          iconSize: 28,
          onPressed: () => controller.seekRelative(const Duration(seconds: 10)),
          tooltip: l10n.forward,
        ),
        const SizedBox(width: 10),
        _CircleAction(
          icon: Icons.skip_next_rounded,
          size: 46,
          iconSize: 26,
          onPressed: state.hasNextInQueue ? controller.playNextInQueue : null,
          tooltip: l10n.next,
        ),
      ],
      ),
    );
  }

  Widget _buildBottomControls(
    BuildContext context,
    SharedPlayerState state,
    SharedPlayerController controller,
    AppLocalizations l10n,
  ) {
    final double maxMs = state.duration.inMilliseconds.toDouble();
    final double sliderValue = (_scrubMs ?? state.position.inMilliseconds.toDouble())
        .clamp(0, maxMs <= 0 ? 1 : maxMs)
        .toDouble();
    final Duration displayPosition =
        _scrubMs == null ? state.position : Duration(milliseconds: _scrubMs!.round());

    return Container(
      decoration: const BoxDecoration(gradient: MxColors.bottomScrim),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 44, 10, 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: <Widget>[
                  SizedBox(
                    width: 60,
                    child: Text(
                      Formatters.duration(displayPosition),
                      style: const TextStyle(fontSize: 11.5, color: Colors.white70),
                    ),
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 2.5,
                        activeTrackColor: MxColors.brand,
                        inactiveTrackColor: Colors.white24,
                        thumbColor: MxColors.brand,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                        overlayColor: MxColors.brand.withOpacity(0.18),
                      ),
                      child: Slider(
                        value: sliderValue,
                        max: maxMs <= 0 ? 1 : maxMs,
                        onChangeStart: (double value) {
                          _hideTimer?.cancel();
                          setState(() => _scrubMs = value);
                        },
                        onChanged: (double value) => setState(() => _scrubMs = value),
                        onChangeEnd: (double value) async {
                          await controller.seekTo(Duration(milliseconds: value.round()));
                          if (!mounted) {
                            return;
                          }
                          setState(() => _scrubMs = null);
                          _scheduleAutoHide();
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 60,
                    child: Text(
                      Formatters.duration(state.duration),
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 11.5, color: Colors.white70),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: _PlayerAction(
                        icon: Icons.speed_rounded,
                        label: state.playbackSpeed == 1
                            ? l10n.playbackSpeed
                            : '${state.playbackSpeed}x',
                        onTap: () => _showSpeedSheet(context, l10n),
                      ),
                    ),
                    Expanded(
                      child: _PlayerAction(
                        icon: Icons.subtitles_outlined,
                        label: state.subtitlesEnabled ? l10n.subtitles : l10n.subtitlesOff,
                        active: state.subtitlesEnabled && state.subtitlePath != null,
                        onTap: () => _showSubtitleSheet(context, state, l10n),
                      ),
                    ),
                    Expanded(
                      child: _PlayerAction(
                        icon: Icons.aspect_ratio_rounded,
                        label: _aspectLabel(state.aspectMode, l10n),
                        onTap: () => _showAspectSheet(context, state, l10n),
                      ),
                    ),
                    Expanded(
                      child: _PlayerAction(
                        icon: Icons.lock_outline_rounded,
                        label: l10n.lockControls,
                        onTap: () {
                          controller.toggleLock();
                          setState(() => _controlsVisible = false);
                        },
                      ),
                    ),
                    Expanded(
                      child: _PlayerAction(
                        icon: _fullscreen ? Icons.fullscreen_exit_rounded : Icons.fullscreen_rounded,
                        label: l10n.rotate,
                        onTap: _toggleFullscreen,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLockedOverlay(
    BuildContext context,
    SharedPlayerController controller,
    AppLocalizations l10n,
  ) {
    return IgnorePointer(
      ignoring: !_controlsVisible,
      child: AnimatedOpacity(
        opacity: _controlsVisible ? 1 : 0,
        duration: const Duration(milliseconds: 180),
        child: Center(
          child: GestureDetector(
            onTap: () {
              controller.toggleLock();
              setState(() => _controlsVisible = true);
              _scheduleAutoHide();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(Icons.lock_outline_rounded, size: 18, color: MxColors.brand),
                  const SizedBox(width: 8),
                  Text(l10n.playerLocked, style: const TextStyle(fontSize: 12.5)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _aspectLabel(PlayerAspectMode mode, AppLocalizations l10n) {
    switch (mode) {
      case PlayerAspectMode.fit:
        return l10n.aspectFit;
      case PlayerAspectMode.crop:
        return l10n.aspectFill;
      case PlayerAspectMode.stretch:
        return l10n.aspectStretch;
      case PlayerAspectMode.original:
        return l10n.aspectOriginal;
    }
  }

  Future<void> _showSpeedSheet(BuildContext context, AppLocalizations l10n) async {
    final SharedPlayerController controller = ref.read(sharedPlayerControllerProvider.notifier);
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext sheetContext) {
        final double current = ref.read(sharedPlayerControllerProvider).playbackSpeed;
        return SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              MxSheetHeader(title: l10n.playbackSpeed),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 340),
                child: ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    for (final double speed in AppConstants.playbackSpeeds)
                      ListTile(
                        leading: Icon(
                          speed == current ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                          color: speed == current ? MxColors.brand : null,
                          size: 20,
                        ),
                        title: Text(speed == 1 ? '1x • ${l10n.speedNormal}' : '${speed}x'),
                        onTap: () {
                          controller.setPlaybackSpeed(speed);
                          Navigator.of(sheetContext).pop();
                        },
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
    _scheduleAutoHide();
  }

  Future<void> _showSubtitleSheet(
    BuildContext context,
    SharedPlayerState state,
    AppLocalizations l10n,
  ) async {
    final SharedPlayerController controller = ref.read(sharedPlayerControllerProvider.notifier);

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (BuildContext sheetContext) {
        return SafeArea(
          top: false,
          child: Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              final SharedPlayerState current = ref.watch(sharedPlayerControllerProvider);
              return SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    MxSheetHeader(
                      title: l10n.subtitles,
                      subtitle: current.subtitlePath?.split(RegExp(r'[/\\]')).last,
                      trailing: Switch(
                        value: current.subtitlesEnabled,
                        onChanged: (bool value) async {
                          await controller.setSubtitlesEnabled(value);
                          if (value) {
                            await controller.autoDetectSubtitle();
                          }
                        },
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.auto_awesome_rounded),
                      title: Text(l10n.autoDetectSubtitles),
                      onTap: () async {
                        await controller.setSubtitlesEnabled(true);
                        await controller.autoDetectSubtitle();
                        if (sheetContext.mounted) {
                          Navigator.of(sheetContext).pop();
                        }
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.folder_open_rounded),
                      title: Text(l10n.loadSubtitle),
                      onTap: () async {
                        await controller.pickSubtitleFile();
                        if (sheetContext.mounted) {
                          Navigator.of(sheetContext).pop();
                        }
                      },
                    ),
                    const Divider(height: 20),
                    _SliderRow(
                      label: l10n.subtitleDelay,
                      value: current.subtitleDelayMs.toDouble(),
                      min: -3000,
                      max: 3000,
                      suffix: '${current.subtitleDelayMs} ms',
                      onChanged: (double value) => controller.setSubtitleDelay(value.round()),
                    ),
                    _SliderRow(
                      label: l10n.subtitleSize,
                      value: current.subtitleFontSize,
                      min: 12,
                      max: 36,
                      suffix: current.subtitleFontSize.round().toString(),
                      onChanged: controller.setSubtitleFontSize,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                      child: Row(
                        children: <Widget>[
                          Text(l10n.subtitleColor, style: Theme.of(context).textTheme.bodySmall),
                          const Spacer(),
                          for (final Color color in <Color>[
                            Colors.white,
                            const Color(0xFFFFE082),
                            const Color(0xFF80D8FF),
                            MxColors.brand,
                          ])
                            GestureDetector(
                              onTap: () => controller.setSubtitleColor(color),
                              child: Container(
                                margin: const EdgeInsets.only(left: 10),
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: current.subtitleColor == color ? MxColors.brand : Colors.white24,
                                    width: current.subtitleColor == color ? 2.5 : 1,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
    _scheduleAutoHide();
  }

  Future<void> _showAspectSheet(
    BuildContext context,
    SharedPlayerState state,
    AppLocalizations l10n,
  ) async {
    final SharedPlayerController controller = ref.read(sharedPlayerControllerProvider.notifier);
    final Map<PlayerAspectMode, String> labels = <PlayerAspectMode, String>{
      PlayerAspectMode.fit: l10n.aspectFit,
      PlayerAspectMode.crop: l10n.aspectFill,
      PlayerAspectMode.stretch: l10n.aspectStretch,
      PlayerAspectMode.original: l10n.aspectOriginal,
    };

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext sheetContext) {
        return SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              MxSheetHeader(title: l10n.aspectRatio),
              for (final PlayerAspectMode mode in PlayerAspectMode.values)
                ListTile(
                  leading: Icon(
                    mode == state.aspectMode ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                    color: mode == state.aspectMode ? MxColors.brand : null,
                    size: 20,
                  ),
                  title: Text(labels[mode]!),
                  onTap: () {
                    controller.setAspectMode(mode);
                    Navigator.of(sheetContext).pop();
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
    _scheduleAutoHide();
  }

  Future<void> _showMoreMenu(
    BuildContext context,
    SharedPlayerState state,
    AppLocalizations l10n,
  ) async {
    final SharedPlayerController controller = ref.read(sharedPlayerControllerProvider.notifier);
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext sheetContext) {
        return SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              MxSheetHeader(title: l10n.more, subtitle: state.current?.title),
              SwitchListTile(
                value: state.nightMode,
                onChanged: (bool value) => controller.toggleNightMode(),
                secondary: const Icon(Icons.nightlight_round),
                title: Text(l10n.nightMode),
              ),
              SwitchListTile(
                value: state.repeatCurrent,
                onChanged: (_) => controller.toggleRepeatCurrent(),
                secondary: const Icon(Icons.repeat_one_rounded),
                title: Text(l10n.autoPlayNext),
              ),
              ListTile(
                leading: const Icon(Icons.info_outline_rounded),
                title: Text(l10n.videoInfo),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _showInfoDialog(context, state, l10n);
                },
              ),
              ListTile(
                leading: const Icon(Icons.stop_circle_outlined, color: MxColors.danger),
                title: Text(l10n.close, style: const TextStyle(color: MxColors.danger)),
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  await controller.stop();
                  if (context.mounted) {
                    Navigator.of(context).maybePop();
                  }
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
    _scheduleAutoHide();
  }

  void _showInfoDialog(BuildContext context, SharedPlayerState state, AppLocalizations l10n) {
    final PlaybackItem? item = state.current;
    final List<List<String>> rows = <List<String>>[
      <String>[l10n.pathLabel, item?.uri ?? ''],
      <String>[l10n.resolution, Formatters.resolution(state.videoWidth, state.videoHeight)],
      <String>[l10n.durationLabel, Formatters.duration(state.duration)],
      <String>[l10n.playerEngine, '${AppConstants.playerEngine} • ${AppConstants.version}'],
      <String>[l10n.decoder, l10n.decoderHardware],
    ];

    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(l10n.videoInfo),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              for (final List<String> row in rows)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(row[0], style: Theme.of(dialogContext).textTheme.labelSmall),
                      const SizedBox(height: 2),
                      Text(row[1], style: Theme.of(dialogContext).textTheme.bodyMedium),
                    ],
                  ),
                ),
            ],
          ),
          actions: <Widget>[
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: Text(l10n.close)),
          ],
        );
      },
    );
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({
    required this.icon,
    required this.onPressed,
    required this.size,
    required this.iconSize,
    this.filled = false,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final double iconSize;
  final bool filled;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final Widget button = Material(
      color: filled ? MxColors.brand : Colors.black.withOpacity(0.32),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            icon,
            size: iconSize,
            color: filled
                ? const Color(0xFF06210F)
                : (onPressed == null ? Colors.white24 : Colors.white),
          ),
        ),
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}

class _PlayerAction extends StatelessWidget {
  const _PlayerAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 21, color: active ? MxColors.brand : Colors.white),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w500,
                color: active ? MxColors.brand : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SeekPulse extends StatelessWidget {
  const _SeekPulse({required this.visible, required this.forward, required this.seconds});

  final bool visible;
  final bool forward;
  final int seconds;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: const Duration(milliseconds: 160),
        child: Align(
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              if (!forward) _pulse(context) else const SizedBox(width: 110),
              if (forward) _pulse(context) else const SizedBox(width: 110),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pulse(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        shape: BoxShape.circle,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            forward ? Icons.fast_forward_rounded : Icons.fast_rewind_rounded,
            color: Colors.white,
            size: 30,
          ),
          const SizedBox(height: 4),
          Text('$seconds s', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _SeekPreviewChip extends StatelessWidget {
  const _SeekPreviewChip({required this.position, required this.duration});

  final Duration position;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.72),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: MxColors.brand.withOpacity(0.4)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            Formatters.duration(position),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: MxColors.brand),
          ),
          const SizedBox(height: 2),
          Text(
            '/ ${Formatters.duration(duration)}',
            style: const TextStyle(fontSize: 11, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _HudChip extends StatelessWidget {
  const _HudChip({required this.label, required this.value, required this.kind});

  final String label;
  final double value;
  final _HudKind kind;

  @override
  Widget build(BuildContext context) {
    final IconData icon = kind == _HudKind.volume
        ? (value <= 0.001 ? Icons.volume_off_rounded : Icons.volume_up_rounded)
        : (kind == _HudKind.brightness ? Icons.brightness_6_rounded : Icons.speed_rounded);

    return IgnorePointer(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.65),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(icon, size: 18, color: MxColors.brand),
                const SizedBox(width: 8),
                Text(label, style: const TextStyle(fontSize: 12.5, color: Colors.white)),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 120,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: value.clamp(0, 1).toDouble(),
                  minHeight: 4,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation<Color>(MxColors.brand),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.suffix,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              const Spacer(),
              if (suffix != null)
                Text(suffix!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: MxColors.brand)),
            ],
          ),
          Slider(
            value: value.clamp(min, max).toDouble(),
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
