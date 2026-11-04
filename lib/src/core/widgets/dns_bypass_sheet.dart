import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class DnsServerInfo {
  final String name;
  final String primaryIp;
  final String secondaryIp;
  final String description;
  final String tag;

  const DnsServerInfo({
    required this.name,
    required this.primaryIp,
    required this.secondaryIp,
    required this.description,
    required this.tag,
  });
}

class DnsBypassSheet extends StatefulWidget {
  const DnsBypassSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF13151F),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const DnsBypassSheet(),
    );
  }

  @override
  State<DnsBypassSheet> createState() => _DnsBypassSheetState();
}

class _DnsBypassSheetState extends State<DnsBypassSheet> {
  static const List<DnsServerInfo> _dnsList = [
    DnsServerInfo(
      name: 'شکن (Shecan)',
      primaryIp: '178.22.122.100',
      secondaryIp: '185.51.200.2',
      description: 'محبوب‌ترین سامانه تحریم‌شکن ایرانی با پایداری بالا',
      tag: 'پیشنهادی',
    ),
    DnsServerInfo(
      name: '۴۰۳ آنلاین (403.online)',
      primaryIp: '10.202.10.202',
      secondaryIp: '10.202.10.102',
      description: 'سامانه رسمی عبور از تحریم‌های اینترنتی با سرعت بالا',
      tag: 'سرعت بالا',
    ),
    DnsServerInfo(
      name: 'الکترو (Electro)',
      primaryIp: '78.157.42.101',
      secondaryIp: '78.157.42.100',
      description: 'دی‌ان‌اس اختصاصی جهت استریم و دانلود محتوا بدون قطعی',
      tag: 'استریم',
    ),
    DnsServerInfo(
      name: 'رادار بازی (Radar Game)',
      primaryIp: '10.202.10.10',
      secondaryIp: '10.202.10.11',
      description: 'کاهش پینگ و رفع انسداد سرورهای دانلود و استریم',
      tag: 'پینگ پایین',
    ),
    DnsServerInfo(
      name: 'کلودفلر (Cloudflare)',
      primaryIp: '1.1.1.1',
      secondaryIp: '1.0.0.1',
      description: 'دی‌ان‌اس بین‌المللی با بالاترین امنیت و سرعت جهانی',
      tag: 'جهانی',
    ),
  ];

  String? _testResult;
  bool _isTesting = false;

  Future<void> _testConnection() async {
    setState(() {
      _isTesting = true;
      _testResult = null;
    });

    final stopwatch = Stopwatch()..start();
    try {
      final client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 4);
      final req = await client.getUrl(
        Uri.parse('https://server-hi-speed-iran.info/api/status'),
      );
      final res = await req.close();
      stopwatch.stop();

      setState(() {
        _isTesting = false;
        _testResult =
            'اتصال به سرور برقرار است (کد ${res.statusCode} - پینگ: ${stopwatch.elapsedMilliseconds}ms)';
      });
    } catch (e) {
      stopwatch.stop();
      setState(() {
        _isTesting = false;
        _testResult = 'ارتباط مسدود است؛ تنظیم DNS یا فیلترشکن را تغییر دهید.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
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
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.brandRed.withValues(alpha: 0.15),
                        ),
                        child: const Icon(
                          Icons.security_rounded,
                          color: AppColors.brandRed,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'راهنمای رفع تحریم و دی‌ان‌اس (DNS)',
                            style: GoogleFonts.vazirmatn(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'حل مشکل قطع Handshake و کندی لود سرورها',
                            style: GoogleFonts.vazirmatn(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
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

              // Connection test banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B1E2B),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'تست وضعیت ارتباط سرور مرکزی',
                            style: GoogleFonts.vazirmatn(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _testResult ??
                                'جهت اطمینان از رفع انسداد، دکمه تست را بزنید',
                            style: GoogleFonts.vazirmatn(
                              fontSize: 11,
                              color: _testResult != null
                                  ? (_testResult!.contains('برقرار')
                                        ? Colors.greenAccent
                                        : Colors.redAccent)
                                  : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _isTesting ? null : _testConnection,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.surfacePill,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isTesting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              'بررسی اتصال',
                              style: GoogleFonts.vazirmatn(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Text(
                'سرورهای DNS تحریم‌شکن پیشنهادی (یک کلیک جهت کپی):',
                style: GoogleFonts.vazirmatn(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 12),

              ..._dnsList.map((dns) => _buildDnsCard(context, dns)),

              const SizedBox(height: 16),
              // Linux Terminal Quick Config
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.terminal_rounded,
                      color: AppColors.imdbGold,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'دستور سریع لینوکس: nmcli dev show | grep DNS',
                        style: GoogleFonts.spaceMono(
                          fontSize: 11,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Clipboard.setData(
                          const ClipboardData(
                            text: 'nmcli dev show | grep DNS',
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'دستور ترمینال کپی شد',
                              style: GoogleFonts.vazirmatn(),
                            ),
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      child: const Icon(
                        Icons.copy_rounded,
                        size: 16,
                        color: AppColors.brandRed,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDnsCard(BuildContext context, DnsServerInfo dns) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.glassBorder, width: 0.8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      dns.name,
                      style: GoogleFonts.vazirmatn(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.brandRed.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        dns.tag,
                        style: GoogleFonts.vazirmatn(
                          fontSize: 10,
                          color: AppColors.brandRed,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  dns.description,
                  style: GoogleFonts.vazirmatn(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      'Primary: ${dns.primaryIp}   •   Secondary: ${dns.secondaryIp}',
                      style: GoogleFonts.spaceMono(
                        fontSize: 11,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy_rounded, size: 18),
            color: AppColors.brandRed,
            tooltip: 'کپی آدرس دی‌ان‌اس',
            onPressed: () {
              Clipboard.setData(
                ClipboardData(text: '${dns.primaryIp}, ${dns.secondaryIp}'),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'آدرس دی‌ان‌اس «${dns.name}» کپی شد: ${dns.primaryIp}',
                    style: GoogleFonts.vazirmatn(),
                  ),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
