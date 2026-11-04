import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/config/app_config.dart';

class UpdateInfo {
  final bool updateAvailable;
  final String status;
  final String latestVersion;
  final String releaseUrl;

  const UpdateInfo({
    required this.updateAvailable,
    required this.status,
    required this.latestVersion,
    required this.releaseUrl,
  });
}

abstract final class UpdateService {
  static Future<UpdateInfo> checkForUpdates() async {
    try {
      final response = await http.get(
        Uri.parse(AppConfig.githubReleasesApi),
        headers: {'Accept': 'application/vnd.github.v3+json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> releases = jsonDecode(response.body);
        if (releases.isNotEmpty) {
          final latestRelease = releases[0];
          final latestVersion = latestRelease['tag_name'] as String;
          final releaseUrl = latestRelease['html_url'] as String;

          if (isVersionNewer(latestVersion, AppConfig.currentVersion)) {
            return UpdateInfo(
              updateAvailable: true,
              status: 'نسخه جدید در دسترس است!',
              latestVersion: latestVersion,
              releaseUrl: releaseUrl,
            );
          } else {
            return UpdateInfo(
              updateAvailable: false,
              status: 'نسخه شما به‌روز است',
              latestVersion: latestVersion,
              releaseUrl: releaseUrl,
            );
          }
        }
      }
      return const UpdateInfo(
        updateAvailable: false,
        status: 'خطا در ارتباط با سرور گیت‌هاب',
        latestVersion: '',
        releaseUrl: '',
      );
    } catch (e) {
      return UpdateInfo(
        updateAvailable: false,
        status: 'خطا در بررسی بروزرسانی: $e',
        latestVersion: '',
        releaseUrl: '',
      );
    }
  }

  static bool isVersionNewer(String latest, String current) {
    try {
      final latestClean = latest.replaceAll('v', '').trim();
      final currentClean = current.replaceAll('v', '').trim();
      final latestParts = latestClean.split('.').map(int.parse).toList();
      final currentParts = currentClean.split('.').map(int.parse).toList();

      for (int i = 0; i < latestParts.length && i < currentParts.length; i++) {
        if (latestParts[i] > currentParts[i]) return true;
        if (latestParts[i] < currentParts[i]) return false;
      }
      return latestParts.length > currentParts.length;
    } catch (_) {
      return latest != current;
    }
  }
}
