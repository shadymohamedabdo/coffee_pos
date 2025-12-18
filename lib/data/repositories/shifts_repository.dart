import '../database_helper.dart';

class ShiftsRepository {
  Future<Map<String, dynamic>?> getOpenShift() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(
      'shifts',
      where: 'is_open = ?',
      whereArgs: [1],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<void> openShift(String type) async {
    final db = await DatabaseHelper.instance.database;
    final open = await getOpenShift();
    if (open != null) return;
    await db.insert('shifts', {
      'type': type,
      'date': DateTime.now().toIso8601String(),
      'is_open': 1
    });
  }

  Future<void> closeShift(int id) async {
    final db = await DatabaseHelper.instance.database;
    await db.update('shifts', {'is_open': 0}, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getAllShifts() async {
    final db = await DatabaseHelper.instance.database;
    return await db.query('shifts');
  }
}
