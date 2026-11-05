import 'package:flutter/material.dart';
import '../models/media_item.dart';
import '../repositories/movie_repository.dart';
import '../utils/storage_utils.dart';

class MovieProvider with ChangeNotifier {
  final MovieRepository _movieRepository = MovieRepository();

  List<MediaItem> _movies = [];
  bool _isLoading = false;
  String _errorMessage = '';
  int _currentPage = 0;
  bool _hasMore = true;
  int _selectedGenreId = 0;
  FilterType _selectedFilter = FilterType.defaultFilter;
  double _minImdb = 0.0;
  int? _minYear;
  int? _maxYear;
  String _audioFilter = 'all';

  double get minImdb => _minImdb;
  int? get minYear => _minYear;
  int? get maxYear => _maxYear;
  String get audioFilter => _audioFilter;

  bool get hasActiveAdvancedFilters =>
      _minImdb > 0.0 ||
      _minYear != null ||
      _maxYear != null ||
      _audioFilter != 'all';

  List<MediaItem> get movies {
    if (!hasActiveAdvancedFilters) return _movies;
    return _movies.where((item) {
      if (_minImdb > 0.0 && item.imdb < _minImdb) return false;
      if (_minYear != null && item.year < _minYear!) return false;
      if (_maxYear != null && item.year > _maxYear!) return false;
      if (_audioFilter == 'dubbed' &&
          !item.sources.any((s) => s.type.toLowerCase().contains('dub'))) {
        return false;
      }
      if (_audioFilter == 'subbed' &&
          !item.sources.any((s) => s.type.toLowerCase().contains('sub'))) {
        return false;
      }
      return true;
    }).toList();
  }

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;
  int get selectedGenreId => _selectedGenreId;
  FilterType get selectedFilter => _selectedFilter;

  Future<void> loadMovies({bool refresh = false}) async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      if (refresh) {
        _movies = [];
        _currentPage = 0;
        _hasMore = true;
      }

      if (!_hasMore) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      final newMovies = await _movieRepository.getMovies(
        page: _currentPage,
        genreId: _selectedGenreId,
        filterType: _selectedFilter,
      );

      final filteredMovies = newMovies
          .where((movie) => !containsFarsiOrArabic(movie.title))
          .toList();

      var currentNewMovies = newMovies;
      var currentFiltered = filteredMovies;
      int emptyAttempts = 0;

      while (currentFiltered.isEmpty &&
          currentNewMovies.isNotEmpty &&
          emptyAttempts < 5) {
        _currentPage++;
        emptyAttempts++;
        currentNewMovies = await _movieRepository.getMovies(
          page: _currentPage,
          genreId: _selectedGenreId,
          filterType: _selectedFilter,
        );
        currentFiltered = currentNewMovies
            .where((movie) => !containsFarsiOrArabic(movie.title))
            .toList();
      }

      if (currentNewMovies.isEmpty) {
        _hasMore = false;
      } else {
        _movies.addAll(currentFiltered);
        _currentPage++;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshMovies() async {
    await loadMovies(refresh: true);
  }

  void selectGenre(int genreId) {
    _selectedGenreId = genreId;
    refreshMovies();
  }

  void selectFilter(FilterType filter) {
    _selectedFilter = filter;
    refreshMovies();
  }

  void resetFilters() {
    _selectedGenreId = 0;
    _selectedFilter = FilterType.defaultFilter;
    clearAdvancedFilters();
    refreshMovies();
  }

  void applyAdvancedFilters({
    required double minImdb,
    required int? minYear,
    required int? maxYear,
    required String audioFilter,
  }) {
    _minImdb = minImdb;
    _minYear = minYear;
    _maxYear = maxYear;
    _audioFilter = audioFilter;
    notifyListeners();
  }

  void clearAdvancedFilters() {
    _minImdb = 0.0;
    _minYear = null;
    _maxYear = null;
    _audioFilter = 'all';
    notifyListeners();
  }
}
