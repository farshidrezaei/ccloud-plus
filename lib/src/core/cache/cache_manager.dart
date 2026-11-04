import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class CacheEntry {
  final String data;
  final int cachedAtMs;
  final int ttlMs;

  const CacheEntry({
    required this.data,
    required this.cachedAtMs,
    required this.ttlMs,
  });

  bool get isExpired =>
      DateTime.now().millisecondsSinceEpoch > (cachedAtMs + ttlMs);

  bool get isFresh => !isExpired;

  Map<String, dynamic> toJson() => {
    'data': data,
    'cachedAtMs': cachedAtMs,
    'ttlMs': ttlMs,
  };

  factory CacheEntry.fromJson(Map<String, dynamic> json) {
    return CacheEntry(
      data: json['data'] as String? ?? '',
      cachedAtMs: json['cachedAtMs'] as int? ?? 0,
      ttlMs: json['ttlMs'] as int? ?? 0,
    );
  }
}

/// Persistent, High-Performance TTL Cache Manager with Stale-While-Revalidate support
class CacheManager {
  static final CacheManager instance = CacheManager._internal();
  CacheManager._internal();

  final Map<String, CacheEntry> _entries = {};
  bool _initialized = false;
  Timer? _saveDebounceTimer;
  File? _cacheFile;

  static const Duration defaultTtl = Duration(hours: 4);

  Future<void> init() async {
    if (_initialized) return;
    try {
      final docDir = await getApplicationDocumentsDirectory();
      _cacheFile = File('${docDir.path}/api_cache.json');

      if (await _cacheFile!.exists()) {
        final content = await _cacheFile!.readAsString();
        if (content.isNotEmpty) {
          final decoded = json.decode(content) as Map<String, dynamic>;
          final now = DateTime.now().millisecondsSinceEpoch;
          // Keep entries that are less than 30 days old
          const maxAgeMs = 30 * 24 * 60 * 60 * 1000;

          decoded.forEach((key, val) {
            if (val is Map<String, dynamic>) {
              final entry = CacheEntry.fromJson(val);
              if (now - entry.cachedAtMs < maxAgeMs) {
                _entries[key] = entry;
              }
            }
          });
        }
      }
      _initialized = true;
    } catch (e) {
      debugPrint('CacheManager init error: $e');
      _initialized = true;
    }
  }

  /// Get cached entry. If allowStale is true, returns even if expired.
  String? get(String key, {bool allowStale = false}) {
    final entry = _entries[key];
    if (entry == null) return null;
    if (entry.isFresh || allowStale) {
      return entry.data;
    }
    return null;
  }

  /// Check if an entry exists and is fresh
  bool isFresh(String key) {
    final entry = _entries[key];
    return entry != null && entry.isFresh;
  }

  /// Check if entry exists in cache (fresh or stale)
  bool has(String key) => _entries.containsKey(key);

  /// Store item in cache with TTL
  void set(String key, String data, {Duration ttl = defaultTtl}) {
    _entries[key] = CacheEntry(
      data: data,
      cachedAtMs: DateTime.now().millisecondsSinceEpoch,
      ttlMs: ttl.inMilliseconds,
    );
    _scheduleSave();
  }

  /// Invalidate specific key
  void invalidate(String key) {
    if (_entries.remove(key) != null) {
      _scheduleSave();
    }
  }

  /// Clear entire cache
  Future<void> clear() async {
    _entries.clear();
    _saveDebounceTimer?.cancel();
    try {
      if (_cacheFile != null && await _cacheFile!.exists()) {
        await _cacheFile!.delete();
      }
    } catch (e) {
      debugPrint('CacheManager clear error: $e');
    }
  }

  /// Total cached entries
  int get count => _entries.length;

  /// Approximate cache size in bytes
  int get sizeInBytes {
    int total = 0;
    for (final e in _entries.values) {
      total += e.data.length;
    }
    return total;
  }

  void _scheduleSave() {
    _saveDebounceTimer?.cancel();
    _saveDebounceTimer = Timer(const Duration(milliseconds: 1500), () async {
      await _persistToDisk();
    });
  }

  Future<void> _persistToDisk() async {
    try {
      if (_cacheFile == null) {
        final docDir = await getApplicationDocumentsDirectory();
        _cacheFile = File('${docDir.path}/api_cache.json');
      }
      final map = <String, dynamic>{};
      for (final entry in _entries.entries) {
        map[entry.key] = entry.value.toJson();
      }
      final jsonString = json.encode(map);
      await _cacheFile!.writeAsString(jsonString, flush: true);
    } catch (e) {
      debugPrint('CacheManager persist error: $e');
    }
  }
}
