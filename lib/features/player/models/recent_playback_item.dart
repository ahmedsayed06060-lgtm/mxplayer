class RecentPlaybackItem {
  const RecentPlaybackItem({
    required this.id,
    required this.title,
    required this.path,
    required this.isNetwork,
    required this.playedAt,
  });

  final String id;
  final String title;
  final String path;
  final bool isNetwork;
  final DateTime playedAt;
}
