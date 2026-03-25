import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../../data/models/video_item.dart';
import '../../favorites/controllers/favorites_controller.dart';
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

  SharedPlayerState copyWith({
    PlaybackItem? current,
    bool clearCurrent = false,
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
  ProviderSubscription<bool>? _playingSub;
  ProviderSubscription<Duration>? _positionSub;
  ProviderSubscription<Duration>? _durationSub;

  @override
  SharedPlayerState build() {
    player = Player(configuration: const PlayerConfiguration(title: 'Smart Player Pro'));
    videoController = VideoController(player);

    player.stream.playing.listen((playing) {
      state = state.copyWith(isPlaying: playing);
    });
    player.stream.position.listen((position) {
      state = state.copyWith(position: position);
    });
    player.stream.duration.listen((duration) {
      state = state.copyWith(duration: duration);
    });

    ref.onDispose(() async {
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

  Future<void> _open(PlaybackItem item) async {
    state = state.copyWith(
      current: item,
      position: Duration.zero,
      duration: Duration.zero,
      clearSubtitlePath: true,
      zoom: 1,
      locked: false,
    );
    await player.open(Media(item.uri), play: true);
    ref.read(recentPlaybackProvider.notifier).push(
          RecentPlaybackItem(
            id: item.id,
            title: item.title,
            path: item.uri,
            isNetwork: item.sourceType != PlaybackSourceType.local,
            playedAt: DateTime.now(),
          ),
        );
  }

  Future<void> togglePlayPause() async {
    if (state.isPlaying) {
      await player.pause();
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
    await player.stop();
    state = state.copyWith(clearCurrent: true, isPlaying: false, position: Duration.zero, duration: Duration.zero);
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
}
