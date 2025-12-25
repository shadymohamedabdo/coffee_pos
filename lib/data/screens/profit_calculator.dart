import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
        if (calculated) calculate();
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
    final salaries =
        double.tryParse(salariesCtrl.text.replaceAll(',', '')) ?? 0;
    final electricity =
        double.tryParse(electricityCtrl.text.replaceAll(',', '')) ?? 0;
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'حاسبة صافي الربح',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'تحديث إجمالي المبيعات',
            onPressed: loadMonthlySales,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const NetworkImage(
              'https://images.unsplash.com/photo-1554118811-1e0d58224f24?ixlib=rb-4.0.3&auto=format&fit=crop&w=1920&q=80',
            ),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.7),
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Total Sales Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.amber.withValues(alpha: 0.5),
                      ),
                    ),
                    child: isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Colors.amber,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.show_chart,
                                color: Colors.amber,
                                size: 32,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'مبيعات الشهر: ${_formatter.format(totalSales)} جنيه',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                  ),

                  const SizedBox(height: 24),

                  // Inputs
                  _buildField('إيجار المحل', rentCtrl, Icons.store),
                  const SizedBox(height: 12),
                  _buildField('مرتبات الموظفين', salariesCtrl, Icons.people),
                  const SizedBox(height: 12),
                  _buildField(
                    'فاتورة الكهرباء',
                    electricityCtrl,
                    Icons.electric_bolt,
                  ),
                  const SizedBox(height: 12),
                  _buildField('بضاعة', waterCtrl, Icons.shopping_bag),
                  const SizedBox(height: 12),
                  _buildField('مصروفات أخرى', otherCtrl, Icons.attach_money),

                  const SizedBox(height: 32),

                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: calculate,
                          icon: const Icon(Icons.calculate),
                          label: const Text('احسب الصافي'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            foregroundColor: Colors.brown[900],
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      OutlinedButton.icon(
                        onPressed: clearFields,
                        icon: const Icon(Icons.refresh),
                        label: const Text('مسح'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 24,
                          ),
                          side: const BorderSide(color: Colors.white70),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Result
                  if (calculated) ...[
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: netProfit >= 0
                            ? Colors.green.withValues(alpha: 0.2)
                            : Colors.red.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: netProfit >= 0 ? Colors.green : Colors.red,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            netProfit >= 0
                                ? Icons.trending_up
                                : Icons.trending_down,
                            size: 48,
                            color: netProfit >= 0
                                ? Colors.greenAccent
                                : Colors.redAccent,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            netProfit >= 0
                                ? 'صافي الربح: ${_formatter.format(netProfit)} جنيه'
                                : 'صافي الخسارة: ${_formatter.format(netProfit.abs())} جنيه',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: netProfit >= 0
                                  ? Colors.greenAccent
                                  : Colors.redAccent,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Colors.white),
      onChanged: (_) => setState(() => calculated = false),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear, color: Colors.white70),
          onPressed: controller.clear,
        ),
        filled: true,
        fillColor: Colors.black.withValues(alpha: 0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.amber),
        ),
      ),
    );
  }
}
