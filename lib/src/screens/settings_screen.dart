import 'dart:io' show Platform, exit;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import '../core/enums/settings_section.dart';
import 'settings/widgets/about_settings_section.dart';
import 'settings/widgets/appearance_settings_section.dart';
import 'settings/widgets/player_settings_section.dart';
import 'settings/widgets/subtitle_settings_section.dart';
import 'settings/widgets/updates_settings_section.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  SettingsSection _selectedSection = SettingsSection.subtitle;

  void _confirmExit(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF161824) : Colors.white,
          title: Text(
            'خروج از برنامه',
            style: GoogleFonts.vazirmatn(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'آیا مطمئن هستید که می‌خواهید خارج شوید؟',
            style: GoogleFonts.vazirmatn(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('انصراف', style: GoogleFonts.vazirmatn()),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                if (!kIsWeb &&
                    (Platform.isWindows ||
                        Platform.isLinux ||
                        Platform.isMacOS)) {
                  exit(0);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandRed,
              ),
              child: Text(
                'خروج',
                style: GoogleFonts.vazirmatn(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;

    return Scaffold(
      backgroundColor: isDarkMode
          ? const Color(0xFF0D0E15)
          : const Color(0xFFF5F6FA),
      body: Padding(
        padding: EdgeInsets.all(isDesktop ? 32.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Header
            Row(
              children: [
                const Icon(
                  Icons.tune_rounded,
                  color: AppColors.brandRed,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'تنظیمات پیشرفته',
                  style: GoogleFonts.vazirmatn(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Main Settings Layout
            Expanded(
              child: isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Sidebar Navigation
                        Container(
                          width: 240,
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? const Color(0xFF141622)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDarkMode
                                  ? Colors.white.withValues(alpha: 0.05)
                                  : Colors.black.withValues(alpha: 0.05),
                            ),
                          ),
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Column(
                              children: [
                                _buildNavItem(
                                  SettingsSection.subtitle,
                                  'زیرنویس و متن',
                                  Icons.subtitles_rounded,
                                ),
                                _buildNavItem(
                                  SettingsSection.player,
                                  'پخش‌کننده ویدیو',
                                  Icons.smart_display_rounded,
                                ),
                                _buildNavItem(
                                  SettingsSection.appearance,
                                  'ظاهر و تم',
                                  Icons.palette_rounded,
                                ),
                                _buildNavItem(
                                  SettingsSection.updates,
                                  'بروزرسانی',
                                  Icons.system_update_rounded,
                                ),
                                _buildNavItem(
                                  SettingsSection.about,
                                  'درباره برنامه',
                                  Icons.info_outline_rounded,
                                ),
                                const Divider(height: 24),
                                _buildExitNavItem(),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),

                        // Section Content Container
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? const Color(0xFF141622)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDarkMode
                                    ? Colors.white.withValues(alpha: 0.05)
                                    : Colors.black.withValues(alpha: 0.05),
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.all(32),
                                child: _buildSectionContent(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        // Mobile/Tablet Horizontal Tabs
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: SettingsSection.values
                                .map((sec) => _buildMobileChip(sec))
                                .toList(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: SingleChildScrollView(
                            child: _buildSectionContent(),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(SettingsSection section, String title, IconData icon) {
    final isSelected = _selectedSection == section;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: isSelected
            ? AppColors.brandRed.withValues(alpha: 0.15)
            : Colors.transparent,
        leading: Icon(
          icon,
          color: isSelected
              ? AppColors.brandRed
              : (isDarkMode ? Colors.white70 : Colors.black54),
          size: 22,
        ),
        title: Text(
          title,
          style: GoogleFonts.vazirmatn(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? AppColors.brandRed
                : (isDarkMode ? Colors.white : Colors.black87),
          ),
        ),
        onTap: () => setState(() => _selectedSection = section),
      ),
    );
  }

  Widget _buildExitNavItem() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: const Icon(
          Icons.power_settings_new_rounded,
          color: Colors.redAccent,
          size: 22,
        ),
        title: Text(
          'خروج از برنامه',
          style: GoogleFonts.vazirmatn(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.redAccent,
          ),
        ),
        onTap: () => _confirmExit(context),
      ),
    );
  }

  Widget _buildMobileChip(SettingsSection section) {
    final isSelected = _selectedSection == section;
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: ChoiceChip(
        label: Text(section.title, style: GoogleFonts.vazirmatn(fontSize: 13)),
        selected: isSelected,
        selectedColor: AppColors.brandRed,
        onSelected: (_) => setState(() => _selectedSection = section),
      ),
    );
  }

  Widget _buildSectionContent() {
    return switch (_selectedSection) {
      SettingsSection.subtitle => const SubtitleSettingsSection(),
      SettingsSection.player => const PlayerSettingsSection(),
      SettingsSection.appearance => const AppearanceSettingsSection(),
      SettingsSection.updates => const UpdatesSettingsSection(),
      SettingsSection.about => const AboutSettingsSection(),
    };
  }
}
