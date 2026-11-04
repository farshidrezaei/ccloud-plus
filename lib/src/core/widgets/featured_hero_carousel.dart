import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../../models/media_item.dart';
import '../../screens/single_movie_screen.dart';
import '../../screens/video_player_screen.dart';
import '../../utils/storage_utils.dart';

class FeaturedHeroCarousel extends StatefulWidget {
  final List<MediaItem> items;

  const FeaturedHeroCarousel({super.key, required this.items});

  @override
  State<FeaturedHeroCarousel> createState() => _FeaturedHeroCarouselState();
}

class _FeaturedHeroCarouselState extends State<FeaturedHeroCarousel> {
  late final PageController _pageController;
  int _currentIndex = 0;
  Timer? _autoSlideTimer;

  List<MediaItem> get _featuredItems {
    // Pick top items by rating or top 5
    if (widget.items.isEmpty) return [];
    final sorted = List<MediaItem>.from(widget.items)
      ..sort((a, b) => b.imdb.compareTo(a.imdb));
    return sorted.take(5).toList();
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _autoSlideTimer?.cancel();
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 7), (_) {
      if (!mounted) return;
      final count = _featuredItems.length;
      if (count <= 1) return;
      final next = (_currentIndex + 1) % count;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = _featuredItems;
    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 320,
          decoration: BoxDecoration(
            color: const Color(0xFF13151F),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.glassBorder, width: 0.8),
          ),
          child: Stack(
            children: [
              // Page View
              PageView.builder(
                controller: _pageController,
                itemCount: items.length,
                onPageChanged: (idx) {
                  setState(() => _currentIndex = idx);
                  _startAutoSlide(); // Reset auto timer on swipe
                },
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _HeroSlideItem(item: item);
                },
              ),

              // Bottom-Left Indicator Dots
              Positioned(
                bottom: 24,
                left: 32,
                child: Row(
                  children: List.generate(items.length, (idx) {
                    final isActive = idx == _currentIndex;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.only(right: 6),
                      width: isActive ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.brandRed
                            : Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroSlideItem extends StatefulWidget {
  final MediaItem item;

  const _HeroSlideItem({required this.item});

  @override
  State<_HeroSlideItem> createState() => _HeroSlideItemState();
}

class _HeroSlideItemState extends State<_HeroSlideItem> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavorite();
  }

  Future<void> _checkFavorite() async {
    final fav = await StorageUtils.isFavorite(widget.item.id, widget.item.type);
    if (mounted) setState(() => _isFavorite = fav);
  }

  Future<void> _toggleFavorite() async {
    if (_isFavorite) {
      await StorageUtils.removeFromFavorites(widget.item.id, widget.item.type);
    } else {
      await StorageUtils.addToFavorites(widget.item);
    }
    if (mounted) {
      setState(() => _isFavorite = !_isFavorite);
    }
  }

  void _watchMovie() {
    final item = widget.item;
    if (item.sources.isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => VideoPlayerScreen(
            videoUrl: item.sources.first.url,
            title: '${item.title} (${item.sources.first.quality})',
            mediaItem: item,
          ),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => SingleMovieScreen(movie: item)),
      );
    }
  }

  void _openDetails() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SingleMovieScreen(movie: widget.item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final backdropUrl = item.cover.isNotEmpty ? item.cover : item.image;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Backdrop Image
        Image.network(
          backdropUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(color: Colors.black87),
        ),

        // Cinematic Vignette (Gradient Overlays)
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.black.withValues(alpha: 0.1),
                Colors.black.withValues(alpha: 0.85),
                Colors.black.withValues(alpha: 0.95),
              ],
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.6, 1.0],
              colors: [
                Colors.black.withValues(alpha: 0.3),
                Colors.transparent,
                Colors.black.withValues(alpha: 0.8),
              ],
            ),
          ),
        ),

        // Foreground Content (RTL aligned right)
        Positioned(
          top: 0,
          bottom: 0,
          right: 36,
          left: 120,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Title
              Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.vazirmatn(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  shadows: const [Shadow(color: Colors.black, blurRadius: 10)],
                ),
              ),
              const SizedBox(height: 10),

              // Badges Row (IMDb, Year, Genres, Duration)
              Wrap(
                spacing: 10,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (item.imdb > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.starGold,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: Colors.black,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.imdb.toStringAsFixed(1),
                            style: GoogleFonts.spaceMono(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (item.year > 0)
                    Text(
                      '${item.year}',
                      style: GoogleFonts.spaceMono(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                      ),
                    ),
                  if (item.genres.isNotEmpty)
                    Text(
                      '•  ${item.genres.take(2).map((g) => g.title).join("، ")}',
                      style: GoogleFonts.vazirmatn(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  if (item.duration != null && item.duration!.isNotEmpty)
                    Text(
                      '•  ${item.duration}',
                      style: GoogleFonts.vazirmatn(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),

              // Synopsis
              if (item.description.isNotEmpty)
                Text(
                  item.description.trim(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.vazirmatn(
                    fontSize: 13,
                    height: 1.7,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              const SizedBox(height: 20),

              // Action Buttons
              Row(
                children: [
                  // Play Pill
                  ElevatedButton.icon(
                    onPressed: _watchMovie,
                    icon: const Icon(Icons.play_arrow_rounded, size: 24),
                    label: Text(
                      'تماشای فیلم',
                      style: GoogleFonts.vazirmatn(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandRed,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 6,
                      shadowColor: AppColors.brandRedGlow,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Favorite Circle Button
                  InkWell(
                    onTap: _toggleFavorite,
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _isFavorite
                              ? AppColors.brandRed
                              : Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Icon(
                        _isFavorite
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        color: _isFavorite ? AppColors.brandRed : Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Info Button
                  OutlinedButton.icon(
                    onPressed: _openDetails,
                    icon: const Icon(Icons.info_outline_rounded, size: 20),
                    label: Text(
                      'اطلاعات بیشتر',
                      style: GoogleFonts.vazirmatn(fontSize: 13),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
