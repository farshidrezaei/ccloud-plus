import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/cache/cache_manager.dart';
import '../core/config/app_config.dart';

class BaseRepository {
  String get apiKey => AppConfig.apiKey;
  String get baseUrl => AppConfig.baseUrl;
  List<String> get helperServers => AppConfig.helperServers;

  /// Executes an HTTP request with automatic caching and Stale-While-Revalidate support.
  /// If fresh data is in cache, returns immediately with 0ms latency.
  /// If stale data is in cache, returns stale immediately and refreshes in background.
  /// If offline/network fails, falls back to stale cache if available.
  Future<String> executeRequest(
    String primaryUrl, {
    Duration? ttl,
    bool forceRefresh = false,
  }) async {
    final cache = CacheManager.instance;
    final effectiveTtl = ttl ?? CacheManager.defaultTtl;

    if (!forceRefresh) {
      if (cache.isFresh(primaryUrl)) {
        final cached = cache.get(primaryUrl);
        if (cached != null) {
          return cached;
        }
      } else {
        // Stale-While-Revalidate
        final stale = cache.get(primaryUrl, allowStale: true);
        if (stale != null) {
          unawaited(
            _fetchAndCache(primaryUrl, effectiveTtl).catchError((e) {
              debugPrint('Background cache refresh failed: $e');
              return '';
            }),
          );
          return stale;
        }
      }
    }

    try {
      return await _fetchAndCache(primaryUrl, effectiveTtl);
    } catch (e) {
      final stale = cache.get(primaryUrl, allowStale: true);
      if (stale != null) {
        debugPrint('Network error, served stale cache for $primaryUrl: $e');
        return stale;
      }
      rethrow;
    }
  }

  Future<String> _fetchAndCache(String primaryUrl, Duration ttl) async {
    final responseBody = await _fetchFromNetwork(primaryUrl);
    CacheManager.instance.set(primaryUrl, responseBody, ttl: ttl);
    return responseBody;
  }

  Future<String> _fetchFromNetwork(String primaryUrl) async {
    try {
      final response = await http
          .get(Uri.parse(primaryUrl))
          .timeout(const Duration(seconds: 12));
      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw HttpException(
          'خطای سرور با کد ${response.statusCode}',
          uri: Uri.parse(primaryUrl),
        );
      }
    } catch (primaryException) {
      for (String helperServer in helperServers) {
        try {
          final helperUrl = primaryUrl.replaceFirst(
            RegExp(r'^https?://[^/]+'),
            helperServer,
          );
          final response = await http
              .get(Uri.parse(helperUrl))
              .timeout(const Duration(seconds: 8));
          if (response.statusCode == 200) {
            return response.body;
          }
        } catch (_) {
          continue;
        }
      }
      rethrow;
    }
  }
}
