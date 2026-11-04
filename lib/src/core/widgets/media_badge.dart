import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

class ImdbRatingBadge extends StatelessWidget {
  final double rating;

  const ImdbRatingBadge({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {
    if (rating <= 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.starGold,
        borderRadius: BorderRadius.circular(AppDimensions.badgeRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: Colors.black, size: 16),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: GoogleFonts.spaceMono(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class YearBadge extends StatelessWidget {
  final int year;

  const YearBadge({super.key, required this.year});

  @override
  Widget build(BuildContext context) {
    if (year <= 0) return const SizedBox.shrink();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.white.withValues(alpha: 0.12)
            : Colors.black.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppDimensions.badgeRadius),
      ),
      child: Text(
        '$year',
        style: GoogleFonts.spaceMono(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isDarkMode ? Colors.white : Colors.black87,
        ),
      ),
    );
  }
}

class DurationBadge extends StatelessWidget {
  final String? duration;

  const DurationBadge({super.key, required this.duration});

  @override
  Widget build(BuildContext context) {
    if (duration == null || duration!.isEmpty) return const SizedBox.shrink();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.white.withValues(alpha: 0.12)
            : Colors.black.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppDimensions.badgeRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.access_time_rounded,
            size: 14,
            color: isDarkMode ? Colors.white70 : Colors.black54,
          ),
          const SizedBox(width: 4),
          Text(
            duration!,
            style: GoogleFonts.vazirmatn(
              fontSize: 12,
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

class GenrePill extends StatelessWidget {
  final String title;

  const GenrePill({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1B1D2A) : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Text(
        title,
        style: GoogleFonts.vazirmatn(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.85)
              : Colors.black87,
        ),
      ),
    );
  }
}
