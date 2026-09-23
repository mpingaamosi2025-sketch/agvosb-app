import 'package:flutter/material.dart';

import '../models/playlist.dart';
import '../models/song.dart';
import '../services/audio_service.dart';
import '../services/media_storage_service.dart';
import '../services/music_service.dart';
import '../widgets/now_playing_card.dart';
import '../widgets/song_card.dart';

class MusicScreen extends StatefulWidget {
  const MusicScreen({super.key, required this.audio, this.onSongSelected});

  final AudioService audio;
  final void Function(Song song, List<Song> songs)? onSongSelected;

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  final TextEditingController _searchController = TextEditingController();
  final MediaStorageService _storage = MediaStorageService();
  List<Song> _songs = [];
  List<Song> _displaySongs = [];
  List<String> _favoriteIds = [];
  List<Playlist> _playlists = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final songs = await MusicService.loadLocalSongs();
    final favoriteSongs = await _storage.loadFavoriteSongs();
    final playlistData = await _storage.loadPlaylists();
    final playlists = (playlistData['playlists'] as List<dynamic>? ?? const [])
        .map((item) => Playlist.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();

    if (!mounted) return;
    setState(() {
      _songs = songs;
      _displaySongs = songs;
      _favoriteIds = favoriteSongs;
      _playlists = playlists;
    });
  }

  void _toggleFavorite(String songId) {
    setState(() {
      if (_favoriteIds.contains(songId)) {
        _favoriteIds.remove(songId);
      } else {
        _favoriteIds.add(songId);
      }
    });
    _storage.saveFavoriteSongs(_favoriteIds);
  }

  void _handleSearch(String query) {
    setState(() {
      _displaySongs = MusicService.searchSongs(_songs, query);
    });
  }

  void _createPlaylist() {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create playlist'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Playlist name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              setState(() => _playlists.add(Playlist(id: DateTime.now().millisecondsSinceEpoch.toString(), name: name, songIds: const [])));
              Navigator.pop(context);
              _storage.savePlaylists(_playlists.map((playlist) => playlist.toJson()).toList());
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final recent = _songs.where((song) => song.lastPlayed != null).toList()..sort((a, b) => (b.lastPlayed ?? DateTime.fromMillisecondsSinceEpoch(0)).compareTo(a.lastPlayed ?? DateTime.fromMillisecondsSinceEpoch(0)));
    final favoriteSongs = _songs.where((song) => _favoriteIds.contains(song.id)).toList();

    return AnimatedBuilder(
      animation: widget.audio,
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: const Text('AgVosb Music'),
          actions: [
            IconButton(onPressed: _createPlaylist, icon: const Icon(Icons.playlist_add_rounded)),
          ],
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search music...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          _handleSearch('');
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,
              ),
              onChanged: _handleSearch,
            ),
            const SizedBox(height: 22),
            if (widget.audio.currentSong != null) ...[
              NowPlayingCard(audio: widget.audio),
              const SizedBox(height: 22),
            ],
            Text('Recently Played', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: recent.take(6).length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final song = recent[index];
                  return SizedBox(
                    width: 160,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: song.albumArt.isNotEmpty
                                  ? Image.network(song.albumArt, width: 56, height: 56, fit: BoxFit.cover,
                                      errorBuilder: (context, _, _) => Container(width: 56, height: 56, color: theme.colorScheme.primaryContainer, child: const Icon(Icons.music_note)))
                                  : Container(width: 56, height: 56, color: theme.colorScheme.primaryContainer, child: const Icon(Icons.music_note)),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                                  Text(song.artist, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Text('Albums', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                const Spacer(),
                Text('${_songs.length} tracks', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _songs.map((song) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: theme.colorScheme.surfaceContainerHighest,
                ),
                child: Text(song.album),
              )).toList(),
            ),
            const SizedBox(height: 22),
            Text('Playlists', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            if (_playlists.isEmpty)
              const Text('No playlists yet. Create one to group your favorite tracks.')
            else
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _playlists.map((playlist) => Chip(label: Text(playlist.name))).toList(),
              ),
            const SizedBox(height: 22),
            Text('Favorites', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            if (favoriteSongs.isEmpty)
              const Text('Save songs as favorites to keep them close.')
            else
              ...favoriteSongs.map((song) => SongCard(song: song, onTap: () {}, onFavorite: (value) => _toggleFavorite(song.id))),
            const SizedBox(height: 22),
            Text('Library', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            ..._displaySongs.map((song) => SongCard(
                  song: song,
                  onTap: () => widget.onSongSelected?.call(song, _songs),
                  onFavorite: (value) => _toggleFavorite(song.id),
                )),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
