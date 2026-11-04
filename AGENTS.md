# AGENTS.md — AI Agent Operating Guide for CCloud+

This document provides operational context, coding conventions, architectural invariants, and verification steps for AI coding assistants (Claude Code, Cursor, Antigravity, Copilot Workspace) working on this codebase.

---

## 1. Project Identity & Architecture
- **App Name**: `CCloud+` (`CCloud Plus`)
- **Package / Binary Identifier**: `ccloud_plus`
- **Bundle ID**: `com.farshidrezaei.ccloud_plus` (macOS: `com.farshidrezaei.ccloudPlus`)
- **Upstream Origin**: Forked and modernized from `code3-dev/CCloud-GUI` by Hossein Pira. Maintain respectful attribution in UI and docs.
- **State Management**: `provider` pattern (`ChangeNotifier`). Avoid introducing secondary reactive frameworks (Bloc, Riverpod) unless explicitly requested.
- **Routing**: `go_router` declared in `lib/src/core/routes/app_router.dart`.
- **Media Playback**: `media_kit` with native `libmpv`. Always handle lifecycle properly (`player.dispose()`).

---

## 2. Coding Standards & Invariants

### Null Safety & Strict Typing
- 100% sound null safety.
- Keep constructors `const` where possible.
- Avoid dynamic typing; define strong DTOs in `lib/src/models/`.

### UI & Styling Invariants
- **Palette**: OLED Deep Dark background (`AppColors.scaffoldBackground = Color(0xFF090A0E)`), Brand Red (`AppColors.brandRed = Color(0xFFE50914)`), surface card (`Color(0xFF13151F)`).
- **Typography**: RTL Persian using `GoogleFonts.vazirmatn()` for body/labels and `GoogleFonts.spaceMono()` for code/numbers/stats.
- **Error Handling**: Never show raw red Dart exceptions to users. Use `AppErrorHandler.handle(error)` and `ErrorRetryView`.

### Download Service Invariants
- The downloader uses chunked HTTP `Range` requests.
- Persistence is handled via `StorageUtils` (`downloads.json` and `watched_episodes.json`).
- Downloads are stored in user documents or custom download paths (`~/Downloads/CCloudPlus`).

---

## 3. Developer Workflow & Quality Gates

Run these verification commands before submitting code:
```bash
# 1. Format code strictly
dart format .

# 2. Static analysis (zero warnings, zero errors)
flutter analyze --fatal-infos

# 3. Regenerate icons when assets/logo.png changes
dart run generate_icons.dart
```

---

## 4. Platform Specifics

- **Linux**: Requires `libmpv-dev`, `libgtk-3-dev`, `libayatana-appindicator3-dev`.
- **Windows**: Uses Inno Setup script `windows/installer/CCloud.iss`. Binary output: `ccloud_plus.exe`.
- **macOS**: Bundle name: `ccloud_plus.app`. Supports Universal (ARM64 + x86_64).
