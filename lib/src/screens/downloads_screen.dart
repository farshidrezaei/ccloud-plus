import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimensions.dart';
import '../core/widgets/empty_state_view.dart';
import '../models/download_task.dart';
import '../providers/download_provider.dart';
import 'video_player_screen.dart';

class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  int _selectedFilter = 0; // 0: All, 1: Active, 2: Completed

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: AppDimensions.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: AppDimensions.headerHorizontalPadding,
              child: Consumer<DownloadProvider>(
                builder: (context, provider, _) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          if (Navigator.of(context).canPop()) ...[
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back_rounded,
                                color: Colors.white,
                                size: 26,
                              ),
                              tooltip: 'بازگشت',
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            const SizedBox(width: 12),
                          ],
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'دانلودها',
                                style: GoogleFonts.vazirmatn(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'مدیریت دانلودها و تماشای آفلاین بدون اینترنت',
                                style: GoogleFonts.vazirmatn(
                                  fontSize: 13,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // Storage info badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceCard,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.glassBorder,
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.folder_outlined,
                              color: AppColors.brandRed,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'فایل‌های دانلود شده: ${provider.totalCompletedCount}',
                              style: GoogleFonts.vazirmatn(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Filter Pills
            Padding(
              padding: AppDimensions.headerHorizontalPadding,
              child: Consumer<DownloadProvider>(
                builder: (context, provider, _) {
                  final allCount = provider.tasks.length;
                  final activeCount = provider.activeDownloadsCount;
                  final completedCount = provider.totalCompletedCount;

                  return Row(
                    children: [
                      _buildFilterPill(0, 'همه ($allCount)'),
                      const SizedBox(width: 8),
                      _buildFilterPill(1, 'در حال دانلود ($activeCount)'),
                      const SizedBox(width: 8),
                      _buildFilterPill(2, 'کامل شده ($completedCount)'),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Downloads List
            Expanded(
              child: Consumer<DownloadProvider>(
                builder: (context, provider, _) {
                  List<DownloadTask> filtered = provider.tasks;
                  if (_selectedFilter == 1) {
                    filtered = provider.tasks
                        .where(
                          (t) =>
                              t.status == DownloadStatus.downloading ||
                              t.status == DownloadStatus.queued ||
                              t.status == DownloadStatus.paused,
                        )
                        .toList();
                  } else if (_selectedFilter == 2) {
                    filtered = provider.tasks
                        .where((t) => t.status == DownloadStatus.completed)
                        .toList();
                  }

                  if (filtered.isEmpty) {
                    return const EmptyStateView(
                      title: 'هیچ فایلی در این بخش نیست',
                      subtitle:
                          'می‌توانید کیفیت مورد نظر فیلم یا سریال را دانلود کرده و بدون اینترنت تماشا کنید',
                      icon: Icons.download_done_rounded,
                    );
                  }

                  return ListView.separated(
                    padding: AppDimensions.gridPadding,
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final task = filtered[index];
                      return _buildDownloadCard(context, provider, task);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterPill(int index, String label) {
    final isSelected = _selectedFilter == index;
    return InkWell(
      onTap: () => setState(() => _selectedFilter = index),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brandRed : AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.brandRed : AppColors.glassBorder,
            width: 0.8,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.brandRedGlow,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
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

  Widget _buildDownloadCard(
    BuildContext context,
    DownloadProvider provider,
    DownloadTask task,
  ) {
    final isDownloading = task.status == DownloadStatus.downloading;
    final isPaused = task.status == DownloadStatus.paused;
    final isCompleted = task.status == DownloadStatus.completed;
    final isFailed = task.status == DownloadStatus.failed;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDownloading
              ? AppColors.brandRed.withValues(alpha: 0.4)
              : AppColors.glassBorder,
          width: 0.8,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Poster / Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 60,
              height: 80,
              color: Colors.black26,
              child: task.posterPath != null && task.posterPath!.isNotEmpty
                  ? Image.network(
                      task.posterPath!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.movie_outlined,
                        color: Colors.white38,
                        size: 28,
                      ),
                    )
                  : const Icon(
                      Icons.movie_outlined,
                      color: Colors.white38,
                      size: 28,
                    ),
            ),
          ),
          const SizedBox(width: 14),

          // Details & Progress
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        task.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.vazirmatn(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Quality badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.brandRed.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: AppColors.brandRed.withValues(alpha: 0.4),
                          width: 0.6,
                        ),
                      ),
                      child: Text(
                        task.quality.toUpperCase(),
                        style: GoogleFonts.spaceMono(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.brandRed,
                        ),
                      ),
                    ),
                  ],
                ),
                if (task.subTitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    task.subTitle,
                    style: GoogleFonts.vazirmatn(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
                const SizedBox(height: 8),

                // Progress bar
                if (!isCompleted) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: task.progress > 0 ? task.progress : null,
                      backgroundColor: Colors.white10,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isFailed ? Colors.redAccent : AppColors.brandRed,
                      ),
                      minHeight: 5,
                    ),
                  ),
                  const SizedBox(height: 6),
                ],

                // Status info line
                Row(
                  children: [
                    if (isDownloading) ...[
                      Text(
                        '${(task.progress * 100).toStringAsFixed(1)}% • ${task.formattedDownloadedSize} از ${task.formattedTotalSize}',
                        style: GoogleFonts.vazirmatn(
                          fontSize: 11,
                          color: Colors.white70,
                        ),
                      ),
                      if (task.formattedSpeed.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Text(
                          '• ${task.formattedSpeed}',
                          style: GoogleFonts.spaceMono(
                            fontSize: 11,
                            color: AppColors.imdbGold,
                          ),
                        ),
                      ],
                      if (task.eta.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Text(
                          '• ${task.eta} باقی‌مانده',
                          style: GoogleFonts.vazirmatn(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ] else if (isPaused) ...[
                      Text(
                        'متوقف شده • ${task.formattedDownloadedSize} از ${task.formattedTotalSize}',
                        style: GoogleFonts.vazirmatn(
                          fontSize: 11,
                          color: Colors.amberAccent,
                        ),
                      ),
                    ] else if (isCompleted) ...[
                      const Icon(
                        Icons.check_circle_rounded,
                        color: Colors.greenAccent,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'دانلود کامل شد (${task.formattedDownloadedSize})',
                        style: GoogleFonts.vazirmatn(
                          fontSize: 11,
                          color: Colors.greenAccent,
                        ),
                      ),
                    ] else if (isFailed) ...[
                      const Icon(
                        Icons.error_outline_rounded,
                        color: Colors.redAccent,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'خطا در دانلود: ${task.error ?? 'ناشناخته'}',
                        style: GoogleFonts.vazirmatn(
                          fontSize: 11,
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isCompleted) ...[
                ElevatedButton.icon(
                  onPressed: () {
                    if (!File(task.localPath).existsSync()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'فایل ویدیو روی حافظه دستگاه یافت نشد.',
                            style: GoogleFonts.vazirmatn(),
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }
                    Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(
                        builder: (context) => VideoPlayerScreen(
                          videoUrl: task.localPath,
                          title: '${task.title} (آفلاین)',
                          mediaItem: task.mediaItem,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.play_arrow_rounded, size: 18),
                  label: Text(
                    'پخش آفلاین',
                    style: GoogleFonts.vazirmatn(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandRed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded),
                  color: AppColors.textMuted,
                  tooltip: 'حذف فایل',
                  onPressed: () => _confirmDelete(context, provider, task),
                ),
              ] else if (isDownloading) ...[
                IconButton(
                  icon: const Icon(Icons.pause_circle_filled_rounded),
                  color: Colors.amberAccent,
                  iconSize: 28,
                  tooltip: 'توقف موقت',
                  onPressed: () => provider.pauseDownload(task.id),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  color: AppColors.textMuted,
                  tooltip: 'انصراف',
                  onPressed: () => provider.cancelDownload(task.id),
                ),
              ] else if (isPaused) ...[
                IconButton(
                  icon: const Icon(Icons.play_circle_fill_rounded),
                  color: AppColors.brandRed,
                  iconSize: 28,
                  tooltip: 'ادامه دانلود',
                  onPressed: () => provider.resumeDownload(task.id),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded),
                  color: AppColors.textMuted,
                  tooltip: 'حذف',
                  onPressed: () => provider.cancelDownload(task.id),
                ),
              ] else if (isFailed) ...[
                IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  color: Colors.white70,
                  tooltip: 'تلاش مجدد',
                  onPressed: () => provider.resumeDownload(task.id),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded),
                  color: AppColors.textMuted,
                  tooltip: 'حذف',
                  onPressed: () => provider.cancelDownload(task.id),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    DownloadProvider provider,
    DownloadTask task,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'حذف دانلود',
          style: GoogleFonts.vazirmatn(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        content: Text(
          'آیا از حذف فایل دانلود شده «${task.title}» مطمئن هستید؟',
          style: GoogleFonts.vazirmatn(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'انصراف',
              style: GoogleFonts.vazirmatn(color: Colors.white60),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              provider.deleteDownload(task.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'حذف فایل',
              style: GoogleFonts.vazirmatn(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
