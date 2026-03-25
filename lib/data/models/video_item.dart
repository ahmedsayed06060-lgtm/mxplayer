class VideoItem {
  const VideoItem({
    required this.id,
    required this.title,
    required this.path,
    required this.folderPath,
    required this.folderName,
    required this.extension,
    required this.fileSizeBytes,
    required this.lastModifiedEpochMs,
    this.durationMs,
    this.width,
    this.height,
  });

  final String id;
  final String title;
  final String path;
  final String folderPath;
  final String folderName;
  final String extension;
  final int fileSizeBytes;
  final int lastModifiedEpochMs;
  final int? durationMs;
  final int? width;
  final int? height;

  Duration? get duration =>
      durationMs == null ? null : Duration(milliseconds: durationMs!);

  VideoItem copyWith({
    String? id,
    String? title,
    String? path,
    String? folderPath,
    String? folderName,
    String? extension,
    int? fileSizeBytes,
    int? lastModifiedEpochMs,
    int? durationMs,
    int? width,
    int? height,
    bool clearDuration = false,
    bool clearResolution = false,
  }) {
    return VideoItem(
      id: id ?? this.id,
      title: title ?? this.title,
      path: path ?? this.path,
      folderPath: folderPath ?? this.folderPath,
      folderName: folderName ?? this.folderName,
      extension: extension ?? this.extension,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      lastModifiedEpochMs: lastModifiedEpochMs ?? this.lastModifiedEpochMs,
      durationMs: clearDuration ? null : (durationMs ?? this.durationMs),
      width: clearResolution ? null : (width ?? this.width),
      height: clearResolution ? null : (height ?? this.height),
    );
  }
}
