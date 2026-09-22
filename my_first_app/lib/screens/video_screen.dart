import 'package:flutter/material.dart';

import '../models/video.dart';
import '../services/media_storage_service.dart';
import '../services/video_service.dart';
import '../widgets/video_card.dart';
import 'video_player_screen.dart';

class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  final TextEditingController _searchController = TextEditingController();
  final MediaStorageService _storage = MediaStorageService();
  List<Video> _videos = [];
  List<Video> _displayVideos = [];
  List<String> _favoriteIds = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final videos = await VideoService.loadLocalVideos();
    final favorites = await _storage.loadFavoriteVideos();
    if (!mounted) return;
    setState(() {
      _videos = videos;
      _displayVideos = videos;
      _favoriteIds = favorites;
    });
  }

  void _toggleFavorite(String videoId) {
    setState(() {
      if (_favoriteIds.contains(videoId)) {
        _favoriteIds.remove(videoId);
      } else {
        _favoriteIds.add(videoId);
      }
    });
    _storage.saveFavoriteVideos(_favoriteIds);
  }

  void _handleSearch(String query) {
    setState(() {
      _displayVideos = VideoService.searchVideos(_videos, query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final recent = _videos.where((video) => video.lastPlayed != null).toList()..sort((a, b) => (b.lastPlayed ?? DateTime.fromMillisecondsSinceEpoch(0)).compareTo(a.lastPlayed ?? DateTime.fromMillisecondsSinceEpoch(0)));

    return Scaffold(
      appBar: AppBar(title: const Text('AgVosb Video')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search videos...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty ? IconButton(onPressed: () {
                  _searchController.clear();
                  _handleSearch('');
                }, icon: const Icon(Icons.clear)) : null,
              ),
              onChanged: _handleSearch,
            ),
            const SizedBox(height: 22),
            Text('Recently Watched', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            SizedBox(
              height: 220,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: recent.take(4).length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final video = recent[index];
                  return SizedBox(
                    width: 220,
                    child: VideoCard(
                      video: video,
                      isFavorite: _favoriteIds.contains(video.id),
                      onFavorite: () => _toggleFavorite(video.id),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => VideoPlayerScreen(videos: _videos, initialIndex: _videos.indexOf(video)))),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 22),
            Text('Library', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount: _displayVideos.length,
              itemBuilder: (context, index) {
                final video = _displayVideos[index];
                return VideoCard(
                  video: video,
                  isFavorite: _favoriteIds.contains(video.id),
                  onFavorite: () => _toggleFavorite(video.id),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => VideoPlayerScreen(videos: _displayVideos, initialIndex: index))),
                );
              },
            ),
          ],
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
