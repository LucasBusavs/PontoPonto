import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        content TEXT NOT NULL
      )
    ''');
  }

  Future<int> insert(String content) async {
    final db = await instance.database;
    return await db.insert('notes', {'content': content});
  }

  Future<List<Map<String, dynamic>>> fetchAll() async {
    final db = await instance.database;
    return await db.query('notes', orderBy: 'id DESC');
  }

  Future<int> update(int id, String content) async {
    final db = await instance.database;
    return await db.update(
      'notes',
      {'content': content},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await _database;
    db?.close();
  }
}