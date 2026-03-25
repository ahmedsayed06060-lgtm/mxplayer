import 'video_folder.dart';
import 'video_item.dart';

class LibrarySnapshot {
  const LibrarySnapshot({
    required this.scanRoots,
    required this.videos,
    required this.folders,
    required this.scannedAt,
  });

  final List<String> scanRoots;
  final List<VideoItem> videos;
  final List<VideoFolder> folders;
  final DateTime scannedAt;

  int get totalVideos => videos.length;
}
