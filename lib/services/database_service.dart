import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/note.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'gonotes.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notes (
        id TEXT PRIMARY KEY,
        guid TEXT NOT NULL UNIQUE,
        title TEXT NOT NULL,
        description TEXT,
        body TEXT NOT NULL,
        tags TEXT,
        isPrivate INTEGER NOT NULL DEFAULT 0,
        encryptionIv TEXT,
        createdBy TEXT,
        updatedBy TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        authoredAt TEXT,
        syncedAt TEXT,
        deletedAt TEXT,
        language TEXT NOT NULL,
        isPinned INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Create indexes for searching and sync
    await db.execute('''
      CREATE INDEX idx_guid ON notes(guid)
    ''');

    await db.execute('''
      CREATE INDEX idx_title ON notes(title)
    ''');

    await db.execute('''
      CREATE INDEX idx_updated ON notes(updatedAt DESC)
    ''');

    await db.execute('''
      CREATE INDEX idx_synced ON notes(syncedAt)
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add new columns for gonotes compatibility
      await db.execute('ALTER TABLE notes ADD COLUMN guid TEXT');
      await db.execute('ALTER TABLE notes ADD COLUMN description TEXT');
      await db.execute('ALTER TABLE notes ADD COLUMN body TEXT');
      await db.execute('ALTER TABLE notes ADD COLUMN tags TEXT');
      await db.execute('ALTER TABLE notes ADD COLUMN isPrivate INTEGER NOT NULL DEFAULT 0');
      await db.execute('ALTER TABLE notes ADD COLUMN encryptionIv TEXT');
      await db.execute('ALTER TABLE notes ADD COLUMN createdBy TEXT');
      await db.execute('ALTER TABLE notes ADD COLUMN updatedBy TEXT');
      await db.execute('ALTER TABLE notes ADD COLUMN authoredAt TEXT');
      await db.execute('ALTER TABLE notes ADD COLUMN syncedAt TEXT');
      await db.execute('ALTER TABLE notes ADD COLUMN deletedAt TEXT');

      // Migrate existing data: copy content to body, generate GUIDs
      final notes = await db.query('notes');
      for (final note in notes) {
        final id = note['id'] as String;
        await db.update(
          'notes',
          {
            'guid': id, // Use existing id as guid for migration
            'body': note['content'], // Copy content to body
          },
          where: 'id = ?',
          whereArgs: [id],
        );
      }

      // Create new indexes
      await db.execute('CREATE INDEX idx_guid ON notes(guid)');
      await db.execute('CREATE INDEX idx_synced ON notes(syncedAt)');
    }
  }

  Future<List<Note>> getAllNotes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      orderBy: 'isPinned DESC, updatedAt DESC',
    );

    return List.generate(maps.length, (i) => Note.fromMap(maps[i]));
  }

  Future<Note?> getNoteById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return Note.fromMap(maps.first);
  }

  Future<List<Note>> searchNotes(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      where: 'title LIKE ? OR body LIKE ? OR tags LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'isPinned DESC, updatedAt DESC',
    );

    return List.generate(maps.length, (i) => Note.fromMap(maps[i]));
  }

  Future<void> insertNote(Note note) async {
    final db = await database;
    await db.insert(
      'notes',
      note.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateNote(Note note) async {
    final db = await database;
    await db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<void> deleteNote(String id) async {
    final db = await database;
    await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> togglePin(String id) async {
    final note = await getNoteById(id);
    if (note != null) {
      await updateNote(note.copyWith(
        isPinned: !note.isPinned,
        updatedAt: DateTime.now(),
      ));
    }
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
