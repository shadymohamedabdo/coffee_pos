part of 'monthly_report_cubit.dart';

abstract class MonthlyReportState {}

class MonthlyReportInitial extends MonthlyReportState {}

class MonthlyReportLoading extends MonthlyReportState {}

class MonthlyReportLoaded extends MonthlyReportState {
  final List<Map<String, dynamic>> data;
  final double totalSum;
  final int month;
  final int year;

  MonthlyReportLoaded({
    required this.data,
    required this.totalSum,
    required this.month,
    required this.year,
  });
}

class MonthlyReportError extends MonthlyReportState {
  final String message;
  final int month; // Keep track of current selection even on error
  final int year;

  MonthlyReportError(this.message, {required this.month, required this.year});
}
