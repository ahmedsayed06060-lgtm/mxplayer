class RecentPlaybackItem {
  const RecentPlaybackItem({
    required this.id,
    required this.title,
    required this.path,
    required this.isNetwork,
    required this.playedAt,
    this.positionMs = 0,
    this.durationMs = 0,
  });

  final String id;
  final String title;
  final String path;
  final bool isNetwork;
  final DateTime playedAt;
  final int positionMs;
  final int durationMs;

  double get progress {
    if (durationMs <= 0) {
      return 0;
    }
    return (positionMs / durationMs).clamp(0.0, 1.0).toDouble();
  }

  bool get isInProgress => progress > 0.02 && progress < 0.96;

  RecentPlaybackItem copyWith({
    int? positionMs,
    int? durationMs,
  }) {
    return RecentPlaybackItem(
      id: id,
      title: title,
      path: path,
      isNetwork: isNetwork,
      playedAt: playedAt,
      positionMs: positionMs ?? this.positionMs,
      durationMs: durationMs ?? this.durationMs,
    );
  }
}
