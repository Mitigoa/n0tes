import 'package:flutter/foundation.dart';
import '../models/note_model.dart';
import '../services/database_service.dart';

class NoteProvider with ChangeNotifier {
  final DatabaseService _databaseService;

  List<Note> _notes = [];
  bool _isLoading = false;
  String _searchQuery = '';

  NoteProvider(this._databaseService) {
    print('NoteProvider: initializing and loading notes');
    loadNotes();
  }

  List<Note> get notes {
    if (_searchQuery.isNotEmpty) {
      return _notes.where((note) {
        final query = _searchQuery.toLowerCase();
        return note.title.toLowerCase().contains(query) ||
            note.content.toLowerCase().contains(query) ||
            note.tags.any((tag) => tag.toLowerCase().contains(query));
      }).toList();
    }
    return [..._notes];
  }

  List<Note> get pinnedNotes =>
      notes.where((note) => note.isPinned && !note.isArchived).toList();
  List<Note> get unpinnedNotes =>
      notes.where((note) => !note.isPinned && !note.isArchived).toList();
  List<Note> get archivedNotes =>
      _notes.where((note) => note.isArchived).toList();

  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  Future<void> loadNotes() async {
    _isLoading = true;
    notifyListeners();

    print('NoteProvider.loadNotes: fetching from database');
    _notes = await _databaseService.getAllNotes();
    print('NoteProvider.loadNotes: fetched ${_notes.length} notes');
    // Sort by updated descending by default
    _notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    _isLoading = false;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> addNote(Note note) async {
    print('NoteProvider.addNote: adding id=${note.id}');
    await _databaseService.createNote(note);
    _notes.insert(0, note); // add at top since sorted by newest
    print('NoteProvider.addNote: local list now ${_notes.length}');
    notifyListeners();
  }

  Future<void> updateNote(Note note) async {
    note.updatedAt = DateTime.now();
    print('NoteProvider.updateNote: updating id=${note.id}');
    await _databaseService.updateNote(note);
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      _notes[index] = note;
      // Re-sort
      _notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      print('NoteProvider.updateNote: updated local list');
      notifyListeners();
    }
  }

  Future<void> deleteNote(String id) async {
    print('NoteProvider.deleteNote: deleting id=$id');
    await _databaseService.deleteNote(id);
    _notes.removeWhere((n) => n.id == id);
    print('NoteProvider.deleteNote: local list now ${_notes.length}');
    notifyListeners();
  }

  Future<void> togglePin(Note note) async {
    note.isPinned = !note.isPinned;
    await updateNote(note);
  }

  Future<void> toggleArchive(Note note) async {
    note.isArchived = !note.isArchived;
    // Unpin when archiving
    if (note.isArchived) {
      note.isPinned = false;
    }
    await updateNote(note);
  }

  Future<void> changeColor(Note note, int colorCode) async {
    note.colorCode = colorCode;
    await updateNote(note);
  }
}
