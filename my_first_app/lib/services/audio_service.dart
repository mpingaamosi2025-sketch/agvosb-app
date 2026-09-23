import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart' as audio_service;
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../models/song.dart';

class AudioService extends ChangeNotifier {
  AudioService._(this._handler) {
    _playbackSubscription = _handler.playbackState.listen((state) {
      _isPlaying = state.playing;
      _position = state.updatePosition;
      notifyListeners();
    });
    _mediaItemSubscription = _handler.mediaItem.listen((item) {
      _duration = item?.duration ?? Duration.zero;
      if (item != null) {
        _currentSong = _songs.firstWhere(
          (song) => song.id == item.id,
          orElse: () => _songFromMediaItem(item),
        );
      }
      notifyListeners();
    });
  }

  static Future<AudioService> initialize() async {
    final handler = await audio_service.AudioService.init(
      builder: () => AgVosbAudioHandler(),
      config: const audio_service.AudioServiceConfig(
        androidNotificationChannelId: 'com.agvosb.cal.audio',
        androidNotificationChannelName: 'AgVosb Music',
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: true,
        androidNotificationIcon: 'mipmap/ic_launcher',
      ),
    );
    return AudioService._(handler);
  }

  final AgVosbAudioHandler _handler;
  late final StreamSubscription<audio_service.PlaybackState> _playbackSubscription;
  late final StreamSubscription<audio_service.MediaItem?> _mediaItemSubscription;
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
      await _handler.playSong(song, _songs);
    } catch (error) {
      debugPrint('Music playback error: $error');
      _isPlaying = false;
      notifyListeners();
    }
  }

  Future<void> togglePlayPause() async {
    if (_currentSong == null) return;
    if (_isPlaying) {
      await _handler.pause();
    } else {
      await _handler.play();
    }
  }

  Future<void> pause() => _handler.pause();

  Future<void> seek(Duration value) async {
    await _handler.seek(value);
  }

  Future<void> next() => _handler.skipToNext();

  Future<void> previous() => _handler.skipToPrevious();

  Song _songFromMediaItem(audio_service.MediaItem item) => Song(
        id: item.id,
        title: item.title,
        artist: item.artist ?? 'Unknown artist',
        album: item.album ?? 'Unknown album',
        durationSeconds: item.duration?.inSeconds ?? 0,
        filePath: item.extras?['filePath'] as String? ?? '',
        albumArt: item.artUri?.toString() ?? '',
        isFavorite: false,
      );

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _playbackSubscription.cancel();
    _mediaItemSubscription.cancel();
    super.dispose();
  }
}

class AgVosbAudioHandler extends audio_service.BaseAudioHandler with audio_service.QueueHandler {
  AgVosbAudioHandler() {
    _player.playbackEventStream.listen((_) {
      _broadcastState();
      if (_player.processingState == ProcessingState.completed && !_handlingCompletion) {
        _handlingCompletion = true;
        skipToNext();
      }
    });
    _player.positionStream.listen((_) => _broadcastState());
    _player.durationStream.listen((duration) {
      final item = mediaItem.value;
      if (item != null && duration != null) {
        mediaItem.add(item.copyWith(duration: duration));
      }
      _broadcastState();
    });
  }

  final AudioPlayer _player = AudioPlayer();
  List<Song> _songs = const [];
  int _currentIndex = 0;
  bool _handlingCompletion = false;

  Future<void> playSong(Song song, List<Song> songs) async {
    _songs = List.unmodifiable(songs);
    _currentIndex = _songs.indexWhere((item) => item.id == song.id);
    if (_currentIndex < 0) _currentIndex = 0;
    final item = _mediaItem(song);
    _handlingCompletion = false;
    queue.add(_songs.map(_mediaItem).toList());
    mediaItem.add(item);
    await _player.setAudioSource(AudioSource.uri(Uri.file(song.filePath), tag: item));
    await play();
  }

  @override
  Future<void> play() async {
    await _player.play();
  }

  @override
  Future<void> pause() async {
    await _player.pause();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() async {
    if (_songs.isEmpty) return;
    _currentIndex = (_currentIndex + 1) % _songs.length;
    await _loadIndexAndPlay();
  }

  @override
  Future<void> skipToPrevious() async {
    if (_songs.isEmpty) return;
    _currentIndex = (_currentIndex - 1 + _songs.length) % _songs.length;
    await _loadIndexAndPlay();
  }

  Future<void> _loadIndexAndPlay() async {
    final song = _songs[_currentIndex];
    final item = _mediaItem(song);
    _handlingCompletion = false;
    mediaItem.add(item);
    await _player.setAudioSource(AudioSource.uri(Uri.file(song.filePath), tag: item));
    await play();
  }

  audio_service.MediaItem _mediaItem(Song song) => audio_service.MediaItem(
        id: song.id,
        title: song.title,
        artist: song.artist,
        album: song.album,
        duration: Duration(seconds: song.durationSeconds),
        artUri: song.albumArt.isNotEmpty ? Uri.tryParse(song.albumArt) : null,
        extras: {'filePath': song.filePath},
      );

  void _broadcastState() {
    final event = _player.playbackEvent;
    playbackState.add(playbackState.value.copyWith(
      controls: [
        audio_service.MediaControl.skipToPrevious,
        _player.playing ? audio_service.MediaControl.pause : audio_service.MediaControl.play,
        audio_service.MediaControl.skipToNext,
      ],
      systemActions: const {
        audio_service.MediaAction.seek,
        audio_service.MediaAction.seekForward,
        audio_service.MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: {
        ProcessingState.idle: audio_service.AudioProcessingState.idle,
        ProcessingState.loading: audio_service.AudioProcessingState.loading,
        ProcessingState.buffering: audio_service.AudioProcessingState.buffering,
        ProcessingState.ready: audio_service.AudioProcessingState.ready,
        ProcessingState.completed: audio_service.AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: event.bufferedPosition,
      speed: _player.speed,
    ));
  }

  @override
  Future<void> onTaskRemoved() async {
    await stop();
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    await super.stop();
  }
}
