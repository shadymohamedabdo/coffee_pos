import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';

import '../dashboard_cubit/dashboard_cubit.dart';
import '../dashboard_cubit/dashboard_state.dart';
import '../sale_cubit/sales_refresh_cubit.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SalesRefreshCubit, int>(
      listener: (context, _) {
        // 🔥 أي إلغاء / تفعيل أوردر → إعادة تحميل الداشبورد
        context.read<DashboardCubit>().loadData();
      },
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text('Dashboard'),
          backgroundColor: Colors.teal[700],
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () =>
                  context.read<DashboardCubit>().loadData(),
            )
          ],
        ),
        body: BlocBuilder<DashboardCubit, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoading || state is DashboardInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is DashboardLoaded) {
              final totalSales = state.dailySales.fold<double>(
                0,
                    (sum, e) => sum + e.total,
              );

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ===== إجمالي المبيعات =====
                    Card(
                      color: Colors.teal[50],
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'إجمالي المبيعات: $totalSales جنيه',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal[800],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ===== Bar Chart للمنتجات =====
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: SizedBox(
                          height: 300,
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: state.dailySales.isNotEmpty
                                  ? state.dailySales
                                  .map((e) => e.total)
                                  .reduce((a, b) => a > b ? a : b) +
                                  10
                                  : 10,
                              barGroups: state.dailySales
                                  .asMap()
                                  .entries
                                  .map(
                                    (entry) => BarChartGroupData(
                                  x: entry.key,
                                  barRods: [
                                    BarChartRodData(
                                      toY: entry.value.total,
                                      color: Colors.teal[400],
                                      width: 16,
                                      borderRadius: BorderRadius.circular(6),
                                    )
                                  ],
                                ),
                              )
                                  .toList(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            if (state is DashboardError) {
              return Center(
                child: Text(
                  state.message,
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}
