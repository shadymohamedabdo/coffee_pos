import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/dashboard_repository.dart';
import '../database_helper.dart'; // ← مهم جدًا عشان salesStream
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final DashboardRepository repo;

  StreamSubscription? _salesSubscription;

  // متغيرات داخلية نحتفظ فيها بالشهر والسنة الحاليين
  int _currentMonth = DateTime.now().month;
  int _currentYear = DateTime.now().year;

  DashboardCubit(this.repo) : super(DashboardInitial()) {
    loadData(month: _currentMonth, year: _currentYear);

    // 🔥 التحديث التلقائي لما يحصل أي تغيير في جدول المبيعات
    _salesSubscription = DatabaseHelper.salesStream.listen((_) {
      reloadCurrentMonth();
    });
  }

  Future<void> reloadCurrentMonth() async {
    // نمنع التحميل المتكرر لو الداشبورد بيتحمل أصلاً
    if (state is DashboardLoading) return;

    await loadData(month: _currentMonth, year: _currentYear);
  }

  Future<void> loadData({required int month, required int year}) async {
    // حفظ القيم الحالية
    _currentMonth = month;
    _currentYear = year;

    emit(DashboardLoading());

    try {
      final dailySales = await repo.getDailySales(month, year);
      final topProducts = await repo.getTopProducts(month, year);

      emit(DashboardLoaded(
        dailySales: dailySales,
        topProducts: topProducts,
        selectedMonth: month,
        selectedYear: year,
      ));
    } catch (e) {
      emit(DashboardError('فشل تحميل البيانات: $e'));
    }
  }

  // دالة تغيير الشهر والسنة (من الشاشة)
  void changeMonthYear(int month, int year) {
    loadData(month: month, year: year);
  }

  @override
  Future<void> close() {
    _salesSubscription?.cancel(); // مهم جدًا عشان مفيش memory leak
    return super.close();
  }
}