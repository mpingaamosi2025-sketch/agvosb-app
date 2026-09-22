import 'package:flutter/material.dart';

import '../models/song.dart';

class SongCard extends StatelessWidget {
  const SongCard({
    super.key,
    required this.song,
    this.onTap,
    this.onFavorite,
    this.isCompact = false,
  });

  final Song song;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onFavorite;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final artwork = song.albumArt.isNotEmpty
        ? Image.network(
            song.albumArt,
            width: isCompact ? 56 : 70,
            height: isCompact ? 56 : 70,
            fit: BoxFit.cover,
            errorBuilder: (context, _, _) => Container(
              width: isCompact ? 56 : 70,
              height: isCompact ? 56 : 70,
              color: theme.colorScheme.primaryContainer,
              child: const Icon(Icons.music_note),
            ),
          )
        : Container(
            width: isCompact ? 56 : 70,
            height: isCompact ? 56 : 70,
            color: theme.colorScheme.primaryContainer,
            child: const Icon(Icons.music_note),
          );

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      leading: ClipRRect(borderRadius: BorderRadius.circular(12), child: artwork),
      title: Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(song.artist, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: song.isFavorite ? 'Remove favorite' : 'Add favorite',
            onPressed: () => onFavorite?.call(!song.isFavorite),
            icon: Icon(song.isFavorite ? Icons.favorite : Icons.favorite_border),
            color: song.isFavorite ? Colors.red : null,
          ),
          IconButton(
            onPressed: onTap,
            icon: const Icon(Icons.play_arrow_rounded),
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}
