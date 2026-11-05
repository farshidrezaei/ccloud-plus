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
import '../providers/seasons_provider.dart';
import '../utils/storage_utils.dart';
import '../platform/vlc_launcher.dart';
import 'downloads_screen.dart';
import 'video_player_screen.dart';

class SingleSeriesScreen extends StatefulWidget {
  final MediaItem series;

  const SingleSeriesScreen({super.key, required this.series});

  @override
  State<SingleSeriesScreen> createState() => _SingleSeriesScreenState();
}

class _SingleSeriesScreenState extends State<SingleSeriesScreen> {
  late MediaItem _series;
  bool _isFavorite = false;
  bool _isDescriptionExpanded = false;
  Episode? _selectedEpisode;
  Set<String> _watchedEpisodes = {};

  @override
  void initState() {
    super.initState();
    _series = widget.series;
    _saveSeriesToStorage();
    _checkFavoriteStatus();
    _loadWatchedEpisodes();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_series.id > 0) {
        Provider.of<SeasonsProvider>(
          context,
          listen: false,
        ).loadSeasons(_series.id);
      }
    });
  }

  Future<void> _loadWatchedEpisodes() async {
    final watched = await StorageUtils.getWatchedEpisodes(_series.id);
    if (mounted) {
      setState(() => _watchedEpisodes = watched);
    }
  }

  Future<void> _toggleWatched(int epId) async {
    await StorageUtils.toggleEpisodeWatched(_series.id, epId);
    await _loadWatchedEpisodes();
  }

  Future<void> _checkFavoriteStatus() async {
    final isFav = await StorageUtils.isFavorite(_series.id, _series.type);
    if (mounted) {
      setState(() {
        _isFavorite = isFav;
      });
    }
  }

  Future<void> _saveSeriesToStorage() async {
    await StorageUtils.saveSeries(_series);
  }

  Future<void> _toggleFavorite() async {
    if (_isFavorite) {
      await StorageUtils.removeFromFavorites(_series.id, _series.type);
    } else {
      await StorageUtils.addToFavorites(_series);
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

  void _playSource(
    String title,
    Source source, {
    String? nextUrl,
    String? nextTitle,
  }) {
    if (source.url.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'لینک پخش برای این قسمت موجود نیست',
              style: GoogleFonts.vazirmatn(),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }
    final settings = Provider.of<AppSettingsProvider>(context, listen: false);
    if (settings.defaultPlayer == DefaultPlayer.vlc) {
      _playWithVlc(source.url);
    } else {
      _playInApp(source.url, title, nextUrl: nextUrl, nextTitle: nextTitle);
    }
  }

  void _playInApp(
    String url,
    String title, {
    String? nextUrl,
    String? nextTitle,
  }) {
    if (url.trim().isEmpty) return;
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(
          videoUrl: url,
          title: title,
          mediaItem: _series,
          episodeTitle: title,
          nextEpisodeUrl: nextUrl,
          nextEpisodeTitle: nextTitle,
        ),
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
      body: Consumer<SeasonsProvider>(
        builder: (context, seasonsProvider, child) {
          return CustomScrollView(
            slivers: [
              // Hero AppBar
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
                        color: _isFavorite
                            ? const Color(0xFFE11D48)
                            : Colors.white,
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
                      // Backdrop Image
                      Image.network(
                        _series.cover.isNotEmpty
                            ? _series.cover
                            : _series.image,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Container(color: Colors.black87),
                      ),
                      // Vignette Gradient
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
                                  ? const Color(
                                      0xFF0D0E15,
                                    ).withValues(alpha: 0.85)
                                  : Colors.white.withValues(alpha: 0.85),
                              isDarkMode
                                  ? const Color(0xFF0D0E15)
                                  : Colors.white,
                            ],
                          ),
                        ),
                      ),

                      // Floating Poster & Info
                      Positioned(
                        bottom: 24,
                        right: 32,
                        left: 32,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (isDesktop)
                              Container(
                                height: 220,
                                width: 150,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.6,
                                      ),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.network(
                                    _series.image,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            if (isDesktop) const SizedBox(width: 28),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _series.title,
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

                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      ImdbRatingBadge(rating: _series.imdb),
                                      YearBadge(year: _series.year),

                                      if (seasonsProvider.seasons.isNotEmpty)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.brandRed
                                                .withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            '${seasonsProvider.seasons.length} فصل',
                                            style: GoogleFonts.vazirmatn(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.brandRed,
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

              // Content Body
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 48.0 : 20.0,
                    vertical: 24.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Genres
                      if (_series.genres.isNotEmpty) ...[
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _series.genres
                              .map((genre) => GenrePill(title: genre.title))
                              .toList(),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Story
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
                              _series.description.trim(),
                              maxLines: _isDescriptionExpanded ? null : 4,
                              overflow: _isDescriptionExpanded
                                  ? TextOverflow.visible
                                  : TextOverflow.ellipsis,
                              style: GoogleFonts.vazirmatn(
                                fontSize: 15,
                                height: 1.8,
                                color: isDarkMode
                                    ? Colors.white70
                                    : Colors.black87,
                              ),
                            ),
                            if (_series.description.length > 250)
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
                        imdb: _series.imdb,
                        year: _series.year,
                        duration: _series.duration,
                        countryOrLanguage: _series.countries.isNotEmpty
                            ? _series.countries.first.title
                            : null,
                        qualityOrSeasons: seasonsProvider.seasons.isNotEmpty
                            ? '${seasonsProvider.seasons.length} فصل'
                            : null,
                      ),
                      const SizedBox(height: 36),

                      // Seasons and Episodes Section
                      Text(
                        'فصل‌ها و قسمت‌ها',
                        style: GoogleFonts.vazirmatn(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (seasonsProvider.isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (seasonsProvider.errorMessage.isNotEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              children: [
                                Text(
                                  seasonsProvider.errorMessage,
                                  style: GoogleFonts.vazirmatn(
                                    color: Colors.redAccent,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton(
                                  onPressed: () =>
                                      seasonsProvider.loadSeasons(_series.id),
                                  child: Text(
                                    'تلاش مجدد',
                                    style: GoogleFonts.vazirmatn(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else if (seasonsProvider.seasons.isNotEmpty) ...[
                        // Season Pill Selector
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: seasonsProvider.seasons
                                .asMap()
                                .entries
                                .map((entry) {
                                  final index = entry.key;
                                  final season = entry.value;
                                  final isSelected =
                                      index ==
                                      seasonsProvider.selectedSeasonIndex;

                                  return Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: ChoiceChip(
                                      label: Text(
                                        season.title,
                                        style: GoogleFonts.vazirmatn(
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: isSelected
                                              ? Colors.white
                                              : (isDarkMode
                                                    ? Colors.white70
                                                    : Colors.black87),
                                        ),
                                      ),
                                      selected: isSelected,
                                      selectedColor: const Color(0xFFE11D48),
                                      backgroundColor: isDarkMode
                                          ? const Color(0xFF1B1D2A)
                                          : Colors.grey.shade200,
                                      onSelected: (selected) {
                                        if (selected) {
                                          seasonsProvider.selectSeason(index);
                                          setState(() {
                                            _selectedEpisode = null;
                                          });
                                        }
                                      },
                                    ),
                                  );
                                })
                                .toList(),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Episodes List for current season
                        if (seasonsProvider.selectedSeason != null)
                          _buildEpisodesList(
                            seasonsProvider.selectedSeason!,
                            isDarkMode,
                          ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEpisodesList(Season season, bool isDarkMode) {
    if (season.episodes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            'قسمتی برای این فصل ثبت نشده است',
            style: GoogleFonts.vazirmatn(color: Colors.white54),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: season.episodes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final ep = season.episodes[index];
        final isSelected = _selectedEpisode?.id == ep.id;
        final isWatched = _watchedEpisodes.contains(ep.id.toString());
        final hasNext = index + 1 < season.episodes.length;
        final nextEp = hasNext ? season.episodes[index + 1] : null;
        final nextSrc = (nextEp != null && nextEp.sources.isNotEmpty)
            ? nextEp.sources.first
            : null;
        final nextEpTitle = nextEp != null
            ? '${_series.title} - ${nextEp.title}'
            : null;
        final nextEpUrl = nextSrc?.url;

        return Container(
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF161824) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFE11D48)
                  : isDarkMode
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.06),
              width: isSelected ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ExpansionTile(
            shape: const Border(),
            initiallyExpanded: isSelected,
            onExpansionChanged: (expanded) {
              if (expanded) {
                setState(() {
                  _selectedEpisode = ep;
                });
              }
            },
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFE11D48).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: GoogleFonts.spaceMono(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFE11D48),
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    ep.title.isNotEmpty ? ep.title : 'قسمت ${index + 1}',
                    style: GoogleFonts.vazirmatn(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                if (isWatched) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Colors.green.withValues(alpha: 0.4),
                        width: 0.6,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 12,
                          color: Colors.greenAccent,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'تماشا شده',
                          style: GoogleFonts.vazirmatn(
                            fontSize: 10,
                            color: Colors.greenAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(width: 4),
                IconButton(
                  icon: Icon(
                    isWatched
                        ? Icons.check_circle_rounded
                        : Icons.check_circle_outline_rounded,
                    color: isWatched
                        ? Colors.greenAccent
                        : (isDarkMode ? Colors.white38 : Colors.black38),
                    size: 20,
                  ),
                  tooltip: isWatched
                      ? 'علامت به عنوان تماشا نشده'
                      : 'علامت به عنوان تماشا شده',
                  onPressed: () => _toggleWatched(ep.id),
                ),
              ],
            ),
            subtitle: ep.duration != null && ep.duration!.isNotEmpty
                ? Text(
                    ep.duration!,
                    style: GoogleFonts.vazirmatn(
                      fontSize: 12,
                      color: isDarkMode ? Colors.white54 : Colors.black54,
                    ),
                  )
                : null,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (ep.description.isNotEmpty) ...[
                      Text(
                        ep.description,
                        style: GoogleFonts.vazirmatn(
                          fontSize: 13,
                          height: 1.6,
                          color: isDarkMode ? Colors.white70 : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    Text(
                      'کیفیت‌های پخش و دانلود:',
                      style: GoogleFonts.vazirmatn(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white54 : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...ep.sources.map(
                      (src) => _buildEpisodeSourceTile(
                        ep,
                        src,
                        isDarkMode,
                        nextUrl: nextEpUrl,
                        nextTitle: nextEpTitle,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEpisodeSourceTile(
    Episode ep,
    Source src,
    bool isDarkMode, {
    String? nextUrl,
    String? nextTitle,
  }) {
    final title = '${_series.title} - ${ep.title} (${src.quality})';

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E202E) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              src.quality,
              style: GoogleFonts.vazirmatn(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.play_circle_fill_rounded),
            color: const Color(0xFFE11D48),
            iconSize: 28,
            tooltip: 'پخش آنلاین',
            onPressed: () =>
                _playSource(title, src, nextUrl: nextUrl, nextTitle: nextTitle),
          ),
          Consumer<DownloadProvider>(
            builder: (context, downloadProvider, _) {
              final isDownloaded = downloadProvider.isDownloaded(src.url);
              final isDownloading = downloadProvider.isDownloading(src.url);

              if (isDownloaded) {
                return IconButton(
                  icon: const Icon(Icons.download_done_rounded, size: 20),
                  color: Colors.greenAccent,
                  tooltip: 'دانلود شده',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'این قسمت قبلاً دانلود شده است',
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
                icon: const Icon(Icons.download_rounded, size: 20),
                color: AppColors.brandRed,
                tooltip: 'دانلود قسمت',
                onPressed: () {
                  downloadProvider.startDownload(
                    title: _series.title,
                    subTitle: ep.title.isNotEmpty ? ep.title : 'قسمت',
                    url: src.url,
                    quality: src.quality,
                    mediaItem: _series,
                    posterPath: _series.poster,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'دانلود «${_series.title} - ${ep.title}» آغاز شد',
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
          IconButton(
            icon: const Icon(Icons.tv_rounded, size: 22),
            color: isDarkMode ? Colors.white70 : Colors.black54,
            tooltip: 'پخش با VLC',
            onPressed: () => _playWithVlc(src.url),
          ),
          IconButton(
            icon: const Icon(Icons.copy_rounded, size: 18),
            color: isDarkMode ? Colors.white70 : Colors.black54,
            tooltip: 'کپی لینک استریم',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: src.url));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('لینک کپی شد', style: GoogleFonts.vazirmatn()),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.open_in_browser_rounded, size: 18),
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
    );
  }
}
