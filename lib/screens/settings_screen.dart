// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import '../services/theme_service.dart';
import 'about_screen.dart';

// Add this widget to the settings_screen.dart file

class ThemePreview extends StatelessWidget {
  const ThemePreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Theme Preview',
                  style: TextStyle(
                    fontSize: themeService.settings.fontSize + 4,
                    fontFamily: themeService.settings.fontFamily,
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: themeService.settings.primaryColor
                        .withValues(alpha: 1000),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sample Note Title',
                        style: TextStyle(
                          fontSize: themeService.settings.fontSize + 2,
                          fontFamily: themeService.settings.fontFamily,
                          color: themeService.settings.primaryColor,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'This is how your notes will look with the current theme settings. The text size, font family, and colors will be applied throughout the app.',
                        style: TextStyle(
                          fontSize: themeService.settings.fontSize,
                          fontFamily: themeService.settings.fontFamily,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeService.settings.primaryColor,
                      ),
                      child: Text(
                        'Primary Button',
                        style: TextStyle(
                          color: !themeService.settings.isDarkMode
                              ? Colors.black
                              : Colors.white,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        foregroundColor: themeService.settings.secondaryColor,
                      ),
                      child: Text('Secondary Button'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Consumer<ThemeService>(
        builder: (context, themeService, child) {
          return ListView(
            padding: EdgeInsets.all(16),
            children: [
              Card(
                child: ListTile(
                  leading: Icon(Icons.info),
                  title: Text('About'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AboutScreen(),
                      ),
                    );
                  },
                ),
              ),
              Card(
                child: ListTile(
                  title: Text('Dark Mode'),
                  trailing: Switch(
                    value: themeService.settings.isDarkMode,
                    onChanged: (value) => themeService.toggleDarkMode(),
                  ),
                ),
              ),
              ThemePreview(),
              SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Primary Color'),
                      SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _showColorPicker(
                          context,
                          themeService.settings.primaryColor,
                          (color) => themeService.updatePrimaryColor(color),
                        ),
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: themeService.settings.primaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Secondary Color'),
                      SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _showColorPicker(
                          context,
                          themeService.settings.secondaryColor,
                          (color) => themeService.updateSecondaryColor(color),
                        ),
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: themeService.settings.secondaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Font Family'),
                      SizedBox(height: 8),
                      DropdownButton<String>(
                        value: themeService.settings.fontFamily,
                        isExpanded: true,
                        items: themeService.availableFonts
                            .map((font) => DropdownMenuItem(
                                  value: font,
                                  child: Text(font,
                                      style: TextStyle(fontFamily: font)),
                                ))
                            .toList(),
                        onChanged: (font) {
                          if (font != null) {
                            themeService.updateFontFamily(font);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Font Size'),
                      SizedBox(height: 8),
                      Slider(
                        value: themeService.settings.fontSize,
                        min: 12,
                        max: 24,
                        divisions: 12,
                        label: themeService.settings.fontSize.toString(),
                        onChanged: (value) =>
                            themeService.updateFontSize(value),
                      ),
                      Text(
                        'Sample Text',
                        style:
                            TextStyle(fontSize: themeService.settings.fontSize),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // In your settings_screen.dart, update the _showColorPicker method:

  void _showColorPicker(
    BuildContext context,
    Color currentColor,
    Function(Color) onColorChanged,
  ) {
    Color pickerColor = currentColor;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Pick a color'),
        content: SingleChildScrollView(
          child: StatefulBuilder(
            builder: (context, setState) {
              return ColorPicker(
                pickerColor: pickerColor,
                onColorChanged: (color) {
                  setState(() => pickerColor = color);
                  onColorChanged(color); // Update in real-time
                },
                pickerAreaHeightPercent: 0.8,
                enableAlpha: false, // Disable alpha to avoid transparent colors
                labelTypes: const [], // Remove RGB/HSV labels for cleaner UI
                displayThumbColor: true,
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Done'),
          ),
        ],
      ),
    );
  }
}
