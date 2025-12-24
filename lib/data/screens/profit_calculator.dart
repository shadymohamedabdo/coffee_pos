import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/reports_repository.dart';

class ProfitCalculatorScreen extends StatefulWidget {
  const ProfitCalculatorScreen({super.key});

  @override
  State<ProfitCalculatorScreen> createState() => _ProfitCalculatorScreenState();
}

class _ProfitCalculatorScreenState extends State<ProfitCalculatorScreen> {
  final repo = ReportsRepository();
  final rentCtrl = TextEditingController();
  final salariesCtrl = TextEditingController();
  final electricityCtrl = TextEditingController();
  final waterCtrl = TextEditingController();
  final otherCtrl = TextEditingController();

  double totalSales = 0.0;
  double netProfit = 0.0;
  bool isLoading = true;
  bool calculated = false;

  final _formatter = NumberFormat('#,##0', 'ar_EG');

  @override
  void initState() {
    super.initState();
    loadMonthlySales();
  }

  Future<void> loadMonthlySales() async {
    setState(() => isLoading = true);

    final now = DateTime.now();
    try {
      final data = await repo.getMonthlyReport(
        month: now.month,
        year: now.year,
      );

      final sales = data.fold<double>(
        0.0,
            (sum, item) => sum + (item['total_amount'] as double),
      );

      setState(() {
        totalSales = sales;
        isLoading = false;
        if (calculated) calculate(); // إعادة حساب لو كان محسوب
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل تحميل المبيعات، حاول لاحقًا')),
        );
      }
    }
  }

  void calculate() {
    final rent = double.tryParse(rentCtrl.text.replaceAll(',', '')) ?? 0;
    final salaries = double.tryParse(salariesCtrl.text.replaceAll(',', '')) ?? 0;
    final electricity = double.tryParse(electricityCtrl.text.replaceAll(',', '')) ?? 0;
    final water = double.tryParse(waterCtrl.text.replaceAll(',', '')) ?? 0;
    final other = double.tryParse(otherCtrl.text.replaceAll(',', '')) ?? 0;

    final totalExpenses = rent + salaries + electricity + water + other;

    setState(() {
      netProfit = totalSales - totalExpenses;
      calculated = true;
    });
  }

  void clearFields() {
    rentCtrl.clear();
    salariesCtrl.clear();
    electricityCtrl.clear();
    waterCtrl.clear();
    otherCtrl.clear();
    setState(() => calculated = false);
  }

  Widget buildField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.attach_money),
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: controller.clear,
        ),
      ),
      onChanged: (_) => setState(() => calculated = false),
    );
  }

  @override
  void dispose() {
    rentCtrl.dispose();
    salariesCtrl.dispose();
    electricityCtrl.dispose();
    waterCtrl.dispose();
    otherCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حاسبة صافي الربح'),
        backgroundColor: Colors.teal[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'تحديث إجمالي المبيعات',
            onPressed: loadMonthlySales, // زر تحديث يدوي
          ),
        ],
      ),
      body: Center(
        child: SizedBox(
          width: 500,
          child: Card(
            margin: const EdgeInsets.all(24),
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // إجمالي المبيعات
                    Card(
                      color: Colors.teal[50],
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: isLoading
                            ? const CircularProgressIndicator()
                            : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.trending_up, color: Colors.teal, size: 32),
                            const SizedBox(width: 12),
                            Text(
                              'إجمالي مبيعات الشهر: ${_formatter.format(totalSales)} جنيه',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // الحقول
                    buildField('إيجار المحل', rentCtrl),
                    const SizedBox(height: 12),
                    buildField('مرتبات الموظفين', salariesCtrl),
                    const SizedBox(height: 12),
                    buildField('فاتورة الكهرباء', electricityCtrl),
                    const SizedBox(height: 12),
                    buildField('بضاعه', waterCtrl),
                    const SizedBox(height: 12),
                    buildField('مصروفات أخرى', otherCtrl),

                    const SizedBox(height: 24),

                    // الأزرار
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: calculate,
                            icon: const Icon(Icons.calculate),
                            label: const Text('احسب الصافي', style: TextStyle(fontSize: 18)),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Colors.teal[600],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: clearFields,
                          icon: const Icon(Icons.refresh),
                          label: const Text('مسح'),
                        ),
                      ],
                    ),

                    // النتيجة
                    if (calculated) ...[
                      const SizedBox(height: 32),
                      Card(
                        elevation: 6,
                        color: netProfit >= 0 ? Colors.green[50] : Colors.red[50],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: netProfit >= 0 ? Colors.green : Colors.red,
                            width: 3,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              Icon(
                                netProfit >= 0 ? Icons.thumb_up : Icons.thumb_down,
                                size: 48,
                                color: netProfit >= 0 ? Colors.green : Colors.red,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                netProfit >= 0
                                    ? 'صافي الربح: ${_formatter.format(netProfit)} جنيه'
                                    : 'صافي الخسارة: ${_formatter.format(netProfit.abs())} جنيه',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: netProfit >= 0 ? Colors.green[800] : Colors.red[800],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}