<div align="center">

<img src="img/home (1).jpeg" width="90" alt="DROP icon" />

# 💧 DROP

### One thought at a time.

*A quiet place to put down what feels heavy.*

[![License: MIT](https://img.shields.io/badge/license-MIT-2E86AB.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
![Platform](https://img.shields.io/badge/platform-Android%20%7C%20iOS-lightgrey)
[![Privacy](https://img.shields.io/badge/privacy-nothing%20saved%2C%20nothing%20sent-2E86AB)](#-privacy)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

</div>

---

DROP is a small, open-source Flutter app for expressing a thought and letting it go. Write it, release it into a lake, and watch it disappear. You can also hold a thought in your mind and drop it without typing or recording — no accounts, no streaks, no history. Just the drop.

<div align="center">

<img src="img/home (1).jpeg" width="180" alt="Home screen"/>&nbsp;
<img src="img/drop with txt (1).jpeg" width="180" alt="Writing a thought"/>&nbsp;
<img src="img/breath (1).jpeg" width="180" alt="Guided breathing"/>&nbsp;
<img src="img/setting (1).jpeg" width="180" alt="Settings screen"/>

</div>

## ✨ Features

- 🌊 **Unlimited releases** — no counts, streaks, calendar, or activity history.
- 🤫 **A wordless drop** — let something go with no microphone or recording.
- 🌬️ **Three guided breaths** — available anytime, no session required.
- 🕯️ **A quiet ending** — stay beside the lake or return home when ready.
- 🎧 **Personal touches** — music, volume, theme, reduced-motion, and optional daily reminders. The drop sound effect always plays, even when music is muted.
- 🧘 **Zero clutter** — no login, no analytics, no ads, no distractions.

<div align="center">

<img src="img/home (2).jpeg" width="180" alt="Home screen alternate"/>&nbsp;
<img src="img/drop without text (1).jpeg" width="180" alt="Wordless drop"/>&nbsp;
<img src="img/breath (2).jpeg" width="180" alt="Breathing exercise"/>&nbsp;
<img src="img/setting (2).jpeg" width="180" alt="Settings alternate"/>

</div>

## 🔒 Privacy

Your words are **never saved or sent** by DROP. They exist temporarily in memory while writing and during the release animation. Leaving the writing screen discards its input; there is no draft recovery.

Only preferences and whether the introduction was completed are stored locally on-device. Previous versions stored drop dates; DROP removes those legacy values on startup. No new activity metadata is written. DROP has **no account, database, analytics, or AI service** — you can verify all of this yourself, because the source is right here.

The phone's keyboard and operating system operate separately from DROP. Android and iOS hide the app-switcher preview. On Android versions before Android 13, that protection also prevents screenshots and screen recordings.

## 🧱 Tech stack

| | |
|---|---|
| **Framework** | [Flutter](https://flutter.dev) (Dart) |
| **State management** | [provider](https://pub.dev/packages/provider) |
| **Local storage** | [shared_preferences](https://pub.dev/packages/shared_preferences) |
| **Audio** | [audioplayers](https://pub.dev/packages/audioplayers) |
| **Notifications** | [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications) + [timezone](https://pub.dev/packages/timezone) |
| **Typography** | [google_fonts](https://pub.dev/packages/google_fonts) |
| **Updates** | [in_app_update](https://pub.dev/packages/in_app_update) (Android) |

## 🚀 Getting started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) `^3.10.3`
- Android Studio / Xcode for platform tooling, or a connected device/emulator

### Run locally

```sh
git clone https://github.com/Maher-Tec/DROP.git
cd DROP
flutter pub get
flutter run
```

### Useful commands

```sh
flutter analyze     # static analysis
flutter test        # run the test suite
flutter build apk    # release build for Android
flutter build ios    # release build for iOS
```

### Code navigation with dart_context_mcp (optional)

```sh
dart pub global activate dart_context_mcp
dart_context_mcp overview .
dart_context_mcp context SoundService.playWaterDrop --root .
dart_context_mcp impact SoundService --root .
```

The tool keeps its generated index in `.dart_context/`, which is ignored by Git.

## 📁 Project structure

```
lib/
├── app/          # App entry widget, routing, top-level setup
├── config/       # Theme and app-wide configuration
├── screens/      # Onboarding, home, write, breathing, settings, etc.
├── services/     # Haptics, notifications, sound — no analytics, no network
└── widgets/      # Reusable UI: drop animation, particles, ripples, lake
```

## 🤝 Contributing

Contributions are welcome — bug fixes, accessibility improvements, translations, and thoughtful new features that keep DROP simple and private.

1. Fork the repo and create a branch from `main`.
2. Make your changes, keeping the app's minimal, distraction-free spirit.
3. Run `flutter analyze` and `flutter test` before opening a PR.
4. Open a pull request describing what changed and why.

Please open an issue first for larger changes so we can discuss the approach.

> **Note:** The Android app is already published to Google Play. Repository changes are not automatically deployed.

## 📄 License

DROP is licensed under the [MIT License](LICENSE) — free to use, modify, and distribute.

---

<div align="center">
<sub>Let it go. 💧</sub>
</div>
