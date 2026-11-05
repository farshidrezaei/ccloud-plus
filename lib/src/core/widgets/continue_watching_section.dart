import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../../models/watch_history_item.dart';
import '../../providers/watch_history_provider.dart';
import '../../screens/video_player_screen.dart';

class ContinueWatchingSection extends StatelessWidget {
  const ContinueWatchingSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Consumer<WatchHistoryProvider>(
      builder: (context, historyProvider, _) {
        if (historyProvider.isLoading || !historyProvider.hasItems) {
          return const SizedBox.shrink();
        }

        final items = historyProvider.items;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Section Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.history_rounded,
                    color: AppColors.brandRed,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'ادامه تماشا',
                    style: GoogleFonts.vazirmatn(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? AppColors.surfacePill
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDarkMode
                            ? AppColors.glassBorder
                            : Colors.black12,
                      ),
                    ),
                    child: Text(
                      '${items.length}',
                      style: GoogleFonts.spaceMono(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.brandRed,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Horizontal Carousel
            SizedBox(
              height: 150,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _ContinueWatchingCard(item: item);
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }
}

class _ContinueWatchingCard extends StatefulWidget {
  final WatchHistoryItem item;

  const _ContinueWatchingCard({required this.item});

  @override
  State<_ContinueWatchingCard> createState() => _ContinueWatchingCardState();
}

class _ContinueWatchingCardState extends State<_ContinueWatchingCard> {
  bool _isHovered = false;

  void _resumePlayback() {
    if (widget.item.videoUrl.trim().isEmpty) return;
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(
          videoUrl: widget.item.videoUrl,
          title: widget.item.episodeTitle ?? widget.item.mediaItem.title,
          mediaItem: widget.item.mediaItem,
          startPositionMs: widget.item.positionMs,
          episodeTitle: widget.item.episodeTitle,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final media = item.mediaItem;
    final coverUrl = media.cover.isNotEmpty ? media.cover : media.image;
    final historyProvider = Provider.of<WatchHistoryProvider>(
      context,
      listen: false,
    );

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: _resumePlayback,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 250,
          decoration: BoxDecoration(
            color: const Color(0xFF13151F),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _isHovered ? AppColors.brandRed : AppColors.glassBorder,
              width: _isHovered ? 1.5 : 0.8,
            ),
            boxShadow: [
              if (_isHovered)
                const BoxShadow(
                  color: AppColors.brandRedGlow,
                  blurRadius: 16,
                  offset: Offset(0, 4),
                )
              else
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Backdrop Image
                Image.network(
                  coverUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFF1E202C),
                    child: const Center(
                      child: Icon(Icons.movie_outlined, color: Colors.grey),
                    ),
                  ),
                ),

                // Cinematic Dark Vignette
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.45, 1.0],
                      colors: [
                        Colors.black.withValues(alpha: 0.3),
                        Colors.black.withValues(alpha: 0.5),
                        Colors.black.withValues(alpha: 0.95),
                      ],
                    ),
                  ),
                ),

                // Center/Left Play Button
                Positioned(
                  bottom: 22,
                  right: 12,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: _isHovered
                          ? AppColors.brandRed
                          : Colors.black.withValues(alpha: 0.65),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _isHovered
                            ? AppColors.brandRed
                            : Colors.white.withValues(alpha: 0.4),
                      ),
                      boxShadow: [
                        if (_isHovered)
                          const BoxShadow(
                            color: AppColors.brandRedGlow,
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                      ],
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),

                // Title & Remaining Time Info
                Positioned(
                  bottom: 18,
                  left: 12,
                  right: 58,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.episodeTitle ?? media.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.vazirmatn(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: const [
                            Shadow(color: Colors.black, blurRadius: 6),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.remainingFormatted,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.vazirmatn(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFA0A3B1),
                        ),
                      ),
                    ],
                  ),
                ),

                // Remove from History (Hover Action)
                if (_isHovered)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => historyProvider.removeItem(item.id),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ),
                  ),

                // Bottom Red Progress Bar
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 3.5,
                  child: Container(
                    color: Colors.white.withValues(alpha: 0.15),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: item.progress,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: AppColors.brandRed,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.brandRedGlow,
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
