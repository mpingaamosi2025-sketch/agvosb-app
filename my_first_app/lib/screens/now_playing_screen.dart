import 'package:flutter/material.dart';

import '../models/song.dart';
import '../services/audio_service.dart';
import '../widgets/now_playing_card.dart';

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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.audio,
      builder: (context, _) {
        final theme = Theme.of(context);

        return Scaffold(
          appBar: AppBar(title: const Text('Now Playing')),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                children: [
                  Expanded(
                    child: NowPlayingCard(audio: widget.audio, showPlayButton: false, expanded: true),
                  ),
                  const SizedBox(height: 22),
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
                  const SizedBox(height: 8),
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
