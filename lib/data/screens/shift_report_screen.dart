import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart'; // 🔥 لازم تتأكد إنك ضفت المكتبة دي
import '../shift_report_cubit/shift_report_cubit.dart';
import '../shift_report_cubit/shift_report_state.dart';

class ShiftReportScreen extends StatelessWidget {
  final Map<String, dynamic> currentUser;
  const ShiftReportScreen({super.key, required this.currentUser});

  // ✨ دالة تنسيق الوقت والتاريخ
  String formatDateTime(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return '';
    try {
      DateTime dt = DateTime.parse(rawDate);
      return DateFormat('yyyy-MM-dd • hh:mm a').format(dt);
    } catch (e) {
      return rawDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = currentUser['role'] == 'admin';

    return Scaffold(
      appBar: AppBar(title: const Text('تقرير الشيفت')),
      body: BlocListener<ShiftReportCubit, ShiftReportState>(
        listener: (context, state) {
          if (state is ShiftReportSuccess && state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!), backgroundColor: Colors.red),
            );
          }
        },
        child: BlocBuilder<ShiftReportCubit, ShiftReportState>(
          builder: (context, state) {
            if (state is! ShiftReportSuccess) {
              return const Center(child: CircularProgressIndicator());
            }

            final shifts = state.shifts;
            final reportData = state.reportData;
            final totalSum = reportData
                .where((r) => r['status'] == 'active')
                .fold<double>(0, (sum, r) => sum + (r['total_amount'] as double));

            return Column(
              children: [
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          child: DropdownButtonFormField<int>(
                            initialValue: state.selectedShiftId,
                            hint: const Text('اختر الشيفت'),
                            icon: const Icon(Icons.keyboard_arrow_down_rounded),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              prefixIcon: Icon(Icons.work_outline),
                            ),
                            items: shifts.map((s) {
                              return DropdownMenuItem<int>(
                                value: s['id'],
                                child: Row(
                                  children: [
                                    Icon(
                                      s['status'] == 'active'
                                          ? Icons.play_circle_fill
                                          : Icons.check_circle,
                                      color: s['status'] == 'active'
                                          ? Colors.green
                                          : Colors.grey,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      // 🔥 التعديل هنا: تنسيق التاريخ والوقت في القائمة
                                      '${s['type']} • ${formatDateTime(s['date'])}',
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (v) {
                              if (v != null) {
                                context.read<ShiftReportCubit>().selectShift(v);
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: state.isLoading
                          ? null
                          : () => context.read<ShiftReportCubit>().loadReport(),
                      child: state.isLoading
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : const Text('عرض التقرير'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: reportData.isEmpty
                      ? const Center(child: Text('لا توجد بيانات لهذا الشيفت'))
                      : SingleChildScrollView(
                    scrollDirection: Axis.horizontal, // مهم جداً عشان الجدول ميعملش Overflow
                    child: SingleChildScrollView(
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('الموظف')),
                          DataColumn(label: Text('المنتج')),
                          DataColumn(label: Text('الكمية')),
                          DataColumn(label: Text('سعر الوحدة')),
                          DataColumn(label: Text('الإجمالي')),
                          DataColumn(label: Text('إجراء')),
                        ],
                        rows: reportData.map((row) {
                          final isCancelled = row['status'] == 'cancelled';
                          return DataRow(
                            color: WidgetStateProperty.all(
                              isCancelled ? Colors.red[100] : null,
                            ),
                            cells: [
                              DataCell(Text(row['employee_name'] ?? '')),
                              DataCell(Text(row['product_name'] ?? '')),
                              DataCell(Text(row['total_quantity'].toString())),
                              DataCell(Text(row['unit_price'].toString())),
                              DataCell(Text(row['total_amount'].toString())),
                              DataCell(ElevatedButton(
                                onPressed: () {
                                  context.read<ShiftReportCubit>().toggleSaleStatus(
                                    row['id'],
                                    row['status'],
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isCancelled ? Colors.green : Colors.red,
                                ),
                                child: Text(isCancelled ? 'تفعيل' : 'إلغاء'),
                              )),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                if (isAdmin && reportData.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'إجمالي الشيفت: $totalSum جنيه',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}