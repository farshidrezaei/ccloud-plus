import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../models/download_task.dart';
import '../models/media_item.dart';
import '../services/download_service.dart';

class DownloadProvider extends ChangeNotifier {
  final List<DownloadTask> _tasks = [];
  final Map<String, DownloadController> _controllers = {};
  bool _isInitialized = false;

  List<DownloadTask> get tasks => List.unmodifiable(_tasks);

  int get activeDownloadsCount =>
      _tasks.where((t) => t.status == DownloadStatus.downloading).length;

  int get totalCompletedCount =>
      _tasks.where((t) => t.status == DownloadStatus.completed).length;

  int get totalDownloadedBytes => _tasks
      .where((t) => t.status == DownloadStatus.completed)
      .fold<int>(0, (sum, t) => sum + t.downloadedBytes);

  DownloadProvider() {
    init();
  }

  Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;
    await _loadTasksFromStorage();
  }

  Future<File> _getMetadataFile() async {
    final docs = await getApplicationDocumentsDirectory();
    return File(p.join(docs.path, 'downloads_metadata.json'));
  }

  Future<void> _loadTasksFromStorage() async {
    try {
      final file = await _getMetadataFile();
      if (!await file.exists()) return;

      final jsonStr = await file.readAsString();
      final List<dynamic> list = jsonDecode(jsonStr);

      _tasks.clear();
      for (final item in list) {
        final task = DownloadTask.fromJson(item as Map<String, dynamic>);
        // Check if file still exists on disk
        if (task.status == DownloadStatus.completed) {
          final exists = await File(task.localPath).exists();
          if (exists) {
            _tasks.add(task);
          }
        } else if (task.status == DownloadStatus.downloading) {
          // If was downloading when app closed, set to paused
          _tasks.add(task.copyWith(status: DownloadStatus.paused, speed: 0.0));
        } else {
          _tasks.add(task);
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading download metadata: $e');
    }
  }

  Future<void> _saveTasksToStorage() async {
    try {
      final file = await _getMetadataFile();
      final list = _tasks.map((t) => t.toJson()).toList();
      await file.writeAsString(jsonEncode(list));
    } catch (e) {
      debugPrint('Error saving download metadata: $e');
    }
  }

  DownloadTask? getTaskByUrl(String url) {
    try {
      return _tasks.firstWhere((t) => t.url == url);
    } catch (_) {
      return null;
    }
  }

  bool isDownloaded(String url) {
    final task = getTaskByUrl(url);
    return task != null && task.status == DownloadStatus.completed;
  }

  bool isDownloading(String url) {
    final task = getTaskByUrl(url);
    return task != null &&
        (task.status == DownloadStatus.downloading ||
            task.status == DownloadStatus.queued);
  }

  Future<void> startDownload({
    required String title,
    required String url,
    required String quality,
    String subTitle = '',
    String? posterPath,
    MediaItem? mediaItem,
  }) async {
    // Check if task already exists
    final existingIndex = _tasks.indexWhere((t) => t.url == url);
    if (existingIndex != -1) {
      final existing = _tasks[existingIndex];
      if (existing.status == DownloadStatus.completed) return;
      if (existing.status == DownloadStatus.downloading) return;
      resumeDownload(existing.id);
      return;
    }

    final downloadsDir = await DownloadService.getDownloadsDirectory();
    final sanitizedTitle = DownloadService.sanitizeFileName(
      '$title ${subTitle.isNotEmpty ? subTitle : ''} $quality'.trim(),
    );
    final fileName = '$sanitizedTitle.mp4';
    final localPath = p.join(downloadsDir.path, fileName);
    final taskId = '${DateTime.now().millisecondsSinceEpoch}_${url.hashCode}';

    final task = DownloadTask(
      id: taskId,
      title: title,
      subTitle: subTitle,
      url: url,
      quality: quality,
      posterPath: posterPath ?? mediaItem?.poster,
      localPath: localPath,
      status: DownloadStatus.queued,
      mediaItem: mediaItem,
    );

    _tasks.insert(0, task);
    notifyListeners();
    await _saveTasksToStorage();

    _runDownload(taskId);
  }

  void _runDownload(String taskId) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index == -1) return;

    final task = _tasks[index];
    final controller = DownloadController();
    _controllers[taskId] = controller;

    _tasks[index] = task.copyWith(
      status: DownloadStatus.downloading,
      error: null,
    );
    notifyListeners();

    try {
      await DownloadService.downloadFile(
        url: task.url,
        destinationPath: task.localPath,
        controller: controller,
        onProgress: (downloaded, total, speed) {
          final curIndex = _tasks.indexWhere((t) => t.id == taskId);
          if (curIndex != -1) {
            _tasks[curIndex] = _tasks[curIndex].copyWith(
              downloadedBytes: downloaded,
              totalBytes: total > 0 ? total : _tasks[curIndex].totalBytes,
              speed: speed,
              status: DownloadStatus.downloading,
            );
            notifyListeners();
          }
        },
      );

      final finishIndex = _tasks.indexWhere((t) => t.id == taskId);
      if (finishIndex != -1) {
        if (controller.isCancelled) {
          _tasks.removeAt(finishIndex);
        } else if (controller.isPaused) {
          _tasks[finishIndex] = _tasks[finishIndex].copyWith(
            status: DownloadStatus.paused,
            speed: 0.0,
          );
        } else {
          _tasks[finishIndex] = _tasks[finishIndex].copyWith(
            status: DownloadStatus.completed,
            speed: 0.0,
          );
        }
        notifyListeners();
        await _saveTasksToStorage();
      }
    } catch (e) {
      final errIndex = _tasks.indexWhere((t) => t.id == taskId);
      if (errIndex != -1) {
        _tasks[errIndex] = _tasks[errIndex].copyWith(
          status: DownloadStatus.failed,
          speed: 0.0,
          error: e.toString(),
        );
        notifyListeners();
        await _saveTasksToStorage();
      }
    } finally {
      _controllers.remove(taskId);
    }
  }

  void pauseDownload(String id) {
    final controller = _controllers[id];
    controller?.pause();

    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(
        status: DownloadStatus.paused,
        speed: 0.0,
      );
      notifyListeners();
      _saveTasksToStorage();
    }
  }

  void resumeDownload(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) return;

    if (_tasks[index].status == DownloadStatus.downloading) return;

    _runDownload(id);
  }

  void cancelDownload(String id) {
    final controller = _controllers[id];
    controller?.cancel();

    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
    _saveTasksToStorage();
  }

  Future<void> deleteDownload(String id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) return;

    final task = _tasks[index];
    final controller = _controllers[id];
    controller?.cancel();

    try {
      final file = File(task.localPath);
      if (await file.exists()) {
        await file.delete();
      }
      final partFile = File('${task.localPath}.part');
      if (await partFile.exists()) {
        await partFile.delete();
      }
    } catch (e) {
      debugPrint('Error deleting download file: $e');
    }

    _tasks.removeAt(index);
    notifyListeners();
    await _saveTasksToStorage();
  }
}
