# 🎬 Halal Player

<p align="center">
  <img src="assets/img/logo.png" alt="Halal Player Logo" width="200">
</p>

<p align="center">
  <strong>Privacy-first media player with AI content filtering for Islamic compliance</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.38-blue?logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/Platform-Windows-0078D6?logo=windows" alt="Windows">
  <img src="https://img.shields.io/badge/License-MIT-green" alt="License">
  <img src="https://img.shields.io/badge/AI-Powered-orange" alt="AI">
</p>

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

## 🎨 Brand Colors

| Color | Hex | Usage |
|-------|-----|-------|
| 🟢 Primary Green | `#4CAF50` | Buttons, accents, safe indicators |
| ⬛ Dark Background | `#1A1A1A` | Main background (dark mode) |
| 🔲 Dark Surface | `#2A2A2A` | Cards, panels |
| ⬜ Light Background | `#F5F5F5` | Main background (light mode) |
| ⚪ Light Surface | `#FFFFFF` | Cards, panels (light mode) |

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
├── core/                  # Config, themes, engine
├── modules/               # Video, audio, subtitles, translation
├── ai/                    # Frame & image analyzers
├── ui/                    # Home, settings, logs screens
└── l10n/                  # 15 language files

assets/
├── img/                   # Logo and branding
├── models/                # AI models (ONNX)
└── icons/                 # App icons
```

---

## 🔧 Configuration

### AI Models (Optional)
Download and place in `assets/models/`:
- `nsfw.onnx` - OpenNSFW2 model
- `nudenet.onnx` - NudeNet model

### Whisper STT (Optional)
```bash
pip install openai-whisper
```

### Argos Translate (Optional)
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

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

MIT License - see [LICENSE](LICENSE) for details.

---

## 🙏 Acknowledgments

- [Flutter](https://flutter.dev)
- [media_kit](https://github.com/media-kit/media-kit)
- [OpenSubtitles](https://opensubtitles.com)
- [OpenAI Whisper](https://github.com/openai/whisper)

---

<p align="center">
  <img src="assets/img/logo-icon.png" alt="Halal Player Icon" width="64">
  <br>
  Made with ❤️ for the Muslim community
</p>
