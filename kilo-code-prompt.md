# Kilo Code Prompt: Flutter Note-Taking App

## Project Overview
Create a lightweight, offline Flutter note-taking application with a clean, modern UI inspired by Google Keep. The app should be fast, intuitive, and feature-rich while maintaining a small footprint.

## Core Requirements

### 1. App Specifications
- **Platform**: Flutter (iOS & Android)
- **Storage**: Hive database (offline-first)
- **State Management**: Provider or Riverpod
- **Target Size**: Under 15MB
- **Launch Time**: Under 2 seconds
- **Min SDK**: Android 21+ / iOS 12+

### 2. Architecture
Use clean architecture with the following structure:
```
lib/
├── main.dart
├── models/
│   ├── note_model.dart
│   ├── folder_model.dart
│   └── tag_model.dart
├── services/
│   ├── database_service.dart
│   └── search_service.dart
├── providers/
│   ├── note_provider.dart
│   ├── folder_provider.dart
│   └── theme_provider.dart
├── screens/
│   ├── home_screen.dart
│   ├── note_editor_screen.dart
│   ├── folder_management_screen.dart
│   └── settings_screen.dart
├── widgets/
│   ├── note_card.dart
│   ├── note_grid.dart
│   ├── folder_chip.dart
│   ├── color_picker.dart
│   └── custom_app_bar.dart
├── utils/
│   ├── constants.dart
│   ├── colors.dart
│   └── date_formatter.dart
└── themes/
    └── app_theme.dart
```

### 3. Data Models

#### Note Model
```dart
class Note {
  String id;              // UUID
  String title;
  String content;
  String? folderId;
  List<String> tags;
  int colorCode;          // Material color code
  bool isPinned;
  bool isArchived;
  DateTime createdAt;
  DateTime updatedAt;
  NoteType type;          // text, checklist
}

enum NoteType { text, checklist }
```

#### Folder Model
```dart
class Folder {
  String id;
  String name;
  int colorCode;
  int noteCount;
  DateTime createdAt;
}
```

#### Tag Model
```dart
class Tag {
  String name;
  int usageCount;
}
```

### 4. Core Features to Implement

#### A. Home Screen
- **Layout**: Staggered grid view (masonry style) using `flutter_staggered_grid_view`
- **Top App Bar**:
  - App title/logo
  - Search icon
  - View toggle (grid/list)
  - Menu button (settings, folders)
- **Note Cards**: 
  - Show title (bold, 16sp)
  - Show content preview (2-3 lines, fade at end)
  - Show timestamp (bottom, small gray text)
  - Show folder chip if assigned
  - Color-coded background
  - Pin icon if pinned
- **FAB**: Bottom-right floating action button to create new note
- **Empty State**: Show friendly message with illustration when no notes
- **Features**:
  - Pull to refresh
  - Pinned notes appear at top
  - Long-press note for context menu (pin, delete, change color, archive)
  - Swipe actions: left swipe = archive, right swipe = delete

#### B. Note Editor Screen
- **Top Bar**:
  - Back button
  - Note actions: pin, color picker, folder selector, delete
- **Editor Area**:
  - Title TextField (hint: "Title", bold, 20sp)
  - Content TextField (hint: "Start typing...", multiline, 16sp)
  - Auto-save after 500ms of no typing (debounced)
- **Bottom Bar**:
  - Timestamp (last edited)
  - Character/word count
  - Tag input field (optional)
- **Features**:
  - Support basic markdown shortcuts (# for heading, * for bold)
  - Undo/Redo buttons
  - Share button
  - For checklist type: allow adding checkboxes

#### C. Search Functionality
- **Search Bar**: Expandable from home screen
- **Search Logic**: 
  - Search in title and content
  - Real-time filtering (debounced 300ms)
  - Highlight matching text
  - Show results count
- **Filters**:
  - Filter by folder
  - Filter by color
  - Filter by tags
  - Show pinned only
  - Show archived only

#### D. Folder Management
- Create folders with name and color
- Edit/Delete folders
- Show note count per folder
- Maximum 10 folders for free version
- Default "General" folder (cannot delete)

#### E. Settings Screen
- **Appearance**:
  - Theme toggle: Light, Dark, System
  - Grid columns: 2 or 3
  - Font size: Small, Medium, Large
- **Data Management**:
  - Export all notes (JSON)
  - Import notes
  - Clear all data (with confirmation)
  - Storage usage indicator
- **About**:
  - App version
  - Developer info
  - Rate app button

#### F. Additional Features
- **Color Palette**: 10 predefined colors (pastel shades)
- **Sorting Options**:
  - Date created (newest/oldest)
  - Date modified (newest/oldest)
  - Alphabetically (A-Z/Z-A)
  - Color
- **Trash/Archive**:
  - Archived notes stored separately
  - Access via menu
  - Restore or permanently delete
  - Auto-delete after 30 days

### 5. Database Implementation (Hive)

#### Setup
```dart
// Initialize Hive
await Hive.initFlutter();
Hive.registerAdapter(NoteAdapter());
Hive.registerAdapter(FolderAdapter());

// Open boxes
final notesBox = await Hive.openBox<Note>('notes');
final foldersBox = await Hive.openBox<Folder>('folders');
final settingsBox = await Hive.openBox('settings');
```

#### Database Service Methods
```dart
class DatabaseService {
  // Notes
  Future<void> createNote(Note note);
  Future<Note?> getNote(String id);
  Future<List<Note>> getAllNotes();
  Future<List<Note>> getNotesByFolder(String folderId);
  Future<void> updateNote(Note note);
  Future<void> deleteNote(String id);
  Future<List<Note>> searchNotes(String query);
  
  // Folders
  Future<void> createFolder(Folder folder);
  Future<List<Folder>> getAllFolders();
  Future<void> updateFolder(Folder folder);
  Future<void> deleteFolder(String id);
  
  // Settings
  Future<void> saveSetting(String key, dynamic value);
  Future<T?> getSetting<T>(String key);
}
```

### 6. UI/UX Guidelines

#### Design System
- **Colors**:
  - Primary: Material Blue (Blue.shade700)
  - Accent: Material Teal
  - Note Colors: Pastel variants (Red.shade100, Blue.shade100, etc.)
  - Background: White (light), Grey.shade900 (dark)
- **Typography**:
  - Use Google Fonts (Poppins or Inter)
  - Title: 20sp, bold
  - Body: 16sp, regular
  - Caption: 12sp, light
- **Spacing**:
  - Padding: 16dp standard, 8dp compact
  - Corner radius: 12dp for cards
  - Elevation: 2dp for cards

#### Animations
- Hero animation when opening note
- Fade in/out for dialogs
- Smooth scroll on grid
- Ripple effect on cards
- Snackbar for confirmations

#### Gestures
- Tap: Open note
- Long press: Show context menu
- Swipe left: Archive
- Swipe right: Delete (with confirmation)
- Pull down: Refresh

### 7. Performance Optimizations

- Use `ListView.builder` or `GridView.builder` for lazy loading
- Implement pagination (load 50 notes at a time)
- Cache search results for 30 seconds
- Compress large text content (>10KB)
- Use `const` constructors where possible
- Debounce auto-save (500ms)
- Debounce search (300ms)

### 8. Dependencies (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  provider: ^6.1.1
  
  # Database
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  
  # UI Components
  google_fonts: ^6.1.0
  flutter_staggered_grid_view: ^0.7.0
  
  # Utilities
  uuid: ^4.3.3
  intl: ^0.19.0
  share_plus: ^7.2.1
  path_provider: ^2.1.1
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  hive_generator: ^2.0.1
  build_runner: ^2.4.8
```

### 9. Specific Implementation Instructions

#### Auto-Save Logic
```dart
class NoteEditorScreen extends StatefulWidget {
  // ...
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  Timer? _debounce;
  
  void _onContentChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    _debounce = Timer(const Duration(milliseconds: 500), () {
      // Save note to database
      _saveNote();
    });
  }
  
  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
```

#### Search Implementation
```dart
Future<List<Note>> searchNotes(String query) async {
  final allNotes = await getAllNotes();
  
  if (query.isEmpty) return allNotes;
  
  final lowerQuery = query.toLowerCase();
  
  return allNotes.where((note) {
    final titleMatch = note.title.toLowerCase().contains(lowerQuery);
    final contentMatch = note.content.toLowerCase().contains(lowerQuery);
    final tagMatch = note.tags.any((tag) => 
      tag.toLowerCase().contains(lowerQuery)
    );
    
    return titleMatch || contentMatch || tagMatch;
  }).toList();
}
```

#### Color Picker Widget
```dart
class ColorPicker extends StatelessWidget {
  final int selectedColor;
  final Function(int) onColorSelected;
  
  static const colors = [
    0xFFFFFFFF, // White
    0xFFF28B82, // Red
    0xFFFBBC04, // Orange
    0xFFFFF475, // Yellow
    0xFFCCFF90, // Green
    0xFFA7FFEB, // Teal
    0xFFCBF0F8, // Blue
    0xFFAECBFA, // Light Blue
    0xFFD7AEFB, // Purple
    0xFFFDCFE8, // Pink
  ];
  
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: colors.map((color) {
        return GestureDetector(
          onTap: () => onColorSelected(color),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Color(color),
              shape: BoxShape.circle,
              border: Border.all(
                color: selectedColor == color 
                  ? Colors.black 
                  : Colors.transparent,
                width: 2,
              ),
            ),
            child: selectedColor == color
              ? Icon(Icons.check, size: 20)
              : null,
          ),
        );
      }).toList(),
    );
  }
}
```

### 10. Error Handling

- Wrap all database operations in try-catch
- Show user-friendly error messages via SnackBar
- Log errors for debugging
- Graceful degradation if database fails

### 11. Testing Requirements

Create basic tests for:
- Note CRUD operations
- Search functionality
- Folder management
- Data persistence

### 12. App Metadata

```yaml
# pubspec.yaml
name: quicknote
description: A lightweight, offline note-taking app for quick thoughts and ideas
version: 1.0.0+1

flutter:
  uses-material-design: true
  
  assets:
    - assets/images/
    - assets/icons/
```

### 13. Launch Checklist

Before building:
- [ ] Add app icon (1024x1024)
- [ ] Add splash screen
- [ ] Set app name in AndroidManifest.xml and Info.plist
- [ ] Configure permissions (storage, if needed)
- [ ] Test on both Android and iOS
- [ ] Test light and dark themes
- [ ] Test with empty state
- [ ] Test with 100+ notes
- [ ] Verify offline functionality
- [ ] Check app size (should be <15MB)

### 14. Optional Enhancements (Phase 2)

If time permits, add:
- Rich text formatting toolbar (bold, italic, underline)
- Image attachments from gallery
- Export to PDF
- App lock with PIN/biometric
- Reminder notifications
- Voice notes
- Backup/restore functionality

---

## Build Instructions

1. Generate Hive adapters:
```bash
flutter pub run build_runner build
```

2. Run the app:
```bash
flutter run
```

3. Build release APK:
```bash
flutter build apk --release
```

---

## Expected Deliverables

1. Complete Flutter project with all source code
2. Properly structured folders and files
3. Clean, commented code
4. Working Hive database integration
5. Responsive UI that works on different screen sizes
6. Light and dark theme support
7. README.md with setup instructions
8. All core features implemented and tested

---

## Success Criteria

✅ App launches in under 2 seconds
✅ Smooth scrolling with 100+ notes
✅ Auto-save works reliably
✅ Search returns results instantly
✅ No crashes or memory leaks
✅ Intuitive UI that requires no tutorial
✅ App size under 15MB
✅ Works completely offline

---

## Additional Context

This is a personal productivity app meant for daily use. Prioritize:
1. **Speed**: Everything should feel instant
2. **Simplicity**: Clean UI, no clutter
3. **Reliability**: Never lose user data
4. **Polish**: Smooth animations, thoughtful UX

The app should feel like a digital notebook that's always in your pocket - quick to open, easy to use, and reliable.

---

## Questions to Address During Development

1. Should we implement a tutorial/onboarding screen for first-time users? Yes
2. Do we need a backup reminder after X notes created? yes
3. Should archived notes be permanently deleted or kept indefinitely? indefinitely
4. What's the maximum note size we should support? figure out
5. Should we add a "recently deleted" feature (like iOS Notes)? no

Please implement all core features with clean, production-ready code. Focus on user experience and performance above all else.
