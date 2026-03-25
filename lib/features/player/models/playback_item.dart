enum PlaybackSourceType {
  local,
  network,
  iptv,
}

class PlaybackItem {
  const PlaybackItem({
    required this.id,
    required this.title,
    required this.uri,
    required this.sourceType,
    this.subtitlePath,
  });

  final String id;
  final String title;
  final String uri;
  final PlaybackSourceType sourceType;
  final String? subtitlePath;
}
