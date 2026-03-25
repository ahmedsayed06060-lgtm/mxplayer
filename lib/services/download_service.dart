import 'dart:io';

import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';

import '../data/models/download_item.dart';

class DownloadService {
  Future<DownloadItem> enqueue({required String id, required String url}) async {
    final fileName = Uri.parse(url).pathSegments.isEmpty
        ? 'video_$id.mp4'
        : Uri.parse(url).pathSegments.last;
    if (Platform.isAndroid || Platform.isIOS) {
      final directory = await getApplicationDocumentsDirectory();
      final taskId = await FlutterDownloader.enqueue(
        url: url,
        savedDir: directory.path,
        fileName: fileName,
        showNotification: true,
        openFileFromNotification: true,
      );
      return DownloadItem(
        id: id,
        url: url,
        fileName: fileName,
        status: DownloadStatus.running,
        progress: 0,
        localPath: directory.path,
        platformTaskId: taskId,
      );
    }

    final directory = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
    final output = File('${directory.path}${Platform.pathSeparator}$fileName');
    return _downloadWithHttp(id: id, url: url, fileName: fileName, output: output);
  }

  Future<DownloadItem> _downloadWithHttp({
    required String id,
    required String url,
    required String fileName,
    required File output,
  }) async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();
      final sink = output.openWrite();
      await response.pipe(sink);
      return DownloadItem(
        id: id,
        url: url,
        fileName: fileName,
        status: DownloadStatus.completed,
        progress: 100,
        localPath: output.path,
      );
    } catch (_) {
      return DownloadItem(
        id: id,
        url: url,
        fileName: fileName,
        status: DownloadStatus.failed,
        progress: 0,
      );
    } finally {
      client.close(force: true);
    }
  }

  Future<void> pause(String? taskId) async {
    if (taskId == null || !(Platform.isAndroid || Platform.isIOS)) {
      return;
    }
    await FlutterDownloader.pause(taskId: taskId);
  }

  Future<void> resume(String? taskId) async {
    if (taskId == null || !(Platform.isAndroid || Platform.isIOS)) {
      return;
    }
    await FlutterDownloader.resume(taskId: taskId);
  }

  Future<void> cancel(String? taskId) async {
    if (taskId == null || !(Platform.isAndroid || Platform.isIOS)) {
      return;
    }
    await FlutterDownloader.cancel(taskId: taskId);
  }
}
