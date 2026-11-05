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
  UpdateInfo? _updateInfo;
  String _statusMessage = '';

  // In-app download state
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  String _downloadProgressText = '';
  String? _installSuccessMessage;
  String? _downloadErrorMessage;

  Future<void> _checkForUpdates() async {
    setState(() {
      _isCheckingUpdate = true;
      _statusMessage = 'در حال اتصال به سرور گیت‌هاب و بررسی نسخه‌ها...';
      _updateInfo = null;
      _installSuccessMessage = null;
      _downloadErrorMessage = null;
    });

    final info = await UpdateService.checkForUpdates();

    if (mounted) {
      setState(() {
        _isCheckingUpdate = false;
        _updateInfo = info;
        _statusMessage = info.status;
      });
    }
  }

  Future<void> _startInAppUpdate() async {
    if (_updateInfo == null || _updateInfo!.assetDownloadUrl == null) return;

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
      _downloadProgressText = 'در حال شروع دانلود...';
      _downloadErrorMessage = null;
      _installSuccessMessage = null;
    });

    try {
      final fileName = _updateInfo!.assetName ?? 'ccloud_plus_update';
      final resultMessage = await UpdateService.downloadAndApplyUpdate(
        downloadUrl: _updateInfo!.assetDownloadUrl!,
        fileName: fileName,
        onProgress: (progress, received, total) {
          if (mounted) {
            final receivedMb = (received / (1024 * 1024)).toStringAsFixed(1);
            final totalMb = (total / (1024 * 1024)).toStringAsFixed(1);
            setState(() {
              _downloadProgress = progress;
              _downloadProgressText =
                  '${(progress * 100).toInt()}% ($receivedMb MB / $totalMb MB)';
            });
          }
        },
      );

      if (mounted) {
        setState(() {
          _isDownloading = false;
          _installSuccessMessage = resultMessage;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _downloadErrorMessage = 'خطا در فرآیند بروزرسانی: $e';
        });
      }
    }
  }

  Future<void> _launchURL(String urlString) async {
    try {
      final Uri url = Uri.parse(urlString);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SettingsSectionHeader(
          title: 'بروزرسانی نرم‌افزار',
          subtitle: 'سیستم هوشمند بررسی، دانلود و نصب خودکار آخرین نسخه برنامه',
        ),
        const SizedBox(height: 24),

        // Current Version Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceCard : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? AppColors.glassBorder : Colors.black12,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.brandRed.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.system_update_rounded,
                  color: AppColors.brandRed,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'نسخه فعلی شما',
                      style: GoogleFonts.vazirmatn(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppConfig.currentVersion,
                      style: GoogleFonts.spaceMono(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: _isCheckingUpdate ? null : _checkForUpdates,
                icon: _isCheckingUpdate
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.sync_rounded),
                label: Text(
                  _isCheckingUpdate ? 'در حال بررسی...' : 'بررسی بروزرسانی',
                  style: GoogleFonts.vazirmatn(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Status Message when checked
        if (_statusMessage.isNotEmpty && _updateInfo == null) ...[
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              _statusMessage,
              style: GoogleFonts.vazirmatn(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],

        // Up to date card
        if (_updateInfo != null && !_updateInfo!.updateAvailable) ...[
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.greenAccent,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'شما در حال استفاده از آخرین نسخه موجود (${AppConfig.currentVersion}) هستید.',
                    style: GoogleFonts.vazirmatn(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.greenAccent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        // Update Available Card
        if (_updateInfo != null && _updateInfo!.updateAvailable) ...[
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161926) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.greenAccent.withValues(alpha: 0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.greenAccent.withValues(alpha: 0.1),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.greenAccent.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.new_releases_rounded,
                        color: Colors.greenAccent,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'نسخه جدید ${_updateInfo!.latestVersion} منتشر شد!',
                      style: GoogleFonts.vazirmatn(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    if (_updateInfo!.formattedSize.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceCard,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.glassBorder),
                        ),
                        child: Text(
                          _updateInfo!.formattedSize,
                          style: GoogleFonts.spaceMono(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.greenAccent,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Release Notes
                if (_updateInfo!.releaseNotes.isNotEmpty) ...[
                  Text(
                    'تغییرات نسخه جدید:',
                    style: GoogleFonts.vazirmatn(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxHeight: 140),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        _updateInfo!.releaseNotes,
                        style: GoogleFonts.vazirmatn(
                          fontSize: 12,
                          height: 1.6,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Downloading Progress Bar
                if (_isDownloading) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: _downloadProgress > 0 ? _downloadProgress : null,
                      backgroundColor: Colors.white12,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.greenAccent,
                      ),
                      minHeight: 10,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _downloadProgressText,
                        style: GoogleFonts.spaceMono(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.greenAccent,
                        ),
                      ),
                      Text(
                        'در حال دریافت فایل...',
                        style: GoogleFonts.vazirmatn(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                // Action Buttons
                Row(
                  children: [
                    if (_updateInfo!.assetDownloadUrl != null &&
                        !_isDownloading &&
                        _installSuccessMessage == null)
                      ElevatedButton.icon(
                        onPressed: _startInAppUpdate,
                        icon: const Icon(Icons.download_for_offline_rounded),
                        label: Text(
                          'دانلود و نصب خودکار بروزرسانی',
                          style: GoogleFonts.vazirmatn(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: () => _launchURL(_updateInfo!.releaseUrl),
                      icon: const Icon(Icons.open_in_new_rounded, size: 18),
                      label: Text(
                        'مشاهده در گیت‌هاب',
                        style: GoogleFonts.vazirmatn(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],

        // Success Installation Card with Restart Button
        if (_installSuccessMessage != null) ...[
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.greenAccent),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.celebration_rounded,
                      color: Colors.greenAccent,
                      size: 26,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _installSuccessMessage!,
                        style: GoogleFonts.vazirmatn(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => UpdateService.restartApplication(),
                  icon: const Icon(Icons.restart_alt_rounded),
                  label: Text(
                    'راه‌اندازی مجدد برنامه (Restart)',
                    style: GoogleFonts.vazirmatn(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        // Error Message Card
        if (_downloadErrorMessage != null) ...[
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.brandRed.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.brandRed.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.brandRed,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _downloadErrorMessage!,
                    style: GoogleFonts.vazirmatn(
                      fontSize: 13,
                      color: Colors.white,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
