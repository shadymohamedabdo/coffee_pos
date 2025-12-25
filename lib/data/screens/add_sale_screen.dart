import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../sale_cubit/sale_cubit.dart';

class AddSaleScreen extends StatefulWidget {
  final Map<String, dynamic> currentUser;

  const AddSaleScreen({super.key, required this.currentUser});

  @override
  State<AddSaleScreen> createState() => _AddSaleScreenState();
}

class _AddSaleScreenState extends State<AddSaleScreen> {
  final _quantityController = TextEditingController();
  final _amountController = TextEditingController();

  // لتجنب تحديث الكونترولر لو التغيير جاي من نفس الكونترولر
  bool _isUpdatingQuantity = false;
  bool _isUpdatingAmount = false;

  @override
  void dispose() {
    _quantityController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Color _getAmountColor(AddSaleState state) {
    if (state.unitPrice == 0) return Colors.grey;
    final double calculatedAmount = state.quantity * state.unitPrice;
    final double displayAmount = state.amount ?? calculatedAmount;
    if (displayAmount == 0) return Colors.red;
    if ((displayAmount - calculatedAmount).abs() > 0.01) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: Colors.white),
        title: const Text(
          'تسجيل بيع جديد',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const NetworkImage(
              'https://images.unsplash.com/photo-1497935586351-b67a49e012bf?ixlib=rb-4.0.3&auto=format&fit=crop&w=1920&q=80',
            ),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.5),
              BlendMode.darken,
            ),
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: 500,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: BlocConsumer<AddSaleCubit, AddSaleState>(
                listener: (context, state) {
                  if (state.errorMessage != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.errorMessage!)),
                    );
                  }
                  if (state.saleSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم تسجيل البيع بنجاح'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    _quantityController.clear();
                    _amountController.clear();
                  }

                  // Sync Quantity Controller
                  if (!_isUpdatingQuantity) {
                    double currentVal =
                        double.tryParse(_quantityController.text) ?? 0.0;
                    if ((currentVal - state.quantity).abs() > 0.001) {
                      _quantityController.text = state.quantity == 0
                          ? ''
                          : state.quantity.toStringAsFixed(3);
                    }
                  }

                  // Sync Amount Controller
                  if (!_isUpdatingAmount) {
                    double currentVal =
                        double.tryParse(_amountController.text) ?? 0.0;
                    // إذا كان amount null، نحسبه من الكمية * السعر
                    double targetAmount =
                        state.amount ?? (state.quantity * state.unitPrice);
                    if ((currentVal - targetAmount).abs() > 0.01) {
                      _amountController.text = targetAmount == 0
                          ? ''
                          : targetAmount.toStringAsFixed(2);
                    }
                  }
                },
                builder: (context, state) {
                  final bool isProductSelected =
                      state.selectedProductId != null;

                  if (state.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  }

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.point_of_sale,
                        size: 64,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 24),

                      // Category Dropdown
                      _buildDropdown(
                        label: 'النوع',
                        value: state.selectedCategory,
                        items: const [
                          DropdownMenuItem(value: 'bean', child: Text('بن')),
                          DropdownMenuItem(
                            value: 'drink',
                            child: Text('مشروب'),
                          ),
                        ],
                        onChanged: (v) {
                          context.read<AddSaleCubit>().selectCategory(v!);
                          _quantityController.clear();
                          _amountController.clear();
                        },
                      ),
                      const SizedBox(height: 16),

                      // Product Dropdown
                      if (state.selectedCategory != null)
                        _buildDropdown(
                          label: state.selectedCategory == 'bean'
                              ? 'نوع البن'
                              : 'المشروب',
                          value: state.selectedProductId,
                          items: state.products.map((p) {
                            return DropdownMenuItem<int>(
                              value: p['id'],
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(p['name']),
                                  Text(
                                    '${p['price']} ج/وحدة',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (v) {
                            context.read<AddSaleCubit>().selectProduct(v!);
                          },
                        ),

                      const SizedBox(height: 24),

                      // Inputs Section
                      if (state.selectedCategory == 'bean') ...[
                        // Bean Quick Options
                        Wrap(
                          spacing: 8,
                          children: [0.125, 0.25, 0.5, 1.0].map((qty) {
                            final isSelected =
                                (state.quantity - qty).abs() < 0.001;
                            return ChoiceChip(
                              label: Text(_getBeanLabel(qty)),
                              selected: isSelected,
                              onSelected: isProductSelected
                                  ? (s) {
                                      if (s) {
                                        _isUpdatingQuantity =
                                            true; // Flag to prevent loop
                                        context
                                            .read<AddSaleCubit>()
                                            .updateQuantity(qty);
                                        _isUpdatingQuantity = false;
                                      }
                                    }
                                  : null,
                              selectedColor: Colors.amber,
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.2,
                              ),
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.black : Colors.white,
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Quantity & Amount Fields
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _quantityController,
                              label:
                                  'الكمية (${state.products.firstWhere((element) => element['id'] == state.selectedProductId, orElse: () => {'unit': 'وحدة'})['unit'] ?? 'وحدة'})',
                              enabled: isProductSelected,
                              onChanged: (v) {
                                _isUpdatingQuantity = true;
                                final val = double.tryParse(v);
                                if (val != null)
                                  context.read<AddSaleCubit>().updateQuantity(
                                    val,
                                  );
                                _isUpdatingQuantity = false;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _amountController,
                              label: 'المبلغ (جنيه)',
                              enabled: isProductSelected,
                              onChanged: (v) {
                                _isUpdatingAmount = true;
                                final val = double.tryParse(v);
                                if (val != null)
                                  context.read<AddSaleCubit>().updateAmount(
                                    val,
                                  );
                                _isUpdatingAmount = false;
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Result Text
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _getAmountColor(state).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getAmountColor(
                              state,
                            ).withValues(alpha: 0.5),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '${state.quantity.toStringAsFixed(3)} الكمية',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const Text(
                              '=',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '${(state.amount ?? state.quantity * state.unitPrice).toStringAsFixed(2)} جنيه',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: state.isSaving || !isProductSelected
                              ? null
                              : () {
                                  context.read<AddSaleCubit>().saveSale(
                                    userId: widget.currentUser['id'],
                                    context: context,
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD2B48C),
                            foregroundColor: Colors.brown[900],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 6,
                          ),
                          child: state.isSaving
                              ? const CircularProgressIndicator(
                                  color: Colors.brown,
                                )
                              : const Text(
                                  'تسجيل البيع',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getBeanLabel(double qty) {
    if (qty == 0.125) return 'ثمن';
    if (qty == 0.25) return 'ربع';
    if (qty == 0.5) return 'نص';
    if (qty == 1.0) return 'كيلو';
    return qty.toString();
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          dropdownColor: Colors.brown[800],
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.black.withValues(alpha: 0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          iconEnabledColor: Colors.amber,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required ValueChanged<String> onChanged,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          onChanged: onChanged,
          enabled: enabled,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: enabled
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}
