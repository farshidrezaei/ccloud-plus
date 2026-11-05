import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../../../core/config/app_config.dart';

class UpdateInfo {
  final bool updateAvailable;
  final String status;
  final String currentVersion;
  final String latestVersion;
  final String releaseUrl;
  final String releaseNotes;
  final String? assetName;
  final String? assetDownloadUrl;
  final int? assetSizeBytes;

  const UpdateInfo({
    required this.updateAvailable,
    required this.status,
    required this.currentVersion,
    required this.latestVersion,
    required this.releaseUrl,
    this.releaseNotes = '',
    this.assetName,
    this.assetDownloadUrl,
    this.assetSizeBytes,
  });

  String get formattedSize {
    if (assetSizeBytes == null || assetSizeBytes! <= 0) return '';
    final mb = assetSizeBytes! / (1024 * 1024);
    return '${mb.toStringAsFixed(1)} MB';
  }
}

abstract final class UpdateService {
  static Future<UpdateInfo> checkForUpdates() async {
    try {
      final response = await http
          .get(
            Uri.parse(AppConfig.githubReleasesApi),
            headers: {'Accept': 'application/vnd.github.v3+json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> releases = jsonDecode(response.body);
        if (releases.isNotEmpty) {
          final latestRelease = releases[0];
          final latestVersion = (latestRelease['tag_name'] as String?) ?? '';
          final releaseUrl = (latestRelease['html_url'] as String?) ?? '';
          final releaseNotes = (latestRelease['body'] as String?) ?? '';
          final assets = (latestRelease['assets'] as List<dynamic>?) ?? [];

          // Find platform-specific binary asset
          String? assetName;
          String? assetDownloadUrl;
          int? assetSize;

          for (final asset in assets) {
            final name = (asset['name'] as String?) ?? '';
            final downloadUrl =
                (asset['browser_download_url'] as String?) ?? '';
            final size = (asset['size'] as int?) ?? 0;

            if (Platform.isLinux && name.endsWith('.AppImage')) {
              assetName = name;
              assetDownloadUrl = downloadUrl;
              assetSize = size;
              break;
            } else if (Platform.isWindows &&
                (name.endsWith('-Setup.exe') || name.endsWith('.exe'))) {
              assetName = name;
              assetDownloadUrl = downloadUrl;
              assetSize = size;
              break;
            } else if (Platform.isMacOS && name.endsWith('.dmg')) {
              assetName = name;
              assetDownloadUrl = downloadUrl;
              assetSize = size;
              break;
            }
          }

          final hasNewerVersion = isVersionNewer(
            latestVersion,
            AppConfig.currentVersion,
          );

          return UpdateInfo(
            updateAvailable: hasNewerVersion,
            status: hasNewerVersion
                ? 'نسخه جدید $latestVersion در دسترس است!'
                : 'شما در حال استفاده از آخرین نسخه (${AppConfig.currentVersion}) هستید.',
            currentVersion: AppConfig.currentVersion,
            latestVersion: latestVersion,
            releaseUrl: releaseUrl,
            releaseNotes: releaseNotes,
            assetName: assetName,
            assetDownloadUrl: assetDownloadUrl,
            assetSizeBytes: assetSize,
          );
        }
      }
      return const UpdateInfo(
        updateAvailable: false,
        status: 'پاسخی از سرور ریلیز گیت‌هاب دریافت نشد.',
        currentVersion: AppConfig.currentVersion,
        latestVersion: '',
        releaseUrl: '',
      );
    } catch (e) {
      return UpdateInfo(
        updateAvailable: false,
        status: 'خطا در بررسی بروزرسانی: $e',
        currentVersion: AppConfig.currentVersion,
        latestVersion: '',
        releaseUrl: '',
      );
    }
  }

  static bool isVersionNewer(String latest, String current) {
    try {
      final latestClean = latest.replaceAll(RegExp(r'[^0-9.]'), '').trim();
      final currentClean = current.replaceAll(RegExp(r'[^0-9.]'), '').trim();
      final latestParts = latestClean.split('.').map(int.parse).toList();
      final currentParts = currentClean.split('.').map(int.parse).toList();

      for (int i = 0; i < latestParts.length && i < currentParts.length; i++) {
        if (latestParts[i] > currentParts[i]) return true;
        if (latestParts[i] < currentParts[i]) return false;
      }
      return latestParts.length > currentParts.length;
    } catch (_) {
      return latest.trim() != current.trim();
    }
  }

  /// Downloads the update file with real-time progress and applies/installs it.
  static Future<String> downloadAndApplyUpdate({
    required String downloadUrl,
    required String fileName,
    required void Function(double progress, int received, int total) onProgress,
  }) async {
    final client = http.Client();
    try {
      final request = http.Request('GET', Uri.parse(downloadUrl));
      final response = await client.send(request);

      if (response.statusCode != 200) {
        throw Exception('خطای سرور در دانلود: کد ${response.statusCode}');
      }

      final totalBytes = response.contentLength ?? 0;
      int receivedBytes = 0;

      final tempDir = await getTemporaryDirectory();
      final saveFile = File('${tempDir.path}/$fileName');
      final sink = saveFile.openWrite();

      try {
        await for (final chunk in response.stream) {
          sink.add(chunk);
          receivedBytes += chunk.length;
          if (totalBytes > 0) {
            onProgress(receivedBytes / totalBytes, receivedBytes, totalBytes);
          }
        }
        await sink.flush();
      } finally {
        await sink.close();
      }

      // Platform specific installation
      if (Platform.isLinux) {
        // Make downloaded file executable
        await Process.run('chmod', ['+x', saveFile.path]);

        final home = Platform.environment['HOME'] ?? '';
        final localInstallDir = Directory('$home/.local/share/ccloud_plus');
        await localInstallDir.create(recursive: true);

        final targetAppImage = File(
          '$home/.local/share/ccloud_plus/CCloudPlus.AppImage',
        );

        // Replace local installed AppImage
        await saveFile.copy(targetAppImage.path);
        await Process.run('chmod', ['+x', targetAppImage.path]);

        // Ensure ~/.local/bin/ccloud_plus launcher exists and prioritizes the new AppImage
        final binDir = Directory('$home/.local/bin');
        await binDir.create(recursive: true);
        final launcherFile = File('$home/.local/bin/ccloud_plus');
        await launcherFile.writeAsString('''#!/bin/bash
if [ -f "\$HOME/.local/share/ccloud_plus/CCloudPlus.AppImage" ]; then
    exec "\$HOME/.local/share/ccloud_plus/CCloudPlus.AppImage" "\$@"
else
    exec "\$HOME/.local/share/ccloud_plus/bundle/ccloud_plus" "\$@"
fi
''');
        await Process.run('chmod', ['+x', launcherFile.path]);

        return 'بروزرسانی با موفقیت دانلود و در سیستم شما جایگزین شد! لطفاً روی دکمه «راه‌اندازی مجدد برنامه» کلیک کنید.';
      } else if (Platform.isWindows) {
        // Run Windows installer detached
        await Process.start(saveFile.path, [], mode: ProcessStartMode.detached);
        return 'نصاب نسخه جدید اجرا شد. برنامه در حال بسته‌شدن است...';
      } else if (Platform.isMacOS) {
        // Mount DMG
        await Process.run('open', [saveFile.path]);
        return 'تصویر دیسک نسخه جدید باز شد. لطفاً آن را به Applications منتقل کنید.';
      }

      return 'فایل بروزرسانی دریافت شد: ${saveFile.path}';
    } finally {
      client.close();
    }
  }

  /// Restarts the application on Linux
  static Future<void> restartApplication() async {
    if (Platform.isLinux) {
      final home = Platform.environment['HOME'] ?? '';
      final appImage = File('$home/.local/bin/ccloud_plus');
      if (await appImage.exists()) {
        await Process.start(appImage.path, [], mode: ProcessStartMode.detached);
      }
      exit(0);
    } else {
      exit(0);
    }
  }
}
