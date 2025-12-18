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
      version: 2, // خلي version = 2 عشان نقدر نعمل upgrade للـ columns الجديدة
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  // إنشاء الجداول عند أول تشغيل
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        role TEXT,
        username TEXT UNIQUE,
        password TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        category TEXT,
        unit TEXT,
        price REAL
      )
    ''');

    await db.execute('''
      CREATE TABLE shifts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT,
        date TEXT,
        is_open INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE sales (
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

    await _createDefaultAdmin(db);
  }

  // تحديث قاعدة البيانات القديمة
  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    // لو نسخة القاعدة القديمة أقل من 2
    if (oldVersion < 2) {
      final tableInfo = await db.rawQuery('PRAGMA table_info(sales)');
      final columns = tableInfo.map((c) => c['name'].toString()).toList();

      if (!columns.contains('status')) {
        await db.execute(
            'ALTER TABLE sales ADD COLUMN status TEXT DEFAULT "active"');
      }

      if (!columns.contains('created_at')) {
        await db.execute('ALTER TABLE sales ADD COLUMN created_at TEXT');
      }
    }
  }

  // إنشاء Admin افتراضي
  Future<void> _createDefaultAdmin(Database db) async {
    final result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: ['admin'],
    );

    if (result.isEmpty) {
      await db.insert('users', {
        'name': 'Admin',
        'role': 'admin',
        'username': 'admin',
        'password': '1234',
      });
    }
  }
}
