import 'package:coffee_pos/data/products_cubit/products_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'data/dashboard_cubit/dashboard_cubit.dart';
import 'data/repositories/dashboard_repository.dart';
import 'data/repositories/products_repository.dart';
import 'data/repositories/users_repository.dart';
import 'data/sale_cubit/sale_cubit.dart';
import 'data/screens/login_screen.dart';
import 'data/user_cubit/user_cubit.dart';

void main() {
  // تهيئة قاعدة البيانات للـ Windows/Desktop
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  runApp(const CoffeePOSApp());
}

class CoffeePOSApp extends StatelessWidget {
  const CoffeePOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MultiBlocProvider(
        providers: [
          BlocProvider( create: (context) => DashboardCubit(DashboardRepository()),),
          BlocProvider( create: (context) => ProductsCubit(ProductsRepository()),),
          BlocProvider( create: (context) => UsersCubit(UsersRepository()),),
          BlocProvider( create: (context) => AddSaleCubit(),),



        ],
        child : MaterialApp(
      title: 'Coffee POS',
      theme: ThemeData(primarySwatch: Colors.brown),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    ));
  }
}
