import 'package:get_it/get_it.dart';
import 'repositories/dashboard_repository.dart';
import 'repositories/products_repository.dart';
import 'repositories/reports_repository.dart';
import 'repositories/sales_repository.dart';
import 'repositories/shift_reports_repository.dart';
import 'repositories/shifts_repository.dart';
import 'repositories/users_repository.dart';

import 'dashboard_cubit/dashboard_cubit.dart';
import 'monthly_report_cubit/monthly_report_cubit.dart';
import 'products_cubit/products_cubit.dart';
import 'sale_cubit/sale_cubit.dart';
import 'shift_report_cubit/shift_report_cubit.dart';
import 'user_cubit/user_cubit.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  // Repositories
  getIt.registerLazySingleton(() => DashboardRepository());
  getIt.registerLazySingleton(() => ProductsRepository());
  getIt.registerLazySingleton(() => ReportsRepository());
  getIt.registerLazySingleton(() => SalesRepository());
  getIt.registerLazySingleton(() => ShiftReportRepository());
  getIt.registerLazySingleton(() => ShiftsRepository());
  getIt.registerLazySingleton(() => UsersRepository());

  // Cubits
  getIt.registerFactory(() => DashboardCubit(getIt()));
  getIt.registerFactory(() => ProductsCubit(getIt()));
  getIt.registerFactory(() => MonthlyReportCubit(getIt()));
  getIt.registerFactory(
    () => AddSaleCubit(
      getIt<SalesRepository>(),
      getIt<ShiftsRepository>(),
      getIt<
        ProductsRepository
      >(), // Assuming AddSaleCubit needs ProductsRepo too, verifying later
    ),
  );
  getIt.registerFactory(
    () => ShiftReportCubit(
      getIt<ShiftsRepository>(),
      getIt<ShiftReportRepository>(),
    ),
  );
  getIt.registerFactory(() => UsersCubit(getIt()));
}
