part of 'shift_report_cubit.dart';

abstract class ShiftReportState {}

class ShiftReportInitial extends ShiftReportState {}

class ShiftReportLoading extends ShiftReportState {}

class ShiftReportSuccess extends ShiftReportState {
  final List<Map<String, dynamic>> shifts;
  final List<Map<String, dynamic>> reportData;
  final int? selectedShiftId;
  final bool isLoading;
  final String? error;

  ShiftReportSuccess({
    required this.shifts,
    this.reportData = const [],
    this.selectedShiftId,
    this.isLoading = false,
    this.error,
  });

  ShiftReportSuccess copyWith({
    List<Map<String, dynamic>>? shifts,
    List<Map<String, dynamic>>? reportData,
    int? selectedShiftId,
    bool? isLoading,
    String? error,
  }) {
    return ShiftReportSuccess(
      shifts: shifts ?? this.shifts,
      reportData: reportData ?? this.reportData,
      selectedShiftId: selectedShiftId ?? this.selectedShiftId,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
