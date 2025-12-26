# 🎬 Halal Player

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.38-blue?logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/Platform-Windows-0078D6?logo=windows" alt="Windows">
  <img src="https://img.shields.io/badge/License-MIT-green" alt="License">
  <img src="https://img.shields.io/badge/AI-Powered-orange" alt="AI">
</p>

> **Privacy-first media player with AI content filtering for Islamic compliance**

Halal Player is a Flutter Desktop application that protects you and your family from inappropriate content using on-device AI filtering. All processing happens locally - your media never leaves your device.

---

## ✨ Features

### 🛡️ AI Content Protection
- **5 Filtering Modes**: Strict Islamic, Family, Teen, Educational, Developer
- **On-Device AI**: NSFW detection using OpenNSFW2 & NudeNet
- **Real-time Analysis**: Frame-by-frame video scanning
- **Blur/Block Actions**: Configurable content handling

### 🎥 Media Players
- **Video Player**: Powered by media_kit with full controls
- **Audio Player**: just_audio with waveform visualization
- **Image Viewer**: AI-scanned before display with zoom/pan

### 🌍 Translation System
- **15 Languages**: EN, AR, FR, DE, ES, TR, ID, MS, UR, FA, BN, ZH, JA, RU, HI
- **RTL Support**: Arabic, Urdu, Persian
- **Auto Subtitles**: SRT, VTT, ASS format support
- **OpenSubtitles**: Auto-download by movie hash
- **AI Translation**: Whisper STT + Argos Translate (offline)

### 🎨 Modern UI
- **Material 3 Design**: Beautiful dark/light themes
- **Keyboard Shortcuts**: Full media control
- **Recent Files**: Persistent history

---

## 📸 Screenshots

*Coming soon*

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.7+
- Windows 10/11
- Visual Studio with C++ tools

### Installation

```bash
# Clone the repository
git clone https://github.com/ahmedfawzyjr/Halal-Player.git
cd Halal-Player

# Install dependencies
flutter pub get

# Run the app
flutter run -d windows
```

### Build Release

```bash
flutter build windows --release
```

---

## 📂 Project Structure

```
lib/
├── main.dart              # App entry point
├── providers.dart         # Riverpod state management
├── core/
│   ├── config.dart        # Filter modes & settings
│   ├── policy_engine.dart # AI decision engine
│   ├── ai_gateway.dart    # AI model interface
│   ├── theme.dart         # Light/Dark themes
│   ├── language_provider.dart
│   ├── recent_files.dart
│   └── keyboard_shortcuts.dart
├── modules/
│   ├── video_player/      # Video with AI overlay
│   ├── audio_player/      # Audio with waveform
│   ├── image_viewer/      # Image with AI scan
│   ├── subtitles/         # SRT/VTT parser & OpenSubtitles
│   └── translation/       # Whisper & Argos
├── ai/
│   ├── frame_analyzer.dart
│   ├── image_analyzer.dart
│   └── ui/blur_block_widgets.dart
├── ui/
│   ├── home/
│   ├── settings/
│   └── logs/
└── l10n/                  # 15 language files
```

---

## 🔧 Configuration

### AI Models (Optional)
Download and place in `assets/models/`:
- `nsfw.onnx` - OpenNSFW2 model
- `nudenet.onnx` - NudeNet model

### Whisper STT (Optional)
Install for auto-generated subtitles:
```bash
pip install openai-whisper
```

### Argos Translate (Optional)
Install for offline translation:
```bash
pip install argostranslate
```

---

## 🔒 Privacy

- ✅ **100% Offline** - All AI runs locally
- ✅ **No Cloud** - Your media never leaves your device
- ✅ **No Tracking** - Zero analytics or telemetry
- ✅ **Open Source** - Fully auditable code

---

## 🤝 Contributing

Contributions are welcome! Please read our contributing guidelines first.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- [Flutter](https://flutter.dev) - UI framework
- [media_kit](https://github.com/media-kit/media-kit) - Video player
- [OpenSubtitles](https://opensubtitles.com) - Subtitle database
- [OpenAI Whisper](https://github.com/openai/whisper) - Speech-to-text
- [Argos Translate](https://github.com/argosopentech/argos-translate) - Offline translation

---

<p align="center">
  Made with ❤️ for the Muslim community
</p>
