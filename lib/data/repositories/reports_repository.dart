
import '../database_helper.dart';

class ReportsRepository {
  Future<List<Map<String, dynamic>>> getMonthlyReport({
    required int month,
    required int year,
  }) async {
    final db = await DatabaseHelper.instance.database;

    final monthStr = month.toString().padLeft(2, '0');

    return await db.rawQuery('''
      SELECT 
        p.name AS product_name,
        SUM(s.quantity) AS total_quantity,
        s.unit_price,
        SUM(s.quantity * s.unit_price) AS total_amount
      FROM sales s
      JOIN products p ON s.product_id = p.id
      WHERE strftime('%m', s.created_at) = ?
      AND strftime('%Y', s.created_at) = ?
      AND s.status = 'active'  -- 🔥 السطر ده هو اللي هيحل المشكلة
      GROUP BY s.product_id
    ''', [monthStr, year.toString()]);  }
}
