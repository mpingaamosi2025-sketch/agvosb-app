import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

import '../models/video.dart';

class VideoService {
  static List<Video> sampleVideos() => Video.sampleVideos();

  static Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.videos.status;
      if (status.isGranted) return true;
      final requested = await Permission.videos.request();
      if (requested.isGranted) return true;

      if (await Permission.storage.status.isGranted) return true;
      final storageRequested = await Permission.storage.request();
      return storageRequested.isGranted;
    }
    return true;
  }

  static Future<List<Video>> loadLocalVideos() async {
    final hasPermission = await requestPermission();
    if (!hasPermission) return sampleVideos();

    final roots = [
      '/storage/emulated/0/Movies',
      '/storage/emulated/0/DCIM',
      '/storage/emulated/0/Download',
      '/storage/emulated/0',
      '/sdcard/Movies',
      '/sdcard/DCIM',
      '/sdcard/Download',
    ];

    final videos = <Video>[];
    final seen = <String>{};

    for (final root in roots) {
      final directory = Directory(root);
      if (!await directory.exists()) continue;
      _collectVideoFiles(directory, videos, seen);
    }

    if (videos.isEmpty) return sampleVideos();
    videos.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    return videos;
  }

  static void _collectVideoFiles(Directory directory, List<Video> videos, Set<String> seen) {
    try {
      final entities = directory.listSync(followLinks: false, recursive: false);
      for (final entity in entities) {
        if (entity is File) {
          final lower = entity.path.toLowerCase();
          final isVideo = lower.endsWith('.mp4') ||
              lower.endsWith('.m4v') ||
              lower.endsWith('.mov') ||
              lower.endsWith('.avi') ||
              lower.endsWith('.mkv') ||
              lower.endsWith('.webm') ||
              lower.endsWith('.3gp');

          if (isVideo) {
            final filePath = entity.path;
            if (seen.contains(filePath)) continue;
            seen.add(filePath);
            final fileName = entity.uri.pathSegments.isNotEmpty ? entity.uri.pathSegments.last : 'Unknown';
            final title = fileName.replaceAll(RegExp(r'\.\w+$'), '');
            videos.add(
              Video(
                id: filePath,
                title: title,
                durationSeconds: 0,
                filePath: filePath,
                thumbnail: '',
                sizeBytes: entity.lengthSync(),
                isFavorite: false,
                lastPositionSeconds: 0,
              ),
            );
          }
        } else if (entity is Directory) {
          _collectVideoFiles(entity, videos, seen);
        }
      }
    } catch (_) {}
  }

  static List<Video> searchVideos(List<Video> videos, String query) {
    final text = query.trim().toLowerCase();
    if (text.isEmpty) return videos;
    return videos.where((video) {
      final haystack = [video.title, video.filePath].join(' ').toLowerCase();
      return haystack.contains(text);
    }).toList();
  }
}
