import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../../models/media_item.dart';
import '../../providers/genre_provider.dart';
import '../../widgets/genre_selector.dart';

class MediaFilterBar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final FilterType selectedFilter;
  final ValueChanged<FilterType> onFilterChanged;
  final VoidCallback onRefresh;
  final VoidCallback? onOpenAdvancedFilter;
  final bool isAdvancedFilterActive;

  const MediaFilterBar({
    super.key,
    required this.title,
    this.subtitle,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.onRefresh,
    this.onOpenAdvancedFilter,
    this.isAdvancedFilterActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title & Subtitle Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.vazirmatn(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: GoogleFonts.vazirmatn(
                      fontSize: 13,
                      color: isDarkMode
                          ? AppColors.textMuted
                          : Colors.grey.shade600,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Capsule Filter Pills Row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              // "All" / "همه" Pill
              Consumer<GenreProvider>(
                builder: (context, genreProvider, _) {
                  final isAllSelected =
                      genreProvider.selectedGenre == null &&
                      selectedFilter == FilterType.defaultFilter;

                  return _FilterPill(
                    label: 'همه',
                    isActive: isAllSelected,
                    onTap: () {
                      genreProvider.selectGenre(0);
                      onFilterChanged(FilterType.defaultFilter);
                    },
                  );
                },
              ),
              const SizedBox(width: 10),

              // Sort Dropdown Pill
              _SortFilterDropdownPill(
                selectedFilter: selectedFilter,
                onChanged: onFilterChanged,
              ),
              const SizedBox(width: 10),

              // Genre Pill
              Consumer<GenreProvider>(
                builder: (context, genreProvider, _) {
                  final genreTitle =
                      genreProvider.selectedGenre?.title ?? 'ژانرها';
                  final hasGenre = genreProvider.selectedGenre != null;

                  return _FilterPill(
                    label: genreTitle,
                    icon: Icons.keyboard_arrow_down_rounded,
                    isActive: hasGenre,
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => const GenreSelector(),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(width: 10),

              // Advanced Filter Pill
              if (onOpenAdvancedFilter != null) ...[
                _FilterPill(
                  label: 'فیلتر پیشرفته',
                  icon: Icons.tune_rounded,
                  isActive: isAdvancedFilterActive,
                  onTap: onOpenAdvancedFilter!,
                ),
                const SizedBox(width: 10),
              ],

              // Refresh Button (Frosted Circle)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onRefresh,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? AppColors.surfacePill
                          : Colors.grey.shade100,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDarkMode
                            ? AppColors.glassBorder
                            : Colors.black.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Icon(
                      Icons.refresh_rounded,
                      size: 18,
                      color: isDarkMode
                          ? AppColors.textSecondary
                          : Colors.black87,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.brandRed
                : isDarkMode
                ? AppColors.surfacePill
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isActive
                  ? AppColors.brandRed
                  : isDarkMode
                  ? AppColors.glassBorder
                  : Colors.black.withValues(alpha: 0.08),
            ),
            boxShadow: isActive
                ? const [
                    BoxShadow(
                      color: AppColors.brandRedGlow,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: GoogleFonts.vazirmatn(
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  color: isActive
                      ? Colors.white
                      : isDarkMode
                      ? AppColors.textSecondary
                      : Colors.black87,
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: 4),
                Icon(
                  icon,
                  size: 16,
                  color: isActive
                      ? Colors.white
                      : isDarkMode
                      ? AppColors.textSecondary
                      : Colors.black54,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SortFilterDropdownPill extends StatelessWidget {
  final FilterType selectedFilter;
  final ValueChanged<FilterType> onChanged;

  const _SortFilterDropdownPill({
    required this.selectedFilter,
    required this.onChanged,
  });

  String _getLabel() {
    switch (selectedFilter) {
      case FilterType.defaultFilter:
        return 'مرتب‌سازی: پیش‌فرض';
      case FilterType.byYear:
        return 'مرتب‌سازی: سال ساخت';
      case FilterType.byImdb:
        return 'مرتب‌سازی: امتیاز IMDb';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isActive = selectedFilter != FilterType.defaultFilter;

    return Theme(
      data: Theme.of(context).copyWith(
        popupMenuTheme: PopupMenuThemeData(
          color: isDarkMode ? const Color(0xFF161824) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: isDarkMode ? AppColors.glassBorder : Colors.black12,
            ),
          ),
        ),
      ),
      child: PopupMenuButton<FilterType>(
        tooltip: 'انتخاب مرتب‌سازی',
        onSelected: onChanged,
        itemBuilder: (context) => const [
          PopupMenuItem(
            value: FilterType.defaultFilter,
            child: Text('پیش‌فرض'),
          ),
          PopupMenuItem(value: FilterType.byYear, child: Text('بر اساس سال')),
          PopupMenuItem(
            value: FilterType.byImdb,
            child: Text('بر اساس امتیاز IMDb'),
          ),
        ],
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.brandRed
                : isDarkMode
                ? AppColors.surfacePill
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isActive
                  ? AppColors.brandRed
                  : isDarkMode
                  ? AppColors.glassBorder
                  : Colors.black.withValues(alpha: 0.08),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _getLabel(),
                style: GoogleFonts.vazirmatn(
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  color: isActive
                      ? Colors.white
                      : isDarkMode
                      ? AppColors.textSecondary
                      : Colors.black87,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 16,
                color: isActive
                    ? Colors.white
                    : isDarkMode
                    ? AppColors.textSecondary
                    : Colors.black54,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
