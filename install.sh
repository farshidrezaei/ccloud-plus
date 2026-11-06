#!/bin/bash
set -e

# ==============================================================================
# CCloud+ Universal Linux Installer & Updater
# Supported: Arch Linux, Manjaro, Ubuntu, Debian, Fedora, openSUSE
# ==============================================================================

BOLD='\033[1m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${CYAN}${BOLD}"
echo "  🎬 CCloud+ (CCloud Plus) Linux Installer & Updater"
echo "  ===================================================="
echo -e "${NC}"

INSTALL_DIR="$HOME/.local/share/ccloud_plus"
BIN_DIR="$HOME/.local/bin"
DESKTOP_DIR="$HOME/.local/share/applications"
ICON_DIR="$HOME/.local/share/icons/hicolor/512x512/apps"

mkdir -p "$INSTALL_DIR" "$BIN_DIR" "$DESKTOP_DIR" "$ICON_DIR"

echo -e "🔍 دریافت آخرین اطلاعات انتشار از گیت‌هاب..."
LATEST_RELEASE=$(curl -s "https://api.github.com/repos/farshidrezaei/ccloud-plus-desktop/releases/latest")
TAG_NAME=$(echo "$LATEST_RELEASE" | grep -m1 '"tag_name":' | cut -d '"' -f 4)

if [ -z "$TAG_NAME" ]; then
    echo -e "${RED}خطا در دریافت اطلاعات نسخه از گیت‌هاب. لطفاً اتصال اینترنت را بررسی کنید.${NC}"
    exit 1
fi

APPIMAGE_URL=$(echo "$LATEST_RELEASE" | grep -o 'https://[^" ]*Linux-x86_64\.AppImage' | head -n 1)

if [ -z "$APPIMAGE_URL" ]; then
    echo -e "${RED}فایل AppImage برای نسخه $TAG_NAME یافت نشد.${NC}"
    exit 1
fi

echo -e "📦 نسخه هدف: ${BOLD}$TAG_NAME${NC}"
echo -e "⬇️  در حال دانلود $APPIMAGE_URL ..."

TARGET_FILE="$INSTALL_DIR/CCloudPlus.AppImage"
TMP_FILE="$INSTALL_DIR/CCloudPlus.AppImage.tmp"

curl -L --progress-bar "$APPIMAGE_URL" -o "$TMP_FILE"
mv "$TMP_FILE" "$TARGET_FILE"
chmod +x "$TARGET_FILE"

# Create launcher script
echo -e "⚙️  تنظیم لانچر اجرایی در $BIN_DIR/ccloud_plus ..."
cat << 'EOF' > "$BIN_DIR/ccloud_plus"
#!/bin/bash
if [ -f "$HOME/.local/share/ccloud_plus/CCloudPlus.AppImage" ]; then
    exec "$HOME/.local/share/ccloud_plus/CCloudPlus.AppImage" "$@"
else
    exec "$HOME/.local/share/ccloud_plus/bundle/ccloud_plus" "$@"
fi
EOF
chmod +x "$BIN_DIR/ccloud_plus"

# Download high-res logo if missing
if [ ! -f "$ICON_DIR/ccloud_plus.png" ]; then
    echo -e "🎨 دانلود آیکون برنامه..."
    curl -sL "https://raw.githubusercontent.com/farshidrezaei/ccloud-plus-desktop/main/assets/logo.png" -o "$ICON_DIR/ccloud_plus.png"
fi

# Create Desktop Entry
echo -e "🖥️  ثبت در منوی برنامه‌های سیستم..."
cat << EOF > "$DESKTOP_DIR/com.farshidrezaei.ccloud_plus.desktop"
[Desktop Entry]
Version=1.0
Type=Application
Name=CCloud+
GenericName=Movie & Series Streaming Client
Comment=Cinematic streaming and downloading platform with Persian subtitles and audio
Exec=$BIN_DIR/ccloud_plus %u
Icon=ccloud_plus
Terminal=false
Categories=AudioVideo;Video;Player;Network;
StartupWMClass=ccloud_plus
Keywords=ccloud;movies;series;streaming;persian;film;
EOF

chmod +x "$DESKTOP_DIR/com.farshidrezaei.ccloud_plus.desktop"

# Refresh desktop database
if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$DESKTOP_DIR" 2>/dev/null || true
fi

echo -e "${GREEN}${BOLD}"
echo "✅ نسخه $TAG_NAME برنامه CCloud+ با موفقیت نصب / بروزرسانی شد!"
echo "🚀 برای اجرا: دستور ccloud_plus را بزنید یا از منوی برنامه‌ها باز کنید."
echo -e "${NC}"
