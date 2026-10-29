import 'package:flutter/material.dart';

import '../../../core/themes/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/video_item.dart';
import 'video_thumbnail.dart';

/// MX Player style list row: thumbnail, title, meta line and overflow button.
class VideoListTile extends StatelessWidget {
  const VideoListTile({
    super.key,
    required this.video,
    required this.onTap,
    required this.onMore,
    this.progress,
    this.isFavorite = false,
    this.selected = false,
  });

  final VideoItem video;
  final VoidCallback onTap;
  final VoidCallback onMore;
  final double? progress;
  final bool isFavorite;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onMore,
        child: Container(
          color: selected ? MxColors.brand.withOpacity(0.08) : null,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          child: Row(
            children: <Widget>[
              VideoThumbnail(
                video: video,
                width: 124,
                height: 70,
                radius: 9,
                progress: progress,
                showPlayBadge: false,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      video.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 14,
                        height: 1.25,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: <Widget>[
                        if (isFavorite) ...<Widget>[
                          const Icon(Icons.favorite_rounded, size: 11, color: MxColors.brand),
                          const SizedBox(width: 4),
                        ],
                        Expanded(
                          child: Text(
                            '${video.folderName} • ${Formatters.fileSize(video.fileSizeBytes)}'
                            '${video.duration != null ? ' • ${Formatters.duration(video.duration)}' : ''}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 11.5,
                              color: isDark ? MxColors.textTertiary : MxColors.lightTextSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if ((progress ?? 0) > 0.02) ...<Widget>[
                      const SizedBox(height: 6),
                      SizedBox(
                        width: 130,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 2.5,
                            backgroundColor: isDark ? MxColors.surfaceHigh : MxColors.lightDivider,
                            valueColor: const AlwaysStoppedAnimation<Color>(MxColors.brand),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                onPressed: onMore,
                visualDensity: VisualDensity.compact,
                splashRadius: 20,
                icon: Icon(
                  Icons.more_vert_rounded,
                  size: 20,
                  color: isDark ? MxColors.textTertiary : MxColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Grid variant of the video card.
class VideoGridCard extends StatelessWidget {
  const VideoGridCard({
    super.key,
    required this.video,
    required this.onTap,
    required this.onMore,
    this.progress,
    this.isFavorite = false,
  });

  final VideoItem video;
  final VoidCallback onTap;
  final VoidCallback onMore;
  final double? progress;
  final bool isFavorite;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      onLongPress: onMore,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AspectRatio(
            aspectRatio: 16 / 9,
            child: VideoThumbnail(
              video: video,
              radius: 12,
              progress: progress,
              showPlayBadge: true,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Text(
                  video.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 12.5,
                    height: 1.25,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (isFavorite)
                const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Icon(Icons.favorite_rounded, size: 13, color: MxColors.brand),
                ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            '${video.folderName} • ${Formatters.fileSize(video.fileSizeBytes)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(fontSize: 10.5),
          ),
        ],
      ),
    );
  }
}
