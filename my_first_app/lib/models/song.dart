class Song {
  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.durationSeconds,
    required this.filePath,
    required this.albumArt,
    required this.isFavorite,
    this.lastPlayed,
  });

  final String id;
  final String title;
  final String artist;
  final String album;
  final int durationSeconds;
  final String filePath;
  final String albumArt;
  final bool isFavorite;
  final DateTime? lastPlayed;

  String get durationLabel {
    final minutes = (durationSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (durationSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Song copyWith({
    String? id,
    String? title,
    String? artist,
    String? album,
    int? durationSeconds,
    String? filePath,
    String? albumArt,
    bool? isFavorite,
    DateTime? lastPlayed,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      filePath: filePath ?? this.filePath,
      albumArt: albumArt ?? this.albumArt,
      isFavorite: isFavorite ?? this.isFavorite,
      lastPlayed: lastPlayed ?? this.lastPlayed,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'artist': artist,
        'album': album,
        'durationSeconds': durationSeconds,
        'filePath': filePath,
        'albumArt': albumArt,
        'isFavorite': isFavorite,
        'lastPlayed': lastPlayed?.toIso8601String(),
      };

  factory Song.fromJson(Map<String, dynamic> json) => Song(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? 'Unknown track',
        artist: json['artist'] as String? ?? 'Unknown artist',
        album: json['album'] as String? ?? 'Unknown album',
        durationSeconds: json['durationSeconds'] as int? ?? 0,
        filePath: json['filePath'] as String? ?? '',
        albumArt: json['albumArt'] as String? ?? '',
        isFavorite: json['isFavorite'] as bool? ?? false,
        lastPlayed: json['lastPlayed'] != null ? DateTime.tryParse(json['lastPlayed'] as String) : null,
      );

  static List<Song> sampleSongs() => [
        Song(
          id: 'song_1',
          title: 'Midnight Drive',
          artist: 'North Harbor',
          album: 'City Lights',
          durationSeconds: 214,
          filePath: '/storage/emulated/0/Music/North Harbor/Midnight Drive.mp3',
          albumArt: 'https://images.unsplash.com/photo-1516280440614-37939bbacd81?auto=format&fit=crop&w=500&q=80',
          isFavorite: true,
          lastPlayed: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        Song(
          id: 'song_2',
          title: 'Quiet Waves',
          artist: 'Aster Vale',
          album: 'Coastal Echoes',
          durationSeconds: 192,
          filePath: '/storage/emulated/0/Music/Aster Vale/Quiet Waves.mp3',
          albumArt: 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=500&q=80',
          isFavorite: false,
          lastPlayed: DateTime.now().subtract(const Duration(days: 1)),
        ),
        Song(
          id: 'song_3',
          title: 'Open Skyline',
          artist: 'Milo Rowe',
          album: 'Morning Glass',
          durationSeconds: 236,
          filePath: '/storage/emulated/0/Music/Milo Rowe/Open Skyline.mp3',
          albumArt: 'https://images.unsplash.com/photo-1493246507139-91e8fad9978e?auto=format&fit=crop&w=500&q=80',
          isFavorite: false,
          lastPlayed: DateTime.now().subtract(const Duration(days: 3)),
        ),
      ];
}
