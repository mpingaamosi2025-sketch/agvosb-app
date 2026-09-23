import 'package:flutter/material.dart';

import '../services/audio_service.dart';

class NowPlayingCard extends StatefulWidget {
  const NowPlayingCard({super.key, required this.audio, this.showPlayButton = true, this.expanded = false});

  final AudioService audio;
  final bool showPlayButton;
  final bool expanded;

  @override
  State<NowPlayingCard> createState() => _NowPlayingCardState();
}

class _NowPlayingCardState extends State<NowPlayingCard> with SingleTickerProviderStateMixin {
  late final AnimationController _rotationController;
  String? _songId;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )
      ..addStatusListener(_handleRotationStatus);
    _syncPlayback();
  }

  void _handleRotationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && widget.audio.isPlaying) {
      _rotationController.value = 0;
      _rotationController.forward();
    }
  }

  void _syncPlayback() {
    final song = widget.audio.currentSong;
    if (song?.id != _songId) {
      _songId = song?.id;
      _rotationController.value = 0;
    }

    if (widget.audio.isPlaying) {
      if (!_rotationController.isAnimating) {
        _rotationController.forward();
      }
    } else if (_rotationController.isAnimating) {
      _rotationController.stop(canceled: false);
    }
  }

  @override
  void didUpdateWidget(covariant NowPlayingCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncPlayback();
  }

  String _formatDuration(Duration value) {
    final minutes = value.inMinutes.toString().padLeft(2, '0');
    final seconds = (value.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final song = widget.audio.currentSong;
    if (song == null) return const SizedBox.shrink();

    final duration = widget.audio.duration;
    final position = widget.audio.position;
    final progress = duration.inMilliseconds > 0
        ? (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    final logoSize = widget.expanded ? 230.0 : 86.0;
    final logoRadius = widget.expanded ? 115.0 : 18.0;

    return Card(
      elevation: 3,
      shadowColor: theme.colorScheme.primary.withValues(alpha: 0.18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: widget.expanded ? const EdgeInsets.fromLTRB(24, 24, 24, 18) : const EdgeInsets.fromLTRB(14, 14, 14, 12),
        child: widget.expanded
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Center(
                      child: AnimatedBuilder(
                        animation: _rotationController,
                        builder: (context, child) => Transform.rotate(
                          angle: _rotationController.value * 6.283185307179586,
                          child: child,
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/image/agvosb_logo.png',
                            width: logoSize,
                            height: logoSize,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Text(
                    song.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    song.artist.isEmpty ? 'Unknown artist' : song.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 20),
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 5,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  const SizedBox(height: 7),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_formatDuration(position), style: theme.textTheme.labelMedium),
                      Text(_formatDuration(duration), style: theme.textTheme.labelMedium),
                    ],
                  ),
                ],
              )
            : Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: logoSize,
                  height: logoSize,
                  child: AnimatedBuilder(
                    animation: _rotationController,
                    builder: (context, child) => Transform.rotate(
                      angle: _rotationController.value * 6.283185307179586,
                      child: child,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(logoRadius),
                      child: Image.asset(
                        'assets/image/agvosb_logo.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NOW PLAYING',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        song.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        song.artist.isEmpty ? 'Unknown artist' : song.artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                if (widget.showPlayButton)
                  IconButton(
                    tooltip: widget.audio.isPlaying ? 'Pause' : 'Play',
                    onPressed: widget.audio.togglePlayPause,
                    icon: Icon(widget.audio.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatDuration(position), style: theme.textTheme.labelSmall),
                Text(_formatDuration(duration), style: theme.textTheme.labelSmall),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _rotationController
      ..removeStatusListener(_handleRotationStatus)
      ..dispose();
    super.dispose();
  }
}
