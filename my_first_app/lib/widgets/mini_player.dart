import 'package:flutter/material.dart';

import '../models/song.dart';

class MiniPlayer extends StatefulWidget {
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
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> with SingleTickerProviderStateMixin {
  late final AnimationController _rotationController;
  String? _songId;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..addStatusListener(_handleRotationStatus);
    _syncPlayback();
  }

  void _handleRotationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && widget.isPlaying) {
      _rotationController.value = 0;
      _rotationController.forward();
    }
  }

  void _syncPlayback() {
    if (widget.song.id != _songId) {
      _songId = widget.song.id;
      _rotationController.value = 0;
    }
    if (widget.isPlaying) {
      if (!_rotationController.isAnimating) _rotationController.forward();
    } else if (_rotationController.isAnimating) {
      _rotationController.stop(canceled: false);
    }
  }

  @override
  void didUpdateWidget(covariant MiniPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncPlayback();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final artwork = AnimatedBuilder(
      animation: _rotationController,
      builder: (context, child) => Transform.rotate(
        angle: _rotationController.value * 6.283185307179586,
        child: child,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(
          'assets/image/agvosb_logo.png',
          width: 42,
          height: 42,
          fit: BoxFit.cover,
        ),
      ),
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
          artwork,
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.song.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                Text(widget.song.artist, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
              IconButton(onPressed: widget.onPrevious, icon: const Icon(Icons.skip_previous_rounded)),
              IconButton(onPressed: widget.onPlayPause, icon: Icon(widget.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded)),
              IconButton(onPressed: widget.onNext, icon: const Icon(Icons.skip_next_rounded)),
            ],
          ),
          LinearProgressIndicator(
            value: widget.duration.inMilliseconds > 0 ? (widget.position.inMilliseconds / widget.duration.inMilliseconds).clamp(0.0, 1.0) : 0,
            minHeight: 3,
          ),
        ],
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
