import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/app_settings_provider.dart';
import 'settings_section_header.dart';

class SubtitleSettingsSection extends StatelessWidget {
  const SubtitleSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettingsProvider>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SettingsSectionHeader(
          title: 'تنظیمات زیرنویس',
          subtitle: 'شخصی‌سازی ظاهر، فونت و رنگ زیرنویس فیلم‌ها و سریال‌ها',
        ),
        const SizedBox(height: 24),

        // Live Subtitle Preview Box
        Container(
          width: double.infinity,
          height: 140,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFF1E2235), Color(0xFF0F111D)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: Colors.white12),
          ),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.movie_filter_rounded,
                      color: Colors.white.withValues(alpha: 0.15),
                      size: 48,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'پیش‌نمایش زنده زیرنویس',
                      style: GoogleFonts.vazirmatn(
                        color: Colors.white.withValues(alpha: 0.2),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: settings.subtitleBackground.color,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'این یک متن نمونه برای تست نمایش زیرنویس است.',
                    style: TextStyle(
                      fontFamily: settings.subtitleFontFamily,
                      fontSize: settings.subtitleFontSize,
                      color: settings.subtitleColor.color,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        if (settings.subtitleBackground ==
                            SubtitleBackground.transparent)
                          const Shadow(
                            color: Colors.black,
                            blurRadius: 4,
                            offset: Offset(1, 1),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Font Size Slider
        Text(
          'اندازه قلم زیرنویس: ${settings.subtitleFontSize.toInt()} پیکسل',
          style: GoogleFonts.vazirmatn(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        Slider(
          min: 14.0,
          max: 36.0,
          divisions: 22,
          value: settings.subtitleFontSize,
          activeColor: AppColors.brandRed,
          onChanged: (val) => settings.setSubtitleFontSize(val),
        ),
        const SizedBox(height: 24),

        // Subtitle Color Choices
        Text(
          'رنگ زیرنویس',
          style: GoogleFonts.vazirmatn(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 10,
          children: SubtitleColor.values.map((col) {
            final isSelected = settings.subtitleColor == col;
            return ChoiceChip(
              avatar: CircleAvatar(backgroundColor: col.color, radius: 8),
              label: Text(
                col.label,
                style: GoogleFonts.vazirmatn(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              selectedColor: AppColors.brandRed.withValues(alpha: 0.2),
              onSelected: (_) => settings.setSubtitleColor(col),
            );
          }).toList(),
        ),
        const SizedBox(height: 28),

        // Background Style
        Text(
          'پس‌زمینه زیرنویس',
          style: GoogleFonts.vazirmatn(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 10,
          children: SubtitleBackground.values.map((bg) {
            final isSelected = settings.subtitleBackground == bg;
            return ChoiceChip(
              label: Text(
                bg.label,
                style: GoogleFonts.vazirmatn(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              selectedColor: AppColors.brandRed.withValues(alpha: 0.2),
              onSelected: (_) => settings.setSubtitleBackground(bg),
            );
          }).toList(),
        ),
        const SizedBox(height: 28),

        // Encoding Selection
        Text(
          'کدگذاری کاراکترها (Encoding)',
          style: GoogleFonts.vazirmatn(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButton<String>(
          value: settings.subtitleEncoding,
          dropdownColor: isDarkMode ? const Color(0xFF1B1D2A) : Colors.white,
          items: const [
            DropdownMenuItem(
              value: 'UTF-8',
              child: Text('UTF-8 (استاندارد جهانی)'),
            ),
            DropdownMenuItem(
              value: 'windows-1256',
              child: Text('Windows-1256 (فارسی قدیمی)'),
            ),
          ],
          onChanged: (val) {
            if (val != null) settings.setSubtitleEncoding(val);
          },
        ),
      ],
    );
  }
}
