import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../repositories/dashboard_repository.dart';
import '../models/dashboard_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final repo = DashboardRepository();

  List<DailySale> dailySales = [];
  List<ProductSale> topProducts = [];
  bool loading = true;

  int currentMonth = DateTime.now().month;
  int currentYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() => loading = true);

    dailySales = await repo.getDailySales(currentMonth, currentYear);
    topProducts = await repo.getTopProducts(currentMonth, currentYear);

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final totalSales =
    dailySales.fold<double>(0, (sum, sale) => sum + sale.total);

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== إجمالي المبيعات =====
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'إجمالي المبيعات لهذا الشهر: $totalSales جنيه',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ===== الرسم البياني اليومي =====
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  height: 300,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: dailySales.isNotEmpty
                          ? dailySales
                          .map((e) => e.total)
                          .reduce((a, b) => a > b ? a : b) +
                          10
                          : 10,
                      barGroups: dailySales
                          .asMap()
                          .entries
                          .map((entry) => BarChartGroupData(
                        x: entry.key,
                        barRods: [
                          BarChartRodData(
                            toY: entry.value.total,
                            color: Colors.blue,
                            width: 16,
                            borderRadius:
                            BorderRadius.circular(4),
                          )
                        ],
                      ))
                          .toList(),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index < dailySales.length) {
                                return Text(dailySales[index].day);
                              } else {
                                return const Text('');
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ===== أعلى 5 منتجات مبيعًا =====
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'أعلى 5 منتجات مبيعًا',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...topProducts.map((p) => ListTile(
                      title: Text(p.productName),
                      trailing: Text('${p.total} وحدة'),
                    )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
