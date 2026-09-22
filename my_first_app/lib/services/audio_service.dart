import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import '../models/song.dart';

class AudioService extends ChangeNotifier {
  AudioService() {
    _player.onPlayerStateChanged.listen((state) {
      _isPlaying = state == PlayerState.playing;
      notifyListeners();
    });
    _player.onDurationChanged.listen((value) {
      _duration = value;
      notifyListeners();
    });
    _player.onPositionChanged.listen((value) {
      _position = value;
      notifyListeners();
    });
    _player.onPlayerComplete.listen((_) {
      _isPlaying = false;
      _position = _duration;
      notifyListeners();
    });
  }

  final AudioPlayer _player = AudioPlayer();
  Song? _currentSong;
  List<Song> _songs = const [];
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isPlaying = false;
  bool _disposed = false;

  Song? get currentSong => _currentSong;
  List<Song> get songs => _songs;
  Duration get position => _position;
  Duration get duration => _duration;
  bool get isPlaying => _isPlaying;

  Future<void> playSong(Song song, {List<Song>? songs}) async {
    final file = File(song.filePath);
    if (!await file.exists()) {
      debugPrint('Music playback error: file not found -> ${song.filePath}');
      return;
    }

    _currentSong = song;
    if (songs != null && songs.isNotEmpty) {
      _songs = List.unmodifiable(songs);
    } else if (!_songs.any((item) => item.id == song.id)) {
      _songs = [song, ..._songs];
    }
    _position = Duration.zero;
    _duration = Duration.zero;
    _isPlaying = false;
    notifyListeners();

    try {
      final source = DeviceFileSource(song.filePath);
      await _player.stop();
      await _player.setSource(source);
      await _player.play(source);
    } catch (error) {
      debugPrint('Music playback error: $error');
      _isPlaying = false;
      notifyListeners();
    }
  }

  Future<void> togglePlayPause() async {
    if (_currentSong == null) return;
    if (_isPlaying) {
      await _player.pause();
    } else {
      await _player.resume();
    }
  }

  Future<void> pause() => _player.pause();

  Future<void> seek(Duration value) async {
    await _player.seek(value);
    _position = value;
    notifyListeners();
  }

  Future<void> next() async {
    if (_songs.isEmpty || _currentSong == null) return;
    final currentIndex = _songs.indexWhere((song) => song.id == _currentSong!.id);
    final nextIndex = (currentIndex + 1) % _songs.length;
    await playSong(_songs[nextIndex]);
  }

  Future<void> previous() async {
    if (_songs.isEmpty || _currentSong == null) return;
    final currentIndex = _songs.indexWhere((song) => song.id == _currentSong!.id);
    final previousIndex = (currentIndex - 1 + _songs.length) % _songs.length;
    await playSong(_songs[previousIndex]);
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _player.dispose();
    super.dispose();
  }
}
