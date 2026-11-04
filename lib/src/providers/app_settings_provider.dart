import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SubtitleColor {
  white,
  yellow,
  cyan,
  green;

  String get label {
    switch (this) {
      case SubtitleColor.white:
        return 'سفید';
      case SubtitleColor.yellow:
        return 'زرد کلاسیک';
      case SubtitleColor.cyan:
        return 'فیروزه‌ای';
      case SubtitleColor.green:
        return 'سبز نئون';
    }
  }

  Color get color {
    switch (this) {
      case SubtitleColor.white:
        return Colors.white;
      case SubtitleColor.yellow:
        return const Color(0xFFFFD700);
      case SubtitleColor.cyan:
        return const Color(0xFF00E5FF);
      case SubtitleColor.green:
        return const Color(0xFF69F0AE);
    }
  }
}

enum SubtitleBackground {
  transparent,
  semiTransparentBlack,
  solidBlack;

  String get label {
    switch (this) {
      case SubtitleBackground.transparent:
        return 'بدون پس‌زمینه (حاشیه مشکی)';
      case SubtitleBackground.semiTransparentBlack:
        return 'مشکی نیمه‌شفاف';
      case SubtitleBackground.solidBlack:
        return 'مشکی کامل';
    }
  }

  Color get color {
    switch (this) {
      case SubtitleBackground.transparent:
        return Colors.transparent;
      case SubtitleBackground.semiTransparentBlack:
        return const Color(0x99000000);
      case SubtitleBackground.solidBlack:
        return Colors.black;
    }
  }
}

enum DefaultPlayer {
  internal,
  vlc;

  String get label {
    switch (this) {
      case DefaultPlayer.internal:
        return 'پلیر داخلی پیشرفته (پیش‌فرض)';
      case DefaultPlayer.vlc:
        return 'VLC خارجی';
    }
  }
}

class AppSettingsProvider with ChangeNotifier {
  static const String _keySubtitleFontSize = 'settings_sub_font_size';
  static const String _keySubtitleColor = 'settings_sub_color';
  static const String _keySubtitleBg = 'settings_sub_bg';
  static const String _keySubtitleFontFamily = 'settings_sub_font_family';
  static const String _keySubtitleEncoding = 'settings_sub_encoding';
  static const String _keyDefaultPlayer = 'settings_default_player';
  static const String _keySeekStep = 'settings_seek_step';
  static const String _keyAutoPlayNext = 'settings_auto_play_next';

  // Subtitle Defaults
  double _subtitleFontSize = 22.0;
  SubtitleColor _subtitleColor = SubtitleColor.yellow;
  SubtitleBackground _subtitleBackground =
      SubtitleBackground.semiTransparentBlack;
  String _subtitleFontFamily = 'Vazirmatn';
  String _subtitleEncoding = 'UTF-8';

  // Player Defaults
  DefaultPlayer _defaultPlayer = DefaultPlayer.internal;
  int _seekStepSeconds = 10;
  bool _autoPlayNext = true;

  bool _isLoaded = false;

  AppSettingsProvider() {
    _loadSettings();
  }

  // Getters
  double get subtitleFontSize => _subtitleFontSize;
  SubtitleColor get subtitleColor => _subtitleColor;
  SubtitleBackground get subtitleBackground => _subtitleBackground;
  String get subtitleFontFamily => _subtitleFontFamily;
  String get subtitleEncoding => _subtitleEncoding;
  DefaultPlayer get defaultPlayer => _defaultPlayer;
  int get seekStepSeconds => _seekStepSeconds;
  bool get autoPlayNext => _autoPlayNext;
  bool get isLoaded => _isLoaded;

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    _subtitleFontSize = prefs.getDouble(_keySubtitleFontSize) ?? 22.0;

    final colorIndex = prefs.getInt(_keySubtitleColor);
    if (colorIndex != null &&
        colorIndex >= 0 &&
        colorIndex < SubtitleColor.values.length) {
      _subtitleColor = SubtitleColor.values[colorIndex];
    }

    final bgIndex = prefs.getInt(_keySubtitleBg);
    if (bgIndex != null &&
        bgIndex >= 0 &&
        bgIndex < SubtitleBackground.values.length) {
      _subtitleBackground = SubtitleBackground.values[bgIndex];
    }

    _subtitleFontFamily =
        prefs.getString(_keySubtitleFontFamily) ?? 'Vazirmatn';
    _subtitleEncoding = prefs.getString(_keySubtitleEncoding) ?? 'UTF-8';

    final playerIndex = prefs.getInt(_keyDefaultPlayer);
    if (playerIndex != null &&
        playerIndex >= 0 &&
        playerIndex < DefaultPlayer.values.length) {
      _defaultPlayer = DefaultPlayer.values[playerIndex];
    }

    _seekStepSeconds = prefs.getInt(_keySeekStep) ?? 10;
    _autoPlayNext = prefs.getBool(_keyAutoPlayNext) ?? true;

    _isLoaded = true;
    notifyListeners();
  }

  Future<void> setSubtitleFontSize(double size) async {
    _subtitleFontSize = size;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keySubtitleFontSize, size);
  }

  Future<void> setSubtitleColor(SubtitleColor color) async {
    _subtitleColor = color;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keySubtitleColor, color.index);
  }

  Future<void> setSubtitleBackground(SubtitleBackground bg) async {
    _subtitleBackground = bg;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keySubtitleBg, bg.index);
  }

  Future<void> setSubtitleFontFamily(String fontFamily) async {
    _subtitleFontFamily = fontFamily;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySubtitleFontFamily, fontFamily);
  }

  Future<void> setSubtitleEncoding(String encoding) async {
    _subtitleEncoding = encoding;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySubtitleEncoding, encoding);
  }

  Future<void> setDefaultPlayer(DefaultPlayer player) async {
    _defaultPlayer = player;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyDefaultPlayer, player.index);
  }

  Future<void> setSeekStepSeconds(int seconds) async {
    _seekStepSeconds = seconds;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keySeekStep, seconds);
  }

  Future<void> setAutoPlayNext(bool autoPlay) async {
    _autoPlayNext = autoPlay;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAutoPlayNext, autoPlay);
  }

  Future<void> resetToDefaults() async {
    _subtitleFontSize = 22.0;
    _subtitleColor = SubtitleColor.yellow;
    _subtitleBackground = SubtitleBackground.semiTransparentBlack;
    _subtitleFontFamily = 'Vazirmatn';
    _subtitleEncoding = 'UTF-8';
    _defaultPlayer = DefaultPlayer.internal;
    _seekStepSeconds = 10;
    _autoPlayNext = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keySubtitleFontSize);
    await prefs.remove(_keySubtitleColor);
    await prefs.remove(_keySubtitleBg);
    await prefs.remove(_keySubtitleFontFamily);
    await prefs.remove(_keySubtitleEncoding);
    await prefs.remove(_keyDefaultPlayer);
    await prefs.remove(_keySeekStep);
    await prefs.remove(_keyAutoPlayNext);
  }
}
