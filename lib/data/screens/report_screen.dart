import 'package:flutter/material.dart';
import '../repositories/reports_repository.dart';

class MonthlyReportScreen extends StatefulWidget {
  const MonthlyReportScreen({super.key});

  @override
  State<MonthlyReportScreen> createState() => _MonthlyReportScreenState();
}

class _MonthlyReportScreenState extends State<MonthlyReportScreen> {
  final repo = ReportsRepository();

  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

  List<Map<String, dynamic>> reportData = [];

  Future<void> loadReport() async {
    final data = await repo.getMonthlyReport(
      month: selectedMonth,
      year: selectedYear,
    );

    setState(() {
      reportData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    double totalSum = reportData.fold(
      0,
          (sum, item) => sum + (item['total_amount'] as double),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('التقرير الشهري')),
      body: Center(
        child: SizedBox(
          width: 900,
          child: Column(
            children: [
              const SizedBox(height: 20),

              // ===== اختيارات =====
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DropdownButton<int>(
                    value: selectedMonth,
                    items: List.generate(12, (i) {
                      return DropdownMenuItem(
                        value: i + 1,
                        child: Text('شهر ${i + 1}'),
                      );
                    }),
                    onChanged: (value) {
                      setState(() => selectedMonth = value!);
                    },
                  ),
                  const SizedBox(width: 20),
                  DropdownButton<int>(
                    value: selectedYear,
                    items: [2024, 2025, 2026].map((y) {
                      return DropdownMenuItem(
                        value: y,
                        child: Text(y.toString()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => selectedYear = value!);
                    },
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: loadReport,
                    child: const Text('عرض التقرير'),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // ===== الجدول =====
              Expanded(
                child: Card(
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('المنتج')),
                      DataColumn(label: Text('الكمية')),
                      DataColumn(label: Text('السعر')),
                      DataColumn(label: Text('الإجمالي')),
                    ],
                    rows: reportData.map((row) {
                      return DataRow(cells: [
                        DataCell(Text(row['product_name'])),
                        DataCell(Text(row['total_quantity'].toString())),
                        DataCell(Text(row['unit_price'].toString())),
                        DataCell(Text(row['total_amount'].toString())),
                      ]);
                    }).toList(),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'الإجمالي الكلي: $totalSum جنيه',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
