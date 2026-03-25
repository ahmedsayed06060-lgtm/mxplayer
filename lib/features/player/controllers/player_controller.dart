import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../../core/providers/database_provider.dart';
import '../../../data/database/app_database.dart';
import '../../../data/models/video_item.dart';
import '../../favorites/controllers/favorites_controller.dart';
import '../../playlists/controllers/playlist_controller.dart';
import 'recent_playback_controller.dart';
import '../models/playback_item.dart';
import '../models/recent_playback_item.dart';

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
  });

  final PlaybackItem? current;
  final List<PlaybackItem> queue;
  final int? currentQueueIndex;
  final bool repeatCurrent;
  final bool isPlaying;
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

  bool get hasMedia => current != null;
  bool get hasNextInQueue => currentQueueIndex != null && currentQueueIndex! < queue.length - 1;

  SharedPlayerState copyWith({
    PlaybackItem? current,
    bool clearCurrent = false,
    List<PlaybackItem>? queue,
    int? currentQueueIndex,
    bool clearQueueIndex = false,
    bool? repeatCurrent,
    bool? isPlaying,
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
  }) {
    return SharedPlayerState(
      current: clearCurrent ? null : (current ?? this.current),
      queue: queue ?? this.queue,
      currentQueueIndex: clearQueueIndex ? null : (currentQueueIndex ?? this.currentQueueIndex),
      repeatCurrent: repeatCurrent ?? this.repeatCurrent,
      isPlaying: isPlaying ?? this.isPlaying,
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
    );
  }
}

class SharedPlayerController extends Notifier<SharedPlayerState> {
  late final Player player;
  late final VideoController videoController;
  int _lastSavedSecond = -1;
  bool _handlingCompletion = false;

  @override
  SharedPlayerState build() {
    player = Player(configuration: const PlayerConfiguration(title: 'Smart Player Pro'));
    videoController = VideoController(player);

    player.stream.playing.listen((playing) {
      state = state.copyWith(isPlaying: playing);
    });
    player.stream.position.listen((position) {
      state = state.copyWith(position: position);
      _persistProgressIfNeeded();
    });
    player.stream.duration.listen((duration) {
      state = state.copyWith(duration: duration);
    });
    player.stream.completed.listen((completed) async {
      if (!completed || _handlingCompletion) {
        return;
      }
      _handlingCompletion = true;
      try {
        if (state.repeatCurrent && state.current != null) {
          await player.seek(Duration.zero);
          await player.play();
        } else if (state.hasNextInQueue) {
          await playNextInQueue();
        }
      } finally {
        _handlingCompletion = false;
      }
    });

    ref.onDispose(() async {
      await _persistProgress(force: true);
      await player.dispose();
    });

    return const SharedPlayerState();
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
    final queue = items
        .map(
          (item) => PlaybackItem(
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
    final queue = items
        .map(
          (item) => PlaybackItem(
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
    await _persistProgress(force: true);
    _lastSavedSecond = -1;
    state = state.copyWith(
      current: item,
      queue: queue ?? state.queue,
      currentQueueIndex: queueIndex,
      position: Duration.zero,
      duration: Duration.zero,
      clearSubtitlePath: true,
      zoom: 1,
      locked: false,
    );
    await player.open(Media(item.uri), play: true);
    final progress = await ref.read(appDatabaseProvider).loadWatchProgress(item.id);
    if (progress != null && progress.positionMs > 0) {
      await player.seek(Duration(milliseconds: progress.positionMs));
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
    final nextIndex = state.currentQueueIndex == null ? null : state.currentQueueIndex! + 1;
    if (nextIndex == null || nextIndex < 0 || nextIndex >= state.queue.length) {
      return;
    }
    await _open(state.queue[nextIndex], queue: state.queue, queueIndex: nextIndex);
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

  Future<void> seekTo(Duration position) async {
    await player.seek(position);
  }

  Future<void> seekRelative(Duration delta) async {
    final target = state.position + delta;
    final clamped = target < Duration.zero
        ? Duration.zero
        : (state.duration > Duration.zero && target > state.duration ? state.duration : target);
    await player.seek(clamped);
  }

  Future<void> setPlaybackSpeed(double rate) async {
    await player.setRate(rate);
    state = state.copyWith(playbackSpeed: rate);
  }

  Future<void> setVolume(double volume) async {
    final clamped = volume.clamp(0, 100).toDouble();
    await player.setVolume(clamped);
    state = state.copyWith(volume: clamped);
  }

  void setBrightness(double value) {
    state = state.copyWith(brightness: value.clamp(0, 1).toDouble());
  }

  void setZoom(double value) {
    state = state.copyWith(zoom: value.clamp(1, 2.5).toDouble());
  }

  void toggleLock() {
    state = state.copyWith(locked: !state.locked);
  }

  Future<void> stop() async {
    await _persistProgress(force: true);
    await player.stop();
    state = state.copyWith(
      clearCurrent: true,
      queue: const [],
      clearQueueIndex: true,
      isPlaying: false,
      position: Duration.zero,
      duration: Duration.zero,
    );
  }

  Future<void> pickSubtitleFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['srt', 'ass', 'vtt'],
    );
    final path = result?.files.single.path;
    if (path == null || path.isEmpty) {
      return;
    }
    await player.setSubtitleTrack(SubtitleTrack.uri(Uri.file(path).toString()));
    state = state.copyWith(subtitlePath: path);
  }

  Future<void> autoDetectSubtitle() async {
    final current = state.current;
    if (current == null || current.sourceType != PlaybackSourceType.local) {
      return;
    }
    final file = File(Uri.parse(current.uri).toFilePath());
    final parent = file.parent;
    final basename = file.uri.pathSegments.isEmpty ? file.path : file.uri.pathSegments.last.split('.').first;
    for (final ext in ['srt', 'ass', 'vtt']) {
      final candidate = File('${parent.path}${Platform.pathSeparator}$basename.$ext');
      if (candidate.existsSync()) {
        await player.setSubtitleTrack(SubtitleTrack.uri(Uri.file(candidate.path).toString()));
        state = state.copyWith(subtitlePath: candidate.path);
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
    final current = state.current;
    if (current == null) {
      return;
    }
    ref.read(favoritesControllerProvider.notifier).toggle(current.id);
  }

  Future<void> _persistProgressIfNeeded() async {
    final seconds = state.position.inSeconds;
    if (seconds == _lastSavedSecond || seconds % 5 != 0) {
      return;
    }
    _lastSavedSecond = seconds;
    await _persistProgress();
  }

  Future<void> _persistProgress({bool force = false}) async {
    final current = state.current;
    if (current == null) {
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
  }
}
