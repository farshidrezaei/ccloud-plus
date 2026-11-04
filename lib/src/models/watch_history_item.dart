import 'media_item.dart';

class WatchHistoryItem {
  final String id;
  final MediaItem mediaItem;
  final String videoUrl;
  final int positionMs;
  final int durationMs;
  final DateTime lastWatchedAt;
  final String? episodeTitle;

  const WatchHistoryItem({
    required this.id,
    required this.mediaItem,
    required this.videoUrl,
    required this.positionMs,
    required this.durationMs,
    required this.lastWatchedAt,
    this.episodeTitle,
  });

  double get progress {
    if (durationMs <= 0) return 0.0;
    return (positionMs / durationMs).clamp(0.0, 1.0);
  }

  bool get isCompleted => progress >= 0.95;

  String get remainingFormatted {
    if (durationMs <= 0) return '';
    final remainingSeconds = ((durationMs - positionMs) / 1000).round();
    if (remainingSeconds <= 60) return 'کمتر از ۱ دقیقه مانده';
    final minutes = (remainingSeconds / 60).round();
    if (minutes < 60) {
      return '$minutes دقیقه مانده';
    }
    final hours = minutes ~/ 60;
    final remMins = minutes % 60;
    if (remMins == 0) return '$hours ساعت مانده';
    return '$hours ساعت و $remMins دقیقه مانده';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mediaItem': mediaItem.toJson(),
      'videoUrl': videoUrl,
      'positionMs': positionMs,
      'durationMs': durationMs,
      'lastWatchedAt': lastWatchedAt.toIso8601String(),
      'episodeTitle': episodeTitle,
    };
  }

  factory WatchHistoryItem.fromJson(Map<String, dynamic> json) {
    return WatchHistoryItem(
      id: json['id'] as String,
      mediaItem: MediaItem.fromJson(json['mediaItem'] as Map<String, dynamic>),
      videoUrl: json['videoUrl'] as String? ?? '',
      positionMs: json['positionMs'] as int? ?? 0,
      durationMs: json['durationMs'] as int? ?? 0,
      lastWatchedAt: json['lastWatchedAt'] != null
          ? DateTime.tryParse(json['lastWatchedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      episodeTitle: json['episodeTitle'] as String?,
    );
  }

  WatchHistoryItem copyWith({
    int? positionMs,
    int? durationMs,
    DateTime? lastWatchedAt,
    String? episodeTitle,
    String? videoUrl,
  }) {
    return WatchHistoryItem(
      id: id,
      mediaItem: mediaItem,
      videoUrl: videoUrl ?? this.videoUrl,
      positionMs: positionMs ?? this.positionMs,
      durationMs: durationMs ?? this.durationMs,
      lastWatchedAt: lastWatchedAt ?? this.lastWatchedAt,
      episodeTitle: episodeTitle ?? this.episodeTitle,
    );
  }
}
