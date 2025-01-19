// lib/services/theme_service.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/app_settings.dart';
import 'database_helper.dart';

class ThemeService extends ChangeNotifier {
  AppSettings _settings =
      AppSettings.defaultSettings(); // Initialize with default
  bool _isInitialized = false; // Add initialization flag

  final List<String> availableFonts = [
    'Roboto',
    'Lato',
    'OpenSans',
    'Montserrat',
    'Poppins',
  ];

  ThemeService() {
    initializeSettings(); // Start initialization
  }

  Future<void> initializeSettings() async {
    if (!_isInitialized) {
      try {
        final savedSettings = await DatabaseHelper.instance.getSettings();
        _settings = savedSettings;
        _isInitialized = true;
        notifyListeners();
      } catch (e) {
        if (kDebugMode) {
          print('Error loading settings: $e');
        }
        // Keep default settings if there's an error
      }
    }
  }

  AppSettings get settings => _settings;

  ThemeData getTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _settings.primaryColor,
      primary: _settings.primaryColor,
      secondary: _settings.secondaryColor,
      brightness: _settings.isDarkMode ? Brightness.dark : Brightness.light,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _settings.isDarkMode
          ? Colors.black87
          : _settings.primaryColor.withAlpha(50),
      appBarTheme: AppBarTheme(
        backgroundColor: _settings.primaryColor,
        foregroundColor:
            ThemeData.estimateBrightnessForColor(_settings.primaryColor) ==
                    Brightness.dark
                ? Colors.white
                : Colors.black,
      ),
      fontFamily: _settings.fontFamily,
      textTheme: TextTheme(
        bodyLarge: TextStyle(fontSize: _settings.fontSize),
        bodyMedium: TextStyle(fontSize: _settings.fontSize - 2),
        titleLarge: TextStyle(fontSize: _settings.fontSize + 4),
      ).apply(
        bodyColor: _settings.isDarkMode ? Colors.white : Colors.black87,
        displayColor: _settings.isDarkMode ? Colors.white : Colors.black,
      ),
      cardTheme: CardTheme(
        color: _settings.isDarkMode ? Colors.black54 : Colors.white,
      ),
    );
  }

  Future<void> updateSettings(AppSettings newSettings) async {
    _settings = newSettings;
    try {
      await DatabaseHelper.instance.updateSettings(newSettings);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error updating settings: $e');
      }
      // Revert to previous settings if update fails
      _settings = _settings;
      notifyListeners();
    }
  }

  Future<void> updatePrimaryColor(Color color) async {
    final newSettings = _settings.copyWith(primaryColor: color);
    await updateSettings(newSettings);
  }

  Future<void> updateSecondaryColor(Color color) async {
    final newSettings = _settings.copyWith(secondaryColor: color);
    await updateSettings(newSettings);
  }

  Future<void> updateFontFamily(String fontFamily) async {
    final newSettings = _settings.copyWith(fontFamily: fontFamily);
    await updateSettings(newSettings);
  }

  Future<void> updateFontSize(double fontSize) async {
    final newSettings = _settings.copyWith(fontSize: fontSize);
    await updateSettings(newSettings);
  }

  Future<void> toggleDarkMode() async {
    final newSettings = _settings.copyWith(isDarkMode: !_settings.isDarkMode);
    await updateSettings(newSettings);
  }
}
