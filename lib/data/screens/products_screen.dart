import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/product_model.dart';
import '../products_cubit/products_cubit.dart';
import '../products_cubit/products_state.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final nameCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final searchCtrl = TextEditingController();

  String category = 'bean';
  String unit = 'kg';

  List<Product> filteredProducts = [];

  @override
  void initState() {
    super.initState();

    // تحميل المنتجات مرة واحدة
    context.read<ProductsCubit>().loadProducts();
  }

  void applyFilters(List<Product> products) {
    final q = searchCtrl.text.toLowerCase();
    filteredProducts = products
        .where((p) => p.name.toLowerCase().contains(q))
        .toList();
  }

  void showEditPriceDialog(Product product) {
    final editPriceCtrl = TextEditingController(text: product.price.toString());

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
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
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              final newPrice = double.tryParse(editPriceCtrl.text);
              if (newPrice == null) return;

              // نستخدم context بتاع الشاشة مش dialog
              context.read<ProductsCubit>().updatePrice(product.id, newPrice);

              Navigator.pop(dialogContext);
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
      body: BlocBuilder<ProductsCubit, ProductsState>(
        builder: (context, state) {
          if (state is ProductsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProductsLoaded) {
            applyFilters(state.products);

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // ===== إضافة منتج =====
                  SizedBox(
                    width: 320,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: nameCtrl,
                              decoration: const InputDecoration(
                                labelText: 'اسم المنتج',
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: priceCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'السعر',
                              ),
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField(
                              initialValue: category,
                              items: const [
                                DropdownMenuItem(
                                  value: 'bean',
                                  child: Text('بن'),
                                ),
                                DropdownMenuItem(
                                  value: 'drink',
                                  child: Text('مشروب'),
                                ),
                              ],
                              onChanged: (v) => category = v!,
                              decoration: const InputDecoration(
                                labelText: 'الفئة',
                              ),
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField(
                              value: unit,
                              items: const [
                                DropdownMenuItem(
                                  value: 'kg',
                                  child: Text('كيلو'),
                                ),
                                DropdownMenuItem(
                                  value: 'cup',
                                  child: Text('كوب'),
                                ),
                              ],
                              onChanged: (v) => unit = v!,
                              decoration: const InputDecoration(
                                labelText: 'الوحدة',
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  context.read<ProductsCubit>().addProduct(
                                    name: nameCtrl.text,
                                    category: category,
                                    unit: unit,
                                    price: double.parse(priceCtrl.text),
                                  );
                                  nameCtrl.clear();
                                  priceCtrl.clear();
                                },
                                child: const Text('إضافة'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 20),

                  // ===== الجدول =====
                  Expanded(
                    child: Column(
                      children: [
                        TextField(
                          controller: searchCtrl,
                          decoration: const InputDecoration(labelText: 'بحث'),
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: SingleChildScrollView(
                            child: DataTable(
                              columns: const [
                                DataColumn(label: Text('الاسم')),
                                DataColumn(label: Text('السعر')),
                                DataColumn(label: Text('الوحدة')),
                                DataColumn(label: Text('إجراءات')),
                              ],
                              rows: filteredProducts.map((p) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text(p.name)),
                                    DataCell(Text('${p.price}')),
                                    DataCell(Text(p.unit)),
                                    DataCell(
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.edit,
                                              color: Colors.blue,
                                            ),
                                            onPressed: () =>
                                                showEditPriceDialog(p),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                            onPressed: () => context
                                                .read<ProductsCubit>()
                                                .deleteProduct(p.id),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is ProductsError) {
            return Center(child: Text(state.message));
          }

          return const SizedBox();
        },
      ),
    );
  }
}
