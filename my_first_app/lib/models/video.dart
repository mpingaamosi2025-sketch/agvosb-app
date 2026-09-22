class Video {
  Video({
    required this.id,
    required this.title,
    required this.durationSeconds,
    required this.filePath,
    required this.thumbnail,
    required this.sizeBytes,
    required this.isFavorite,
    this.lastPlayed,
    this.lastPositionSeconds = 0,
  });

  final String id;
  final String title;
  final int durationSeconds;
  final String filePath;
  final String thumbnail;
  final int sizeBytes;
  final bool isFavorite;
  final DateTime? lastPlayed;
  final int lastPositionSeconds;

  String get durationLabel {
    final hours = durationSeconds ~/ 3600;
    final minutes = (durationSeconds % 3600) ~/ 60;
    final seconds = durationSeconds % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get fileSizeLabel {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'durationSeconds': durationSeconds,
        'filePath': filePath,
        'thumbnail': thumbnail,
        'sizeBytes': sizeBytes,
        'isFavorite': isFavorite,
        'lastPlayed': lastPlayed?.toIso8601String(),
        'lastPositionSeconds': lastPositionSeconds,
      };

  factory Video.fromJson(Map<String, dynamic> json) => Video(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? 'Untitled video',
        durationSeconds: json['durationSeconds'] as int? ?? 0,
        filePath: json['filePath'] as String? ?? '',
        thumbnail: json['thumbnail'] as String? ?? '',
        sizeBytes: json['sizeBytes'] as int? ?? 0,
        isFavorite: json['isFavorite'] as bool? ?? false,
        lastPlayed: json['lastPlayed'] != null ? DateTime.tryParse(json['lastPlayed'] as String) : null,
        lastPositionSeconds: json['lastPositionSeconds'] as int? ?? 0,
      );

  static List<Video> sampleVideos() => [
        Video(
          id: 'video_1',
          title: 'City Sunset',
          durationSeconds: 238,
          filePath: '/storage/emulated/0/Movies/City Sunset.mp4',
          thumbnail: 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=700&q=80',
          sizeBytes: 14 * 1024 * 1024,
          isFavorite: false,
          lastPlayed: DateTime.now().subtract(const Duration(minutes: 14)),
          lastPositionSeconds: 128,
        ),
        Video(
          id: 'video_2',
          title: 'Mountain Hike',
          durationSeconds: 312,
          filePath: '/storage/emulated/0/Movies/Mountain Hike.mp4',
          thumbnail: 'https://images.unsplash.com/photo-1469474968028-56623f02e42e?auto=format&fit=crop&w=700&q=80',
          sizeBytes: 18 * 1024 * 1024,
          isFavorite: true,
          lastPlayed: DateTime.now().subtract(const Duration(days: 1)),
          lastPositionSeconds: 72,
        ),
        Video(
          id: 'video_3',
          title: 'Studio Session',
          durationSeconds: 196,
          filePath: '/storage/emulated/0/Movies/Studio Session.mp4',
          thumbnail: 'https://images.unsplash.com/photo-1516280440614-37939bbacd81?auto=format&fit=crop&w=700&q=80',
          sizeBytes: 11 * 1024 * 1024,
          isFavorite: false,
          lastPlayed: DateTime.now().subtract(const Duration(days: 2)),
          lastPositionSeconds: 36,
        ),
      ];
}
