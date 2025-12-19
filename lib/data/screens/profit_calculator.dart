import 'package:flutter/material.dart';
import '../repositories/reports_repository.dart';

class ProfitCalculatorScreen extends StatefulWidget {
  const ProfitCalculatorScreen({super.key});

  @override
  State<ProfitCalculatorScreen> createState() =>
      _ProfitCalculatorScreenState();
}

class _ProfitCalculatorScreenState extends State<ProfitCalculatorScreen> {
  final repo = ReportsRepository();

  final rentCtrl = TextEditingController();
  final salariesCtrl = TextEditingController();
  final electricityCtrl = TextEditingController();
  final waterCtrl = TextEditingController();
  final otherCtrl = TextEditingController();

  double totalSales = 0;
  double netProfit = 0;
  bool calculated = false;

  @override
  void initState() {
    super.initState();
    loadMonthlySales();
  }

  Future<void> loadMonthlySales() async {
    final now = DateTime.now();
    final data = await repo.getMonthlyReport(
      month: now.month,
      year: now.year,
    );

    setState(() {
      totalSales = data.fold(
        0,
            (sum, item) => sum + (item['total_amount'] as double),
      );
    });
  }

  void calculate() {
    final rent = double.tryParse(rentCtrl.text) ?? 0;
    final salaries = double.tryParse(salariesCtrl.text) ?? 0;
    final electricity = double.tryParse(electricityCtrl.text) ?? 0;
    final water = double.tryParse(waterCtrl.text) ?? 0;
    final other = double.tryParse(otherCtrl.text) ?? 0;

    final totalExpenses =
        rent + salaries + electricity + water + other;

    setState(() {
      netProfit = totalSales - totalExpenses;
      calculated = true;
    });
  }

  Widget buildField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.money),
        border: const OutlineInputBorder(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('حاسبة صافي الربح')),
      body: Center(
        child: SizedBox(
          width: 500,
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      'إجمالي مبيعات الشهر: $totalSales جنيه',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 24),

                    buildField('إيجار المحل', rentCtrl),
                    const SizedBox(height: 12),
                    buildField('مرتبات الموظفين', salariesCtrl),
                    const SizedBox(height: 12),
                    buildField('كهرباء', electricityCtrl),
                    const SizedBox(height: 12),
                    buildField('مياه', waterCtrl),
                    const SizedBox(height: 12),
                    buildField('مصروفات أخرى', otherCtrl),

                    const SizedBox(height: 24),

                    ElevatedButton.icon(
                      onPressed: calculate,
                      icon: const Icon(Icons.calculate),
                      label: const Text('احسب الصافي'),
                    ),

                    if (calculated) ...[
                      const SizedBox(height: 24),
                      Text(
                        netProfit >= 0
                            ? '✔ صافي ربح: $netProfit جنيه'
                            : '❌ خسارة: ${netProfit.abs()} جنيه',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color:
                          netProfit >= 0 ? Colors.green : Colors.red,
                        ),
                      ),
                    ]
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
