import 'package:flutter/material.dart';

import '../models/song.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({
    super.key,
    required this.song,
    required this.isPlaying,
    required this.position,
    required this.duration,
    required this.onPrevious,
    required this.onNext,
    required this.onPlayPause,
  });

  final Song song;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onPlayPause;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final artwork = song.albumArt.isNotEmpty
        ? Image.network(
            song.albumArt,
            width: 42,
            height: 42,
            fit: BoxFit.cover,
            errorBuilder: (context, _, _) => Container(
              width: 42,
              height: 42,
              color: theme.colorScheme.primaryContainer,
              child: const Icon(Icons.music_note, size: 18),
            ),
          )
        : Container(
            width: 42,
            height: 42,
            color: theme.colorScheme.primaryContainer,
            child: const Icon(Icons.music_note, size: 18),
          );

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
          ClipRRect(borderRadius: BorderRadius.circular(10), child: artwork),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                Text(song.artist, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
              IconButton(onPressed: onPrevious, icon: const Icon(Icons.skip_previous_rounded)),
              IconButton(onPressed: onPlayPause, icon: Icon(isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded)),
              IconButton(onPressed: onNext, icon: const Icon(Icons.skip_next_rounded)),
            ],
          ),
          LinearProgressIndicator(
            value: duration.inMilliseconds > 0 ? (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0) : 0,
            minHeight: 3,
          ),
        ],
      ),
    );
  }
}
