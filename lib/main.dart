import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'data/dashboard_cubit/dashboard_cubit.dart';
import 'data/monthly_report_cubit/monthly_report_cubit.dart';
import 'data/products_cubit/products_cubit.dart';
import 'data/sale_cubit/sale_cubit.dart';
import 'data/screens/login_screen.dart';
import 'data/service_locator.dart';
import 'data/shift_report_cubit/shift_report_cubit.dart';
import 'data/user_cubit/user_cubit.dart';

void main() {
  setupServiceLocator();

  if (kIsWeb) {
    // Web Initialization
    databaseFactory = databaseFactoryFfiWeb;
  } else {
    // Desktop Initialization
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const CoffeePOSApp());
}

class CoffeePOSApp extends StatelessWidget {
  const CoffeePOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<DashboardCubit>(
          create: (_) => getIt<DashboardCubit>()
            ..loadData(month: DateTime.now().month, year: DateTime.now().year),
        ),

        BlocProvider<ShiftReportCubit>(
          create: (_) => getIt<ShiftReportCubit>()..loadShifts(),
        ),
        BlocProvider<MonthlyReportCubit>(
          create: (_) => getIt<MonthlyReportCubit>(),
        ),
        BlocProvider<ProductsCubit>(create: (_) => getIt<ProductsCubit>()),
        BlocProvider<UsersCubit>(
          create: (_) => getIt<UsersCubit>()..loadEmployees(),
        ),
        BlocProvider<AddSaleCubit>(create: (_) => getIt<AddSaleCubit>()),
      ],
      child: MaterialApp(
        title: 'Coffee POS',
        theme: ThemeData(primarySwatch: Colors.brown),
        home: const LoginScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
