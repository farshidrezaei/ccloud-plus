# Frequently Asked Questions (FAQ) & Troubleshooting

Common questions and troubleshooting tips for CCloud+.

---

### 1. The app shows "HandshakeException: Connection terminated during handshake" or connection errors. What should I do?
This is typically caused by ISP filtering or DNS interference in Iran.
- Open the built-in **DNS Bypass** sheet (available via the error card or Settings).
- Configure your system DNS to **Shecan** (`178.22.122.100`, `185.51.200.2`), **Electro** (`78.157.42.100`, `78.157.42.101`), or **403.online** (`10.202.10.202`, `10.202.10.102`).
- Use the live ping test inside the app to verify latency and connectivity.

---

### 2. On Windows, the application crashes on launch or says a `.dll` is missing.
Install the official [Microsoft Visual C++ 2015-2022 Redistributable](https://learn.microsoft.com/en-US/cpp/windows/latest-supported-vc-redist). This provides the C runtime libraries required by MPV and Flutter desktop plugins.

---

### 3. On Linux, video does not play or shows an MPV error.
Ensure `mpv` and its development libraries are installed:
```bash
sudo apt-get install libmpv1 libmpv2 mpv
```

---

### 4. Where are downloaded movies and series stored?
Downloaded media is stored in your user's Downloads directory:
- **Linux**: `~/Downloads/CCloudPlus/`
- **Windows**: `C:\Users\<User>\Downloads\CCloudPlus\`
- **macOS**: `~/Downloads/CCloudPlus/`

You can play downloaded files offline directly within the app's **Downloads** tab.

---

### 5. Subtitles are out of sync with the video. How do I fix it?
While playing a video, click the **Subtitle Settings** icon on the bottom control bar:
- Use the quick delay tuner buttons (`-1.0s`, `-0.5s`, `-0.1s`, `+0.1s`, `+0.5s`, `+1.0s`) or keyboard shortcuts (`[` and `]`) to sync subtitle timing in real-time.
- If you have an external subtitle file (`.srt` or `.vtt`), click **Load Local Subtitle** to select it directly from your computer.

---

### 6. What is the relationship between CCloud+ and CCloud-GUI?
**CCloud+ (CCloud Plus)** is an independent, modernized fork of the original [CCloud-GUI](https://github.com/code3-dev/CCloud-GUI) created by **Hossein Pira ([@code3-dev](https://github.com/code3-dev))**. CCloud+ introduces modern architecture, native downloads, PiP player, advanced filters, subtitle sync, and new design aesthetics while honoring and respecting the upstream foundation.
