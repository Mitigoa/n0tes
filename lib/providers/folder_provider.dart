import 'package:flutter/foundation.dart';
import '../models/folder_model.dart';
import '../services/database_service.dart';
import 'package:uuid/uuid.dart';

class FolderProvider with ChangeNotifier {
  final DatabaseService _databaseService;

  List<Folder> _folders = [];
  bool _isLoading = false;
  
  static const String generalFolderId = 'general_folder_id';

  FolderProvider(this._databaseService) {
    loadFolders();
  }

  List<Folder> get folders => [..._folders];
  bool get isLoading => _isLoading;

  Future<void> loadFolders() async {
    _isLoading = true;
    notifyListeners();

    _folders = await _databaseService.getAllFolders();
    
    // Ensure "General" folder exists
    if (!_folders.any((f) => f.id == generalFolderId)) {
      final generalFolder = Folder(
        id: generalFolderId,
        name: 'General',
        colorCode: 0xFF9E9E9E, // Grey
        createdAt: DateTime.now(),
      );
      await _databaseService.createFolder(generalFolder);
      _folders.add(generalFolder);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> createFolder(String name, int colorCode) async {
    if (_folders.length >= 10) {
      // Free version limit check
      throw Exception('Maximum 10 folders allowed for free version.');
    }
    final folder = Folder(
      id: const Uuid().v4(),
      name: name,
      colorCode: colorCode,
      createdAt: DateTime.now(),
    );
    await _databaseService.createFolder(folder);
    _folders.add(folder);
    notifyListeners();
  }

  Future<void> updateFolder(Folder folder) async {
    if (folder.id == generalFolderId) return; // Cannot edit general folder easily (or just block name change)
    await _databaseService.updateFolder(folder);
    final index = _folders.indexWhere((f) => f.id == folder.id);
    if (index != -1) {
      _folders[index] = folder;
      notifyListeners();
    }
  }

  Future<void> deleteFolder(String id) async {
    if (id == generalFolderId) return; // Cannot delete General folder
    await _databaseService.deleteFolder(id);
    _folders.removeWhere((f) => f.id == id);
    notifyListeners();
  }

  Folder? getFolderById(String id) {
    try {
      return _folders.firstWhere((f) => f.id == id);
    } catch (_) {
      return null;
    }
  }
}
