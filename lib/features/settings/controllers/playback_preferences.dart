import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Player preferences controlled from the settings screen.
class PlaybackPreferences {
  const PlaybackPreferences({
    this.defaultSpeed = 1.0,
    this.autoPlayNext = true,
    this.rememberPosition = true,
    this.keepScreenOn = true,
    this.nightMode = false,
  });

  final double defaultSpeed;
  final bool autoPlayNext;
  final bool rememberPosition;
  final bool keepScreenOn;
  final bool nightMode;

  PlaybackPreferences copyWith({
    double? defaultSpeed,
    bool? autoPlayNext,
    bool? rememberPosition,
    bool? keepScreenOn,
    bool? nightMode,
  }) {
    return PlaybackPreferences(
      defaultSpeed: defaultSpeed ?? this.defaultSpeed,
      autoPlayNext: autoPlayNext ?? this.autoPlayNext,
      rememberPosition: rememberPosition ?? this.rememberPosition,
      keepScreenOn: keepScreenOn ?? this.keepScreenOn,
      nightMode: nightMode ?? this.nightMode,
    );
  }
}

final playbackPreferencesProvider =
    NotifierProvider<PlaybackPreferencesController, PlaybackPreferences>(
  PlaybackPreferencesController.new,
);

class PlaybackPreferencesController extends Notifier<PlaybackPreferences> {
  @override
  PlaybackPreferences build() => const PlaybackPreferences();

  void setDefaultSpeed(double speed) {
    state = state.copyWith(defaultSpeed: speed);
  }

  void setAutoPlayNext(bool value) {
    state = state.copyWith(autoPlayNext: value);
  }

  void setRememberPosition(bool value) {
    state = state.copyWith(rememberPosition: value);
  }

  void setKeepScreenOn(bool value) {
    state = state.copyWith(keepScreenOn: value);
  }

  void setNightMode(bool value) {
    state = state.copyWith(nightMode: value);
  }
}
