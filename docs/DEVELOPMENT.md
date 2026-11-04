# Development & Contributing Guide

Guide for setting up your local environment, debugging, and building CCloud+ across all supported desktop platforms.

---

## 💻 Environment Setup

### 1. Flutter SDK
Install Flutter 3.24 or newer:
```bash
flutter --version
dart --version
```

### 2. Linux Development Setup
Install required C/C++ compilation tools and multimedia libraries:
```bash
# Ubuntu / Debian
sudo apt-get update
sudo apt-get install -y clang cmake ninja-build pkg-config \
  libgtk-3-dev liblzma-dev libmpv-dev mpv libepoxy-dev \
  librsvg2-dev libgirepository1.0-dev libayatana-appindicator3-dev
```

### 3. Windows Development Setup
- Install Visual Studio 2022 with **Desktop development with C++** workload.
- Install [Inno Setup 6](https://jrsoftware.org/isdl.php) (or via `choco install innosetup`).

### 4. macOS Development Setup
- Install Xcode and Xcode Command Line Tools:
  ```bash
  xcode-select --install
  ```

---

## 🏃 Running the Application

```bash
# Get Flutter dependencies
flutter pub get

# Run on Linux
flutter run -d linux

# Run on Windows
flutter run -d windows

# Run on macOS
flutter run -d macos
```

---

## 🧪 Testing & Code Quality Gates

Always run formatting and static analysis before submitting pull requests:
```bash
# Verify formatting
dart format --output=none --set-exit-if-changed .

# Auto-format
dart format .

# Static analysis
flutter analyze --fatal-infos
```

---

## 🎨 Asset & Icon Generation

If you replace `assets/logo.png`, regenerate platform icons automatically:
```bash
dart run generate_icons.dart
```
This updates:
- Linux icons in `linux/assets/`
- Windows icon in `windows/runner/resources/app_icon.ico`
- macOS icon in `macos/Runner/Assets.xcassets/AppIcon.appiconset/`

---

## 📦 Building Production Binaries Locally

### Linux
```bash
flutter build linux --release
# Bundle output: build/linux/x64/release/bundle/
```

### Windows
```bash
flutter build windows --release
# Executable output: build/windows/x64/runner/Release/
```

### macOS
```bash
flutter build macos --release --no-tree-shake-icons
# App bundle output: build/macos/Build/Products/Release/ccloud_plus.app
```
