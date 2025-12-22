import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _db;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB('coffee_pos.db');
    return _db!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 5,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // جدول المستخدمين
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        role TEXT,
        username TEXT UNIQUE,
        password TEXT
      )
    ''');

    // جدول المنتجات
    await db.execute('''
      CREATE TABLE IF NOT EXISTS products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        category TEXT,
        unit TEXT,
        price REAL
      )
    ''');

    // جدول المبيعات
    await db.execute('''
      CREATE TABLE IF NOT EXISTS sales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER,
        quantity REAL,
        unit_price REAL,
        total REAL,
        user_id INTEGER,
        shift_id INTEGER,
        status TEXT DEFAULT 'active',
        created_at TEXT
      )
    ''');


    // جدول الشيفتات
    await db.execute('''
      CREATE TABLE IF NOT EXISTS shifts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT,
        date TEXT,
        is_open INTEGER
      )
    ''');

    await _createDefaultAdmin(db);
  }

  Future<void> _createDefaultAdmin(Database db) async {
    final result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: ['admin'],
    );

    if (result.isEmpty) {
      await db.insert('users', {
        'name': 'شادي',
        'role': 'admin',
        'username': 'shady',
        'password': '1234',
      });
    }
  }
}
