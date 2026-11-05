import 'dart:io';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'src/core/cache/cache_manager.dart';
import 'src/navigation/app_router.dart';
import 'src/utils/theme_manager.dart';
import 'src/providers/app_settings_provider.dart';
import 'package:provider/provider.dart';
import 'src/providers/movie_provider.dart';
import 'src/providers/genre_provider.dart';
import 'src/providers/series_provider.dart';
import 'src/providers/seasons_provider.dart';
import 'src/providers/search_provider.dart';
import 'src/providers/countries_provider.dart';
import 'src/providers/watch_history_provider.dart';
import 'src/providers/download_provider.dart';
import 'src/providers/mini_player_provider.dart';
import 'package:media_kit/media_kit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    try {
      await windowManager.ensureInitialized();
    } catch (e) {
      debugPrint('windowManager init error: $e');
    }
  }

  // Initialize media_kit
  MediaKit.ensureInitialized();

  // Initialize local metadata cache
  await CacheManager.instance.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeManager()),
        ChangeNotifierProvider(create: (_) => AppSettingsProvider()),
        ChangeNotifierProvider(create: (_) => MovieProvider()),
        ChangeNotifierProvider(create: (_) => GenreProvider()),
        ChangeNotifierProvider(create: (_) => SeriesProvider()),
        ChangeNotifierProvider(create: (_) => SeasonsProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => CountriesProvider()),
        ChangeNotifierProvider(create: (_) => CountryMediaProvider()),
        ChangeNotifierProvider(create: (_) => WatchHistoryProvider()),
        ChangeNotifierProvider(create: (_) => DownloadProvider()),
        ChangeNotifierProvider(create: (_) => MiniPlayerProvider()),
      ],
      child: const CCloudPlus(),
    ),
  );
}

class CCloudPlus extends StatelessWidget {
  const CCloudPlus({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'CCloud+',
      theme: Provider.of<ThemeManager>(context).lightTheme,
      darkTheme: Provider.of<ThemeManager>(context).darkTheme,
      themeMode: Provider.of<ThemeManager>(context).themeMode,
      routerConfig: appRouter,
      builder: (context, child) {
        return Directionality(textDirection: TextDirection.rtl, child: child!);
      },
    );
  }
}
