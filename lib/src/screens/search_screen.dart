import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/widgets/responsive_media_grid.dart';
import '../widgets/media_card.dart';
import '../providers/search_provider.dart';
import '../models/poster.dart';
import '../utils/storage_utils.dart';
import '../screens/single_movie_screen.dart';
import '../screens/single_series_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(8, 20, 8, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                'جستجو',
                style: GoogleFonts.vazirmatn(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Consumer<SearchProvider>(
                builder: (context, searchProvider, child) {
                  return TextField(
                    controller: _searchController,
                    focusNode: _focusNode,
                    onChanged: (value) {
                      searchProvider.updateSearchQuery(value);
                    },
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        searchProvider.triggerSearch();
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'جستجوی فیلم و سریال...',
                      hintStyle: GoogleFonts.vazirmatn(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                      prefixIcon: IconButton(
                        icon: Icon(
                          Icons.search,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        onPressed: () {
                          if (_searchController.text.isNotEmpty) {
                            searchProvider.triggerSearch();
                          }
                        },
                      ),
                      suffixIcon: searchProvider.searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: Theme.of(context).iconTheme.color,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                searchProvider.clearSearch();
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            // Search results
            Expanded(
              child: Consumer<SearchProvider>(
                builder: (context, searchProvider, child) {
                  if (searchProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (searchProvider.errorMessage != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'خطا: ${searchProvider.errorMessage}',
                            style: GoogleFonts.vazirmatn(
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'لطفاً دوباره تلاش کنید',
                            style: GoogleFonts.vazirmatn(
                              fontSize: 14,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.color,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: searchProvider.triggerSearch,
                            child: Text(
                              'تلاش مجدد',
                              style: GoogleFonts.vazirmatn(),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (searchProvider.searchResults.isNotEmpty) {
                    return _buildSearchResultsGrid(
                      searchProvider.searchResults,
                    );
                  }
                  if (searchProvider.hasSearched &&
                      searchProvider.searchQuery.isNotEmpty &&
                      !searchProvider.isLoading) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 48,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'نتیجه‌ای یافت نشد',
                            style: GoogleFonts.vazirmatn(
                              fontSize: 18,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'عبارت جستجو را تغییر دهید',
                            style: GoogleFonts.vazirmatn(
                              fontSize: 14,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_rounded,
                          size: 56,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'جستجوی فیلم و سریال',
                          style: GoogleFonts.vazirmatn(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'نام فیلم، سریال یا بازیگر را جستجو کنید...',
                          style: GoogleFonts.vazirmatn(
                            fontSize: 14,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          'جستجوهای پیشنهادی',
                          style: GoogleFonts.vazirmatn(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children:
                              [
                                'Dune',
                                'Oppenheimer',
                                'Interstellar',
                                'Breaking Bad',
                                'Dark',
                                'Batman',
                              ].map((query) {
                                return ActionChip(
                                  label: Text(
                                    query,
                                    style: GoogleFonts.spaceMono(fontSize: 12),
                                  ),
                                  backgroundColor:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? const Color(0xFF171924)
                                      : Colors.grey.shade200,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    side: BorderSide(
                                      color:
                                          Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white.withValues(alpha: 0.08)
                                          : Colors.transparent,
                                    ),
                                  ),
                                  onPressed: () {
                                    _searchController.text = query;
                                    searchProvider.updateSearchQuery(query);
                                    searchProvider.triggerSearch();
                                  },
                                );
                              }).toList(),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResultsGrid(List<Poster> posters) {
    return ResponsiveMediaGrid(
      itemCount: posters.length,
      itemBuilder: (context, index) {
        final poster = posters[index];
        final mediaItem = poster.toMediaItem();
        return MediaCard(
          mediaItem: mediaItem,
          onTap: () async {
            if (poster.isMovie()) {
              await StorageUtils.saveMovie(mediaItem);
              if (context.mounted) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SingleMovieScreen(movie: mediaItem),
                  ),
                );
              }
            } else if (poster.isSeries()) {
              await StorageUtils.saveSeries(mediaItem);
              if (context.mounted) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SingleSeriesScreen(series: mediaItem),
                  ),
                );
              }
            }
          },
        );
      },
    );
  }
}
