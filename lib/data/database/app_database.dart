import 'dart:async';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

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

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    final dbPath = await getDatabasesPath();
    _database = await openDatabase(
      p.join(dbPath, 'smart_player_pro.db'),
      version: 1,
      onCreate: (db, version) async {
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
    final db = await database;
    await db.insert(
      'watch_progress',
      {
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
  }

  Future<WatchProgressRecord?> loadWatchProgress(String id) async {
    final db = await database;
    final rows = await db.query('watch_progress', where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) {
      return null;
    }
    final row = rows.first;
    return WatchProgressRecord(
      id: row['id'] as String,
      positionMs: row['position_ms'] as int,
      durationMs: row['duration_ms'] as int,
    );
  }

  Future<List<RecentPlaybackItem>> loadRecentPlayback({int limit = 20}) async {
    final db = await database;
    final rows = await db.query('watch_progress', orderBy: 'updated_at DESC', limit: limit);
    return rows
        .map(
          (row) => RecentPlaybackItem(
            id: row['id'] as String,
            title: row['title'] as String? ?? row['id'] as String,
            path: row['path'] as String? ?? '',
            isNetwork: (row['is_network'] as int? ?? 0) == 1,
            playedAt: DateTime.fromMillisecondsSinceEpoch(row['updated_at'] as int),
          ),
        )
        .toList(growable: false);
  }

  Future<void> saveDownloadHistory(DownloadItem item) async {
    final db = await database;
    await db.insert(
      'download_history',
      {
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
  }

  Future<List<DownloadItem>> loadDownloads() async {
    final db = await database;
    final rows = await db.query('download_history', orderBy: 'updated_at DESC');
    return rows
        .map(
          (row) => DownloadItem(
            id: row['id'] as String,
            url: row['url'] as String,
            fileName: row['file_name'] as String,
            status: DownloadStatus.values.byName(row['status'] as String),
            progress: row['progress'] as int,
            localPath: row['local_path'] as String?,
          ),
        )
        .toList(growable: false);
  }

  Future<List<PlaylistRecord>> loadPlaylists() async {
    final db = await database;
    final rows = await db.query('playlists', orderBy: 'name COLLATE NOCASE ASC');
    return rows
        .map((row) => PlaylistRecord(id: row['id'] as int, name: row['name'] as String))
        .toList(growable: false);
  }

  Future<int> createPlaylist(String name) async {
    final db = await database;
    return db.insert('playlists', {'name': name}, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<void> addVideoToPlaylist({
    required int playlistId,
    required String videoId,
    required String title,
    required String path,
  }) async {
    final db = await database;
    await db.insert(
      'playlist_items',
      {
        'playlist_id': playlistId,
        'video_id': videoId,
        'title': title,
        'path': path,
        'added_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<PlaylistVideoRecord>> loadPlaylistVideos(int playlistId) async {
    final db = await database;
    final rows = await db.query(
      'playlist_items',
      where: 'playlist_id = ?',
      whereArgs: [playlistId],
      orderBy: 'added_at DESC',
    );
    return rows
        .map(
          (row) => PlaylistVideoRecord(
            playlistId: row['playlist_id'] as int,
            videoId: row['video_id'] as String,
            title: row['title'] as String,
            path: row['path'] as String,
          ),
        )
        .toList(growable: false);
  }
}
