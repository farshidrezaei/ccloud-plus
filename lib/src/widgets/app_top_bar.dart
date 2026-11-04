import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';

class AppTopBar extends StatelessWidget {
  const AppTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final currentRoute = GoRouterState.of(context).uri.toString();
    final isSearchScreen = currentRoute.startsWith('/search');

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.scaffoldBackground : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDarkMode ? AppColors.glassBorder : Colors.black12,
            width: 0.8,
          ),
        ),
      ),
      child: Row(
        children: [
          // Global Search Capsule (Centered or Leading in RTL)
          if (!isSearchScreen)
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: SizedBox(
                    height: 40,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => context.go('/search'),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? AppColors.surfacePill
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isDarkMode
                                  ? AppColors.glassBorder
                                  : Colors.black.withValues(alpha: 0.08),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.search_rounded,
                                size: 18,
                                color: isDarkMode
                                    ? AppColors.textMuted
                                    : Colors.grey.shade600,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'جستجوی فیلم، سریال، بازیگر...',
                                  style: GoogleFonts.vazirmatn(
                                    fontSize: 13,
                                    color: isDarkMode
                                        ? AppColors.textMuted
                                        : Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          else
            const Spacer(),

          const SizedBox(width: 16),

          // Notification Bell
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.surfacePill : Colors.grey.shade100,
              shape: BoxShape.circle,
              border: Border.all(
                color: isDarkMode
                    ? AppColors.glassBorder
                    : Colors.black.withValues(alpha: 0.08),
              ),
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              size: 20,
              color: isDarkMode ? AppColors.textSecondary : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
