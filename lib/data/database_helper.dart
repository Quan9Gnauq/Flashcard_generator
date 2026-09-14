import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'models.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('flashcards.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE decks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE vocabs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        deckId INTEGER NOT NULL,
        frontText TEXT NOT NULL,
        meaning TEXT NOT NULL,
        reading TEXT,
        example TEXT,
        imagePath TEXT,
        status INTEGER DEFAULT 0, -- THÊM CỘT TRẠNG THÁI
        FOREIGN KEY (deckId) REFERENCES decks (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<int> insertDeck(Deck deck) async {
    final db = await instance.database;
    return await db.insert('decks', deck.toMap());
  }

  Future<int> insertVocab(Vocab vocab) async {
    final db = await instance.database;
    return await db.insert('vocabs', vocab.toMap());
  }

  Future<List<Deck>> getAllDecks() async {
    final db = await instance.database;
    final result = await db.query('decks');
    return result.map((json) => Deck(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
    )).toList();
  }
  Future<List<Vocab>> getVocabsByDeckId(int deckId) async {
    final db = await instance.database;
    final result = await db.query('vocabs', where: 'deckId = ?', whereArgs: [deckId]);
    return result.map((json) => Vocab(
      id: json['id'] as int,
      deckId: json['deckId'] as int,
      frontText: json['frontText'] as String,
      meaning: json['meaning'] as String,
      reading: json['reading'] as String?,
      example: json['example'] as String?,
      imagePath: json['imagePath'] as String?,
      status: json['status'] as int? ?? 0, // Đọc trạng thái
    )).toList();
  }
  Future<void> deleteDeck(int deckId) async {
    final db = await instance.database;

    await db.delete('vocabs', where: 'deckId = ?', whereArgs: [deckId]);

    await db.delete('decks', where: 'id = ?', whereArgs: [deckId]);
  }
  Future<int> updateVocabStatus(int id, int status) async {
    final db = await instance.database;
    return await db.update(
      'vocabs',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
