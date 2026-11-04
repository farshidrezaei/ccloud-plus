import 'package:flutter/material.dart';
import '../models/media_item.dart';
import '../models/watch_history_item.dart';
import '../utils/storage_utils.dart';

class WatchHistoryProvider with ChangeNotifier {
  List<WatchHistoryItem> _items = [];
  bool _isLoading = true;

  List<WatchHistoryItem> get items => _items;
  bool get isLoading => _isLoading;
  bool get hasItems => _items.isNotEmpty;

  WatchHistoryProvider() {
    loadHistory();
  }

  Future<void> loadHistory() async {
    _isLoading = true;
    notifyListeners();

    _items = await StorageUtils.loadWatchHistory();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveProgress({
    required MediaItem mediaItem,
    required String videoUrl,
    required int positionMs,
    required int durationMs,
    String? episodeTitle,
  }) async {
    // Only save if progress is at least 5 seconds and duration is valid
    if (positionMs < 5000 || durationMs <= 0) return;

    final id = '${mediaItem.id}_${mediaItem.type}_${episodeTitle ?? "main"}';

    final historyItem = WatchHistoryItem(
      id: id,
      mediaItem: mediaItem,
      videoUrl: videoUrl,
      positionMs: positionMs,
      durationMs: durationMs,
      lastWatchedAt: DateTime.now(),
      episodeTitle: episodeTitle,
    );

    await StorageUtils.saveWatchHistoryItem(historyItem);

    // Update in-memory state
    _items.removeWhere((i) => i.id == id);
    if (!historyItem.isCompleted) {
      _items.insert(0, historyItem);
    }
    notifyListeners();
  }

  Future<void> removeItem(String id) async {
    _items.removeWhere((i) => i.id == id);
    notifyListeners();
    await StorageUtils.removeFromWatchHistory(id);
  }

  Future<void> clearAll() async {
    _items.clear();
    notifyListeners();
    await StorageUtils.clearWatchHistory();
  }
}
