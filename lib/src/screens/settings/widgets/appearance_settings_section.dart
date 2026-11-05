import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/cache/cache_manager.dart';
import '../../../core/constants/app_colors.dart';
import '../../../utils/theme_manager.dart';
import 'settings_section_header.dart';

class AppearanceSettingsSection extends StatelessWidget {
  const AppearanceSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SettingsSectionHeader(
          title: 'ظاهر و تم',
          subtitle: 'تنظیم حالت تاریک، روشن یا هماهنگ با سیستم‌عامل',
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _ThemeOptionCard(
              title: 'تاریک سینمایی (OLED)',
              icon: Icons.dark_mode_rounded,
              theme: AppTheme.dark,
              manager: themeManager,
            ),
            _ThemeOptionCard(
              title: 'روشن',
              icon: Icons.light_mode_rounded,
              theme: AppTheme.light,
              manager: themeManager,
            ),
            _ThemeOptionCard(
              title: 'سیستمی',
              icon: Icons.brightness_auto_rounded,
              theme: AppTheme.system,
              manager: themeManager,
            ),
          ],
        ),
        const SizedBox(height: 36),
        const SettingsSectionHeader(
          title: 'حافظه پنهان و عملکرد (Cache)',
          subtitle:
              'مدیریت داده‌های ذخیره شده محلی برای بارگذاری با سرعت ۰ ثانیه',
        ),
        const SizedBox(height: 16),
        const _CacheManagementCard(),
      ],
    );
  }
}

class _CacheManagementCard extends StatefulWidget {
  const _CacheManagementCard();

  @override
  State<_CacheManagementCard> createState() => _CacheManagementCardState();
}

class _CacheManagementCardState extends State<_CacheManagementCard> {
  int _cacheCount = CacheManager.instance.count;
  int _cacheBytes = CacheManager.instance.sizeInBytes;

  void _clearCache() async {
    await CacheManager.instance.clear();
    if (mounted) {
      setState(() {
        _cacheCount = CacheManager.instance.count;
        _cacheBytes = CacheManager.instance.sizeInBytes;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'حافظه پنهان با موفقیت پاکسازی شد.',
            style: GoogleFonts.vazirmatn(),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final sizeKb = (_cacheBytes / 1024).toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1B1D2A) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.brandRed.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.storage_rounded,
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
                  'داده‌های متادیتا و صفحات',
                  style: GoogleFonts.vazirmatn(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$_cacheCount آیتم ذخیره شده ($sizeKb کیلوبایت)',
                  style: GoogleFonts.spaceMono(
                    fontSize: 12,
                    color: isDarkMode ? Colors.white60 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: _clearCache,
            icon: const Icon(Icons.delete_sweep_rounded, size: 18),
            label: Text(
              'پاکسازی کش',
              style: GoogleFonts.vazirmatn(fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.brandRed,
              side: const BorderSide(color: AppColors.brandRed),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeOptionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final AppTheme theme;
  final ThemeManager manager;

  const _ThemeOptionCard({
    required this.title,
    required this.icon,
    required this.theme,
    required this.manager,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = manager.currentTheme == theme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => manager.setTheme(theme),
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.brandRed.withValues(alpha: 0.1)
              : (isDarkMode ? const Color(0xFF1B1D2A) : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.brandRed : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 36,
              color: isSelected ? AppColors.brandRed : Colors.grey,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.vazirmatn(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? AppColors.brandRed
                    : (isDarkMode ? Colors.white : Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
