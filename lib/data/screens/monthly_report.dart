import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../monthly_report_cubit/monthly_report_cubit.dart';

class MonthlyReportScreen extends StatelessWidget {
  const MonthlyReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MonthlyReportView();
  }
}

class MonthlyReportView extends StatelessWidget {
  const MonthlyReportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[50],
      appBar: AppBar(
        title: const Text('التقرير الشهري'),
        backgroundColor: Colors.brown[700],
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'تحديث التقرير',
            onPressed: () {
              context.read<MonthlyReportCubit>().reloadCurrentMonth(); // زر تحديث يدوي
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ===== اختيار الشهر والسنة (لو عايز تضيفهم تاني، أضفهم هنا) =====
            // لو مفيش اختيار شهر، التقرير هيبقى للشهر الحالي تلقائي

            const SizedBox(height: 20),

            Expanded(
              child: BlocBuilder<MonthlyReportCubit, MonthlyReportState>(
                builder: (context, state) {
                  if (state is MonthlyReportLoading) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Colors.brown),
                          SizedBox(height: 20),
                          Text('جاري تحميل التقرير...', style: TextStyle(fontSize: 18)),
                        ],
                      ),
                    );
                  }

                  if (state is MonthlyReportError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 64, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(
                            state.message,
                            style: const TextStyle(color: Colors.red, fontSize: 18),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is MonthlyReportLoaded) {
                    if (state.data.isEmpty) {
                      return const Center(
                        child: Text(
                          'لا توجد مبيعات في هذا الشهر',
                          style: TextStyle(fontSize: 20, color: Colors.brown),
                        ),
                      );
                    }

                    return Column(
                      children: [
                        Expanded(
                          child: Card(
                            elevation: 6,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            color: Colors.white,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: SingleChildScrollView(
                                child: DataTable(
                                  headingRowHeight: 56,
                                  dataRowHeight: 60,
                                  headingRowColor: MaterialStateProperty.all(Colors.brown[400]),
                                  columns: const [
                                    DataColumn(
                                      label: Text('المنتج', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                    ),
                                    DataColumn(
                                      label: Text('الكمية', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                    ),
                                    DataColumn(
                                      label: Text('السعر', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                    ),
                                    DataColumn(
                                      label: Text('الإجمالي', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                    ),
                                  ],
                                  rows: state.data.map((row) {
                                    return DataRow(
                                      cells: [
                                        DataCell(Text(row['product_name'] ?? '-', style: const TextStyle(fontWeight: FontWeight.w600))),
                                        DataCell(Text(row['total_quantity'].toString())),
                                        DataCell(Text('${row['unit_price']} جنيه')),
                                        DataCell(Text('${row['total_amount']} جنيه', style: const TextStyle(fontWeight: FontWeight.bold))),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Card(
                          elevation: 8,
                          color: Colors.green[700],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.account_balance_wallet, size: 40, color: Colors.white),
                                const SizedBox(width: 16),
                                Text(
                                  'الإجمالي الكلي: ${state.totalSum.toStringAsFixed(2)} جنيه',
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}