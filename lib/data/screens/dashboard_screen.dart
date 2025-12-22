import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../dashboard_cubit/dashboard_cubit.dart';
import '../dashboard_cubit/dashboard_state.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('لوحة التحكم'),
        backgroundColor: Colors.brown.withOpacity(0.9),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => context.read<DashboardCubit>().loadData(),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.brown[50]!, Colors.brown[100]!],
          ),
        ),
        child: SafeArea(
          child: BlocBuilder<DashboardCubit, DashboardState>(
            builder: (context, state) {
              if (state is DashboardLoading || state is DashboardInitial) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.brown),
                );
              }

              if (state is DashboardLoaded) {
                final totalSales = state.dailySales.fold<double>(
                  0,
                      (sum, e) => sum + e.total,
                );

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // ===== إجمالي المبيعات =====
                      Card(
                        color: Colors.green[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              const Text(
                                'إجمالي المبيعات اليوم',
                                style: TextStyle(color: Colors.white70),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${totalSales.toStringAsFixed(2)} جنيه',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // ===== الرسم البياني =====
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: SizedBox(
                            height: 320,
                            child: BarChart(
                              BarChartData(
                                maxY: state.dailySales
                                    .map((e) => e.total)
                                    .fold<double>(0, (a, b) => a > b ? a : b) +
                                    100,
                                borderData: FlBorderData(show: false),
                                gridData: FlGridData(show: true),
                                titlesData: FlTitlesData(
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 40,
                                    ),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 8),
                                          child: Text(
                                            value.toInt().toString(),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  rightTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                ),
                                barGroups: state.dailySales.map((e) {
                                  return BarChartGroupData(
                                    x: int.parse(e.day), // ✅ اليوم الحقيقي
                                    barRods: [
                                      BarChartRodData(
                                        toY: e.total,
                                        width: 22,
                                        borderRadius: BorderRadius.circular(12),
                                        gradient: LinearGradient(
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                          colors: [
                                            Colors.brown[600]!,
                                            Colors.amber[700]!,
                                          ],
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

                      const SizedBox(height: 30),

                      // ===== أعلى 5 منتجات =====
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'أعلى 5 منتجات مبيعًا',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.brown,
                                ),
                              ),
                              const SizedBox(height: 20),
                              ...state.topProducts.asMap().entries.map((entry) {
                                final p = entry.value;
                                final rank = entry.key + 1;

                                return Padding(
                                  padding:
                                  const EdgeInsets.symmetric(vertical: 8),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Colors.amber[200],
                                        child: Text('$rank'),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          p.productName,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Text('${p.totalQuantity} ${p.unitType}')
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (state is DashboardError) {
                return Center(child: Text(state.message));
              }

              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }
}
