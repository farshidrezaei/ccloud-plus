import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_dimensions.dart';
import '../core/widgets/advanced_filter_sheet.dart';
import '../core/widgets/continue_watching_section.dart';
import '../core/widgets/empty_state_view.dart';
import '../core/widgets/error_retry_view.dart';
import '../core/widgets/featured_hero_carousel.dart';
import '../core/widgets/media_filter_bar.dart';
import '../core/widgets/responsive_media_grid.dart';
import '../providers/genre_provider.dart';
import '../providers/series_provider.dart';
import '../utils/storage_utils.dart';
import '../widgets/media_card.dart';
import 'single_series_screen.dart';

class SeriesScreen extends StatefulWidget {
  const SeriesScreen({super.key});

  @override
  State<SeriesScreen> createState() => _SeriesScreenState();
}

class _SeriesScreenState extends State<SeriesScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final seriesProvider = Provider.of<SeriesProvider>(
        context,
        listen: false,
      );
      final genreProvider = Provider.of<GenreProvider>(context, listen: false);

      if (seriesProvider.series.isEmpty) {
        seriesProvider.loadSeries();
      }

      if (genreProvider.genres.isEmpty) {
        genreProvider.loadGenres();
      }

      genreProvider.addListener(() {
        if (genreProvider.selectedGenre != null) {
          seriesProvider.selectGenre(genreProvider.selectedGenre!.id);
        } else {
          seriesProvider.selectGenre(0);
        }
      });
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final seriesProvider = Provider.of<SeriesProvider>(
        context,
        listen: false,
      );
      if (!seriesProvider.isLoading && seriesProvider.hasMore) {
        seriesProvider.loadSeries();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: AppDimensions.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: AppDimensions.headerHorizontalPadding,
              child: Consumer<SeriesProvider>(
                builder: (context, seriesProvider, _) {
                  return MediaFilterBar(
                    title: 'سریال‌ها',
                    subtitle: 'بهترین سریال‌های دنیا در یک جا',
                    selectedFilter: seriesProvider.selectedFilter,
                    onFilterChanged: seriesProvider.selectFilter,
                    onRefresh: seriesProvider.refreshSeries,
                    isAdvancedFilterActive:
                        seriesProvider.hasActiveAdvancedFilters,
                    onOpenAdvancedFilter: () {
                      AdvancedFilterSheet.show(
                        context: context,
                        initialMinImdb: seriesProvider.minImdb,
                        initialMinYear: seriesProvider.minYear,
                        initialMaxYear: seriesProvider.maxYear,
                        initialAudioFilter: seriesProvider.audioFilter,
                        onApply: seriesProvider.applyAdvancedFilters,
                        onClear: seriesProvider.clearAdvancedFilters,
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Consumer<SeriesProvider>(
                builder: (context, seriesProvider, child) {
                  if (seriesProvider.isLoading &&
                      seriesProvider.series.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (seriesProvider.errorMessage.isNotEmpty) {
                    return ErrorRetryView(
                      errorMessage: seriesProvider.errorMessage,
                      onRetry: seriesProvider.refreshSeries,
                    );
                  }

                  if (seriesProvider.series.isEmpty) {
                    return const EmptyStateView(
                      title: 'سریالی یافت نشد',
                      icon: Icons.tv_outlined,
                    );
                  }

                  return ResponsiveMediaGrid(
                    controller: _scrollController,
                    itemCount: seriesProvider.series.length,
                    hasMore: seriesProvider.hasMore,
                    header: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FeaturedHeroCarousel(items: seriesProvider.series),
                        const SizedBox(height: 8),
                        const ContinueWatchingSection(),
                        const SizedBox(height: 12),
                      ],
                    ),
                    itemBuilder: (context, index) {
                      final series = seriesProvider.series[index];
                      return MediaCard(
                        mediaItem: series,
                        onTap: () async {
                          await StorageUtils.saveSeries(series);
                          if (context.mounted) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    SingleSeriesScreen(series: series),
                              ),
                            );
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
