import 'package:flutter/material.dart';

import '../models/song.dart';
import '../services/audio_service.dart';

class NowPlayingScreen extends StatefulWidget {
  const NowPlayingScreen({
    super.key,
    required this.song,
    required this.audio,
  });

  final Song song;
  final AudioService audio;

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen> {
  bool isFavorite = false;
  bool shuffle = false;
  bool repeat = false;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.song.isFavorite;
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remaining = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remaining.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.audio,
      builder: (context, _) {
        final theme = Theme.of(context);
        final currentSong = widget.audio.currentSong ?? widget.song;
        final totalSeconds = currentSong.durationSeconds > 0 ? currentSong.durationSeconds : widget.audio.duration.inSeconds;
        final currentSeconds = widget.audio.position.inSeconds;
        final progress = totalSeconds > 0 ? (currentSeconds / totalSeconds).clamp(0.0, 1.0) : 0.0;

        return Scaffold(
      appBar: AppBar(title: const Text('Now Playing')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            children: [
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: currentSong.albumArt.isNotEmpty
                    ? Image.network(
                    currentSong.albumArt,
                        height: 300,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, _, _) => Container(
                          height: 300,
                          color: theme.colorScheme.primaryContainer,
                          child: const Icon(Icons.music_note, size: 72),
                        ),
                      )
                    : Container(
                        height: 300,
                        color: theme.colorScheme.primaryContainer,
                        child: const Icon(Icons.music_note, size: 72),
                      ),
              ),
              const SizedBox(height: 28),
              Text(currentSong.title, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800), textAlign: TextAlign.center),
              const SizedBox(height: 6),
              Text(currentSong.artist, style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant), textAlign: TextAlign.center),
              const SizedBox(height: 18),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                  trackHeight: 5,
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
                ),
                child: Slider(
                  value: progress,
                  onChanged: (value) async {
                    final seekTo = Duration(seconds: (totalSeconds * value).round());
                    await widget.audio.seek(seekTo);
                  },
                  min: 0,
                  max: totalSeconds > 0 ? 1 : 0,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_formatDuration(currentSeconds)),
                    Text(_formatDuration(totalSeconds)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: () => setState(() => shuffle = !shuffle),
                    icon: Icon(Icons.shuffle, color: shuffle ? theme.colorScheme.primary : null),
                    tooltip: 'Shuffle',
                  ),
                  const SizedBox(width: 12),
                  IconButton(onPressed: widget.audio.previous, icon: const Icon(Icons.skip_previous_rounded, size: 34)),
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: theme.colorScheme.primary,
                    child: IconButton(
                      onPressed: widget.audio.togglePlayPause,
                      icon: Icon(widget.audio.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 36, color: Colors.white),
                    ),
                  ),
                  IconButton(onPressed: widget.audio.next, icon: const Icon(Icons.skip_next_rounded, size: 34)),
                  IconButton(
                    onPressed: () => setState(() => repeat = !repeat),
                    icon: Icon(Icons.repeat, color: repeat ? theme.colorScheme.primary : null),
                    tooltip: 'Repeat',
                  ),
                ],
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () => setState(() => isFavorite = !isFavorite),
                    icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
                    label: const Text('Favorite'),
                  ),
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.queue_music_rounded),
                    label: const Text('Queue'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
        );
      },
    );
  }
}
