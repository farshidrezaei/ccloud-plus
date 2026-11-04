import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../../models/media_item.dart';
import '../../screens/single_movie_screen.dart';
import '../../screens/single_series_screen.dart';
import '../../utils/storage_utils.dart';

class MediaPreviewModal extends StatefulWidget {
  final MediaItem item;

  const MediaPreviewModal({super.key, required this.item});

  static Future<void> show(BuildContext context, MediaItem item) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (context) => MediaPreviewModal(item: item),
    );
  }

  @override
  State<MediaPreviewModal> createState() => _MediaPreviewModalState();
}

class _MediaPreviewModalState extends State<MediaPreviewModal> {
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

  void _openDetails() {
    Navigator.of(context).pop();
    final isMovie = widget.item.type.toLowerCase() == 'movie';
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => isMovie
            ? SingleMovieScreen(movie: widget.item)
            : SingleSeriesScreen(series: widget.item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final isMovie = item.type.toLowerCase() == 'movie';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF13151F),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.glassBorder, width: 1),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black87,
                  blurRadius: 32,
                  spreadRadius: 8,
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Backdrop Banner with Gradient Scrim
                  Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: item.cover.isNotEmpty
                            ? Image.network(
                                item.cover,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: Colors.black38,
                                  child: const Icon(
                                    Icons.movie_outlined,
                                    size: 48,
                                    color: Colors.white24,
                                  ),
                                ),
                              )
                            : Container(
                                color: Colors.black38,
                                child: const Icon(
                                  Icons.movie_outlined,
                                  size: 48,
                                  color: Colors.white24,
                                ),
                              ),
                      ),
                      // Gradient Vignette
                      Positioned.fill(
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Color(0x66000000),
                                Color(0xFF13151F),
                              ],
                              stops: [0.3, 0.7, 1.0],
                            ),
                          ),
                        ),
                      ),
                      // Close button
                      Positioned(
                        top: 14,
                        right: 14,
                        child: InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black54,
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      // Floating Play Button
                      Positioned(
                        bottom: 16,
                        right: 20,
                        child: ElevatedButton.icon(
                          onPressed: _openDetails,
                          icon: const Icon(Icons.play_arrow_rounded, size: 22),
                          label: Text(
                            isMovie ? 'تماشای فیلم' : 'تماشای قسمت‌ها',
                            style: GoogleFonts.vazirmatn(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.brandRed,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 22,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            shadowColor: AppColors.brandRedGlow,
                            elevation: 8,
                          ),
                        ),
                      ),
                      // Favorite Toggle Button
                      Positioned(
                        bottom: 16,
                        left: 20,
                        child: IconButton(
                          onPressed: _toggleFavorite,
                          icon: Icon(
                            _isFavorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: _isFavorite
                                ? AppColors.brandRed
                                : Colors.white,
                            size: 24,
                          ),
                          tooltip: _isFavorite
                              ? 'حذف از علاقه‌مندی‌ها'
                              : 'افزودن به علاقه‌مندی‌ها',
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Information Body
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          item.title,
                          style: GoogleFonts.vazirmatn(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Badges Row (IMDb, Year, Duration, Type)
                        Row(
                          children: [
                            if (item.imdb > 0) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.imdbGold,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      size: 13,
                                      color: Colors.black,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      item.imdb.toStringAsFixed(1),
                                      style: GoogleFonts.spaceMono(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            if (item.year > 0) ...[
                              Text(
                                '${item.year}',
                                style: GoogleFonts.spaceMono(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            if (item.duration != null &&
                                item.duration!.isNotEmpty) ...[
                              Text(
                                '•  ${item.duration}',
                                style: GoogleFonts.vazirmatn(
                                  color: AppColors.textMuted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Genre Pills
                        if (item.genres.isNotEmpty) ...[
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: item.genres.map((g) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surfacePill,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppColors.glassBorder,
                                    width: 0.6,
                                  ),
                                ),
                                child: Text(
                                  g.title,
                                  style: GoogleFonts.vazirmatn(
                                    fontSize: 11,
                                    color: Colors.white70,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 14),
                        ],

                        // Synopsis / Plot
                        if (item.description.isNotEmpty) ...[
                          Text(
                            item.description,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.vazirmatn(
                              fontSize: 13,
                              height: 1.7,
                              color: Colors.white.withValues(alpha: 0.75),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // View All Sources / Quality button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _openDetails,
                            icon: const Icon(
                              Icons.format_list_bulleted_rounded,
                              size: 18,
                            ),
                            label: Text(
                              'مشاهده کیفیت‌ها، عوامل و اطلاعات کامل',
                              style: GoogleFonts.vazirmatn(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white70,
                              side: BorderSide(
                                color: Colors.white.withValues(alpha: 0.15),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
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
