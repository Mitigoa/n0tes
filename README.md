# n0tes - Flutter Note-Taking App

A modern, feature-rich note-taking application built with Flutter. n0tes allows users to create, organize, and manage their notes with rich text formatting, folder organization, and tags.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-3.6.1-blue.svg)](https://flutter.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Desktop-green.svg)](#)

## 📱 Features

- **Rich Text Editing** - Create notes with formatted text, headings, lists, and more
- **Folder Organization** - Organize notes into custom folders
- **Tag System** - Add tags to notes for easy filtering
- **Search Functionality** - Quickly find notes by title or content
- **Dark/Light Theme** - Toggle between dark and light modes
- **Note Colors** - Personalize notes with custom colors
- **Staggered Grid View** - Beautiful masonry-style note layout
- **Share Notes** - Share notes to other apps
- **Auto-save** - Notes are automatically saved
- **Cross-platform** - Runs on Android, iOS, Web, Windows, macOS, and Linux

## 🛠️ Technologies Used

- **Flutter** - Cross-platform UI framework
- **Provider** - State management
- **Hive** - Local NoSQL database
- **Flutter Quill** - Rich text editor
- **Google Fonts** - Custom typography
- **Share Plus** - Cross-platform sharing
- **UUID** - Unique identifier generation
- **Intl** - Internationalization and date formatting

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.6.1 or higher
- Dart SDK 3.6.1 or higher
- Android SDK (for Android development)
- Xcode (for iOS/macOS development)

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Mitigoa/n0tes.git
   cd n0tes
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the app:**
   ```bash
   flutter run
   ```

### Building for Release

#### Android (APK)
```bash
flutter build apk --release
```

#### iOS
```bash
flutter build ios --release
```

#### Web
```bash
flutter build web
```

#### Desktop (Windows/macOS/Linux)
```bash
flutter build windows
flutter build macos
flutter build linux
```

## 📁 Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── note_model.dart       # Note data model
│   ├── folder_model.dart     # Folder data model
│   └── tag_model.dart        # Tag data model
├── providers/                # State management
│   ├── note_provider.dart    # Notes state
│   ├── folder_provider.dart  # Folders state
│   └── theme_provider.dart   # Theme state
├── screens/                  # App screens
│   ├── home_screen.dart      # Main screen
│   ├── note_editor_screen.dart # Note editor
│   ├── settings_screen.dart  # Settings
│   └── splash_screen.dart    # Splash screen
├── services/                 # Business logic
│   └── database_service.dart # Hive database
├── themes/                   # App themes
│   └── app_theme.dart        # Theme configuration
├── utils/                    # Utilities
│   ├── colors.dart           # Color definitions
│   ├── constants.dart       # Constants
│   └── date_formatter.dart  # Date formatting
└── widgets/                  # Reusable widgets
    ├── note_card.dart        # Note card
    ├── note_grid.dart        # Note grid
    └── rich_text_editor.dart # Rich text editor
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Flutter](https://flutter.dev) - The UI framework used
- [Hive](https://hivedb.dev) - Fast, lightweight NoSQL database
- [Flutter Quill](https://github.com/singerdmx/flutter_quill) - Rich text editor

## 📞 Support

If you encounter any issues or have questions, please open an issue on the GitHub repository.

---

⭐ If you find this project useful, please consider giving it a star!
