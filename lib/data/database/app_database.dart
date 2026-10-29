import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../../core/constants/app_constants.dart';

import '../../features/player/models/recent_playback_item.dart';
import '../models/download_item.dart';

final class WatchProgressRecord {
  const WatchProgressRecord({
    required this.id,
    required this.positionMs,
    required this.durationMs,
  });

  final String id;
  final int positionMs;
  final int durationMs;
}

final class PlaylistRecord {
  const PlaylistRecord({
    required this.id,
    required this.name,
  });

  final int id;
  final String name;
}

final class PlaylistVideoRecord {
  const PlaylistVideoRecord({
    required this.playlistId,
    required this.videoId,
    required this.title,
    required this.path,
  });

  final int playlistId;
  final String videoId;
  final String title;
  final String path;
}

/// Local persistence for watch progress, downloads and playlists.
///
/// Every operation degrades gracefully: platforms without sqflite support
/// (Windows / Linux desktop) simply keep the session data in memory instead of
/// crashing, so the player stays usable everywhere.
class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    final String dbPath = await getDatabasesPath();
    _database = await openDatabase(
      p.join(dbPath, AppConstants.databaseFileName),
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE watch_progress(
            id TEXT PRIMARY KEY,
            title TEXT,
            path TEXT,
            is_network INTEGER NOT NULL,
            position_ms INTEGER NOT NULL,
            duration_ms INTEGER NOT NULL,
            updated_at INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE download_history(
            id TEXT PRIMARY KEY,
            url TEXT NOT NULL,
            file_name TEXT NOT NULL,
            status TEXT NOT NULL,
            progress INTEGER NOT NULL,
            local_path TEXT,
            updated_at INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE playlists(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL UNIQUE
          )
        ''');
        await db.execute('''
          CREATE TABLE playlist_items(
            playlist_id INTEGER NOT NULL,
            video_id TEXT NOT NULL,
            title TEXT NOT NULL,
            path TEXT NOT NULL,
            added_at INTEGER NOT NULL,
            PRIMARY KEY(playlist_id, video_id)
          )
        ''');
      },
    );
    return _database!;
  }

  Future<void> saveWatchProgress({
    required String id,
    required String title,
    required String path,
    required bool isNetwork,
    required int positionMs,
    required int durationMs,
  }) async {
    try {
      final Database db = await database;
      await db.insert(
        'watch_progress',
        <String, Object?>{
          'id': id,
          'title': title,
          'path': path,
          'is_network': isNetwork ? 1 : 0,
          'position_ms': positionMs,
          'duration_ms': durationMs,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (_) {
      // Persistence is best effort.
    }
  }

  Future<WatchProgressRecord?> loadWatchProgress(String id) async {
    try {
      final Database db = await database;
      final List<Map<String, Object?>> rows =
          await db.query('watch_progress', where: 'id = ?', whereArgs: <Object?>[id], limit: 1);
      if (rows.isEmpty) {
        return null;
      }
      final Map<String, Object?> row = rows.first;
      return WatchProgressRecord(
        id: row['id'] as String,
        positionMs: (row['position_ms'] as num?)?.toInt() ?? 0,
        durationMs: (row['duration_ms'] as num?)?.toInt() ?? 0,
      );
    } catch (_) {
      return null;
    }
  }

  Future<List<RecentPlaybackItem>> loadRecentPlayback({int limit = 20}) async {
    try {
      final Database db = await database;
      final List<Map<String, Object?>> rows =
          await db.query('watch_progress', orderBy: 'updated_at DESC', limit: limit);
      return rows
          .map(
            (Map<String, Object?> row) => RecentPlaybackItem(
              id: row['id'] as String,
              title: row['title'] as String? ?? row['id'] as String,
              path: row['path'] as String? ?? '',
              isNetwork: (row['is_network'] as int? ?? 0) == 1,
              playedAt: DateTime.fromMillisecondsSinceEpoch((row['updated_at'] as num?)?.toInt() ?? 0),
              positionMs: (row['position_ms'] as num?)?.toInt() ?? 0,
              durationMs: (row['duration_ms'] as num?)?.toInt() ?? 0,
            ),
          )
          .toList(growable: false);
    } catch (_) {
      return const <RecentPlaybackItem>[];
    }
  }

  Future<void> saveDownloadHistory(DownloadItem item) async {
    try {
      final Database db = await database;
      await db.insert(
        'download_history',
        <String, Object?>{
          'id': item.id,
          'url': item.url,
          'file_name': item.fileName,
          'status': item.status.name,
          'progress': item.progress,
          'local_path': item.localPath,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (_) {
      // Persistence is best effort.
    }
  }

  Future<List<DownloadItem>> loadDownloads() async {
    try {
      final Database db = await database;
      final List<Map<String, Object?>> rows = await db.query('download_history', orderBy: 'updated_at DESC');
      return rows
          .map(
            (Map<String, Object?> row) => DownloadItem(
              id: row['id'] as String,
              url: row['url'] as String,
              fileName: row['file_name'] as String,
              status: DownloadStatus.values.byName(row['status'] as String),
              progress: (row['progress'] as num?)?.toInt() ?? 0,
              localPath: row['local_path'] as String?,
            ),
          )
          .toList(growable: false);
    } catch (_) {
      return const <DownloadItem>[];
    }
  }

  Future<List<PlaylistRecord>> loadPlaylists() async {
    try {
      final Database db = await database;
      final List<Map<String, Object?>> rows = await db.query('playlists', orderBy: 'name COLLATE NOCASE ASC');
      return rows
          .map((Map<String, Object?> row) => PlaylistRecord(id: row['id'] as int, name: row['name'] as String))
          .toList(growable: false);
    } catch (_) {
      return const <PlaylistRecord>[];
    }
  }

  Future<int> createPlaylist(String name) async {
    try {
      final Database db = await database;
      return db.insert('playlists', <String, Object?>{'name': name}, conflictAlgorithm: ConflictAlgorithm.ignore);
    } catch (_) {
      return 0;
    }
  }

  Future<void> addVideoToPlaylist({
    required int playlistId,
    required String videoId,
    required String title,
    required String path,
  }) async {
    try {
      final Database db = await database;
      await db.insert(
        'playlist_items',
        <String, Object?>{
          'playlist_id': playlistId,
          'video_id': videoId,
          'title': title,
          'path': path,
          'added_at': DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (_) {
      // Persistence is best effort.
    }
  }

  Future<List<PlaylistVideoRecord>> loadPlaylistVideos(int playlistId) async {
    try {
      final Database db = await database;
      final List<Map<String, Object?>> rows = await db.query(
        'playlist_items',
        where: 'playlist_id = ?',
        whereArgs: <Object?>[playlistId],
        orderBy: 'added_at DESC',
      );
      return rows
          .map(
            (Map<String, Object?> row) => PlaylistVideoRecord(
              playlistId: (row['playlist_id'] as num).toInt(),
              videoId: row['video_id'] as String,
              title: row['title'] as String,
              path: row['path'] as String,
            ),
          )
          .toList(growable: false);
    } catch (_) {
      return const <PlaylistVideoRecord>[];
    }
  }
}
