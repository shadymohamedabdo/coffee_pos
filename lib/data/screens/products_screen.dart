import 'package:flutter/material.dart';
import 'package:coffee_pos/data/models/product_model.dart';
import 'package:coffee_pos/data/repositories/products_repository.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final repo = ProductsRepository();

  List<Product> products = [];
  List<Product> filteredProducts = [];

  final nameCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final searchCtrl = TextEditingController();

  String category = 'bean';
  String unit = 'kg';
  String filterCategory = 'all';
  String filterUnit = 'all';

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    final data = await repo.getAllProducts();
    setState(() {
      products = data;
      applyFilters();
    });
  }

  void applyFilters() {
    final query = searchCtrl.text.toLowerCase();
    filteredProducts = products.where((p) {
      final categoryMatch =
          filterCategory == 'all' || p.category == filterCategory;
      final unitMatch = filterUnit == 'all' || p.unit == filterUnit;
      final searchMatch = p.name.toLowerCase().contains(query);
      return categoryMatch && unitMatch && searchMatch;
    }).toList();
  }

  Future<void> addProduct() async {
    if (nameCtrl.text.isEmpty || priceCtrl.text.isEmpty) return;

    await repo.addProduct(
      name: nameCtrl.text,
      category: category,
      unit: unit,
      price: double.parse(priceCtrl.text),
    );

    nameCtrl.clear();
    priceCtrl.clear();
    loadProducts();
  }

  void showEditPriceDialog(Product product) {
    final editPriceCtrl =
    TextEditingController(text: product.price.toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('تعديل سعر ${product.name}'),
        content: TextField(
          controller: editPriceCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'السعر الجديد',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newPrice = double.tryParse(editPriceCtrl.text);
              if (newPrice == null) return;

              await repo.updateProductPrice(product.id, newPrice);
              Navigator.pop(context);
              loadProducts();
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إدارة المنتجات')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // ===== إضافة منتج =====
            SizedBox(
              width: 350,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'إضافة منتج',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'اسم المنتج',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: priceCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'السعر',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: category,
                        items: const [
                          DropdownMenuItem(value: 'bean', child: Text('بن')),
                          DropdownMenuItem(
                              value: 'drink', child: Text('مشروب')),
                        ],
                        onChanged: (v) => setState(() => category = v!),
                        decoration: const InputDecoration(
                          labelText: 'الفئة',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: unit,
                        items: const [
                          DropdownMenuItem(value: 'kg', child: Text('كيلو')),
                          DropdownMenuItem(value: 'cup', child: Text('كوب')),
                        ],
                        onChanged: (v) => setState(() => unit = v!),
                        decoration: const InputDecoration(
                          labelText: 'الوحدة',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: addProduct,
                          child: const Text('إضافة'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(width: 20),

            // ===== قائمة المنتجات =====
            Expanded(
              child: Column(
                children: [
                  TextField(
                    controller: searchCtrl,
                    decoration: const InputDecoration(
                      labelText: 'بحث باسم المنتج',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => setState(applyFilters),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Card(
                      child: SingleChildScrollView(
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('الاسم')),
                            DataColumn(label: Text('السعر')),
                            DataColumn(label: Text('الوحدة')),
                            DataColumn(label: Text('إجراءات')),
                          ],
                          rows: filteredProducts.map((p) {
                            return DataRow(cells: [
                              DataCell(Text(p.name)),
                              DataCell(Text('${p.price}')),
                              DataCell(Text(p.unit)),
                              DataCell(
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.blue),
                                      onPressed: () =>
                                          showEditPriceDialog(p),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () async {
                                        await repo.deleteProduct(p.id);
                                        loadProducts();
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ]);
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
