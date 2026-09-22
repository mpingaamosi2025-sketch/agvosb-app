import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../models/video.dart';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({
    super.key,
    required this.videos,
    required this.initialIndex,
  });

  final List<Video> videos;
  final int initialIndex;

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  late int _currentIndex;
  bool _isPlaying = false;
  bool _isInitialized = false;
  bool _showControls = true;
  Timer? _hideControlsTimer;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, widget.videos.length - 1);
    _initController();
  }

  Future<void> _initController() async {
    final video = widget.videos[_currentIndex];
    debugPrint('Video controller initialized: ${video.filePath}');
    _controller = VideoPlayerController.file(
      File(video.filePath),
    );

    try {
      await _controller.initialize();
      if (!mounted) return;
      setState(() {
        _isInitialized = true;
      });
      _controller.play();
      setState(() => _isPlaying = true);
      _controller.addListener(() {
        if (!mounted) return;
        final value = _controller.value;
        setState(() {
          _isPlaying = value.isPlaying;
        });
      });
      _scheduleHideControls();
    } catch (error) {
      debugPrint('Video playback error: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to play video: ${video.title}')),
        );
      }
    }
  }

  void _scheduleHideControls() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showControls = false);
    });
  }

  Future<void> _togglePlayPause() async {
    if (!_isInitialized) return;
    if (_controller.value.isPlaying) {
      await _controller.pause();
    } else {
      await _controller.play();
    }
    _scheduleHideControls();
  }

  Future<void> _seek(Duration duration) async {
    if (!_isInitialized) return;
    final target = _controller.value.position + duration;
    final clamped = target < Duration.zero ? Duration.zero : target;
    await _controller.seekTo(clamped > _controller.value.duration ? _controller.value.duration : clamped);
    _scheduleHideControls();
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final video = widget.videos[_currentIndex];
    final position = _isInitialized ? _controller.value.position : Duration.zero;
    final duration = _isInitialized ? _controller.value.duration : Duration.zero;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            if (_isInitialized)
              Center(child: AspectRatio(aspectRatio: _controller.value.aspectRatio, child: VideoPlayer(_controller)))
            else
              const Center(child: CircularProgressIndicator()),
            if (_showControls)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black.withValues(alpha: 0.25), Colors.black.withValues(alpha: 0.8)],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back, color: Colors.white)),
                            Expanded(child: Text(video.title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
                            IconButton(onPressed: () {}, icon: const Icon(Icons.fullscreen, color: Colors.white)),
                          ],
                        ),
                        Column(
                          children: [
                            Slider(
                              value: duration.inMilliseconds > 0 ? position.inMilliseconds / duration.inMilliseconds : 0,
                              onChanged: (value) async {
                                if (!_isInitialized) return;
                                final target = Duration(milliseconds: (value * duration.inMilliseconds).round());
                                await _controller.seekTo(target);
                                _scheduleHideControls();
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(_formatDuration(position), style: const TextStyle(color: Colors.white)),
                                  Text(_formatDuration(duration), style: const TextStyle(color: Colors.white)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(onPressed: () => _seek(const Duration(seconds: -10)), icon: const Icon(Icons.replay_10, color: Colors.white, size: 32)),
                                const SizedBox(width: 18),
                                IconButton(onPressed: () => _togglePlayPause(), icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 40)),
                                const SizedBox(width: 18),
                                IconButton(onPressed: () => _seek(const Duration(seconds: 10)), icon: const Icon(Icons.forward_10, color: Colors.white, size: 32)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    if (hours > 0) return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
