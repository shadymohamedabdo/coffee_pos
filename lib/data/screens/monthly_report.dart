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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'التقرير الشهري',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            tooltip: 'تحديث التقرير',
            onPressed: () {
              context.read<MonthlyReportCubit>().reloadCurrentMonth();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const NetworkImage(
              'https://images.unsplash.com/photo-1447933601403-0c6688de566e?ixlib=rb-4.0.3&auto=format&fit=crop&w=1920&q=80',
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
          child: Column(
            children: [
              // ===== Dropdown لاختيار الشهر والسنة =====
              BlocBuilder<MonthlyReportCubit, MonthlyReportState>(
                builder: (context, state) {
                  int currentMonth = DateTime.now().month;
                  int currentYear = DateTime.now().year;

                  if (state is MonthlyReportLoaded) {
                    currentMonth = state.month;
                    currentYear = state.year;
                  } else if (state is MonthlyReportError) {
                    currentMonth = state.month;
                    currentYear = state.year;
                  }

                  // سنين متاحة
                  final years = List.generate(
                    DateTime.now().year - 2022 + 1,
                    (index) => 2023 + index,
                  );

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'اختر الفترة: ',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                          ),
                        ),
                        const SizedBox(width: 16),
                        _buildDropdown<int>(
                          value: currentMonth,
                          items: List.generate(12, (index) => index + 1)
                              .map(
                                (month) => DropdownMenuItem(
                                  value: month,
                                  child: Text('شهر $month'),
                                ),
                              )
                              .toList(),
                          onChanged: (month) {
                            if (month != null) {
                              context.read<MonthlyReportCubit>().changeMonth(
                                month,
                              );
                            }
                          },
                        ),
                        const SizedBox(width: 16),
                        _buildDropdown<int>(
                          value: currentYear,
                          items: years
                              .map(
                                (year) => DropdownMenuItem(
                                  value: year,
                                  child: Text('$year'),
                                ),
                              )
                              .toList(),
                          onChanged: (year) {
                            if (year != null) {
                              context.read<MonthlyReportCubit>().changeYear(
                                year,
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              Expanded(
                child: BlocBuilder<MonthlyReportCubit, MonthlyReportState>(
                  builder: (context, state) {
                    if (state is MonthlyReportLoading) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.amber),
                      );
                    }

                    if (state is MonthlyReportError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.redAccent,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              state.message,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 18,
                              ),
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
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white70,
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: [
                          Expanded(
                            child: Container(
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
                                    headingRowHeight: 56,
                                    dataRowMinHeight: 60,
                                    dataRowMaxHeight: 60,
                                    columnSpacing: 24,
                                    columns: const [
                                      DataColumn(label: Text('المنتج')),
                                      DataColumn(label: Text('الكمية')),
                                      DataColumn(label: Text('سعر الوحدة')),
                                      DataColumn(label: Text('الإجمالي')),
                                    ],
                                    rows: state.data.map((row) {
                                      return DataRow(
                                        cells: [
                                          DataCell(
                                            Text(
                                              row['product_name'] ?? '-',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              row['total_quantity'].toString(),
                                            ),
                                          ),
                                          DataCell(
                                            Text('${row['unit_price']}'),
                                          ),
                                          DataCell(
                                            Text(
                                              '${row['total_amount']}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.amberAccent,
                                              ),
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
                          const SizedBox(height: 24),
                          Container(
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
                                const Icon(
                                  Icons.account_balance_wallet,
                                  size: 32,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  'الإجمالي الكلي: ${state.totalSum.toStringAsFixed(2)} جنيه',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
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
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          dropdownColor: Colors.grey[900],
          style: const TextStyle(color: Colors.white),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.amber),
        ),
      ),
    );
  }
}
