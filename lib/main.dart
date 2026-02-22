import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/database_service.dart';
import 'providers/note_provider.dart';
import 'providers/folder_provider.dart';
import 'providers/theme_provider.dart';
import 'themes/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final databaseService = DatabaseService();
  await databaseService.init();

  runApp(
    MultiProvider(
      providers: [
        Provider<DatabaseService>.value(value: databaseService),
        ChangeNotifierProvider(create: (_) => NoteProvider(databaseService)),
        ChangeNotifierProvider(create: (_) => FolderProvider(databaseService)),
        ChangeNotifierProvider(create: (_) => ThemeProvider(databaseService)),
      ],
      child: const QuickNoteApp(),
    ),
  );
}

class QuickNoteApp extends StatelessWidget {
  const QuickNoteApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          title: 'Quicknotes',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          home: const SplashScreen(),
        );
      },
    );
  }
}
