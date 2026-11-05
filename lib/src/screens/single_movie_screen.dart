import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/constants/app_colors.dart';
import '../core/widgets/media_badge.dart';
import '../core/widgets/media_stat_cards.dart';
import '../models/media_item.dart';
import '../providers/app_settings_provider.dart';
import '../providers/download_provider.dart';
import '../utils/storage_utils.dart';
import '../platform/vlc_launcher.dart';
import 'downloads_screen.dart';
import 'video_player_screen.dart';

class SingleMovieScreen extends StatefulWidget {
  final MediaItem movie;

  const SingleMovieScreen({super.key, required this.movie});

  @override
  State<SingleMovieScreen> createState() => _SingleMovieScreenState();
}

class _SingleMovieScreenState extends State<SingleMovieScreen> {
  late MediaItem _movie;
  bool _isFavorite = false;
  bool _isDescriptionExpanded = false;

  @override
  void initState() {
    super.initState();
    _movie = widget.movie;
    _saveMovieToStorage();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final isFav = await StorageUtils.isFavorite(_movie.id, _movie.type);
    if (mounted) {
      setState(() {
        _isFavorite = isFav;
      });
    }
  }

  Future<void> _saveMovieToStorage() async {
    await StorageUtils.saveMovie(_movie);
  }

  Future<void> _toggleFavorite() async {
    if (_isFavorite) {
      await StorageUtils.removeFromFavorites(_movie.id, _movie.type);
    } else {
      await StorageUtils.addToFavorites(_movie);
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

  void _playSource(Source source) {
    final settings = Provider.of<AppSettingsProvider>(context, listen: false);
    if (settings.defaultPlayer == DefaultPlayer.vlc) {
      _playWithVlc(source.url);
    } else {
      _playInApp(source.url, '${_movie.title} (${source.quality})');
    }
  }

  void _playInApp(String url, String title) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) =>
            VideoPlayerScreen(videoUrl: url, title: title, mediaItem: _movie),
      ),
    );
  }

  Future<void> _playWithVlc(String url) async {
    final success = await VLCLauncher.launchInVLC(url);
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'نمی‌توان لینک را در VLC باز کرد. از پلیر داخلی استفاده کنید.',
            style: GoogleFonts.vazirmatn(),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 850;

    return Scaffold(
      backgroundColor: isDarkMode
          ? const Color(0xFF0D0E15)
          : const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          // App Bar with Backdrop Image
          SliverAppBar(
            expandedHeight: isDesktop ? 440 : 340,
            pinned: true,
            backgroundColor: isDarkMode
                ? const Color(0xFF0D0E15)
                : Colors.white,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: _isFavorite ? AppColors.brandRed : Colors.white,
                  ),
                ),
                onPressed: _toggleFavorite,
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Cover Image
                  Image.network(
                    _movie.cover.isNotEmpty ? _movie.cover : _movie.image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Container(color: Colors.black87),
                  ),
                  // Dark Vignette Gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.0, 0.4, 0.8, 1.0],
                        colors: [
                          Colors.black.withValues(alpha: 0.5),
                          Colors.transparent,
                          isDarkMode
                              ? const Color(0xFF0D0E15).withValues(alpha: 0.85)
                              : Colors.white.withValues(alpha: 0.85),
                          isDarkMode ? const Color(0xFF0D0E15) : Colors.white,
                        ],
                      ),
                    ),
                  ),

                  // Bottom Hero Content
                  Positioned(
                    bottom: 24,
                    right: 32,
                    left: 32,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Floating Poster (Desktop)
                        if (isDesktop)
                          Container(
                            height: 220,
                            width: 150,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                _movie.image,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        if (isDesktop) const SizedBox(width: 28),

                        // Title & Metadata
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _movie.title,
                                style: GoogleFonts.vazirmatn(
                                  fontSize: isDesktop ? 32 : 24,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode
                                      ? Colors.white
                                      : Colors.black87,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.5,
                                      ),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Metadata Badges Row
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  ImdbRatingBadge(rating: _movie.imdb),
                                  YearBadge(year: _movie.year),
                                  DurationBadge(duration: _movie.duration),

                                  // Country
                                  if (_movie.countries.isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isDarkMode
                                            ? Colors.white.withValues(
                                                alpha: 0.12,
                                              )
                                            : Colors.black.withValues(
                                                alpha: 0.08,
                                              ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        _movie.countries.first.title,
                                        style: GoogleFonts.vazirmatn(
                                          fontSize: 12,
                                          color: isDarkMode
                                              ? Colors.white70
                                              : Colors.black54,
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
                ],
              ),
            ),
          ),

          // Main Body Content
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 48.0 : 20.0,
                vertical: 24.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fast Play Primary CTA Bar
                  if (_movie.sources.isNotEmpty) ...[
                    Wrap(
                      spacing: 16,
                      runSpacing: 12,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _playSource(_movie.sources.first),
                          icon: const Icon(Icons.play_arrow_rounded, size: 28),
                          label: Text(
                            'پخش آنلاین (${_movie.sources.first.quality})',
                            style: GoogleFonts.vazirmatn(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.brandRed,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 28,
                              vertical: 18,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 8,
                            shadowColor: AppColors.brandRed.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () =>
                              _playWithVlc(_movie.sources.first.url),
                          icon: const Icon(Icons.play_circle_outline_rounded),
                          label: Text(
                            'پخش با VLC',
                            style: GoogleFonts.vazirmatn(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: isDarkMode
                                ? Colors.white
                                : Colors.black87,
                            side: BorderSide(
                              color: isDarkMode
                                  ? Colors.white24
                                  : Colors.black26,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 18,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],

                  // Genres
                  if (_movie.genres.isNotEmpty) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _movie.genres
                          .map((genre) => GenrePill(title: genre.title))
                          .toList(),
                    ),
                    const SizedBox(height: 28),
                  ],

                  // Story / Description
                  Text(
                    'خلاصه داستان',
                    style: GoogleFonts.vazirmatn(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isDescriptionExpanded = !_isDescriptionExpanded;
                      });
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _movie.description.trim(),
                          maxLines: _isDescriptionExpanded ? null : 4,
                          overflow: _isDescriptionExpanded
                              ? TextOverflow.visible
                              : TextOverflow.ellipsis,
                          style: GoogleFonts.vazirmatn(
                            fontSize: 15,
                            height: 1.8,
                            color: isDarkMode ? Colors.white70 : Colors.black87,
                          ),
                        ),
                        if (_movie.description.length > 250)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              _isDescriptionExpanded
                                  ? 'نمایش کمتر'
                                  : 'ادامه مطلب...',
                              style: GoogleFonts.vazirmatn(
                                fontSize: 13,
                                color: AppColors.brandRed,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Cinevex Metric Stat Cards
                  MediaStatCards(
                    imdb: _movie.imdb,
                    year: _movie.year,
                    duration: _movie.duration,
                    countryOrLanguage: _movie.countries.isNotEmpty
                        ? _movie.countries.first.title
                        : null,
                    qualityOrSeasons: _movie.sources.isNotEmpty
                        ? _movie.sources.first.quality
                        : null,
                  ),
                  const SizedBox(height: 36),

                  // Qualities and Sources List
                  if (_movie.sources.isNotEmpty) ...[
                    Row(
                      children: [
                        const Icon(
                          Icons.download_rounded,
                          color: AppColors.brandRed,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'کیفیت‌های آماده پخش و دانلود',
                          style: GoogleFonts.vazirmatn(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _movie.sources.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final src = _movie.sources[index];
                        return _buildSourceCard(src, isDarkMode);
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceCard(Source src, bool isDarkMode) {
    final isDubbed = src.quality.contains('دوبله');
    final isSubbed = src.quality.contains('زیرنویس');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF161824) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Quality Badge Icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.brandRed.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.video_file_rounded,
              color: AppColors.brandRed,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),

          // Quality Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  src.quality,
                  style: GoogleFonts.vazirmatn(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      src.type.toUpperCase(),
                      style: GoogleFonts.spaceMono(
                        fontSize: 12,
                        color: isDarkMode ? Colors.white54 : Colors.black54,
                      ),
                    ),
                    if (isDubbed || isSubbed) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isDubbed
                              ? Colors.green.withValues(alpha: 0.15)
                              : Colors.blue.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isDubbed ? 'دوبله فارسی' : 'زیرنویس چسبیده',
                          style: GoogleFonts.vazirmatn(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDubbed ? Colors.green : Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Action Buttons
          Wrap(
            spacing: 8,
            children: [
              // In-App Play
              IconButton(
                icon: const Icon(Icons.play_circle_fill_rounded),
                color: AppColors.brandRed,
                iconSize: 32,
                tooltip: 'پخش درون‌برنامه',
                onPressed: () =>
                    _playInApp(src.url, '${_movie.title} (${src.quality})'),
              ),
              // In-App Download
              Consumer<DownloadProvider>(
                builder: (context, downloadProvider, _) {
                  final isDownloaded = downloadProvider.isDownloaded(src.url);
                  final isDownloading = downloadProvider.isDownloading(src.url);

                  if (isDownloaded) {
                    return IconButton(
                      icon: const Icon(Icons.download_done_rounded, size: 22),
                      color: Colors.greenAccent,
                      tooltip: 'دانلود شده (مشاهده در بخش دانلودها)',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'این فایل قبلاً دانلود شده است',
                              style: GoogleFonts.vazirmatn(),
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    );
                  }

                  if (isDownloading) {
                    return const Padding(
                      padding: EdgeInsets.all(10.0),
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.brandRed,
                          ),
                        ),
                      ),
                    );
                  }

                  return IconButton(
                    icon: const Icon(Icons.download_rounded, size: 22),
                    color: AppColors.brandRed,
                    tooltip: 'دانلود درون‌برنامه‌ای',
                    onPressed: () {
                      downloadProvider.startDownload(
                        title: _movie.title,
                        url: src.url,
                        quality: src.quality,
                        mediaItem: _movie,
                        posterPath: _movie.poster,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'دانلود «${_movie.title}» آغاز شد',
                            style: GoogleFonts.vazirmatn(),
                          ),
                          behavior: SnackBarBehavior.floating,
                          action: SnackBarAction(
                            label: 'مشاهده',
                            textColor: AppColors.brandRed,
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const DownloadsScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              // VLC Play
              IconButton(
                icon: const Icon(Icons.tv_rounded),
                color: isDarkMode ? Colors.white70 : Colors.black54,
                tooltip: 'پخش با VLC',
                onPressed: () => _playWithVlc(src.url),
              ),
              // Copy Link
              IconButton(
                icon: const Icon(Icons.copy_rounded, size: 20),
                color: isDarkMode ? Colors.white70 : Colors.black54,
                tooltip: 'کپی لینک استریم',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: src.url));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'لینک مستقیم با موفقیت کپی شد',
                        style: GoogleFonts.vazirmatn(),
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              // Download in Browser
              IconButton(
                icon: const Icon(Icons.open_in_browser_rounded, size: 20),
                color: isDarkMode ? Colors.white70 : Colors.black54,
                tooltip: 'دانلود با مرورگر / IDM',
                onPressed: () async {
                  final uri = Uri.parse(src.url);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
