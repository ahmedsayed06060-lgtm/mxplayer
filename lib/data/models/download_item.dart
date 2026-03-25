enum DownloadStatus {
  queued,
  running,
  paused,
  completed,
  failed,
  canceled,
}

class DownloadItem {
  const DownloadItem({
    required this.id,
    required this.url,
    required this.fileName,
    required this.status,
    required this.progress,
    this.localPath,
    this.platformTaskId,
  });

  final String id;
  final String url;
  final String fileName;
  final DownloadStatus status;
  final int progress;
  final String? localPath;
  final String? platformTaskId;

  DownloadItem copyWith({
    DownloadStatus? status,
    int? progress,
    String? localPath,
    String? platformTaskId,
  }) {
    return DownloadItem(
      id: id,
      url: url,
      fileName: fileName,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      localPath: localPath ?? this.localPath,
      platformTaskId: platformTaskId ?? this.platformTaskId,
    );
  }
}
