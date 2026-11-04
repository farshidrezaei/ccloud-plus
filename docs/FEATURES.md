# CCloud+ Flagship Features Guide

Detailed overview of the 8 major features added in CCloud+:

---

## 1. 🎠 Featured Hero Spotlight Carousel
- **Component**: `FeaturedHeroCarousel` (`lib/src/core/widgets/featured_hero_carousel.dart`)
- **How it works**: Displays the top trending items with auto-advancing slides every 7 seconds. Features backdrop imagery, cinema vignette gradients, synopsis text, rating badge, and quick action buttons (*Watch Now* and *Details*).

---

## 2. 📥 Native Chunked Download Manager & Offline Playback
- **Components**: `DownloadService`, `DownloadProvider`, `DownloadsScreen`
- **Key Capabilities**:
  - **Pause & Resume**: Employs HTTP `Range` headers to continue interrupted downloads without restarting from scratch.
  - **Live Metrics**: Calculates real-time speed in MB/s, downloaded bytes, total bytes, and Estimated Time of Arrival (ETA).
  - **Offline Playback**: Downloaded titles appear in the Downloads tab and can be launched directly inside the native player without an internet connection.
  - **Sidebar Badge**: Live counter displays active downloads count.

---

## 3. 🪟 Picture-in-Picture (PiP) Floating Mini-Player
- **Components**: `MiniPlayerProvider`, `FloatingMiniPlayer`
- **How it works**: When a user navigates away or clicks minimize, the current playback session docks into a compact floating player at the bottom corner of `AppShell`.
- **Zero Buffering**: Uses the same `Player` instance; maximizing back restores fullscreen immediately without reconnecting or re-buffering.

---

## 4. ⏱️ Live Subtitle Syncer & Custom Subtitle Loader
- **Location**: Video Player Control Overlay (`lib/src/screens/video_player_screen.dart`)
- **Features**:
  - **Live Delay Tuner**: Quick buttons (`-1.0s`, `-0.5s`, `-0.1s`, `+0.1s`, `+0.5s`, `+1.0s`, and `Reset`) adjust MPV subtitle delay instantly in real-time.
  - **External Subtitle Importer**: Open local `.srt`, `.vtt`, `.ass`, or `.sub` files via file picker dialog.
  - **Dual Audio Switcher**: Toggle easily between original language audio and Persian dubbed audio.

---

## 5. 🍿 Episode Watch Tracker & Binge Auto-Next Countdown
- **Location**: `SingleSeriesScreen` & `VideoPlayerScreen`
- **Features**:
  - **Watched Checkmarks**: Automatically marks episodes as watched upon completion, stored in `StorageUtils` (`watched_episodes.json`).
  - **15-Second Countdown**: A floating toast prompt slides in during the final 15 seconds of an episode offering an auto-play timer for the next episode.

---

## 6. 👁️ Quick Preview Hover Modal
- **Component**: `MediaPreviewModal` (`lib/src/core/widgets/media_preview_modal.dart`)
- **How it works**: Hovering or right-clicking over any movie or series poster presents an instant preview card with high-resolution backdrop, IMDb rating, release year, genres, and storyline overview without navigating away.

---

## 7. 🎛️ Advanced Multi-Filter Drawer
- **Component**: `AdvancedFilterSheet` (`lib/src/core/widgets/advanced_filter_sheet.dart`)
- **Filters Available**:
  - **IMDb Rating Slider**: Filter by minimum rating (e.g. 7.5+).
  - **Release Period**: Multi-select pills for 2024+, 2020-2023, 2010-2019, or Classic.
  - **Language / Audio**: Filter dubbed vs subtitled titles.

---

## 8. 🛡️ Smart Error Handling & Anti-Sanction DNS Bypass
- **Components**: `AppErrorHandler`, `ErrorRetryView`, `DnsBypassSheet`
- **Features**:
  - **Human-Readable Error Cards**: Converts raw SSL/TLS socket handshake errors into helpful Persian explanations.
  - **DNS Preset Switcher**: Provides 1-click copy and latency ping testing for Shecan, 403.online, Electro, Radar Game, and Cloudflare.
