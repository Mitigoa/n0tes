import 'package:hive_flutter/hive_flutter.dart';
import '../models/note_model.dart';
import '../models/folder_model.dart';
import '../models/tag_model.dart';

class DatabaseService {
  static const String notesBoxName = 'notes';
  static const String foldersBoxName = 'folders';
  static const String tagsBoxName = 'tags';
  static const String settingsBoxName = 'settings';

  Future<void> init() async {
    await Hive.initFlutter();

    // Register Adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(NoteTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(NoteAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(FolderAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(TagAdapter());
    }

    // Open Boxes
    await Hive.openBox<Note>(notesBoxName);
    await Hive.openBox<Folder>(foldersBoxName);
    await Hive.openBox<Tag>(tagsBoxName);
    await Hive.openBox(settingsBoxName);

    // Debug
    print('DatabaseService: Hive initialized and boxes opened');
  }

  // --- Notes ---
  Box<Note> get _notesBox => Hive.box<Note>(notesBoxName);

  Future<void> createNote(Note note) async {
    print(
        'DatabaseService.createNote: saving note id=${note.id} title="${note.title}"');
    await _notesBox.put(note.id, note);
    print('DatabaseService.createNote: saved note id=${note.id}');
  }

  Future<Note?> getNote(String id) async {
    final note = _notesBox.get(id);
    print('DatabaseService.getNote: id=$id found=${note != null}');
    return note;
  }

  Future<List<Note>> getAllNotes() async {
    final list = _notesBox.values.toList();
    print('DatabaseService.getAllNotes: count=${list.length}');
    return list;
  }

  Future<List<Note>> getNotesByFolder(String folderId) async {
    final list =
        _notesBox.values.where((note) => note.folderId == folderId).toList();
    print(
        'DatabaseService.getNotesByFolder: folder=$folderId count=${list.length}');
    return list;
  }

  Future<void> updateNote(Note note) async {
    print('DatabaseService.updateNote: updating id=${note.id}');
    await _notesBox.put(note.id, note);
    print('DatabaseService.updateNote: updated id=${note.id}');
  }

  Future<void> deleteNote(String id) async {
    print('DatabaseService.deleteNote: deleting id=$id');
    await _notesBox.delete(id);
    print('DatabaseService.deleteNote: deleted id=$id');
  }

  Future<List<Note>> searchNotes(String query) async {
    final allNotes = await getAllNotes();
    if (query.isEmpty) return allNotes;

    final lowerQuery = query.toLowerCase();

    final result = allNotes.where((note) {
      final titleMatch = note.title.toLowerCase().contains(lowerQuery);
      final contentMatch = note.content.toLowerCase().contains(lowerQuery);
      final tagMatch =
          note.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
      return titleMatch || contentMatch || tagMatch;
    }).toList();
    print(
        'DatabaseService.searchNotes: query="$query" results=${result.length}');
    return result;
  }

  // --- Folders ---
  Box<Folder> get _foldersBox => Hive.box<Folder>(foldersBoxName);

  Future<void> createFolder(Folder folder) async {
    await _foldersBox.put(folder.id, folder);
  }

  Future<List<Folder>> getAllFolders() async {
    return _foldersBox.values.toList();
  }

  Future<void> updateFolder(Folder folder) async {
    await _foldersBox.put(folder.id, folder);
  }

  Future<void> deleteFolder(String id) async {
    await _foldersBox.delete(id);
  }

  // --- Settings ---
  Box get _settingsBox => Hive.box(settingsBoxName);

  Future<void> saveSetting(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }

  Future<T?> getSetting<T>(String key) async {
    return _settingsBox.get(key) as T?;
  }
}
