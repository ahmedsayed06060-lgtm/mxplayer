import 'dart:io';
import 'dart:isolate';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class RawVideoItem {
  const RawVideoItem({
    required this.path,
    required this.title,
    required this.folderPath,
    required this.folderName,
    required this.extension,
    required this.fileSizeBytes,
    required this.lastModifiedEpochMs,
  });

  final String path;
  final String title;
  final String folderPath;
  final String folderName;
  final String extension;
  final int fileSizeBytes;
  final int lastModifiedEpochMs;

  factory RawVideoItem.fromMap(Map<String, Object?> map) {
    return RawVideoItem(
      path: map['path']! as String,
      title: map['title']! as String,
      folderPath: map['folderPath']! as String,
      folderName: map['folderName']! as String,
      extension: map['extension']! as String,
      fileSizeBytes: map['fileSizeBytes']! as int,
      lastModifiedEpochMs: map['lastModifiedEpochMs']! as int,
    );
  }
}

class MediaScanService {
  static const Set<String> supportedExtensions = {
    'mp4',
    'mkv',
    'avi',
    'mov',
    'flv',
    'wmv',
    'webm',
    'm4v',
  };

  Future<List<String>> resolveInitialRoots() async {
    final roots = <String>{};

    if (Platform.isAndroid) {
      await _requestAndroidPermissions();
      final commonRoots = <String>{
        '/storage/emulated/0/Movies',
        '/storage/emulated/0/DCIM',
        '/storage/emulated/0/Download',
        '/storage/emulated/0/Downloads',
        '/storage/emulated/0/Videos',
      };
      final externalDirs = await getExternalStorageDirectories();
      for (final directory in externalDirs ?? <Directory>[]) {
        commonRoots.add(directory.path);
      }
      for (final path in commonRoots) {
        if (Directory(path).existsSync()) {
          roots.add(path);
        }
      }
    } else {
      final home = Platform.environment['USERPROFILE'] ??
          Platform.environment['HOME'] ??
          '';
      final candidates = <String>[
        if (home.isNotEmpty) '$home${Platform.pathSeparator}Videos',
        if (home.isNotEmpty) '$home${Platform.pathSeparator}Downloads',
      ];
      for (final path in candidates) {
        if (Directory(path).existsSync()) {
          roots.add(path);
        }
      }
    }

    return roots.toList()..sort();
  }

  Future<String?> pickDirectory() {
    return FilePicker.platform.getDirectoryPath(dialogTitle: 'Choose video folder');
  }

  Future<List<RawVideoItem>> scanRoots(List<String> roots) async {
    final sanitizedRoots = roots.where((element) => element.trim().isNotEmpty).toList();
    if (sanitizedRoots.isEmpty) {
      return const <RawVideoItem>[];
    }

    final results = await Isolate.run<List<Map<String, Object?>>>(() {
      return _scanVideoFiles(sanitizedRoots);
    });

    return results.map(RawVideoItem.fromMap).toList();
  }

  Future<void> _requestAndroidPermissions() async {
    final statuses = await [
      Permission.storage,
      Permission.videos,
      Permission.manageExternalStorage,
    ].request();

    final anyGranted = statuses.values.any(
      (status) => status.isGranted || status.isLimited,
    );

    if (!anyGranted) {
      throw FileSystemException('Storage access permission was denied.');
    }
  }
}

@pragma('vm:entry-point')
List<Map<String, Object?>> _scanVideoFiles(List<String> roots) {
  final items = <Map<String, Object?>>[];

  for (final root in roots) {
    final directory = Directory(root);
    if (!directory.existsSync()) {
      continue;
    }

    try {
      final entities = directory.listSync(recursive: true, followLinks: false);
      for (final entity in entities) {
        if (entity is! File) {
          continue;
        }

        final path = entity.path;
        final extension = _extensionOf(path).toLowerCase();
        if (!MediaScanService.supportedExtensions.contains(extension)) {
          continue;
        }

        final stat = entity.statSync();
        final folderPath = entity.parent.path;
        items.add({
          'path': path,
          'title': _basenameWithoutExtension(path),
          'folderPath': folderPath,
          'folderName': _basename(folderPath),
          'extension': extension,
          'fileSizeBytes': stat.size,
          'lastModifiedEpochMs': stat.modified.millisecondsSinceEpoch,
        });
      }
    } catch (_) {
      continue;
    }
  }

  items.sort((a, b) => (b['lastModifiedEpochMs']! as int).compareTo(a['lastModifiedEpochMs']! as int));
  return items;
}

String _basename(String path) {
  final normalized = path.replaceAll('\\', '/');
  final parts = normalized.split('/').where((part) => part.isNotEmpty).toList();
  return parts.isEmpty ? path : parts.last;
}

String _basenameWithoutExtension(String path) {
  final base = _basename(path);
  final dot = base.lastIndexOf('.');
  return dot <= 0 ? base : base.substring(0, dot);
}

String _extensionOf(String path) {
  final normalized = path.replaceAll('\\', '/');
  final dot = normalized.lastIndexOf('.');
  return dot == -1 ? '' : normalized.substring(dot + 1);
}


