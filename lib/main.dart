import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'data/screens/login_screen.dart';

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
    return MaterialApp(
      title: 'Coffee POS',
      theme: ThemeData(primarySwatch: Colors.brown),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
