import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../shift_report_cubit/shift_report_cubit.dart';

class ShiftReportScreen extends StatelessWidget {
  final Map<String, dynamic> currentUser;
  const ShiftReportScreen({super.key, required this.currentUser});

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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'تقرير الشيفت',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const NetworkImage(
              'https://images.unsplash.com/photo-1453614512568-c4024d13c247?ixlib=rb-4.0.3&auto=format&fit=crop&w=1920&q=80',
            ),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.7),
              BlendMode.darken,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 100, 24, 24),
          child: BlocListener<ShiftReportCubit, ShiftReportState>(
            listener: (context, state) {
              if (state is ShiftReportSuccess && state.error != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.error!),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: BlocBuilder<ShiftReportCubit, ShiftReportState>(
              builder: (context, state) {
                if (state is! ShiftReportSuccess) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }

                final shifts = state.shifts;
                final reportData = state.reportData;
                final totalSum = reportData
                    .where((r) => r['status'] == 'active')
                    .fold<double>(
                      0,
                      (sum, r) => sum + (r['total_amount'] as double),
                    );

                return Column(
                  children: [
                    // Shift Selector Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: state.selectedShiftId,
                              hint: const Text(
                                'اختر الشيفت',
                                style: TextStyle(color: Colors.white70),
                              ),
                              icon: const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: Colors.amber,
                              ),
                              dropdownColor: Colors.brown[900],
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                prefixIcon: const Icon(
                                  Icons.work_outline,
                                  color: Colors.amber,
                                ),
                                filled: true,
                                fillColor: Colors.black.withValues(alpha: 0.3),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Colors.amber,
                                  ),
                                ),
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
                                            ? Colors.greenAccent
                                            : Colors.grey,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${s['type']} • ${formatDateTime(s['date'])}',
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (v) {
                                if (v != null) {
                                  context.read<ShiftReportCubit>().selectShift(
                                    v,
                                  );
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.refresh),
                            label: const Text('عرض التقرير'),
                            onPressed: state.isLoading
                                ? null
                                : () => context
                                      .read<ShiftReportCubit>()
                                      .loadReport(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber,
                              foregroundColor: Colors.brown[900],
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Report Table
                    Expanded(
                      child: reportData.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(
                                    Icons.assignment_outlined,
                                    size: 64,
                                    color: Colors.white30,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'لا توجد مبيعات لهذا الشيفت',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.1),
                                ),
                              ),
                              child: SingleChildScrollView(
                                child: Theme(
                                  data: Theme.of(context).copyWith(
                                    textTheme: Theme.of(context).textTheme
                                        .apply(
                                          bodyColor: Colors.white,
                                          displayColor: Colors.white,
                                        ),
                                    dataTableTheme: DataTableThemeData(
                                      headingTextStyle: const TextStyle(
                                        color: Colors.amber,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      dataTextStyle: const TextStyle(
                                        color: Colors.white,
                                      ),
                                      headingRowColor: WidgetStateProperty.all(
                                        Colors.black.withValues(alpha: 0.2),
                                      ),
                                    ),
                                  ),
                                  child: DataTable(
                                    dataRowMinHeight: 56,
                                    dataRowMaxHeight: 64,
                                    columnSpacing: 24,
                                    columns: const [
                                      DataColumn(label: Text('الموظف')),
                                      DataColumn(label: Text('المنتج')),
                                      DataColumn(label: Text('الكمية')),
                                      DataColumn(label: Text('السعر')),
                                      DataColumn(label: Text('الإجمالي')),
                                      DataColumn(label: Text('الحالة')),
                                      DataColumn(label: Text('إجراء')),
                                    ],
                                    rows: reportData.map((row) {
                                      final isCancelled =
                                          row['status'] == 'cancelled';
                                      return DataRow(
                                        color: WidgetStateProperty.resolveWith(
                                          (states) => isCancelled
                                              ? Colors.red.withValues(
                                                  alpha: 0.2,
                                                )
                                              : null,
                                        ),
                                        cells: [
                                          DataCell(
                                            Text(
                                              row['employee_name'] ?? '',
                                              style: TextStyle(
                                                decoration: isCancelled
                                                    ? TextDecoration.lineThrough
                                                    : null,
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              row['product_name'] ?? '',
                                              style: TextStyle(
                                                decoration: isCancelled
                                                    ? TextDecoration.lineThrough
                                                    : null,
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              row['total_quantity'].toString(),
                                            ),
                                          ),
                                          DataCell(
                                            Text(row['unit_price'].toString()),
                                          ),
                                          DataCell(
                                            Text(
                                              row['total_amount'].toString(),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.amberAccent,
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: isCancelled
                                                    ? Colors.red.withValues(
                                                        alpha: 0.2,
                                                      )
                                                    : Colors.green.withValues(
                                                        alpha: 0.2,
                                                      ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: isCancelled
                                                      ? Colors.red
                                                      : Colors.green,
                                                ),
                                              ),
                                              child: Text(
                                                isCancelled ? 'ملغي' : 'مفعل',
                                                style: TextStyle(
                                                  color: isCancelled
                                                      ? Colors.redAccent
                                                      : Colors.greenAccent,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            IconButton(
                                              icon: Icon(
                                                isCancelled
                                                    ? Icons.restore_from_trash
                                                    : Icons.cancel_outlined,
                                                color: isCancelled
                                                    ? Colors.green
                                                    : Colors.red,
                                              ),
                                              onPressed: () {
                                                context
                                                    .read<ShiftReportCubit>()
                                                    .toggleSaleStatus(
                                                      row['id'],
                                                      row['status'],
                                                    );
                                              },
                                              tooltip: isCancelled
                                                  ? 'استعادة البيع'
                                                  : 'إلغاء البيع',
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ),
                    ),

                    if (isAdmin && reportData.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 16),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.amber.shade700,
                              Colors.amber.shade900,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'إجمالي مبيعات الشيفت: ',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white70,
                              ),
                            ),
                            Text(
                              '${totalSum.toStringAsFixed(2)} جنيه',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
