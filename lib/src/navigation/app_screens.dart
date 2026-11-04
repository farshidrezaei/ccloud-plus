import 'package:flutter/material.dart';

enum AppScreen {
  movies,
  series,
  search,
  countries,
  favorites,
  downloads,
  settings,
}

extension AppScreenExtension on AppScreen {
  String get route {
    switch (this) {
      case AppScreen.movies:
        return '/movies';
      case AppScreen.series:
        return '/series';
      case AppScreen.search:
        return '/search';
      case AppScreen.favorites:
        return '/favorites';
      case AppScreen.downloads:
        return '/downloads';
      case AppScreen.settings:
        return '/settings';
      case AppScreen.countries:
        return '/countries';
    }
  }

  String get title {
    switch (this) {
      case AppScreen.movies:
        return 'فیلم‌ها';
      case AppScreen.series:
        return 'سریال‌ها';
      case AppScreen.search:
        return 'جستجو';
      case AppScreen.favorites:
        return 'علاقه‌مندی‌ها';
      case AppScreen.downloads:
        return 'دانلودها';
      case AppScreen.countries:
        return 'کشورها';
      case AppScreen.settings:
        return 'تنظیمات';
    }
  }

  IconData get icon {
    switch (this) {
      case AppScreen.movies:
        return Icons.movie_outlined;
      case AppScreen.series:
        return Icons.tv_outlined;
      case AppScreen.search:
        return Icons.search_rounded;
      case AppScreen.favorites:
        return Icons.favorite_border_rounded;
      case AppScreen.downloads:
        return Icons.download_rounded;
      case AppScreen.countries:
        return Icons.public_rounded;
      case AppScreen.settings:
        return Icons.settings_outlined;
    }
  }

  bool get showInSidebar {
    return true;
  }
}
