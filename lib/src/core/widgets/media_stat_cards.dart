import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class MediaStatCards extends StatelessWidget {
  final double imdb;
  final int year;
  final String? duration;
  final String? countryOrLanguage;
  final String? qualityOrSeasons;

  const MediaStatCards({
    super.key,
    required this.imdb,
    required this.year,
    this.duration,
    this.countryOrLanguage,
    this.qualityOrSeasons,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final stats = <_StatItem>[
      if (imdb > 0)
        _StatItem(
          label: 'امتیاز IMDb',
          value: imdb.toStringAsFixed(1),
          valueColor: AppColors.starGold,
          isMono: true,
        ),
      if (year > 0) _StatItem(label: 'سال تولید', value: '$year', isMono: true),
      if (duration != null && duration!.isNotEmpty)
        _StatItem(label: 'مدت زمان', value: duration!),
      if (countryOrLanguage != null && countryOrLanguage!.isNotEmpty)
        _StatItem(label: 'کشور سازنده', value: countryOrLanguage!),
      if (qualityOrSeasons != null && qualityOrSeasons!.isNotEmpty)
        _StatItem(label: 'کیفیت / فصل', value: qualityOrSeasons!),
    ];

    if (stats.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: stats.map((stat) {
          return Container(
            margin: const EdgeInsets.only(left: 12),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.surfaceCard : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDarkMode
                    ? AppColors.glassBorder
                    : Colors.black.withValues(alpha: 0.08),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  stat.label,
                  style: GoogleFonts.vazirmatn(
                    fontSize: 12,
                    color: isDarkMode
                        ? AppColors.textMuted
                        : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  stat.value,
                  style: stat.isMono
                      ? GoogleFonts.spaceMono(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color:
                              stat.valueColor ??
                              (isDarkMode ? Colors.white : Colors.black87),
                        )
                      : GoogleFonts.vazirmatn(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color:
                              stat.valueColor ??
                              (isDarkMode ? Colors.white : Colors.black87),
                        ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _StatItem {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isMono;

  const _StatItem({
    required this.label,
    required this.value,
    this.valueColor,
    this.isMono = false,
  });
}
