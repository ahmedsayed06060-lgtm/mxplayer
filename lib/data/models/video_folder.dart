class VideoFolder {
  const VideoFolder({
    required this.path,
    required this.name,
    required this.videoCount,
    required this.totalSizeBytes,
    required this.lastModifiedEpochMs,
  });

  final String path;
  final String name;
  final int videoCount;
  final int totalSizeBytes;
  final int lastModifiedEpochMs;
}
