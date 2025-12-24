import 'package:bloc/bloc.dart';
import '../repositories/reports_repository.dart';

part 'monthly_report_state.dart';

class MonthlyReportCubit extends Cubit<MonthlyReportState> {
  final ReportsRepository repository;

  int _currentMonth = DateTime.now().month;
  int _currentYear = DateTime.now().year;

  MonthlyReportCubit(this.repository) : super(MonthlyReportInitial());

  Future<void> reloadCurrentMonth() async {
    await loadReport(_currentMonth, _currentYear);
  }

  void changeMonth(int month) {
    _currentMonth = month;
    loadReport(_currentMonth, _currentYear);
  }

  void changeYear(int year) {
    _currentYear = year;
    loadReport(_currentMonth, _currentYear);
  }

  Future<void> loadReport(int month, int year) async {
    emit(MonthlyReportLoading());
    try {
      final data = await repository.getMonthlyReport(month: month, year: year);

      double totalSum = 0;
      for (var item in data) {
        // Handle potential nulls or types
        final total = item['total_amount'];
        if (total != null) {
          totalSum += (total as num).toDouble();
        }
      }

      emit(
        MonthlyReportLoaded(
          data: data,
          totalSum: totalSum,
          month: month,
          year: year,
        ),
      );
    } catch (e) {
      emit(
        MonthlyReportError(
          'حدث خطأ أثناء تحميل التقرير: $e',
          month: month,
          year: year,
        ),
      );
    }
  }
}
