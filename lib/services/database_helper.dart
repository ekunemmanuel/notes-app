// lib/services/database_helper.dart
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import '../models/app_settings.dart';
import '../models/note.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('notes.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.linux ||
            defaultTargetPlatform == TargetPlatform.macOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2, // Increment version number
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Create notes table
    await db.execute('''
      CREATE TABLE notes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create settings table
    await db.execute('''
      CREATE TABLE settings(
        id INTEGER PRIMARY KEY CHECK (id = 1),
        primary_color INTEGER NOT NULL,
        secondary_color INTEGER NOT NULL,
        font_family TEXT NOT NULL,
        is_dark_mode INTEGER NOT NULL,
        font_size REAL NOT NULL
      )
    ''');

    // Insert default settings
    final defaultSettings = AppSettings.defaultSettings();
    await db.insert('settings', defaultSettings.toMap());
  }

  // Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Create settings table if it doesn't exist
      await db.execute('''
        CREATE TABLE IF NOT EXISTS settings(
          id INTEGER PRIMARY KEY CHECK (id = 1),
          primary_color INTEGER NOT NULL,
          secondary_color INTEGER NOT NULL,
          font_family TEXT NOT NULL,
          is_dark_mode INTEGER NOT NULL,
          font_size REAL NOT NULL
        )
      ''');

      // Check if settings table is empty
      final List<Map<String, dynamic>> settings = await db.query('settings');
      if (settings.isEmpty) {
        // Insert default settings
        final defaultSettings = AppSettings.defaultSettings();
        await db.insert('settings', defaultSettings.toMap());
      }
    }
  }

  Future<Note> createNote(Note note) async {
    final db = await instance.database;
    final id = await db.insert('notes', note.toMap());
    return Note(
      id: id,
      title: note.title,
      content: note.content,
      createdAt: note.createdAt,
      updatedAt: note.updatedAt,
    );
  }

  Future<List<Note>> getAllNotes() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      orderBy: 'updated_at DESC',
    );
    return List.generate(maps.length, (i) => Note.fromMap(maps[i]));
  }

  Future<Note?> getNote(int id) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Note.fromMap(maps.first);
  }

  Future<int> updateNote(Note note) async {
    final db = await instance.database;
    return db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> deleteNote(int id) async {
    final db = await instance.database;
    return await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateSettings(AppSettings settings) async {
    final db = await instance.database;
    await db.update(
      'settings',
      settings.toMap(),
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  Future<AppSettings> getSettings() async {
    final db = await instance.database;
    try {
      final List<Map<String, dynamic>> maps = await db.query('settings');
      if (maps.isEmpty) {
        final defaultSettings = AppSettings.defaultSettings();
        await db.insert('settings', defaultSettings.toMap());
        return defaultSettings;
      }
      return AppSettings.fromMap(maps.first);
    } catch (e) {
      // If there's an error (like table doesn't exist), create the table and return default settings
      await _onUpgrade(db, 1, 2);
      return AppSettings.defaultSettings();
    }
  }

  Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'notes.db');
    if (await File(path).exists()) {
      await File(path).delete();
      _database = null;
    }
  }
}
