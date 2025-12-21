import 'package:flutter_test/flutter_test.dart';
import 'package:gonotes/models/note.dart';

void main() {
  group('Note Model Tests', () {
    test('Note should be created with all required fields', () {
      final now = DateTime.now();
      final note = Note(
        id: '123',
        title: 'Test Note',
        content: 'Test content',
        language: 'markdown',
        createdAt: now,
        updatedAt: now,
      );

      expect(note.id, '123');
      expect(note.title, 'Test Note');
      expect(note.content, 'Test content');
      expect(note.language, 'markdown');
      expect(note.isPinned, false);
    });

    test('Note should convert to map correctly', () {
      final now = DateTime.now();
      final note = Note(
        id: '123',
        title: 'Test Note',
        content: 'Test content',
        language: 'markdown',
        createdAt: now,
        updatedAt: now,
        isPinned: true,
      );

      final map = note.toMap();

      expect(map['id'], '123');
      expect(map['title'], 'Test Note');
      expect(map['content'], 'Test content');
      expect(map['language'], 'markdown');
      expect(map['isPinned'], 1);
      expect(map['createdAt'], now.toIso8601String());
      expect(map['updatedAt'], now.toIso8601String());
    });

    test('Note should be created from map correctly', () {
      final now = DateTime.now();
      final map = {
        'id': '123',
        'title': 'Test Note',
        'content': 'Test content',
        'language': 'markdown',
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
        'isPinned': 1,
      };

      final note = Note.fromMap(map);

      expect(note.id, '123');
      expect(note.title, 'Test Note');
      expect(note.content, 'Test content');
      expect(note.language, 'markdown');
      expect(note.isPinned, true);
    });

    test('Note copyWith should create a new instance with updated fields', () {
      final now = DateTime.now();
      final note = Note(
        id: '123',
        title: 'Test Note',
        content: 'Test content',
        language: 'markdown',
        createdAt: now,
        updatedAt: now,
      );

      final updatedNote = note.copyWith(
        title: 'Updated Title',
        isPinned: true,
      );

      expect(updatedNote.id, '123');
      expect(updatedNote.title, 'Updated Title');
      expect(updatedNote.content, 'Test content');
      expect(updatedNote.isPinned, true);
      expect(updatedNote.language, 'markdown');
    });

    test('Notes with same id should be equal', () {
      final now = DateTime.now();
      final note1 = Note(
        id: '123',
        title: 'Test Note 1',
        content: 'Content 1',
        language: 'markdown',
        createdAt: now,
        updatedAt: now,
      );

      final note2 = Note(
        id: '123',
        title: 'Test Note 2',
        content: 'Content 2',
        language: 'python',
        createdAt: now,
        updatedAt: now,
      );

      expect(note1, equals(note2));
      expect(note1.hashCode, equals(note2.hashCode));
    });

    test('Notes with different ids should not be equal', () {
      final now = DateTime.now();
      final note1 = Note(
        id: '123',
        title: 'Test Note',
        content: 'Content',
        language: 'markdown',
        createdAt: now,
        updatedAt: now,
      );

      final note2 = Note(
        id: '456',
        title: 'Test Note',
        content: 'Content',
        language: 'markdown',
        createdAt: now,
        updatedAt: now,
      );

      expect(note1, isNot(equals(note2)));
    });
  });
}
