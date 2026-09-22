class Playlist {
  Playlist({
    required this.id,
    required this.name,
    required this.songIds,
  });

  final String id;
  final String name;
  final List<String> songIds;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'songIds': songIds,
      };

  factory Playlist.fromJson(Map<String, dynamic> json) => Playlist(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? 'New playlist',
        songIds: (json['songIds'] as List<dynamic>? ?? const []).map((e) => e.toString()).toList(),
      );
}
