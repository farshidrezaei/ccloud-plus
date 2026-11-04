import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AdvancedFilterSheet extends StatefulWidget {
  final double initialMinImdb;
  final int? initialMinYear;
  final int? initialMaxYear;
  final String initialAudioFilter;
  final void Function({
    required double minImdb,
    required int? minYear,
    required int? maxYear,
    required String audioFilter,
  })
  onApply;
  final VoidCallback onClear;

  const AdvancedFilterSheet({
    super.key,
    required this.initialMinImdb,
    required this.initialMinYear,
    required this.initialMaxYear,
    required this.initialAudioFilter,
    required this.onApply,
    required this.onClear,
  });

  static Future<void> show({
    required BuildContext context,
    required double initialMinImdb,
    required int? initialMinYear,
    required int? initialMaxYear,
    required String initialAudioFilter,
    required void Function({
      required double minImdb,
      required int? minYear,
      required int? maxYear,
      required String audioFilter,
    })
    onApply,
    required VoidCallback onClear,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF13151F),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => AdvancedFilterSheet(
        initialMinImdb: initialMinImdb,
        initialMinYear: initialMinYear,
        initialMaxYear: initialMaxYear,
        initialAudioFilter: initialAudioFilter,
        onApply: onApply,
        onClear: onClear,
      ),
    );
  }

  @override
  State<AdvancedFilterSheet> createState() => _AdvancedFilterSheetState();
}

class _AdvancedFilterSheetState extends State<AdvancedFilterSheet> {
  late double _minImdb;
  late int? _minYear;
  late int? _maxYear;
  late String _audioFilter;

  @override
  void initState() {
    super.initState();
    _minImdb = widget.initialMinImdb;
    _minYear = widget.initialMinYear;
    _maxYear = widget.initialMaxYear;
    _audioFilter = widget.initialAudioFilter;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.tune_rounded,
                        color: AppColors.brandRed,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'فیلتر و مرتب‌سازی پیشرفته',
                        style: GoogleFonts.vazirmatn(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.white70,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(color: Colors.white12, height: 24),

              // 1. Minimum IMDb Slider
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'حداقل امتیاز IMDb:',
                    style: GoogleFonts.vazirmatn(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _minImdb > 0.0
                          ? AppColors.imdbGold
                          : Colors.white10,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _minImdb > 0.0
                          ? '${_minImdb.toStringAsFixed(1)}+'
                          : 'همه امتیازها',
                      style: GoogleFonts.spaceMono(
                        color: _minImdb > 0.0 ? Colors.black : Colors.white70,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 4,
                  activeTrackColor: AppColors.imdbGold,
                  inactiveTrackColor: Colors.white12,
                  thumbColor: AppColors.imdbGold,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 8,
                  ),
                ),
                child: Slider(
                  value: _minImdb,
                  min: 0.0,
                  max: 9.0,
                  divisions: 18,
                  onChanged: (val) => setState(() => _minImdb = val),
                ),
              ),
              const SizedBox(height: 20),

              // 2. Year Range Selection
              Text(
                'بازه سال تولید:',
                style: GoogleFonts.vazirmatn(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildYearPill('همه سال‌ها', null, null),
                  _buildYearPill('۲۰۲۴ و جدیدتر', 2024, null),
                  _buildYearPill('۲۰۲۰ تا ۲۰۲۳', 2020, 2023),
                  _buildYearPill('۲۰۱۰ تا ۲۰۱۹', 2010, 2019),
                  _buildYearPill('کلاسیک (قبل ۲۰۱۰)', null, 2009),
                ],
              ),
              const SizedBox(height: 20),

              // 3. Audio & Subtitle Filter
              Text(
                'نوع دوبله و زبان:',
                style: GoogleFonts.vazirmatn(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildAudioPill('همه', 'all'),
                  _buildAudioPill('فقط دوبله فارسی', 'dubbed'),
                  _buildAudioPill('فقط زیرنویس چسبیده', 'subbed'),
                ],
              ),
              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onApply(
                          minImdb: _minImdb,
                          minYear: _minYear,
                          maxYear: _maxYear,
                          audioFilter: _audioFilter,
                        );
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brandRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'اعمال فیلترها',
                        style: GoogleFonts.vazirmatn(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: () {
                      widget.onClear();
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text('پاکسازی', style: GoogleFonts.vazirmatn()),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildYearPill(String label, int? min, int? max) {
    final isSelected = _minYear == min && _maxYear == max;
    return InkWell(
      onTap: () => setState(() {
        _minYear = min;
        _maxYear = max;
      }),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brandRed : AppColors.surfacePill,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.brandRed : AppColors.glassBorder,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.vazirmatn(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildAudioPill(String label, String value) {
    final isSelected = _audioFilter == value;
    return InkWell(
      onTap: () => setState(() => _audioFilter = value),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brandRed : AppColors.surfacePill,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.brandRed : AppColors.glassBorder,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.vazirmatn(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}
