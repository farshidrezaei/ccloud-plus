import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../errors/app_error_handler.dart';
import 'dns_bypass_sheet.dart';

class ErrorRetryView extends StatefulWidget {
  final Object? error;
  final String? errorMessage;
  final VoidCallback onRetry;
  final String retryButtonText;

  const ErrorRetryView({
    super.key,
    this.error,
    this.errorMessage,
    required this.onRetry,
    this.retryButtonText = 'تلاش مجدد',
  });

  @override
  State<ErrorRetryView> createState() => _ErrorRetryViewState();
}

class _ErrorRetryViewState extends State<ErrorRetryView> {
  bool _showDetails = false;

  @override
  Widget build(BuildContext context) {
    final appError = AppErrorHandler.parse(widget.error ?? widget.errorMessage);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.brandRed.withValues(alpha: 0.25),
                width: 1,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 24,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Glowing Error Icon
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.brandRed.withValues(alpha: 0.12),
                    border: Border.all(
                      color: AppColors.brandRed.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.brandRedGlow,
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    appError.icon,
                    size: 34,
                    color: AppColors.brandRed,
                  ),
                ),
                const SizedBox(height: 20),

                // Friendly Title
                Text(
                  appError.title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.vazirmatn(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),

                // User-friendly Message
                Text(
                  appError.message,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.vazirmatn(
                    fontSize: 13,
                    height: 1.7,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),

                // Suggestion Tip Box
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B1E2B),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.lightbulb_outline_rounded,
                        color: AppColors.imdbGold,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          appError.suggestion,
                          style: GoogleFonts.vazirmatn(
                            fontSize: 12,
                            height: 1.5,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Actions: Retry & DNS Helper
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 10,
                  children: [
                    ElevatedButton.icon(
                      onPressed: widget.onRetry,
                      icon: const Icon(Icons.refresh_rounded, size: 20),
                      label: Text(
                        widget.retryButtonText,
                        style: GoogleFonts.vazirmatn(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brandRed,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 26,
                          vertical: 13,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        shadowColor: AppColors.brandRedGlow,
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => DnsBypassSheet.show(context),
                      icon: const Icon(Icons.shield_outlined, size: 18),
                      label: Text(
                        'رفع تحریم و تغییر DNS',
                        style: GoogleFonts.vazirmatn(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 13,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Technical details toggle
                if (appError.rawError.isNotEmpty) ...[
                  InkWell(
                    onTap: () => setState(() => _showDetails = !_showDetails),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _showDetails
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            size: 16,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _showDetails
                                ? 'مخفی کردن جزئیات فنی'
                                : 'مشاهده جزئیات فنی خطا',
                            style: GoogleFonts.vazirmatn(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_showDetails) ...[
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Log Exception:',
                                style: GoogleFonts.spaceMono(
                                  fontSize: 10,
                                  color: Colors.white38,
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Clipboard.setData(
                                    ClipboardData(text: appError.rawError),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'متن خطا کپی شد',
                                        style: GoogleFonts.vazirmatn(),
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                },
                                child: Text(
                                  'کپی متن',
                                  style: GoogleFonts.vazirmatn(
                                    fontSize: 10,
                                    color: AppColors.brandRed,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: SelectableText(
                              appError.rawError,
                              style: GoogleFonts.spaceMono(
                                fontSize: 11,
                                color: Colors.red.shade300,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
