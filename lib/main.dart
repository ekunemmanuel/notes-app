// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/note_list_screen.dart';
import 'services/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Create and initialize ThemeService
  final themeService = ThemeService();
  await themeService.initializeSettings();

  runApp(
    ChangeNotifierProvider.value(
      value: themeService,
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return MaterialApp(
          title: 'Notes App',
          theme: themeService.getTheme(),
          debugShowCheckedModeBanner: false,
          home: NoteListScreen(),
        );
      },
    );
  }
}