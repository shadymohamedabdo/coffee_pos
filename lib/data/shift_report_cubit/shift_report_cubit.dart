import 'package:bloc/bloc.dart';
import '../repositories/shifts_repository.dart';
import '../repositories/shift_reports_repository.dart';

part 'shift_report_state.dart';

class ShiftReportCubit extends Cubit<ShiftReportState> {
  final ShiftsRepository shiftsRepository;
  final ShiftReportRepository reportRepository;

  ShiftReportCubit(this.shiftsRepository, this.reportRepository)
    : super(ShiftReportInitial());

  Future<void> loadShifts() async {
    try {
      emit(ShiftReportLoading());
      final shifts = await shiftsRepository.getAllShifts();
      // Sort shifts by date descending
      final sortedShifts = List<Map<String, dynamic>>.from(shifts);
      sortedShifts.sort(
        (a, b) =>
            DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])),
      );

      emit(ShiftReportSuccess(shifts: sortedShifts));
    } catch (e) {
      emit(ShiftReportSuccess(shifts: [], error: 'فشل تحميل الشيفتات: $e'));
    }
  }

  void selectShift(int shiftId) {
    if (state is ShiftReportSuccess) {
      emit((state as ShiftReportSuccess).copyWith(selectedShiftId: shiftId));
    }
  }

  Future<void> loadReport() async {
    if (state is! ShiftReportSuccess) return;
    final currentState = state as ShiftReportSuccess;
    if (currentState.selectedShiftId == null) return;

    emit(currentState.copyWith(isLoading: true, error: null));

    try {
      final report = await reportRepository.getShiftReport(
        currentState.selectedShiftId!,
      );
      emit(currentState.copyWith(isLoading: false, reportData: report));
    } catch (e) {
      emit(
        currentState.copyWith(isLoading: false, error: 'فشل تحميل التقرير: $e'),
      );
    }
  }

  Future<void> toggleSaleStatus(int saleId, String currentStatus) async {
    if (state is! ShiftReportSuccess) return;
    final currentState = state as ShiftReportSuccess;

    // We only support cancelling for now based on UI
    if (currentStatus == 'cancelled') {
      // Option to reactivate if needed, but repository only has cancelSale
      // Assuming we might want to implement reactivate later or just show error
      emit(
        currentState.copyWith(error: 'لا يمكن تفعيل المبيعات الملغاة حالياً'),
      );
      return;
    }

    try {
      await reportRepository.cancelSale(saleId);
      await loadReport(); // Reload to see changes
    } catch (e) {
      emit(currentState.copyWith(error: 'فشل تغيير حالة البيع: $e'));
    }
  }
}
