import 'package:flutter/material.dart';
import '../repositories/products_repository.dart';
import '../repositories/sales_repository.dart';
import '../repositories/shifts_repository.dart';

class AddSaleScreen extends StatefulWidget {
  final Map<String, dynamic> currentUser;
  const AddSaleScreen({super.key, required this.currentUser});

  @override
  State<AddSaleScreen> createState() => _AddSaleScreenState();
}

class _AddSaleScreenState extends State<AddSaleScreen> {
  final productsRepo = ProductsRepository();
  final salesRepo = SalesRepository();
  final shiftsRepo = ShiftsRepository();

  String? selectedCategory; // bean | drink
  int? selectedProductId;
  double unitPrice = 0;
  double quantity = 1.0;
  double? amount; // لو الموظف دخل مبلغ محدد

  List<Map<String, dynamic>> products = []; // mutable list
  final qtyController = TextEditingController(text: '1');
  final amountController = TextEditingController();

  // ===== تحميل المنتجات حسب النوع =====
  Future<void> loadProducts(String category) async {
    final data = await productsRepo.getProductsByCategory(category);
    setState(() {
      products = List<Map<String, dynamic>>.from(data); // 👈 mutable copy
    });
  }

  // ===== حفظ عملية البيع =====
  Future<void> saveSale() async {
    if (selectedCategory == null || selectedProductId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اختار النوع والمنتج')),
      );
      return;
    }

    final shift = await shiftsRepo.getOpenShift();
    if (shift == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يوجد شيفت مفتوح')),
      );
      return;
    }

    final totalQuantity = quantity;

    await salesRepo.addSale(
      shiftId: shift['id'],
      userId: widget.currentUser['id'],
      productId: selectedProductId!,
      quantity: totalQuantity,
      unitPrice: unitPrice,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم تسجيل البيع')),
    );

    // ===== reset form =====
    setState(() {
      selectedCategory = null;
      selectedProductId = null;
      products = []; // 👈 بدل clear
      quantity = 1.0;
      amount = null;
      qtyController.text = '1';
      amountController.clear();
    });
  }

  Widget quantityOrAmountWidget() {
    Color getAmountColor() {
      if (amount == null || amount == 0) return Colors.red;
      if (amount! < quantity * unitPrice) return Colors.orange;
      return Colors.green;
    }

    if (selectedCategory == 'bean') {
      final beanOptions = {
        0.125: 'ثمن كيلو',
        0.25: 'ربع كيلو',
        0.5: 'نص كيلو',
        1.0: 'كيلو كامل',
      };

      return Column(
        children: [
          DropdownButtonFormField<double>(
            value: beanOptions.keys.contains(quantity) ? quantity : null,
            items: beanOptions.entries.map((e) {
              return DropdownMenuItem<double>(
                value: e.key,
                child: Text(e.value),
              );
            }).toList(),
            onChanged: (v) {
              setState(() {
                quantity = v!;
                amount = quantity * unitPrice;
                amountController.text = amount!.toStringAsFixed(2);
                qtyController.text = quantity.toStringAsFixed(3);
              });
            },
            decoration: const InputDecoration(
              labelText: 'اختر الكمية',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'أو أدخل المبلغ',
              border: OutlineInputBorder(),
            ),
            onChanged: (v) {
              final val = double.tryParse(v);
              if (val != null && unitPrice > 0) {
                setState(() {
                  amount = val;
                  quantity = val / unitPrice;
                  qtyController.text = quantity.toStringAsFixed(3);
                });
              }
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: qtyController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'أو عدل الكمية',
              border: OutlineInputBorder(),
            ),
            onChanged: (v) {
              final val = double.tryParse(v);
              if (val != null) {
                setState(() {
                  quantity = val;
                  amount = val * unitPrice;
                  amountController.text = amount!.toStringAsFixed(2);
                });
              }
            },
          ),
          const SizedBox(height: 8),
          Text(
            'المبلغ مقابل الكمية: ${quantity.toStringAsFixed(3)} كيلو = ${(amount ?? quantity * unitPrice).toStringAsFixed(2)} جنيه',
            style: TextStyle(
              fontSize: 16,
              color: getAmountColor(),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'الإجمالي: ${(amount ?? quantity * unitPrice).toStringAsFixed(2)} جنيه',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    } else if (selectedCategory == 'drink') {
      return Column(
        children: [
          TextFormField(
            controller: qtyController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'الكمية',
              border: OutlineInputBorder(),
            ),
            onChanged: (v) {
              final val = double.tryParse(v);
              if (val != null) {
                setState(() {
                  quantity = val;
                  amount = val * unitPrice;
                  amountController.text = amount!.toStringAsFixed(2);
                });
              }
            },
          ),
          const SizedBox(height: 8),
          Text(
            'المبلغ مقابل الكمية: ${quantity.toStringAsFixed(3)} وحدة = ${(amount ?? quantity * unitPrice).toStringAsFixed(2)} جنيه',
            style: TextStyle(
              fontSize: 16,
              color: getAmountColor(),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'الإجمالي: ${(amount ?? quantity * unitPrice).toStringAsFixed(2)} جنيه',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تسجيل بيع')),
      body: Center(
        child: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),

                // اختيار النوع
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  items: const [
                    DropdownMenuItem(value: 'bean', child: Text('بن')),
                    DropdownMenuItem(value: 'drink', child: Text('مشروب')),
                  ],
                  onChanged: (v) async {
                    setState(() {
                      selectedCategory = v;
                      selectedProductId = null;
                      unitPrice = 0;
                      products = []; // 👈 بدل clear
                      quantity = 1.0;
                      amount = null;
                      qtyController.text = '1';
                      amountController.clear();
                    });
                    await loadProducts(v!);
                  },
                  decoration: const InputDecoration(
                    labelText: 'اختر النوع',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                // اختيار المنتج
                if (selectedCategory != null)
                  DropdownButtonFormField<int>(
                    value: selectedProductId,
                    items: products.map((p) {
                      return DropdownMenuItem<int>(
                        value: p['id'],
                        child: Text(p['name']),
                      );
                    }).toList(),
                    onChanged: (v) {
                      final product = products.firstWhere((e) => e['id'] == v);
                      setState(() {
                        selectedProductId = v;
                        unitPrice = product['price'];
                        amount = quantity * unitPrice;
                        amountController.text = amount!.toStringAsFixed(2);
                      });
                    },
                    decoration: InputDecoration(
                      labelText: selectedCategory == 'bean'
                          ? 'اختر نوع البن'
                          : 'اختر المشروب',
                      border: const OutlineInputBorder(),
                    ),
                  ),

                const SizedBox(height: 16),

                // كمية البن أو المشروب أو مبلغ
                quantityOrAmountWidget(),

                const SizedBox(height: 20),

                // زر تسجيل البيع
                ElevatedButton(
                  onPressed: saveSale,
                  child: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text('تسجيل البيع'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
