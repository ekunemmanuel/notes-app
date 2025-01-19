// lib/screens/note_list_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/note.dart';
import '../services/database_helper.dart';
import '../services/theme_service.dart';
import 'note_edit_screen.dart';
import 'settings_screen.dart';

class NoteListScreen extends StatefulWidget {
  const NoteListScreen({super.key});

  @override
  NoteListScreenState createState() => NoteListScreenState();
}

class NoteListScreenState extends State<NoteListScreen> {
  late Future<List<Note>> _notesFuture;
  Set<int> selectedNotes = {};
  bool isSelectMode = false;

  @override
  void initState() {
    super.initState();
    _refreshNotes();
  }

  void _refreshNotes() {
    setState(() {
      _notesFuture = DatabaseHelper.instance.getAllNotes();
    });
  }

  void _toggleNoteSelection(int id) {
    setState(() {
      if (selectedNotes.contains(id)) {
        selectedNotes.remove(id);
        if (selectedNotes.isEmpty) {
          isSelectMode = false;
        }
      } else {
        selectedNotes.add(id);
        isSelectMode = true;
      }
    });
  }

  void _toggleSelectAll(List<Note> notes) {
    setState(() {
      if (selectedNotes.length == notes.length) {
        // If all notes are selected, unselect all
        selectedNotes.clear();
        isSelectMode = false;
      } else {
        // Select all notes
        selectedNotes = notes.map((note) => note.id!).toSet();
        isSelectMode = true;
      }
    });
  }

  Future<void> _deleteSelectedNotes(List<Note> allNotes) async {
    // Store selected notes before deletion for potential undo
    final notesToDelete =
        allNotes.where((note) => selectedNotes.contains(note.id)).toList();

    // Delete all selected notes
    for (var note in notesToDelete) {
      await DatabaseHelper.instance.deleteNote(note.id!);
    }

    if (!mounted) return;

    // Show undo snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${notesToDelete.length} notes deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () async {
            // Restore all deleted notes
            for (var note in notesToDelete) {
              await DatabaseHelper.instance.createNote(Note(
                title: note.title,
                content: note.content,
                createdAt: note.createdAt,
                updatedAt: note.updatedAt,
              ));
            }
            if (mounted) {
              _refreshNotes();
            }
          },
        ),
        duration: Duration(seconds: 3),
      ),
    );

    // Clear selection and refresh
    setState(() {
      selectedNotes.clear();
      isSelectMode = false;
    });
    _refreshNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            isSelectMode ? '${selectedNotes.length} selected' : 'My Notes'),
        actions: [
          FutureBuilder<List<Note>>(
            future: _notesFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return SizedBox();

              return Row(
                children: [
                  if (isSelectMode) ...[
                    IconButton(
                      icon: Icon(
                        selectedNotes.length == snapshot.data!.length
                            ? Icons.deselect
                            : Icons.select_all,
                        color: selectedNotes.length == snapshot.data!.length
                            ? Colors.amber
                            : null,
                      ),
                      tooltip: selectedNotes.length == snapshot.data!.length
                          ? 'Deselect All'
                          : 'Select All',
                      onPressed: () => _toggleSelectAll(snapshot.data!),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _deleteSelectedNotes(snapshot.data!),
                    ),
                  ] else ...[
                    IconButton(
                      icon: Icon(Icons.checklist),
                      tooltip: 'Select Notes',
                      onPressed: () => _toggleSelectAll(snapshot.data!),
                    ),
                    IconButton(
                      icon: Icon(Icons.settings),
                      tooltip: 'Settings',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SettingsScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Note>>(
        future: _notesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No notes yet'));
          }

          final notes = snapshot.data!;
          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              return Dismissible(
                key: Key(note.id.toString()),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Icon(Icons.delete, color: Colors.white),
                ),
                direction: DismissDirection.endToStart,
                confirmDismiss: (direction) async {
                  Note deletedNote = note;
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Note "${note.title}" deleted'),
                        action: SnackBarAction(
                          label: 'Undo',
                          onPressed: () async {
                            await DatabaseHelper.instance.createNote(Note(
                              title: deletedNote.title,
                              content: deletedNote.content,
                              createdAt: deletedNote.createdAt,
                              updatedAt: deletedNote.updatedAt,
                            ));
                            if (mounted) {
                              _refreshNotes();
                            }
                          },
                        ),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                  await DatabaseHelper.instance.deleteNote(note.id!);
                  if (mounted) {
                    _refreshNotes();
                  }
                  return true;
                },
                child: Consumer<ThemeService>(
                    builder: (context, themeService, child) {
                  return ListTile(
                    tileColor: themeService.settings.primaryColor
                        .withValues(alpha: 500),
                    leading: isSelectMode
                        ? Checkbox(
                            value: selectedNotes.contains(note.id),
                            onChanged: (bool? value) {
                              _toggleNoteSelection(note.id!);
                            },
                          )
                        : null,
                    title: Text(
                      note.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: themeService.settings.primaryColor,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          note.content,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey.shade200),
                        ),
                        Text(
                          DateFormat('MMM d, y').format(note.updatedAt),
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                    onTap: isSelectMode
                        ? () => _toggleNoteSelection(note.id!)
                        : () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    NoteEditScreen(note: note),
                              ),
                            );
                            _refreshNotes();
                          },
                    onLongPress: () => _toggleNoteSelection(note.id!),
                  );
                }),
              );
            },
          );
        },
      ),
      floatingActionButton: !isSelectMode
          ? FloatingActionButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NoteEditScreen(),
                  ),
                );
                _refreshNotes();
              },
              child: Icon(Icons.add),
            )
          : null,
    );
  }
}
