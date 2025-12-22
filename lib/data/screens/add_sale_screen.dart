import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../sale_cubit/sale_cubit.dart';

class AddSaleScreen extends StatelessWidget {
  final Map<String, dynamic> currentUser;

  const AddSaleScreen({super.key, required this.currentUser});

  Color _getAmountColor(AddSaleState state) {
    final double calculatedAmount = state.quantity * state.unitPrice;
    final double displayAmount = state.amount ?? calculatedAmount;
    if (displayAmount == 0) return Colors.red;
    if (displayAmount < calculatedAmount) return Colors.orange;
    return Colors.green;
  }

  Widget _quantityOrAmountWidget(BuildContext context, AddSaleState state) {
    // ... (نفس الكود اللي عندك بالضبط، مفيش تغيير)
    if (state.selectedCategory == 'bean') {
      final beanOptions = {
        0.125: 'ثمن كيلو',
        0.25: 'ربع كيلو',
        0.5: 'نص كيلو',
        1.0: 'كيلو كامل',
      };
      return Column(
        children: [
          DropdownButtonFormField<double>(
            value: beanOptions.keys.contains(state.quantity) ? state.quantity : null,
            items: beanOptions.entries.map((e) {
              return DropdownMenuItem<double>(value: e.key, child: Text(e.value));
            }).toList(),
            onChanged: (v) => context.read<AddSaleCubit>().updateQuantity(v!),
            decoration: const InputDecoration(labelText: 'اختر الكمية', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: state.amount?.toStringAsFixed(2) ?? '',
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'أو أدخل المبلغ', border: OutlineInputBorder()),
            onChanged: (v) {
              final val = double.tryParse(v);
              if (val != null) context.read<AddSaleCubit>().updateAmount(val);
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: state.quantity.toStringAsFixed(3),
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'أو عدل الكمية', border: OutlineInputBorder()),
            onChanged: (v) {
              final val = double.tryParse(v);
              if (val != null) context.read<AddSaleCubit>().updateQuantity(val);
            },
          ),
          const SizedBox(height: 8),
          Text(
            'المبلغ مقابل الكمية: ${state.quantity.toStringAsFixed(3)} كيلو = ${(state.amount ?? state.quantity * state.unitPrice).toStringAsFixed(2)} جنيه',
            style: TextStyle(fontSize: 16, color: _getAmountColor(state), fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            'الإجمالي: ${(state.amount ?? state.quantity * state.unitPrice).toStringAsFixed(2)} جنيه',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      );
    } else if (state.selectedCategory == 'drink') {
      return Column(
        children: [
          TextFormField(
            initialValue: state.quantity.toStringAsFixed(3),
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'الكمية', border: OutlineInputBorder()),
            onChanged: (v) {
              final val = double.tryParse(v);
              if (val != null) context.read<AddSaleCubit>().updateQuantity(val);
            },
          ),
          const SizedBox(height: 8),
          Text(
            'المبلغ مقابل الكمية: ${state.quantity.toStringAsFixed(3)} وحدة = ${(state.amount ?? state.quantity * state.unitPrice).toStringAsFixed(2)} جنيه',
            style: TextStyle(fontSize: 16, color: _getAmountColor(state), fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            'الإجمالي: ${(state.amount ?? state.quantity * state.unitPrice).toStringAsFixed(2)} جنيه',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white10,
        elevation: 0,

      ),
      extendBodyBehindAppBar: true, // عشان الخلفية تكمل تحت الـ AppBar
      body: Stack(
        children: [
          // ===== الخلفية =====
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/coffe.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // ===== طبقة داكنة شفافة عشان الوضوح =====
          Container(
            color: Colors.black.withOpacity(0.4),
          ),

          // ===== المحتوى الأساسي (الفورم) =====
          Center(
            child: SizedBox(
              width: 420,
              child: Card(
                elevation: 12,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                color: Colors.white.withOpacity(0.95), // خلفية بيضاء شفافة شوية
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: BlocConsumer<AddSaleCubit, AddSaleState>(
                    listener: (context, state) {
                      if (state.errorMessage != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(state.errorMessage!)),
                        );
                      }
                      if (state.saleSuccess) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تم تسجيل البيع')),
                        );
                      }
                    },
                    builder: (context, state) {
                      if (state.isLoading) {
                        return const Center(child: CircularProgressIndicator(color: Colors.brown));
                      }

                      return SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 20),
                            DropdownButtonFormField<String>(
                              value: state.selectedCategory,
                              items: const [
                                DropdownMenuItem(value: 'bean', child: Text('بن')),
                                DropdownMenuItem(value: 'drink', child: Text('مشروب')),
                              ],
                              onChanged: (v) => context.read<AddSaleCubit>().selectCategory(v!),
                              decoration: const InputDecoration(
                                labelText: 'اختر النوع',
                                border: OutlineInputBorder(),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (state.selectedCategory != null)
                              DropdownButtonFormField<int>(
                                value: state.selectedProductId,
                                items: state.products.map((p) {
                                  return DropdownMenuItem<int>(value: p['id'], child: Text(p['name']));
                                }).toList(),
                                onChanged: (v) => context.read<AddSaleCubit>().selectProduct(v!),
                                decoration: InputDecoration(
                                  labelText: state.selectedCategory == 'bean' ? 'اختر نوع البن' : 'اختر المشروب',
                                  border: const OutlineInputBorder(),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                              ),
                            const SizedBox(height: 16),
                            _quantityOrAmountWidget(context, state),
                            const SizedBox(height: 30),
                            ElevatedButton(
                              onPressed: state.isSaving
                                  ? null
                                  : () {
                                context.read<AddSaleCubit>().saveSale(
                                  userId: currentUser['id'],
                                  context: context,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.brown[700],
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              child: state.isSaving
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text('تسجيل البيع', style: TextStyle(fontSize: 18, color: Colors.white)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}