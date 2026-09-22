import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

import '../models/song.dart';

class MusicService {
  static List<Song> sampleSongs() => Song.sampleSongs();

  static Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.audio.status;
      if (status.isGranted) return true;
      final requested = await Permission.audio.request();
      if (requested.isGranted) return true;

      if (await Permission.storage.status.isGranted) return true;
      final storageRequested = await Permission.storage.request();
      return storageRequested.isGranted;
    }
    return true;
  }

  static Future<List<Song>> loadLocalSongs() async {
    final hasPermission = await requestPermission();
    if (!hasPermission) return sampleSongs();

    final roots = [
      '/storage/emulated/0/Music',
      '/storage/emulated/0/Download',
      '/storage/emulated/0',
      '/sdcard/Music',
      '/sdcard/Download',
    ];

    final songs = <Song>[];
    final seen = <String>{};

    for (final root in roots) {
      final directory = Directory(root);
      if (!await directory.exists()) continue;
      _collectAudioFiles(directory, songs, seen);
    }

    if (songs.isEmpty) return sampleSongs();
    songs.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    return songs;
  }

  static void _collectAudioFiles(Directory directory, List<Song> songs, Set<String> seen) {
    try {
      final entities = directory.listSync(followLinks: false, recursive: false);
      for (final entity in entities) {
        if (entity is File) {
          final lower = entity.path.toLowerCase();
          final isAudio = lower.endsWith('.mp3') ||
              lower.endsWith('.wav') ||
              lower.endsWith('.m4a') ||
              lower.endsWith('.aac') ||
              lower.endsWith('.flac') ||
              lower.endsWith('.ogg') ||
              lower.endsWith('.opus');

          if (isAudio) {
            final filePath = entity.path;
            if (seen.contains(filePath)) continue;
            seen.add(filePath);
            final fileName = entity.uri.pathSegments.isNotEmpty ? entity.uri.pathSegments.last : 'Unknown';
            final title = fileName.replaceAll(RegExp(r'\.\w+$'), '');
            songs.add(
              Song(
                id: filePath,
                title: title,
                artist: 'Unknown artist',
                album: directory.path.split('/').lastWhere((segment) => segment.isNotEmpty, orElse: () => 'Music'),
                durationSeconds: 0,
                filePath: filePath,
                albumArt: '',
                isFavorite: false,
              ),
            );
          }
        } else if (entity is Directory) {
          _collectAudioFiles(entity, songs, seen);
        }
      }
    } catch (_) {}
  }

  static List<Song> searchSongs(List<Song> songs, String query) {
    final text = query.trim().toLowerCase();
    if (text.isEmpty) return songs;
    return songs.where((song) {
      final haystack = [song.title, song.artist, song.album].join(' ').toLowerCase();
      return haystack.contains(text);
    }).toList();
  }
}
