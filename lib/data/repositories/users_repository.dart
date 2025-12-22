import '../database_helper.dart';

class UsersRepository {
  final dbHelper = DatabaseHelper.instance;
  // users_repository.dart
  Future<void> deleteUser(int id) async {
    final db = await dbHelper.database;
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }


  // ===== إضافة موظف =====
  Future<void> addUser({
    required String name,
    required String username,
    required String password,
    required String role,
  }) async {
    final db = await dbHelper.database;

    await db.insert('users', {
      'name': name,
      'username': username,
      'password': password,
      'role': role,
    });
  }

  // ===== جلب كل الموظفين =====
  Future<List<Map<String, dynamic>>> getAllEmployees() async {
    final db = await dbHelper.database;
    return await db.query(
      'users',
      // احذف where لو عايز كل المستخدمين
      // or استخدم شرط يناسبك
    );
  }


  // ===== تسجيل الدخول =====
  Future<Map<String, dynamic>?> login(
      String username, String password) async {
    final db = await dbHelper.database;

    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first; // بيانات المستخدم كاملة
    } else {
      return null;
    }
  }
}
