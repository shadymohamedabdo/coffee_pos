import '../database_helper.dart';

class SalesRepository {
  final dbHelper = DatabaseHelper.instance;

  // إضافة عملية بيع
  Future<void> addSale({
    required int shiftId,
    required int userId,
    required int productId,
    required double quantity,
    required double unitPrice,
    String status = 'active',                // ← هنا
    String? createdAt,                        // ← هنا
  }) async {
    final db = await dbHelper.database;
    await db.insert('sales', {
      'shift_id': shiftId,
      'user_id': userId,
      'product_id': productId,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total': quantity * unitPrice,
      'status': status,
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
    });
  }


  // 🟥 هنا الدالة الجديدة لتحديث حالة البيع
  Future<void> updateSaleStatus(int saleId, String newStatus) async {
    final db = await dbHelper.database;
    await db.update(
      'sales',
      {'status': newStatus},
      where: 'id = ?',
      whereArgs: [saleId],
    );
    // 🔥 السطر ده هو اللي هيخلي "تقرير الشهر" وكل الصفحات تحس بالتغيير
    DatabaseHelper.notifySalesChanged();
  }

  // جلب كل المبيعات لشيفت معين
  Future<List<Map<String, dynamic>>> getSalesByShift(int shiftId) async {
    final db = await dbHelper.database;
    return await db.query(
      'sales',
      where: 'shift_id = ?',
      whereArgs: [shiftId],
    );
  }
}
