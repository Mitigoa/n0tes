import 'package:flutter/material.dart';
import '../services/database_service.dart';

class ThemeProvider with ChangeNotifier {
  final DatabaseService _databaseService;

  ThemeMode _themeMode = ThemeMode.system;

  ThemeProvider(this._databaseService) {
    _loadTheme();
  }

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      return WidgetsBinding.instance.window.platformBrightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  Future<void> _loadTheme() async {
    final themeIndex = await _databaseService.getSetting<int>('themeMode');
    if (themeIndex != null) {
      _themeMode = ThemeMode.values[themeIndex];
      notifyListeners();
    }
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    _themeMode = themeMode;
    await _databaseService.saveSetting('themeMode', themeMode.index);
    notifyListeners();
  }
}
