import 'package:coffee_pos/data/models/product_model.dart';
import '../database_helper.dart';

class ProductsRepository {
  final dbHelper = DatabaseHelper.instance;

  Future<List<Product>> getAllProducts() async {
    final db = await dbHelper.database;
    final result = await db.query('products');
    return result.map((e) => Product.fromMap(e)).toList();
  }

  Future<void> addProduct({
    required String name,
    required String category,
    required String unit,
    required double price,
  }) async {
    final db = await dbHelper.database;
    await db.insert('products', {
      'name': name,
      'category': category,
      'unit': unit,
      'price': price,
    });
  }

  Future<void> updateProduct(Product product) async {
    final db = await dbHelper.database;
    await db.update(
      'products',
      {
        'name': product.name,
        'category': product.category,
        'unit': product.unit,
        'price': product.price,
      },
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<void> deleteProduct(int id) async {
    final db = await dbHelper.database;
    await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  Future<List<Map<String, dynamic>>> getProductsByCategory(String category) async {
    final db = await dbHelper.database;

    return await db.query(
      'products',
      where: 'category = ?',
      whereArgs: [category],
    );
  }

}
