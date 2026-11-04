import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/config/app_config.dart';
import '../../../core/constants/app_colors.dart';
import '../services/update_service.dart';
import 'settings_section_header.dart';

class UpdatesSettingsSection extends StatefulWidget {
  const UpdatesSettingsSection({super.key});

  @override
  State<UpdatesSettingsSection> createState() => _UpdatesSettingsSectionState();
}

class _UpdatesSettingsSectionState extends State<UpdatesSettingsSection> {
  bool _isCheckingUpdate = false;
  String _updateStatus = '';
  String _latestVersion = '';
  String _latestReleaseUrl = '';
  bool _updateAvailable = false;

  Future<void> _checkForUpdates() async {
    setState(() {
      _isCheckingUpdate = true;
      _updateStatus = 'در حال بررسی...';
      _updateAvailable = false;
    });

    final info = await UpdateService.checkForUpdates();

    if (mounted) {
      setState(() {
        _isCheckingUpdate = false;
        _updateStatus = info.status;
        _latestVersion = info.latestVersion;
        _latestReleaseUrl = info.releaseUrl;
        _updateAvailable = info.updateAvailable;
      });
    }
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SettingsSectionHeader(
          title: 'بروزرسانی نرم‌افزار',
          subtitle: 'بررسی نسخه‌های جدید منتشر شده در گیت‌هاب',
        ),
        const SizedBox(height: 24),
        Text(
          'نسخه فعلی شما: ${AppConfig.currentVersion}',
          style: GoogleFonts.spaceMono(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (_updateStatus.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              _updateStatus,
              style: GoogleFonts.vazirmatn(
                fontSize: 15,
                color: _updateAvailable
                    ? Colors.greenAccent
                    : AppColors.brandRed,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: _isCheckingUpdate ? null : _checkForUpdates,
              icon: _isCheckingUpdate
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.refresh_rounded),
              label: Text(
                'بررسی نسخه جدید',
                style: GoogleFonts.vazirmatn(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandRed,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            if (_updateAvailable && _latestReleaseUrl.isNotEmpty) ...[
              const SizedBox(width: 16),
              OutlinedButton.icon(
                onPressed: () => _launchURL(_latestReleaseUrl),
                icon: const Icon(Icons.download_rounded),
                label: Text(
                  'دانلود $_latestVersion',
                  style: GoogleFonts.vazirmatn(fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
