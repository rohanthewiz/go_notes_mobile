import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:gonotes/models/note.dart';
import 'package:gonotes/services/database_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  group('DatabaseService Tests', () {
    late DatabaseService dbService;

    setUp(() async {
      // Use in-memory database for testing
      databaseFactory = databaseFactoryFfi;
      dbService = DatabaseService();
    });

    tearDown(() async {
      await dbService.close();
    });

    test('Should insert and retrieve a note', () async {
      final now = DateTime.now();
      final note = Note(
        id: '123',
        title: 'Test Note',
        content: 'Test content',
        language: 'markdown',
        createdAt: now,
        updatedAt: now,
      );

      await dbService.insertNote(note);
      final retrieved = await dbService.getNoteById('123');

      expect(retrieved, isNotNull);
      expect(retrieved!.id, '123');
      expect(retrieved.title, 'Test Note');
      expect(retrieved.content, 'Test content');
    });

    test('Should update a note', () async {
      final now = DateTime.now();
      final note = Note(
        id: '123',
        title: 'Test Note',
        content: 'Test content',
        language: 'markdown',
        createdAt: now,
        updatedAt: now,
      );

      await dbService.insertNote(note);

      final updatedNote = note.copyWith(
        title: 'Updated Title',
        content: 'Updated content',
      );

      await dbService.updateNote(updatedNote);
      final retrieved = await dbService.getNoteById('123');

      expect(retrieved!.title, 'Updated Title');
      expect(retrieved.content, 'Updated content');
    });

    test('Should delete a note', () async {
      final now = DateTime.now();
      final note = Note(
        id: '123',
        title: 'Test Note',
        content: 'Test content',
        language: 'markdown',
        createdAt: now,
        updatedAt: now,
      );

      await dbService.insertNote(note);
      await dbService.deleteNote('123');
      final retrieved = await dbService.getNoteById('123');

      expect(retrieved, isNull);
    });

    test('Should search notes by title', () async {
      final now = DateTime.now();

      await dbService.insertNote(Note(
        id: '1',
        title: 'JavaScript Tutorial',
        content: 'Learn JS',
        language: 'markdown',
        createdAt: now,
        updatedAt: now,
      ));

      await dbService.insertNote(Note(
        id: '2',
        title: 'Python Guide',
        content: 'Learn Python',
        language: 'markdown',
        createdAt: now,
        updatedAt: now,
      ));

      final results = await dbService.searchNotes('JavaScript');

      expect(results.length, 1);
      expect(results[0].title, 'JavaScript Tutorial');
    });

    test('Should search notes by content', () async {
      final now = DateTime.now();

      await dbService.insertNote(Note(
        id: '1',
        title: 'Note 1',
        content: 'Contains keyword Flutter',
        language: 'markdown',
        createdAt: now,
        updatedAt: now,
      ));

      await dbService.insertNote(Note(
        id: '2',
        title: 'Note 2',
        content: 'Contains keyword React',
        language: 'markdown',
        createdAt: now,
        updatedAt: now,
      ));

      final results = await dbService.searchNotes('Flutter');

      expect(results.length, 1);
      expect(results[0].content, contains('Flutter'));
    });

    test('Should toggle pin status', () async {
      final now = DateTime.now();
      final note = Note(
        id: '123',
        title: 'Test Note',
        content: 'Test content',
        language: 'markdown',
        createdAt: now,
        updatedAt: now,
        isPinned: false,
      );

      await dbService.insertNote(note);
      await dbService.togglePin('123');

      final retrieved = await dbService.getNoteById('123');
      expect(retrieved!.isPinned, true);

      await dbService.togglePin('123');
      final retrievedAgain = await dbService.getNoteById('123');
      expect(retrievedAgain!.isPinned, false);
    });

    test('Should return notes ordered by pinned status and update time', () async {
      final now = DateTime.now();

      await dbService.insertNote(Note(
        id: '1',
        title: 'Old Note',
        content: 'Content',
        language: 'markdown',
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
        isPinned: false,
      ));

      await dbService.insertNote(Note(
        id: '2',
        title: 'Recent Note',
        content: 'Content',
        language: 'markdown',
        createdAt: now,
        updatedAt: now,
        isPinned: false,
      ));

      await dbService.insertNote(Note(
        id: '3',
        title: 'Pinned Note',
        content: 'Content',
        language: 'markdown',
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
        isPinned: true,
      ));

      final notes = await dbService.getAllNotes();

      expect(notes[0].id, '3'); // Pinned note first
      expect(notes[1].id, '2'); // Recent note second
      expect(notes[2].id, '1'); // Old note last
    });
  });
}
