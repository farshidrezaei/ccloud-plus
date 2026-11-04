import 'media_item.dart';

enum DownloadStatus { queued, downloading, paused, completed, failed, canceled }

class DownloadTask {
  final String id;
  final String title;
  final String subTitle;
  final String url;
  final String quality;
  final String? posterPath;
  final String localPath;
  final int totalBytes;
  final int downloadedBytes;
  final double speed; // bytes per sec
  final DownloadStatus status;
  final String? error;
  final DateTime createdAt;
  final MediaItem? mediaItem;

  DownloadTask({
    required this.id,
    required this.title,
    this.subTitle = '',
    required this.url,
    required this.quality,
    this.posterPath,
    required this.localPath,
    this.totalBytes = 0,
    this.downloadedBytes = 0,
    this.speed = 0.0,
    this.status = DownloadStatus.queued,
    this.error,
    DateTime? createdAt,
    this.mediaItem,
  }) : createdAt = createdAt ?? DateTime.now();

  double get progress =>
      totalBytes > 0 ? (downloadedBytes / totalBytes).clamp(0.0, 1.0) : 0.0;

  String get formattedTotalSize => _formatBytes(totalBytes);
  String get formattedDownloadedSize => _formatBytes(downloadedBytes);

  String get formattedSpeed {
    if (status != DownloadStatus.downloading || speed <= 0) return '';
    return '${_formatBytes(speed.toInt())}/s';
  }

  String get eta {
    if (status != DownloadStatus.downloading || speed <= 0 || totalBytes <= 0) {
      return '';
    }
    final remainingBytes = totalBytes - downloadedBytes;
    if (remainingBytes <= 0) return '';
    final seconds = remainingBytes / speed;
    if (seconds < 60) return '${seconds.toInt()} ثانیه';
    final minutes = (seconds / 60).toInt();
    if (minutes < 60) return '$minutes دقیقه';
    final hours = (minutes / 60).toInt();
    return '$hours ساعت و ${minutes % 60} دقیقه';
  }

  static String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = 0;
    double count = bytes.toDouble();
    while (count >= 1024 && i < suffixes.length - 1) {
      count /= 1024;
      i++;
    }
    return '${count.toStringAsFixed(count >= 100 ? 0 : 1)} ${suffixes[i]}';
  }

  DownloadTask copyWith({
    String? id,
    String? title,
    String? subTitle,
    String? url,
    String? quality,
    String? posterPath,
    String? localPath,
    int? totalBytes,
    int? downloadedBytes,
    double? speed,
    DownloadStatus? status,
    String? error,
    DateTime? createdAt,
    MediaItem? mediaItem,
  }) {
    return DownloadTask(
      id: id ?? this.id,
      title: title ?? this.title,
      subTitle: subTitle ?? this.subTitle,
      url: url ?? this.url,
      quality: quality ?? this.quality,
      posterPath: posterPath ?? this.posterPath,
      localPath: localPath ?? this.localPath,
      totalBytes: totalBytes ?? this.totalBytes,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      speed: speed ?? this.speed,
      status: status ?? this.status,
      error: error ?? this.error,
      createdAt: createdAt ?? this.createdAt,
      mediaItem: mediaItem ?? this.mediaItem,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'subTitle': subTitle,
    'url': url,
    'quality': quality,
    'posterPath': posterPath,
    'localPath': localPath,
    'totalBytes': totalBytes,
    'downloadedBytes': downloadedBytes,
    'status': status.name,
    'error': error,
    'createdAt': createdAt.toIso8601String(),
    'mediaItem': mediaItem?.toJson(),
  };

  factory DownloadTask.fromJson(Map<String, dynamic> json) => DownloadTask(
    id: json['id'] as String,
    title: json['title'] as String,
    subTitle: (json['subTitle'] as String?) ?? '',
    url: json['url'] as String,
    quality: (json['quality'] as String?) ?? '',
    posterPath: json['posterPath'] as String?,
    localPath: json['localPath'] as String,
    totalBytes: (json['totalBytes'] as num?)?.toInt() ?? 0,
    downloadedBytes: (json['downloadedBytes'] as num?)?.toInt() ?? 0,
    status: DownloadStatus.values.firstWhere(
      (e) => e.name == json['status'],
      orElse: () => DownloadStatus.failed,
    ),
    error: json['error'] as String?,
    createdAt: json['createdAt'] != null
        ? DateTime.tryParse(json['createdAt'] as String)
        : null,
    mediaItem: json['mediaItem'] != null
        ? MediaItem.fromJson(json['mediaItem'] as Map<String, dynamic>)
        : null,
  );
}
