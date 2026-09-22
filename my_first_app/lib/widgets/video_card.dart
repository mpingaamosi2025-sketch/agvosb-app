import 'package:flutter/material.dart';

import '../models/video.dart';

class VideoCard extends StatelessWidget {
  const VideoCard({
    super.key,
    required this.video,
    this.onTap,
    this.onFavorite,
    this.isFavorite = false,
  });

  final Video video;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final bool isFavorite;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: video.thumbnail.isNotEmpty
                        ? Image.network(
                            video.thumbnail,
                            fit: BoxFit.cover,
                            errorBuilder: (context, _, _) => Container(color: theme.colorScheme.primaryContainer, child: const Icon(Icons.play_circle_fill, size: 44)),
                          )
                        : Container(color: theme.colorScheme.primaryContainer, child: const Icon(Icons.videocam, size: 44)),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        video.durationLabel,
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  video.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              if (onFavorite != null)
                IconButton(
                  onPressed: onFavorite,
                  icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
                  color: isFavorite ? Colors.red : null,
                  splashRadius: 18,
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(video.fileSizeLabel, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
