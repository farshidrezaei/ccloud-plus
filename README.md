<p align="center">
  <img src="assets/logo.png" alt="CCloud+ Logo" width="160">
</p>

<h1 align="center">CCloud+ (CCloud Plus)</h1>

<p align="center">
  <b>A modernized, high-performance, cinematic desktop streaming and download powerhouse for movies and series with Persian subtitles and dubbed audio.</b>
</p>

<p align="center">
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter"></a>
  <a href="https://dart.dev"><img src="https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart"></a>
  <img src="https://img.shields.io/badge/Platform-Linux%20%7C%20Windows%20%7C%20macOS-blue?style=for-the-badge" alt="Cross-Platform">
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-red.svg?style=for-the-badge" alt="License: MIT"></a>
  <a href="https://github.com/code3-dev/CCloud-GUI"><img src="https://img.shields.io/badge/Forked%20From-CCloud--GUI-purple?style=for-the-badge&logo=github" alt="Upstream CCloud-GUI"></a>
</p>

---

## 📖 Table of Contents

- [🌟 Upstream Attribution & Heartfelt Gratitude](#-upstream-attribution--heartfelt-gratitude)
- [✨ Why CCloud+? (Feature Comparison)](#-why-ccloud-feature-comparison)
- [🚀 Key Features](#-key-features)
  - [1. 🎨 Cinevex OLED Theme & Fluid Interface](#1--cinevex-oled-theme--fluid-interface)
  - [2. 🎠 Featured Hero Spotlight Carousel](#2--featured-hero-spotlight-carousel)
  - [3. 📥 Native Chunked Download Manager & Offline Playback](#3--native-chunked-download-manager--offline-playback)
  - [4. 🪟 Picture-in-Picture (PiP) Floating Mini-Player](#4--picture-in-picture-pip-floating-mini-player)
  - [5. ⏱️ Live Subtitle Syncer & Custom Subtitle Loader](#5-️-live-subtitle-syncer--custom-subtitle-loader)
  - [6. 🍿 Binge-Watcher Tracker & Auto-Next Countdown](#6--binge-watcher-tracker--auto-next-countdown)
  - [7. 👁️ Quick Preview Hover Modal](#7-️-quick-preview-hover-modal)
  - [8. 🎛️ Advanced Multi-Filter & Sorter](#8-️-advanced-multi-filter--sorter)
  - [9. 🛡️ Smart Error Diagnosis & Anti-Sanction DNS Bypass](#9-️-smart-error-diagnosis--anti-sanction-dns-bypass)
- [⌨️ Desktop Keyboard Shortcuts](#-desktop-keyboard-shortcuts)
- [💻 System Requirements](#-system-requirements)
- [📦 Installation & Releases](#-installation--releases)
- [🛠️ Building from Source](#️-building-from-source)
- [📂 Project Architecture](#-project-architecture)
- [🤝 Contributing](#-contributing)
- [📄 License & Credits](#-license--credits)

---

## 🌟 Upstream Attribution & Heartfelt Gratitude

> ### 💖 Standing on the Shoulders of Giants
> 
> **CCloud+ (CCloud Plus)** is an independent, advanced evolution built upon the remarkable open-source foundation of [**CCloud-GUI**](https://github.com/code3-dev/CCloud-GUI), originally crafted by [**Hossein Pira (code3-dev)**](https://github.com/code3-dev).
> 
> We extend our deepest respect, admiration, and gratitude to **Hossein Pira** and all original contributors for their vision and dedication to open-source software for the Persian community. CCloud+ preserves this open spirit while pushing the boundaries of desktop streaming performance, usability, and design.

---

## ✨ Why CCloud+? (Feature Comparison)

| Capability / Feature | Original CCloud-GUI | CCloud+ (Plus) 🎬 |
|:---|:---:|:---:|
| **Design System** | Clean Classic Layout | **Cinevex Glassmorphic OLED UI** |
| **Hero Spotlight Carousel** | ❌ | **✅ Auto-rotating 7s cinematic spotlight** |
| **Download Manager** | Browser Redirect Only | **✅ Native chunked range downloader + live ETA/speed** |
| **Offline Playback** | ❌ | **✅ Play downloaded movies & series offline directly** |
| **Floating Mini-Player (PiP)** | ❌ | **✅ Dockable player with 0-rebuffering restore** |
| **Live Subtitle Tuner** | ❌ | **✅ Real-time ±1.0s sync + custom external file loader** |
| **Binge Tracker & Auto-Next** | ❌ | **✅ Watched badges + 15s auto-next countdown banner** |
| **Quick Peek Modal** | ❌ | **✅ Instant hover/right-click metadata preview** |
| **Multi-Filter Drawer** | Basic Sort | **✅ IMDb slider, decade range, dubbed/subbed filters** |
| **Network Error Handling** | Raw exception messages | **✅ Persian diagnostic cards + anti-sanction DNS switcher** |

---

## 🚀 Key Features

### 1. 🎨 Cinevex OLED Theme & Fluid Interface
- **True Black Aesthetic**: OLED `#090A0E` background with `#E50914` signature Netflix-inspired red accents.
- **Glassmorphic Navigation**: Frosted glass sidebars, glowing pill badges, and RTL Persian typography optimized with Google Fonts (Vazirmatn & Space Mono).
- **Responsive Fluid Layout**: Adaptive grids scaling effortlessly from 13-inch ultrabooks to 4K ultra-wide monitors.

### 2. 🎠 Featured Hero Spotlight Carousel
- Smooth auto-sliding banner highlighting top trending movies and series.
- Cinema vignette backdrop with backdrop image caching, live IMDb badges, genres, story plot, and direct play/detail action triggers.

### 3. 📥 Native Chunked Download Manager & Offline Playback
- **Pause & Resume**: Multi-threaded chunked downloads using HTTP `Range` headers.
- **Live Diagnostics**: Real-time download speed calculation (MB/s), downloaded size, and estimated time of completion (ETA).
- **Offline Playback**: Watch any downloaded title directly in the app player without requiring an active internet connection.
- **Badge Indicators**: Dynamic download count badges on the navigation sidebar.

### 4. 🪟 Picture-in-Picture (PiP) Floating Mini-Player
- Multitask without missing a second of playback.
- Dockable bottom-corner mini-player with smooth hover controls (Play/Pause, Fullscreen Restore, and Dismiss).
- **Zero Buffering**: Seamless transition back to fullscreen with continuous audio/video playback state.

### 5. ⏱️ Live Subtitle Syncer & Custom Subtitle Loader
- **Live Delay Adjuster**: Tuner buttons (`-1.0s`, `-0.5s`, `-0.1s`, `+0.1s`, `+0.5s`, `+1.0s`) hooked directly into the MPV rendering pipeline.
- **External Subtitle Import**: Load local `.srt`, `.vtt`, `.ass`, or `.sub` files via file picker dialog.
- **Dual Audio Switcher**: Instant switching between Persian dubbed tracks and original voice tracks.

### 6. 🍿 Binge-Watcher Tracker & Auto-Next Countdown
- **Persistent Episode Checkmarks**: Automatically marks episodes as watched once completed.
- **End-of-Episode Countdown**: Non-intrusive floating countdown banner during the last 15 seconds of an episode to automatically launch the next episode.

### 7. 👁️ Quick Preview Hover Modal
- Right-click or hover over any media card to peek at backdrops, ratings, release years, and synopses without losing your browsing scroll position.

### 8. 🎛️ Advanced Multi-Filter & Sorter
- **IMDb Rating Range**: Slider filtering content by minimum rating threshold (0.0 to 9.0+).
- **Release Era**: Multi-select filter for recent releases (2024+), 2020-2023, 2010-2019, or classic cinema.
- **Audio & Subtitle Filter**: Isolate dubbed content from subbed content in one click.

### 9. 🛡️ Smart Error Diagnosis & Anti-Sanction DNS Bypass
- **Friendly Persian Error Views**: Translates cryptic TLS/SSL handshake, socket, and proxy exceptions into clear explanations with guided solutions.
- **Built-in DNS Bypass Selector**: 1-click configuration and ping latency test for Shecan, 403.online, Electro, Radar Game, and Cloudflare DNS.

---

## ⌨️ Desktop Keyboard Shortcuts

| Shortcut | Description |
|:---:|:---|
| <kbd>Space</kbd> / <kbd>K</kbd> | Play / Pause toggle |
| <kbd>F</kbd> | Toggle Fullscreen mode |
| <kbd>Esc</kbd> | Exit Fullscreen / Close modal / Back |
| <kbd>J</kbd> / <kbd>←</kbd> | Seek backward 10 seconds |
| <kbd>L</kbd> / <kbd>→</kbd> | Seek forward 10 seconds |
| <kbd>↑</kbd> | Volume Up (+5%) |
| <kbd>↓</kbd> | Volume Down (-5%) |
| <kbd>M</kbd> | Mute / Unmute audio |
| <kbd>[</kbd> | Subtitle delay -0.1s |
| <kbd>]</kbd> | Subtitle delay +0.1s |

---

## 💻 System Requirements

- **Linux**: Ubuntu 20.04+, Debian 11+, Fedora 36+, Arch Linux, or any modern distribution with GTK+ 3.20+ and GLib 2.48+.
- **Windows**: Windows 10 (64-bit) or Windows 11. (Requires Microsoft Visual C++ 2015-2022 Redistributable).
- **macOS**: macOS 11 (Big Sur) or newer (Universal binary supports Apple Silicon M-series & Intel).

---

## 📦 Installation & Releases

Download pre-built binaries from GitHub Releases:

| Platform | Format | Description |
|:---|:---:|:---|
| **Windows** | `.exe` | Windows 64-bit Setup Installer |
| **Windows** | `.zip` | Portable standalone package (no install required) |
| **Linux** | `.AppImage` | Universal self-contained executable for all distros |
| **Linux** | `.deb` | Debian / Ubuntu / Mint package |
| **Linux** | `.rpm` | Fedora / RHEL / openSUSE package |
| **Linux** | `.tar.gz` | Standalone binary bundle |
| **macOS** | `.dmg` | Universal Apple Silicon & Intel Disk Image |

---

## 🛠️ Building from Source

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (>= 3.24)
- Dart SDK (>= 3.5)
- Git

### Linux System Libraries
```bash
# Ubuntu / Debian / Pop!_OS
sudo apt-get update
sudo apt-get install -y clang cmake ninja-build pkg-config \
  libgtk-3-dev liblzma-dev libmpv-dev mpv libepoxy-dev \
  librsvg2-dev libgirepository1.0-dev libayatana-appindicator3-dev
```

### Setup & Run
```bash
# 1. Clone the repository
git clone https://github.com/<your-username>/CCloud-Plus.git
cd CCloud-Plus

# 2. Install Flutter packages
flutter pub get

# 3. (Optional) Regenerate OS icons from assets/logo.png
dart run generate_icons.dart

# 4. Run application in development mode
flutter run -d linux   # or -d windows / -d macos
```

### Production Release Builds
```bash
# Linux
flutter build linux --release

# Windows
flutter build windows --release

# macOS
flutter build macos --release
```

---

## 📂 Project Architecture

```
lib/
├── main.dart                          # Application entry point & window manager init
└── src/
    ├── core/
    │   ├── config/app_config.dart     # Central configuration & branding
    │   ├── constants/app_colors.dart  # Cinevex OLED color palette
    │   ├── errors/app_error_handler.dart # Intelligent Persian error classifier
    │   ├── routes/app_router.dart     # GoRouter declaration & navigation tree
    │   └── widgets/                   # Reusable components (HeroCarousel, ErrorRetry, etc.)
    ├── models/                        # Immutable data models (Movie, Series, Episode, Task)
    ├── providers/                     # State management (Player, Download, MiniPlayer, Theme)
    ├── repositories/                  # HTTP client with timeout & caching logic
    ├── screens/                       # Presentation screens (Home, Player, Downloads, Settings)
    ├── services/                      # Background services (DownloadService, StorageUtils)
    └── widgets/                       # Shell layouts, sidebar navigation, floating mini player
```

---

## 🇮🇷 درباره پروژه CCloud Plus (راهنمای فارسی)

اپلیکیشن **CCloud+ (سی‌کلاد پلاس)** یک کلاینت مدرن، آزاد و متن‌باز برای سیستم‌عامل‌های **ویندوز (Windows)**، **لینوکس (Linux)** و **مک (macOS)** است که امکان جستجو، تماشا و دانلود هزاران فیلم و سریال روز دنیا با **زیرنویس فارسی هماهنگ** و **صوت دوبله فارسی** را با بالاترین کیفیت ممکن فراهم می‌کند.

### 🌟 ویژگی‌های برجسته:
- **دانلود منیجر چندبخشی داخلی**: دانلود فایل‌ها با پشتیبانی از توقف و ادامه (Resume)، محاسبه دقیق سرعت و زمان پایان، و امکان پخش آفلاین بدون نیاز به اینترنت.
- **پخش‌کننده تصویر-در-تصویر (PiP شناور)**: امکان کوچک کردن پلیر در گوشه صفحه و ادامه‌ی وبگردی با حفظ پخش بدون بافرینگ.
- **تنظیم‌کننده زنده زیرنویس**: همگام‌سازی لحظه‌ای زیرنویس (تأخیر و تقدم صدم ثانیه‌ای) و امکان انتخاب فایل زیرنویس دلخواه از روی هارد.
- **سامانه ضدتحریم داخلی**: دور زدن خودکار خطاهای شبکه و تغییر سریع به دی‌ان‌اس‌های شکن، الکترو، ۴۰۳ و رادار به همراه تست پینگ زنده.
- **رابط کاربری سینمایی OLED**: تم فوق‌العاده تاریک با گرادیان‌های جذاب و فونت زیبای وزیرمتن.

---

## 🔍 Tags & Keywords (SEO)

`ccloud` • `ccloud-plus` • `ccloud-gui` • `flutter-desktop` • `movie-streaming-desktop` • `persian-subtitles` • `farsi-dubbed` • `iran-streaming` • `mpv-player` • `download-manager` • `offline-playback` • `picture-in-picture` • `linux-streaming-app` • `windows-movie-app` • `macos-media-player` • `استریم-فیلم` • `دانلود-سریال` • `زیرنویس-فارسی` • `سی‌کلاد`

---

## 🤝 Contributing

Contributions, feedback, and suggestions are warmly welcomed!
1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'feat: Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License & Credits

- Licensed under the **[MIT License](LICENSE)**.
- Original project foundation: [CCloud-GUI](https://github.com/code3-dev/CCloud-GUI) by [**Hossein Pira**](https://github.com/code3-dev).
- Maintained and modernized with ❤️ by [**Farshid Rezaei**](https://github.com/farshidrezaei).
