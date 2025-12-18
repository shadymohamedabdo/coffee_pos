import 'package:flutter/material.dart';
import '../repositories/shift_reports_repository.dart';
import '../repositories/shifts_repository.dart';
import '../repositories/sales_repository.dart';

class ShiftReportScreen extends StatefulWidget {
  final Map<String, dynamic> currentUser;
  const ShiftReportScreen({super.key, required this.currentUser});

  @override
  State<ShiftReportScreen> createState() => _ShiftReportScreenState();
}

class _ShiftReportScreenState extends State<ShiftReportScreen> {
  final shiftsRepo = ShiftsRepository();
  final reportRepo = ShiftReportRepository();
  final salesRepo = SalesRepository();

  List<Map<String, dynamic>> shifts = [];
  List<Map<String, dynamic>> reportData = [];

  int? selectedShiftId;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    loadShifts();
  }

  Future<void> loadShifts() async {
    final data = await shiftsRepo.getAllShifts();
    setState(() => shifts = data);
  }

  Future<void> loadReport() async {
    if (selectedShiftId == null) return;

    setState(() => loading = true);

    final data = await reportRepo.getShiftReport(selectedShiftId!);

    setState(() {
      reportData = data;
      loading = false;
    });
  }

  // ===== إلغاء أو تفعيل البيع =====
  Future<void> toggleSaleStatus(int saleId, String currentStatus) async {
    final newStatus = currentStatus == 'active' ? 'cancelled' : 'active';
    await salesRepo.updateSaleStatus(saleId, newStatus);
    await loadReport();
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.currentUser['role'] == 'admin';

    final totalSum = reportData
        .where((r) => r['status'] == 'active')
        .fold<double>(0, (sum, row) => sum + (row['total_amount'] as double));

    return Scaffold(
      appBar: AppBar(title: const Text('تقرير الشيفت')),
      body: Center(
        child: SizedBox(
          width: 1000,
          child: Column(
            children: [
              const SizedBox(height: 20),

              // اختيار الشيفت
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DropdownButton<int>(
                    hint: const Text('اختر الشيفت'),
                    value: selectedShiftId,
                    items: shifts.map((s) {
                      return DropdownMenuItem<int>(
                        value: s['id'],
                        child: Text('${s['type']} - ${s['date']}'),
                      );
                    }).toList(),
                    onChanged: (v) {
                      setState(() => selectedShiftId = v);
                    },
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: loadReport,
                    child: const Text('عرض التقرير'),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              if (loading)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (reportData.isNotEmpty)
                Expanded(
                  child: Card(
                    margin: const EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('الموظف')),
                          DataColumn(label: Text('المنتج')),
                          DataColumn(label: Text('الكمية')),
                          DataColumn(label: Text('سعر الوحدة')),
                          DataColumn(label: Text('الإجمالي')),
                          DataColumn(label: Text('الحالة')),
                          DataColumn(label: Text('إجراء')),
                        ],
                        rows: reportData.map((row) {
                          final isCancelled = row['status'] == 'cancelled';
                          return DataRow(
                            color: MaterialStateProperty.all(
                                isCancelled ? Colors.red[100] : null),
                            cells: [
                              DataCell(Text(row['employee_name'] ?? '')),
                              DataCell(Text(row['product_name'] ?? '')),
                              DataCell(Text(row['total_quantity'].toString())),
                              DataCell(Text(row['unit_price'].toString())),
                              DataCell(Text(row['total_amount'].toString())),
                              DataCell(Text(row['status'] ?? '')),
                              DataCell(
                                ElevatedButton(
                                  onPressed: () {
                                    toggleSaleStatus(
                                        row['id'], row['status'] ?? 'active');
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isCancelled
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                  child: Text(isCancelled ? 'تفعيل' : 'إلغاء'),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                )
              else
                const Expanded(
                  child: Center(
                    child: Text(
                      'لا توجد بيانات لهذا الشيفت',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),

              if (isAdmin && reportData.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'إجمالي الشيفت: $totalSum جنيه',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
