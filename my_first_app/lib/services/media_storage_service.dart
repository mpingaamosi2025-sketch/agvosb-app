import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class MediaStorageService {
  static const String _favoritesKey = 'agvosb_media_favorites';
  static const String _recentSongsKey = 'agvosb_recent_songs';
  static const String _recentVideosKey = 'agvosb_recent_videos';
  static const String _playlistsKey = 'agvosb_playlists';
  static const String _favoritesVideosKey = 'agvosb_video_favorites';
  static const String _videoPositionsKey = 'agvosb_video_positions';

  String _videoPositionKey(String videoId) => '$_videoPositionsKey:$videoId';

  Future<List<String>> loadFavoriteSongs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_favoritesKey) ?? const <String>[];
    return raw;
  }

  Future<void> saveFavoriteSongs(List<String> values) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesKey, values);
  }

  Future<List<String>> loadFavoriteVideos() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_favoritesVideosKey) ?? const <String>[];
    return raw;
  }

  Future<void> saveFavoriteVideos(List<String> values) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesVideosKey, values);
  }

  Future<List<String>> loadRecentSongs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_recentSongsKey) ?? const <String>[];
  }

  Future<void> saveRecentSongs(List<String> values) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_recentSongsKey, values.take(12).toList());
  }

  Future<List<String>> loadRecentVideos() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_recentVideosKey) ?? const <String>[];
  }

  Future<void> saveRecentVideos(List<String> values) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_recentVideosKey, values.take(12).toList());
  }

  Future<Map<String, dynamic>> loadPlaylists() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_playlistsKey) ?? '[]';
    final decoded = jsonDecode(raw) as List<dynamic>;
    return {'playlists': decoded};
  }

  Future<void> savePlaylists(List<Map<String, dynamic>> playlists) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_playlistsKey, jsonEncode(playlists));
  }

  Future<int> loadVideoPosition(String videoId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_videoPositionKey(videoId)) ?? 0;
  }

  Future<void> saveVideoPosition(String videoId, int positionSeconds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_videoPositionKey(videoId), positionSeconds);
  }
}
