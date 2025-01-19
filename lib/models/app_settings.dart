// lib/models/app_settings.dart
import 'package:flutter/material.dart';

class AppSettings {
  final Color primaryColor;
  final Color secondaryColor;
  final String fontFamily;
  final bool isDarkMode;
  final double fontSize;

  AppSettings({
    required this.primaryColor,
    required this.secondaryColor,
    required this.fontFamily,
    required this.isDarkMode,
    required this.fontSize,
  });

  Map<String, dynamic> toMap() {
    return {
      'primary_color': primaryColor.r, // Convert Color to integer
      'secondary_color': secondaryColor.r, // Convert Color to integer
      'font_family': fontFamily,
      'is_dark_mode': isDarkMode ? 1 : 0,
      'font_size': fontSize,
    };
  }

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      primaryColor: Color(map['primary_color'] as int), // Convert integer back to Color
      secondaryColor: Color(map['secondary_color'] as int), // Convert integer back to Color
      fontFamily: map['font_family'] as String,
      isDarkMode: map['is_dark_mode'] == 1,
      fontSize: map['font_size'] as double,
    );
  }

  factory AppSettings.defaultSettings() {
    return AppSettings(
      primaryColor: Colors.blue, // This will be converted to an integer value
      secondaryColor: Colors.blueAccent, // This will be converted to an integer value
      fontFamily: 'Roboto',
      isDarkMode: false,
      fontSize: 14.0,
    );
  }

  AppSettings copyWith({
    Color? primaryColor,
    Color? secondaryColor,
    String? fontFamily,
    bool? isDarkMode,
    double? fontSize,
  }) {
    return AppSettings(
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      fontFamily: fontFamily ?? this.fontFamily,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      fontSize: fontSize ?? this.fontSize,
    );
  }
}