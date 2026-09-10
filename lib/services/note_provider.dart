import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/note.dart';
import 'database_service.dart';

class NoteProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  List<Note> _notes = [];
  List<Note> _filteredNotes = [];
  String _searchQuery = '';
  bool _isLoading = false;

  List<Note> get notes => _filteredNotes.isEmpty && _searchQuery.isEmpty
      ? _notes
      : _filteredNotes;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  Future<void> loadNotes() async {
    _isLoading = true;
    notifyListeners();

    try {
      _notes = await _dbService.getAllNotes();
      _filteredNotes = [];
      _searchQuery = '';
    } catch (e) {
      debugPrint('Error loading notes: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Note?> getNoteById(String id) async {
    return await _dbService.getNoteById(id);
  }

  Future<Note> createNote({
    String? title,
    String? content,
    String language = 'markdown',
  }) async {
    final now = DateTime.now();
    final uuid = const Uuid().v4();
    final note = Note(
      id: uuid,
      guid: uuid,
      title: title ?? 'Untitled Note',
      body: content ?? '',
      language: language,
      createdAt: now,
      updatedAt: now,
    );

    await _dbService.insertNote(note);
    await loadNotes();
    return note;
  }

  Future<void> updateNote(Note note) async {
    final updatedNote = note.copyWith(updatedAt: DateTime.now());
    await _dbService.updateNote(updatedNote);
    await loadNotes();
  }

  Future<void> deleteNote(String id) async {
    await _dbService.deleteNote(id);
    await loadNotes();
  }

  Future<void> togglePin(String id) async {
    await _dbService.togglePin(id);
    await loadNotes();
  }

  Future<void> searchNotes(String query) async {
    _searchQuery = query;

    if (query.isEmpty) {
      _filteredNotes = [];
    } else {
      _filteredNotes = await _dbService.searchNotes(query);
    }

    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _filteredNotes = [];
    notifyListeners();
  }

  Future<void> importNote(String filePath, String content) async {
    final fileName = filePath.split('/').last;
    final extension = fileName.split('.').last.toLowerCase();

    // Map file extensions to Monaco language identifiers
    final languageMap = {
      'md': 'markdown',
      'js': 'javascript',
      'ts': 'typescript',
      'py': 'python',
      'kt': 'kotlin',
      'java': 'java',
      'go': 'go',
      'rs': 'rust',
      'c': 'c',
      'cpp': 'cpp',
      'swift': 'swift',
      'dart': 'dart',
      'rb': 'ruby',
      'php': 'php',
      'html': 'html',
      'css': 'css',
      'json': 'json',
      'yaml': 'yaml',
      'yml': 'yaml',
      'xml': 'xml',
      'sql': 'sql',
      'sh': 'shell',
      'bash': 'shell',
    };

    final language = languageMap[extension] ?? 'plaintext';
    final title = fileName.replaceAll(RegExp(r'\.[^.]+$'), ''); // Remove extension

    await createNote(
      title: title,
      content: content,  // Will be assigned to 'body' in createNote
      language: language,
    );
  }
}
