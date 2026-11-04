import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../navigation/app_screens.dart';
import '../providers/download_provider.dart';

class SidebarNavigation extends StatelessWidget {
  final GoRouter router;

  const SidebarNavigation({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    final String currentRoute = GoRouterState.of(context).uri.toString();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 185,
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.sidebarBackground : Colors.white,
        border: Border(
          left: BorderSide(
            color: isDarkMode ? AppColors.glassBorder : Colors.black12,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Logo Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 28),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'assets/logo.png',
                    width: 38,
                    height: 38,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE50914), Color(0xFFB80710)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'CCLOUD+',
                  style: GoogleFonts.spaceMono(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          // Nav Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              children: AppScreen.values
                  .where((screen) => screen.showInSidebar)
                  .map((screen) {
                    final isSelected =
                        currentRoute.split('?').first == screen.route;

                    return _SidebarNavItem(
                      screen: screen,
                      isSelected: isSelected,
                      onTap: () => router.go(screen.route),
                    );
                  })
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarNavItem extends StatefulWidget {
  final AppScreen screen;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarNavItem({
    required this.screen,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_SidebarNavItem> createState() => _SidebarNavItemState();
}

class _SidebarNavItemState extends State<_SidebarNavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.isSelected;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.brandRed
                  : _isHovered
                  ? (isDarkMode
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.black.withValues(alpha: 0.04))
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              boxShadow: isSelected
                  ? const [
                      BoxShadow(
                        color: AppColors.brandRedGlow,
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  widget.screen.icon,
                  size: 20,
                  color: isSelected
                      ? Colors.white
                      : isDarkMode
                      ? AppColors.textSecondary
                      : Colors.black54,
                ),
                const SizedBox(width: 12),
                Text(
                  widget.screen.title,
                  style: GoogleFonts.vazirmatn(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : isDarkMode
                        ? AppColors.textPrimary
                        : Colors.black87,
                  ),
                ),
                if (widget.screen == AppScreen.downloads) ...[
                  const Spacer(),
                  Consumer<DownloadProvider>(
                    builder: (context, dp, _) {
                      if (dp.activeDownloadsCount == 0) {
                        return const SizedBox.shrink();
                      }
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : AppColors.brandRed,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${dp.activeDownloadsCount}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? AppColors.brandRed
                                : Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
