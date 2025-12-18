import 'package:coffee_pos/data/screens/products_screen.dart';
import 'package:coffee_pos/data/screens/shift_screen.dart';
import 'package:flutter/material.dart';
import 'add_sale_screen.dart';
import 'dashboard_screen.dart';
import 'shift_report_screen.dart';
class HomeScreen extends StatelessWidget {
  final Map<String, dynamic> currentUser;

  const HomeScreen({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    final isAdmin = currentUser['role'] == 'admin';

    return Scaffold(
      appBar: AppBar(title: const Text('نظام POS - محل البن')),
      body: Center(
        child: SizedBox(
          width: 800,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              // 🔴 إدارة الشيفتات (Admin فقط)
              if (isAdmin) ...[
                ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ShiftScreen()),
                  ),
                  child: const Text('إدارة الشيفتات'),
                ),
                const SizedBox(height: 16),
              ],

              // 🟢 تسجيل بيع (الكل)
              ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddSaleScreen(
                      currentUser: currentUser,
                    ),
                  ),
                ),
                child: const Text('تسجيل بيع'),
              ),
              const SizedBox(height: 16),

              // 🟢 تقرير الشيفت (الكل – بس محتواه يختلف)
              ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ShiftReportScreen(
                      currentUser: currentUser,
                    ),
                  ),
                ),
                child: const Text('تقرير الشيفت'),
              ),
              const SizedBox(height: 16),

              // 🔴 Dashboard (Admin فقط)
              if (isAdmin)
                ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DashboardScreen(),
                    ),
                  ),
                  child: const Text('لوحة التحكم Dashboard'),
                ),
              const SizedBox(height: 16),

              if (isAdmin) ...[
                ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProductsScreen()),
                  ),
                  child: const Text('إدارة المنتجات'),
                ),
                const SizedBox(height: 16),
              ]

            ],
          ),
        ),
      ),
    );
  }
}
