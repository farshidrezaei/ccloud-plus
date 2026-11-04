import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';

class AppError {
  final String title;
  final String message;
  final String suggestion;
  final IconData icon;
  final String rawError;

  const AppError({
    required this.title,
    required this.message,
    required this.suggestion,
    required this.icon,
    required this.rawError,
  });
}

class AppErrorHandler {
  static AppError parse(Object? error) {
    if (error == null) {
      return const AppError(
        title: 'خطای نامشخص',
        message: 'خطایی رخ داده است.',
        suggestion: 'لطفاً دوباره تلاش کنید.',
        icon: Icons.error_outline_rounded,
        rawError: '',
      );
    }

    final raw = error.toString();
    final lower = raw.toLowerCase();

    // SSL / TLS / Handshake
    if (error is HandshakeException ||
        error is TlsException ||
        lower.contains('handshake') ||
        lower.contains('certificate') ||
        lower.contains('tls') ||
        lower.contains('ssl')) {
      return AppError(
        title: 'خطا در ارتباط امن با سرور',
        message:
            'ارتباط رمزنگاری‌شده (SSL/TLS) با سرور به درستی برقرار نشد. سرورهای محتوای داخلی معمولاً به دلیل فیلترشکن فعال یا تداخل پروکسی دچار این اختلال می‌شوند.',
        suggestion:
            'فیلترشکن (VPN) خود را روی حالت Bypass Iran بگذارید یا موقتاً آن را قطع کنید.',
        icon: Icons.vpn_lock_rounded,
        rawError: raw,
      );
    }

    // Network / Socket / Offline / DNS
    if (error is SocketException ||
        lower.contains('socketexception') ||
        lower.contains('failed host lookup') ||
        lower.contains('network is unreachable') ||
        lower.contains('connection refused') ||
        lower.contains('no route to host')) {
      return AppError(
        title: 'عدم دسترسی به شبکه یا سرور',
        message:
            'امکان برقراری تماس با سرور وجود ندارد. اینترنت شما قطع است یا دامنه سرور مسدود شده است.',
        suggestion:
            'اتصال اینترنت (مودم یا Wi-Fi) را بررسی کنید و از وصل بودن شبکه مطمئن شوید.',
        icon: Icons.wifi_off_rounded,
        rawError: raw,
      );
    }

    // Timeout
    if (error is TimeoutException ||
        lower.contains('timeoutexception') ||
        lower.contains('connection timed out') ||
        lower.contains('deadline exceeded')) {
      return AppError(
        title: 'پایان مهلت پاسخگویی سرور',
        message:
            'پاسخی در زمان مقرر از سرور دریافت نشد. سرعت اینترنت کم است یا ترافیک سرور بسیار بالاست.',
        suggestion:
            'چند ثانیه صبر کنید و مجدداً روی دکمه «تلاش مجدد» کلیک کنید.',
        icon: Icons.timer_off_rounded,
        rawError: raw,
      );
    }

    // HTTP 5xx Server Errors
    if (lower.contains('500') ||
        lower.contains('502') ||
        lower.contains('503') ||
        lower.contains('504') ||
        lower.contains('bad gateway') ||
        lower.contains('service unavailable')) {
      return AppError(
        title: 'اختلال در سرور محتوا',
        message:
            'سرور مرکزی ارائه‌دهنده فیلم‌ها با مشکل فنی موقت مواجه شده است.',
        suggestion:
            'این مشکل از سمت دستگاه شما نیست. دقایقی دیگر دوباره وارد برنامه شوید.',
        icon: Icons.dns_rounded,
        rawError: raw,
      );
    }

    // HTTP 403 / 401 Access Denied / Cloudflare
    if (lower.contains('403') ||
        lower.contains('forbidden') ||
        lower.contains('access denied')) {
      return AppError(
        title: 'دسترسی محدود شده است',
        message:
            'سرور دسترسی آی‌پی یا درخواست را مسدود کرده است (سیاست‌های ضدروبات یا تحریم).',
        suggestion: 'آی‌پی یا فیلترشکن خود را تغییر دهید و دوباره تلاش کنید.',
        icon: Icons.shield_outlined,
        rawError: raw,
      );
    }

    // Clean any "Exception: " prefix for cleaner display
    String cleanMessage = raw;
    if (cleanMessage.startsWith('Exception: ')) {
      cleanMessage = cleanMessage.substring('Exception: '.length);
    }

    return AppError(
      title: 'خطا در بارگذاری محتوا',
      message: cleanMessage.length > 120
          ? 'در برقراری ارتباط با سرور خطای غیرمنتظره‌ای رخ داده است.'
          : cleanMessage,
      suggestion: 'لطفاً وضعیت اتصال شبکه را بررسی کرده و دوباره تلاش کنید.',
      icon: Icons.cloud_off_rounded,
      rawError: raw,
    );
  }
}
