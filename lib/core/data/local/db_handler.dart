import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  // Singleton instance
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Get the default database path
    String path = join(await getDatabasesPath(), 'my_database.db');

    // Open the database
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE library(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      book_name TEXT,
      scroll_location REAL,
      is_favorite INTEGER NOT NULL DEFAULT 0
    )
  ''');
  }

  Future<int> insertBook(String bookName, {double scrollLocation = 0.0}) async {
    final db = await database;

    return await db.insert(
      'library',
      {'book_name': bookName, 'scroll_location': scrollLocation},
      conflictAlgorithm: ConflictAlgorithm.ignore, // ignore if already exists
    );
  }

  /// Get a book by name
  Future<Map<String, dynamic>?> getBookByName(String bookName) async {
    final db = await database;

    final result = await db.query(
      'library',
      where: 'book_name = ?',
      whereArgs: [bookName],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return result.first;
  }

  Future<Map<String, dynamic>?> getBookById(int id) async {
    final db = await database;
    final result = await db.query(
      'library',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return result.first;
  }

  Future<bool> updateBookScroll(int id, double scrollLocation) async {
    final db = await database;
    int result = await db.update(
      'library',
      {'scroll_location': scrollLocation},
      where: 'id =?',
      whereArgs: [id],
    );
    return result > 0;
  }

  Future<bool> toggleIsFavorite(int id, bool state) async {
    final db = await database;

    final result = await db.update(
      'library',
      {'is_favorite': state ? 1 : 0}, // ✅ convert to int
      where: 'id = ?',
      whereArgs: [id],
    );

    return result > 0;
  }
}
