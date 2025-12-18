import '../database_helper.dart';
import '../models/dashboard_model.dart';

class DashboardRepository {
  /// جلب المبيعات اليومية لشهر معين
  Future<List<DailySale>> getDailySales(int month, int year) async {
    final db = await DatabaseHelper.instance.database;
    final monthStr = month.toString().padLeft(2, '0');

    final result = await db.rawQuery('''
      SELECT strftime('%d', created_at) as day,
             SUM(quantity * unit_price) as total
      FROM sales
      WHERE strftime('%m', created_at) = ?
        AND strftime('%Y', created_at) = ?
      GROUP BY day
      ORDER BY day
    ''', [monthStr, year.toString()]);

    return result.map((e) => DailySale(
      day: e['day']?.toString() ?? '',
      total: (e['total'] as num?)?.toDouble() ?? 0.0,
    )).toList();
  }

  /// جلب أعلى 5 منتجات مبيعًا لشهر معين
  Future<List<ProductSale>> getTopProducts(int month, int year) async {
    final db = await DatabaseHelper.instance.database;
    final monthStr = month.toString().padLeft(2, '0');

    final result = await db.rawQuery('''
      SELECT p.name as product_name,
             SUM(s.quantity) as total
      FROM sales s
      JOIN products p ON s.product_id = p.id
      WHERE strftime('%m', s.created_at) = ?
        AND strftime('%Y', s.created_at) = ?
      GROUP BY s.product_id
      ORDER BY total DESC
      LIMIT 5
    ''', [monthStr, year.toString()]);

    return result.map((e) => ProductSale(
      productName: e['product_name']?.toString() ?? '',
      total: (e['total'] as num?)?.toDouble() ?? 0.0,
    )).toList();
  }
}
