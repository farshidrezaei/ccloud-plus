import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimensions.dart';
import '../core/widgets/media_preview_modal.dart';
import '../models/media_item.dart';
import '../utils/storage_utils.dart';

class MediaCard extends StatefulWidget {
  final MediaItem mediaItem;
  final VoidCallback onTap;
  final bool showFavoriteButton;

  const MediaCard({
    super.key,
    required this.mediaItem,
    required this.onTap,
    this.showFavoriteButton = true,
  });

  @override
  State<MediaCard> createState() => _MediaCardState();
}

class _MediaCardState extends State<MediaCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppDimensions.hoverDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: AppDimensions.hoverScale,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final isFav = await StorageUtils.isFavorite(
      widget.mediaItem.id,
      widget.mediaItem.type,
    );
    if (mounted) {
      setState(() {
        _isFavorite = isFav;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    if (_isFavorite) {
      await StorageUtils.removeFromFavorites(
        widget.mediaItem.id,
        widget.mediaItem.type,
      );
    } else {
      await StorageUtils.addToFavorites(widget.mediaItem);
    }
    if (mounted) {
      setState(() {
        _isFavorite = !_isFavorite;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isFavorite
                ? 'به علاقه‌مندی‌ها اضافه شد'
                : 'از علاقه‌مندی‌ها حذف شد',
            style: GoogleFonts.vazirmatn(),
          ),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final item = widget.mediaItem;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          _isHovered = true;
          _controller.forward();
        });
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
          _controller.reverse();
        });
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onTap: widget.onTap,
          onSecondaryTap: () =>
              MediaPreviewModal.show(context, widget.mediaItem),
          child: AnimatedContainer(
            duration: AppDimensions.hoverDuration,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
              border: Border.all(
                color: _isHovered
                    ? AppColors.brandRed.withValues(alpha: 0.8)
                    : isDarkMode
                    ? AppColors.darkBorder
                    : AppColors.lightBorder,
                width: _isHovered ? 2.0 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: _isHovered
                      ? AppColors.brandRedGlow
                      : isDarkMode
                      ? Colors.black.withValues(alpha: 0.5)
                      : Colors.black.withValues(alpha: 0.15),
                  blurRadius: _isHovered ? 20 : 12,
                  offset: Offset(0, _isHovered ? 8 : 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                AppDimensions.cardInnerRadius,
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Poster Image
                  Image.network(
                    item.image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: isDarkMode
                            ? AppColors.darkCardBackground
                            : Colors.grey.shade300,
                        child: const Center(
                          child: Icon(
                            Icons.movie_outlined,
                            size: 48,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: isDarkMode
                            ? AppColors.darkCardPlaceholder
                            : Colors.grey.shade200,
                        child: const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      );
                    },
                  ),

                  // Cinema Vignette Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.0, 0.45, 0.8, 1.0],
                        colors: [
                          Colors.black.withValues(alpha: 0.4),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                          Colors.black.withValues(alpha: 0.95),
                        ],
                      ),
                    ),
                  ),

                  // Top Floating Badges
                  Positioned(
                    top: 10,
                    right: 10,
                    left: 10,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // IMDb Badge
                        if (item.imdb > 0)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.badgeRadius,
                                  ),
                                  border: Border.all(
                                    color: AppColors.starGold.withValues(
                                      alpha: 0.5,
                                    ),
                                    width: 0.8,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      color: AppColors.starGold,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      item.imdb.toStringAsFixed(1),
                                      style: GoogleFonts.spaceMono(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        else
                          const SizedBox.shrink(),

                        // Type Badge or Favorite
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (item.type.isNotEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 8,
                                    sigmaY: 8,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(
                                        alpha: 0.6,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      item.type == 'movie' ? 'فیلم' : 'سریال',
                                      style: GoogleFonts.vazirmatn(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            if (widget.showFavoriteButton) ...[
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: _toggleFavorite,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                      sigmaX: 8,
                                      sigmaY: 8,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(
                                          alpha: 0.6,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        _isFavorite
                                            ? Icons.favorite_rounded
                                            : Icons.favorite_border_rounded,
                                        color: _isFavorite
                                            ? const Color(0xFFE11D48)
                                            : Colors.white70,
                                        size: 15,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(width: 6),
                            // Quick Preview Peek
                            GestureDetector(
                              onTap: () => MediaPreviewModal.show(
                                context,
                                widget.mediaItem,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 8,
                                    sigmaY: 8,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(
                                        alpha: 0.6,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.remove_red_eye_outlined,
                                      color: Colors.white70,
                                      size: 15,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Bottom Content (Title, Year, Genres)
                  Positioned(
                    bottom: 12,
                    right: 12,
                    left: 12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.vazirmatn(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: const [
                              Shadow(color: Colors.black, blurRadius: 4),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (item.year > 0)
                              Text(
                                '${item.year}',
                                style: GoogleFonts.spaceMono(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                            if (item.year > 0 && item.genres.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                ),
                                child: Text(
                                  '•',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.4),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            if (item.genres.isNotEmpty)
                              Expanded(
                                child: Text(
                                  item.genres.first.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.vazirmatn(
                                    fontSize: 12,
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
