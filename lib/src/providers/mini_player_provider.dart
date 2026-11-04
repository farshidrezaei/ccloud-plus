import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../models/media_item.dart';

class MiniPlayerProvider extends ChangeNotifier {
  Player? _player;
  VideoController? _videoController;
  String? _title;
  String? _videoUrl;
  MediaItem? _mediaItem;
  String? _episodeTitle;
  bool _isDocked = false;

  Player? get player => _player;
  VideoController? get videoController => _videoController;
  String? get title => _title;
  String? get videoUrl => _videoUrl;
  MediaItem? get mediaItem => _mediaItem;
  String? get episodeTitle => _episodeTitle;
  bool get isDocked => _isDocked && _player != null;

  void dock({
    required Player player,
    required VideoController videoController,
    required String title,
    required String videoUrl,
    MediaItem? mediaItem,
    String? episodeTitle,
  }) {
    _player = player;
    _videoController = videoController;
    _title = title;
    _videoUrl = videoUrl;
    _mediaItem = mediaItem;
    _episodeTitle = episodeTitle;
    _isDocked = true;
    notifyListeners();
  }

  void undock() {
    _isDocked = false;
    notifyListeners();
  }

  Future<void> close() async {
    _isDocked = false;
    final p = _player;
    _player = null;
    _videoController = null;
    _title = null;
    _videoUrl = null;
    _mediaItem = null;
    _episodeTitle = null;
    notifyListeners();

    try {
      await p?.stop();
      await p?.dispose();
    } catch (_) {}
  }

  void togglePlayPause() {
    _player?.playOrPause();
  }
}
