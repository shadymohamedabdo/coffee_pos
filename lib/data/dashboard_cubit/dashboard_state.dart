// dashboard_state.dart

import '../models/dashboard_model.dart';

sealed class DashboardState {}

final class DashboardInitial extends DashboardState {}

final class DashboardLoading extends DashboardState {}

final class DashboardLoaded extends DashboardState {
  final List<DailySale> dailySales;
  final List<ProductSale> topProducts;
  final int selectedMonth; // ← جديد
  final int selectedYear;  // ← جديد

  DashboardLoaded({
    required this.dailySales,
    required this.topProducts,
    required this.selectedMonth,
    required this.selectedYear,
  });
}

final class DashboardError extends DashboardState {
  final String message;

  DashboardError(this.message);
}