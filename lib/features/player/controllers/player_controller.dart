import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/providers/database_provider.dart';
import '../../../data/database/app_database.dart';
import '../../../data/models/video_item.dart';
import '../../favorites/controllers/favorites_controller.dart';
import '../../playlists/controllers/playlist_controller.dart';
import '../../settings/controllers/playback_preferences.dart';
import 'recent_playback_controller.dart';
import '../models/playback_item.dart';
import '../models/recent_playback_item.dart';

/// Screen fitting modes supported by the player (mirrors MX Player's menu).
enum PlayerAspectMode {
  fit,
  crop,
  stretch,
  original,
}

final sharedPlayerControllerProvider =
    NotifierProvider<SharedPlayerController, SharedPlayerState>(
  SharedPlayerController.new,
);

class SharedPlayerState {
  const SharedPlayerState({
    this.current,
    this.queue = const [],
    this.currentQueueIndex,
    this.repeatCurrent = false,
    this.isPlaying = false,
    this.isBuffering = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.volume = 100,
    this.brightness = 0.5,
    this.zoom = 1,
    this.playbackSpeed = 1,
    this.locked = false,
    this.subtitleDelayMs = 0,
    this.subtitleFontSize = 18,
    this.subtitleColor = Colors.white,
    this.subtitlePath,
    this.subtitlesEnabled = true,
    this.aspectMode = PlayerAspectMode.fit,
    this.nightMode = false,
    this.videoWidth,
    this.videoHeight,
  });

  final PlaybackItem? current;
  final List<PlaybackItem> queue;
  final int? currentQueueIndex;
  final bool repeatCurrent;
  final bool isPlaying;
  final bool isBuffering;
  final Duration position;
  final Duration duration;
  final double volume;
  final double brightness;
  final double zoom;
  final double playbackSpeed;
  final bool locked;
  final int subtitleDelayMs;
  final double subtitleFontSize;
  final Color subtitleColor;
  final String? subtitlePath;
  final bool subtitlesEnabled;
  final PlayerAspectMode aspectMode;
  final bool nightMode;
  final int? videoWidth;
  final int? videoHeight;

  bool get hasMedia => current != null;
  bool get hasPreviousInQueue => currentQueueIndex != null && currentQueueIndex! > 0;
  bool get hasNextInQueue => currentQueueIndex != null && currentQueueIndex! < queue.length - 1;

  double get progress {
    if (duration.inMilliseconds <= 0) {
      return 0;
    }
    return (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0).toDouble();
  }

  Duration get remaining {
    final Duration left = duration - position;
    return left < Duration.zero ? Duration.zero : left;
  }

  SharedPlayerState copyWith({
    PlaybackItem? current,
    bool clearCurrent = false,
    List<PlaybackItem>? queue,
    int? currentQueueIndex,
    bool clearQueueIndex = false,
    bool? repeatCurrent,
    bool? isPlaying,
    bool? isBuffering,
    Duration? position,
    Duration? duration,
    double? volume,
    double? brightness,
    double? zoom,
    double? playbackSpeed,
    bool? locked,
    int? subtitleDelayMs,
    double? subtitleFontSize,
    Color? subtitleColor,
    String? subtitlePath,
    bool clearSubtitlePath = false,
    bool? subtitlesEnabled,
    PlayerAspectMode? aspectMode,
    bool? nightMode,
    int? videoWidth,
    int? videoHeight,
  }) {
    return SharedPlayerState(
      current: clearCurrent ? null : (current ?? this.current),
      queue: queue ?? this.queue,
      currentQueueIndex: clearQueueIndex ? null : (currentQueueIndex ?? this.currentQueueIndex),
      repeatCurrent: repeatCurrent ?? this.repeatCurrent,
      isPlaying: isPlaying ?? this.isPlaying,
      isBuffering: isBuffering ?? this.isBuffering,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      volume: volume ?? this.volume,
      brightness: brightness ?? this.brightness,
      zoom: zoom ?? this.zoom,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      locked: locked ?? this.locked,
      subtitleDelayMs: subtitleDelayMs ?? this.subtitleDelayMs,
      subtitleFontSize: subtitleFontSize ?? this.subtitleFontSize,
      subtitleColor: subtitleColor ?? this.subtitleColor,
      subtitlePath: clearSubtitlePath ? null : (subtitlePath ?? this.subtitlePath),
      subtitlesEnabled: subtitlesEnabled ?? this.subtitlesEnabled,
      aspectMode: aspectMode ?? this.aspectMode,
      nightMode: nightMode ?? this.nightMode,
      videoWidth: videoWidth ?? this.videoWidth,
      videoHeight: videoHeight ?? this.videoHeight,
    );
  }
}

class SharedPlayerController extends Notifier<SharedPlayerState> {
  late final Player player;
  late final VideoController videoController;
  int _lastSavedSecond = -1;
  bool _handlingCompletion = false;
  bool _disposed = false;
  double? _speedBeforeBoost;

  @override
  SharedPlayerState build() {
    final PlaybackPreferences prefs = ref.read(playbackPreferencesProvider);
    player = Player(
      configuration: PlayerConfiguration(title: AppConstants.appName),
    );
    videoController = VideoController(player);

    player.stream.playing.listen((bool playing) {
      state = state.copyWith(isPlaying: playing);
    });
    player.stream.buffering.listen((bool buffering) {
      state = state.copyWith(isBuffering: buffering);
    });
    player.stream.position.listen((Duration position) {
      state = state.copyWith(position: position);
      _persistProgressIfNeeded();
    });
    player.stream.duration.listen((Duration duration) {
      state = state.copyWith(duration: duration);
    });
    player.stream.width.listen((int? width) {
      state = state.copyWith(videoWidth: width);
    });
    player.stream.height.listen((int? height) {
      state = state.copyWith(videoHeight: height);
    });
    player.stream.completed.listen((bool completed) async {
      if (!completed || _handlingCompletion) {
        return;
      }
      _handlingCompletion = true;
      try {
        final PlaybackPreferences preferences = ref.read(playbackPreferencesProvider);
        if (state.repeatCurrent && state.current != null) {
          await player.seek(Duration.zero);
          await player.play();
        } else if (preferences.autoPlayNext && state.hasNextInQueue) {
          await playNextInQueue();
        } else {
          state = state.copyWith(isPlaying: false);
        }
      } finally {
        _handlingCompletion = false;
      }
    });

    ref.onDispose(() async {
      _disposed = true;
      await _persistProgress(force: true);
      await player.dispose();
    });

    return SharedPlayerState(aspectMode: PlayerAspectMode.fit, nightMode: prefs.nightMode);
  }

  Future<void> openVideoItem(VideoItem item) async {
    await _open(
      PlaybackItem(
        id: item.id,
        title: item.title,
        uri: Uri.file(item.path).toString(),
        sourceType: PlaybackSourceType.local,
      ),
    );
  }

  Future<void> openVideoQueue(List<VideoItem> items, {required int startIndex}) async {
    final List<PlaybackItem> queue = items
        .map(
          (VideoItem item) => PlaybackItem(
            id: item.id,
            title: item.title,
            uri: Uri.file(item.path).toString(),
            sourceType: PlaybackSourceType.local,
          ),
        )
        .toList(growable: false);
    if (queue.isEmpty || startIndex < 0 || startIndex >= queue.length) {
      return;
    }
    await _open(queue[startIndex], queue: queue, queueIndex: startIndex);
  }

  Future<void> openPlaylistQueue(List<PlaylistVideoRecord> items, {required int startIndex}) async {
    final List<PlaybackItem> queue = items
        .map(
          (PlaylistVideoRecord item) => PlaybackItem(
            id: item.videoId,
            title: item.title,
            uri: Uri.file(item.path).toString(),
            sourceType: PlaybackSourceType.local,
          ),
        )
        .toList(growable: false);
    if (queue.isEmpty || startIndex < 0 || startIndex >= queue.length) {
      return;
    }
    await _open(queue[startIndex], queue: queue, queueIndex: startIndex);
  }

  Future<void> openNetwork({
    required String id,
    required String title,
    required String url,
    PlaybackSourceType type = PlaybackSourceType.network,
  }) async {
    await _open(
      PlaybackItem(
        id: id,
        title: title,
        uri: url,
        sourceType: type,
      ),
    );
  }

  Future<void> _open(
    PlaybackItem item, {
    List<PlaybackItem>? queue,
    int? queueIndex,
  }) async {
    final PlaybackPreferences prefs = ref.read(playbackPreferencesProvider);
    await _persistProgress(force: true);
    _lastSavedSecond = -1;
    state = state.copyWith(
      current: item,
      queue: queue ?? <PlaybackItem>[item],
      currentQueueIndex: queueIndex ?? 0,
      position: Duration.zero,
      duration: Duration.zero,
      isPlaying: true,
      clearSubtitlePath: true,
      zoom: 1,
      locked: false,
      playbackSpeed: prefs.defaultSpeed,
      nightMode: prefs.nightMode,
    );

    await player.open(Media(item.uri), play: true);
    if (prefs.defaultSpeed != 1.0) {
      await player.setRate(prefs.defaultSpeed);
    }

    if (prefs.rememberPosition) {
      final WatchProgressRecord? progress = await ref.read(appDatabaseProvider).loadWatchProgress(item.id);
      if (progress != null && progress.positionMs > 3000) {
        await player.seek(Duration(milliseconds: progress.positionMs));
      }
    }

    await ref.read(recentPlaybackProvider.notifier).push(
          RecentPlaybackItem(
            id: item.id,
            title: item.title,
            path: item.uri,
            isNetwork: item.sourceType != PlaybackSourceType.local,
            playedAt: DateTime.now(),
          ),
        );
  }

  Future<void> playNextInQueue() async {
    final int? nextIndex = state.currentQueueIndex == null ? null : state.currentQueueIndex! + 1;
    if (nextIndex == null || nextIndex < 0 || nextIndex >= state.queue.length) {
      return;
    }
    await _open(state.queue[nextIndex], queue: state.queue, queueIndex: nextIndex);
  }

  Future<void> playPreviousInQueue() async {
    final int? previousIndex = state.currentQueueIndex == null ? null : state.currentQueueIndex! - 1;
    if (previousIndex == null || previousIndex < 0 || previousIndex >= state.queue.length) {
      return;
    }
    await _open(state.queue[previousIndex], queue: state.queue, queueIndex: previousIndex);
  }

  void toggleRepeatCurrent() {
    state = state.copyWith(repeatCurrent: !state.repeatCurrent);
  }

  Future<void> togglePlayPause() async {
    if (state.isPlaying) {
      await player.pause();
      await _persistProgress(force: true);
    } else {
      await player.play();
    }
  }

  /// MX Player's long press gesture: temporarily play at 2x.
  Future<void> startSpeedBoost() async {
    if (_speedBeforeBoost != null) {
      return;
    }
    _speedBeforeBoost = state.playbackSpeed;
    await player.setRate(2.0);
    state = state.copyWith(playbackSpeed: 2.0);
  }

  Future<void> endSpeedBoost() async {
    final double? previous = _speedBeforeBoost;
    if (previous == null) {
      return;
    }
    _speedBeforeBoost = null;
    await player.setRate(previous);
    state = state.copyWith(playbackSpeed: previous);
  }

  Future<void> seekTo(Duration position) async {
    await player.seek(position);
  }

  Future<void> seekRelative(Duration delta) async {
    final Duration target = state.position + delta;
    final Duration clamped = target < Duration.zero
        ? Duration.zero
        : (state.duration > Duration.zero && target > state.duration ? state.duration : target);
    await player.seek(clamped);
  }

  Future<void> setPlaybackSpeed(double rate) async {
    await player.setRate(rate);
    state = state.copyWith(playbackSpeed: rate);
  }

  Future<void> setVolume(double volume) async {
    final double clamped = volume.clamp(0, 100).toDouble();
    await player.setVolume(clamped);
    state = state.copyWith(volume: clamped);
  }

  void setBrightness(double value) {
    state = state.copyWith(brightness: value.clamp(0.12, 1).toDouble());
  }

  void setZoom(double value) {
    state = state.copyWith(zoom: value.clamp(1, 2.5).toDouble());
  }

  void toggleLock() {
    state = state.copyWith(locked: !state.locked);
  }

  void setAspectMode(PlayerAspectMode mode) {
    state = state.copyWith(aspectMode: mode);
  }

  void cycleAspectMode() {
    final List<PlayerAspectMode> modes = PlayerAspectMode.values;
    final int next = (modes.indexOf(state.aspectMode) + 1) % modes.length;
    state = state.copyWith(aspectMode: modes[next]);
  }

  void toggleNightMode() {
    state = state.copyWith(nightMode: !state.nightMode);
  }

  Future<void> setSubtitlesEnabled(bool enabled) async {
    state = state.copyWith(subtitlesEnabled: enabled);
    if (enabled) {
      await player.setSubtitleTrack(SubtitleTrack.auto());
    } else {
      await player.setSubtitleTrack(SubtitleTrack.no());
    }
  }

  Future<void> stop() async {
    await _persistProgress(force: true);
    await player.stop();
    state = state.copyWith(
      clearCurrent: true,
      queue: const <PlaybackItem>[],
      clearQueueIndex: true,
      isPlaying: false,
      position: Duration.zero,
      duration: Duration.zero,
    );
  }

  Future<void> pickSubtitleFile() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: <String>['srt', 'ass', 'vtt', 'ssa', 'sub'],
    );
    final String? path = result?.files.single.path;
    if (path == null || path.isEmpty) {
      return;
    }
    await player.setSubtitleTrack(SubtitleTrack.uri(Uri.file(path).toString()));
    state = state.copyWith(subtitlePath: path, subtitlesEnabled: true);
  }

  Future<void> autoDetectSubtitle() async {
    final PlaybackItem? current = state.current;
    if (current == null || current.sourceType != PlaybackSourceType.local) {
      return;
    }
    final File file = File(Uri.parse(current.uri).toFilePath());
    final Directory parent = file.parent;
    final String basename =
        file.uri.pathSegments.isEmpty ? file.path : file.uri.pathSegments.last.split('.').first;
    for (final String ext in <String>['srt', 'ass', 'vtt']) {
      final File candidate = File('${parent.path}${Platform.pathSeparator}$basename.$ext');
      if (candidate.existsSync()) {
        await player.setSubtitleTrack(SubtitleTrack.uri(Uri.file(candidate.path).toString()));
        state = state.copyWith(subtitlePath: candidate.path, subtitlesEnabled: true);
        break;
      }
    }
  }

  void setSubtitleDelay(int milliseconds) {
    state = state.copyWith(subtitleDelayMs: milliseconds);
  }

  void setSubtitleFontSize(double size) {
    state = state.copyWith(subtitleFontSize: size.clamp(12, 36).toDouble());
  }

  void setSubtitleColor(Color color) {
    state = state.copyWith(subtitleColor: color);
  }

  void toggleFavoriteCurrent() {
    final PlaybackItem? current = state.current;
    if (current == null) {
      return;
    }
    ref.read(favoritesControllerProvider.notifier).toggle(current.id);
  }

  Future<void> _persistProgressIfNeeded() async {
    if (_disposed) {
      return;
    }
    final int seconds = state.position.inSeconds;
    if (seconds == _lastSavedSecond || seconds % 5 != 0) {
      return;
    }
    _lastSavedSecond = seconds;
    await _persistProgress();
  }

  Future<void> _persistProgress({bool force = false}) async {
    final PlaybackItem? current = state.current;
    if (current == null) {
      return;
    }
    if (_disposed && !force) {
      return;
    }
    if (!force && state.position == Duration.zero) {
      return;
    }
    await ref.read(appDatabaseProvider).saveWatchProgress(
          id: current.id,
          title: current.title,
          path: current.uri,
          isNetwork: current.sourceType != PlaybackSourceType.local,
          positionMs: state.position.inMilliseconds,
          durationMs: state.duration.inMilliseconds,
        );
    if (!_disposed) {
      ref.read(recentPlaybackProvider.notifier).updateProgress(
            current.id,
            positionMs: state.position.inMilliseconds,
            durationMs: state.duration.inMilliseconds,
          );
    }
  }
}
