import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/app_settings_provider.dart';
import 'settings_section_header.dart';

class PlayerSettingsSection extends StatelessWidget {
  const PlayerSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettingsProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SettingsSectionHeader(
          title: 'تنظیمات پخش‌کننده ویدیو',
          subtitle: 'انتخاب پلیر پیش‌فرض، زمان پرش و کلیدهای میانبر',
        ),
        const SizedBox(height: 24),

        // Default Player Selection
        Text(
          'پلیر پیش‌فرض برای فیلم و سریال',
          style: GoogleFonts.vazirmatn(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _PlayerChoiceCard(
                title: 'پلیر داخلی پیشرفته',
                subtitle: 'پخش فوری، زیرنویس و صدا، کنترل با کیبورد',
                icon: Icons.play_circle_fill_rounded,
                isSelected: settings.defaultPlayer == DefaultPlayer.internal,
                onTap: () => settings.setDefaultPlayer(DefaultPlayer.internal),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _PlayerChoiceCard(
                title: 'پلیر خارجی VLC',
                subtitle: 'باز کردن خودکار لینک در نرم‌افزار VLC دسکتاپ',
                icon: Icons.tv_rounded,
                isSelected: settings.defaultPlayer == DefaultPlayer.vlc,
                onTap: () => settings.setDefaultPlayer(DefaultPlayer.vlc),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Seek Step
        Text(
          'میزان پرش زمانی با کلیدهای جهت‌نما',
          style: GoogleFonts.vazirmatn(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          children: [5, 10, 15, 30].map((sec) {
            final isSelected = settings.seekStepSeconds == sec;
            return ChoiceChip(
              label: Text('$sec ثانیه', style: GoogleFonts.vazirmatn()),
              selected: isSelected,
              selectedColor: AppColors.brandRed.withValues(alpha: 0.2),
              onSelected: (_) => settings.setSeekStepSeconds(sec),
            );
          }).toList(),
        ),
        const SizedBox(height: 28),

        // Auto play next episode
        SwitchListTile(
          title: Text(
            'پخش خودکار قسمت بعدی',
            style: GoogleFonts.vazirmatn(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            'در سریال‌ها، پس از اتمام یک قسمت، قسمت بعدی آماده پخش شود',
            style: GoogleFonts.vazirmatn(fontSize: 12),
          ),
          value: settings.autoPlayNext,
          activeTrackColor: AppColors.brandRed,
          onChanged: (val) => settings.setAutoPlayNext(val),
        ),
        const SizedBox(height: 16),

        // Hardware Decoding
        SwitchListTile(
          title: Text(
            'شتاب سخت‌افزاری (Hardware Decoding)',
            style: GoogleFonts.vazirmatn(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            'در صورت عدم نمایش تصویر یا نمایش صفحه آبی/سیاه، این گزینه را خاموش نگه دارید (رمزگشایی نرم‌افزاری پایدار)',
            style: GoogleFonts.vazirmatn(fontSize: 12),
          ),
          value: settings.hardwareDecoding,
          activeTrackColor: AppColors.brandRed,
          onChanged: (val) => settings.setHardwareDecoding(val),
        ),
        const SizedBox(height: 32),

        // Keyboard Shortcuts Reference Table
        Text(
          'راهنمای کلیدهای میانبر کیبورد در پلیر داخلی',
          style: GoogleFonts.vazirmatn(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Table(
          border: TableBorder.all(
            color: Colors.white12,
            borderRadius: BorderRadius.circular(8),
          ),
          children: [
            _buildShortcutRow('Space / K', 'توقف / ادامه پخش (Play / Pause)'),
            _buildShortcutRow('→ / L', 'پرش به جلو'),
            _buildShortcutRow('← / J', 'پرش به عقب'),
            _buildShortcutRow('↑ / ↓', 'افزایش / کاهش صدا'),
            _buildShortcutRow('M', 'قطع / وصل صدا (Mute)'),
            _buildShortcutRow('F', 'حالت تمام‌صفحه (Fullscreen)'),
            _buildShortcutRow('Esc', 'خروج از تمام‌صفحه / خروج از پلیر'),
          ],
        ),
      ],
    );
  }

  static TableRow _buildShortcutRow(String key, String desc) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            key,
            style: GoogleFonts.spaceMono(
              fontWeight: FontWeight.bold,
              color: AppColors.brandRed,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(desc, style: GoogleFonts.vazirmatn(fontSize: 13)),
        ),
      ],
    );
  }
}

class _PlayerChoiceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _PlayerChoiceCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.brandRed.withValues(alpha: 0.1)
              : (isDarkMode ? const Color(0xFF1B1D2A) : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.brandRed : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.brandRed : Colors.grey,
              size: 28,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.vazirmatn(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isSelected
                          ? AppColors.brandRed
                          : (isDarkMode ? Colors.white : Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.vazirmatn(
                      fontSize: 11,
                      color: isDarkMode ? Colors.white54 : Colors.black54,
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
}
