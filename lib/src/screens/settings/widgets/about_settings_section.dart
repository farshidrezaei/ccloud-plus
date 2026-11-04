import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/config/app_config.dart';
import '../../../core/constants/app_colors.dart';
import 'settings_section_header.dart';

class AboutSettingsSection extends StatelessWidget {
  const AboutSettingsSection({super.key});

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.asset(
                  'assets/logo.png',
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: AppColors.brandRed,
                    ),
                    child: const Icon(
                      Icons.movie_filter_rounded,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                AppConfig.appName,
                style: GoogleFonts.spaceMono(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'نسخه ${AppConfig.currentVersion}',
                style: GoogleFonts.vazirmatn(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const SettingsSectionHeader(
          title: 'درباره ${AppConfig.appFullName} (${AppConfig.appName})',
          subtitle:
              'نسخه ارتقایافته، مدرن و نامحدود برای استریم و دانلود فیلم و سریال',
        ),
        const SizedBox(height: 20),
        Text(
          'اپلیکیشن CCloud Plus (CCloud+) یک کلاینت ارتقایافته، سینمایی و قدرتمند دسکتاپ بر پایه فلاتر است که قابلیت‌های پیشرفته‌ای از جمله بنر اسلایدر، دانلود منیجر داخلی با پخش آفلاین، تصویر-در-تصویر شناور (PiP)، سینک‌کننده هوشمند زیرنویس و دی‌ان‌اس ضدتحریم را در اختیار کاربران قرار می‌دهد.',
          style: GoogleFonts.vazirmatn(fontSize: 14, height: 1.8),
        ),
        const SizedBox(height: 20),
        // Respectful Upstream Acknowledgment Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.favorite_rounded,
                    color: AppColors.brandRed,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'قدردانی و ارجاع به پروژه پایه (Upstream)',
                    style: GoogleFonts.vazirmatn(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'پروژه CCloud+ با نهایت احترام و افتخار برگرفته از پروژه منبع‌باز ارزشمند CCloud-GUI اثر تیم محترم code3-dev است. از زحمات و خلاقیت سازندگان اصلی کمال تشکر و قدردانی را داریم.',
                style: GoogleFonts.vazirmatn(
                  fontSize: 12,
                  height: 1.7,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => _launchURL(AppConfig.upstreamUrl),
                icon: const Icon(Icons.open_in_new_rounded, size: 16),
                label: Text(
                  'مشاهده ریپازیتوری اصلی CCloud-GUI',
                  style: GoogleFonts.vazirmatn(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
