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
import '../providers/movie_provider.dart';
import '../utils/storage_utils.dart';
import '../widgets/media_card.dart';
import 'single_movie_screen.dart';

class MoviesScreen extends StatefulWidget {
  const MoviesScreen({super.key});

  @override
  State<MoviesScreen> createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final movieProvider = Provider.of<MovieProvider>(context, listen: false);
      final genreProvider = Provider.of<GenreProvider>(context, listen: false);

      if (movieProvider.movies.isEmpty) {
        movieProvider.loadMovies();
      }

      if (genreProvider.genres.isEmpty) {
        genreProvider.loadGenres();
      }

      genreProvider.addListener(() {
        if (genreProvider.selectedGenre != null) {
          movieProvider.selectGenre(genreProvider.selectedGenre!.id);
        } else {
          movieProvider.selectGenre(0);
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
      final movieProvider = Provider.of<MovieProvider>(context, listen: false);
      if (!movieProvider.isLoading && movieProvider.hasMore) {
        movieProvider.loadMovies();
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
              child: Consumer<MovieProvider>(
                builder: (context, movieProvider, _) {
                  return MediaFilterBar(
                    title: 'فیلم‌ها',
                    subtitle: 'مجموعه‌ای از برترین فیلم‌های جهان',
                    selectedFilter: movieProvider.selectedFilter,
                    onFilterChanged: movieProvider.selectFilter,
                    onRefresh: movieProvider.refreshMovies,
                    isAdvancedFilterActive:
                        movieProvider.hasActiveAdvancedFilters,
                    onOpenAdvancedFilter: () {
                      AdvancedFilterSheet.show(
                        context: context,
                        initialMinImdb: movieProvider.minImdb,
                        initialMinYear: movieProvider.minYear,
                        initialMaxYear: movieProvider.maxYear,
                        initialAudioFilter: movieProvider.audioFilter,
                        onApply: movieProvider.applyAdvancedFilters,
                        onClear: movieProvider.clearAdvancedFilters,
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Consumer<MovieProvider>(
                builder: (context, movieProvider, child) {
                  if (movieProvider.isLoading && movieProvider.movies.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (movieProvider.errorMessage.isNotEmpty) {
                    return ErrorRetryView(
                      errorMessage: movieProvider.errorMessage,
                      onRetry: movieProvider.refreshMovies,
                    );
                  }

                  if (movieProvider.movies.isEmpty) {
                    return const EmptyStateView(
                      title: 'فیلمی یافت نشد',
                      icon: Icons.movie_outlined,
                    );
                  }

                  return ResponsiveMediaGrid(
                    controller: _scrollController,
                    itemCount: movieProvider.movies.length,
                    hasMore: movieProvider.hasMore,
                    header: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FeaturedHeroCarousel(items: movieProvider.movies),
                        const SizedBox(height: 8),
                        const ContinueWatchingSection(),
                        const SizedBox(height: 12),
                      ],
                    ),
                    itemBuilder: (context, index) {
                      final movie = movieProvider.movies[index];
                      return MediaCard(
                        mediaItem: movie,
                        onTap: () async {
                          await StorageUtils.saveMovie(movie);
                          if (context.mounted) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    SingleMovieScreen(movie: movie),
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
