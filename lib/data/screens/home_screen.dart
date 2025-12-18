import 'package:flutter/material.dart';
import 'add_sale_screen.dart';
import 'dashboard_screen.dart';
import 'login_screen.dart';
import 'shift_report_screen.dart';
import 'shift_screen.dart';
import 'products_screen.dart';
import 'add_employee_screen.dart';

class HomeScreen extends StatelessWidget {
  final Map<String, dynamic> currentUser;

  const HomeScreen({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    final isAdmin = currentUser['role'] == 'admin';

    // قائمة الأزرار حسب الصلاحية
    final List<_HomeButton> buttons = [
      _HomeButton(
        label: 'تسجيل بيع',
        icon: Icons.add_shopping_cart,
        color: Colors.green,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddSaleScreen(currentUser: currentUser),
          ),
        ),
      ),
      _HomeButton(
        label: 'تقرير الشيفت',
        icon: Icons.receipt_long,
        color: Colors.orange,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ShiftReportScreen(currentUser: currentUser),
          ),
        ),
      ),
      if (isAdmin)
        _HomeButton(
          label: 'لوحة التحكم Dashboard',
          icon: Icons.dashboard,
          color: Colors.blue,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
          ),
        ),
      if (isAdmin)
        _HomeButton(
          label: 'إدارة الشيفتات',
          icon: Icons.access_time,
          color: Colors.red,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ShiftScreen()),
          ),
        ),
      if (isAdmin)
        _HomeButton(
          label: 'إدارة المنتجات',
          icon: Icons.coffee,
          color: Colors.brown,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProductsScreen()),
          ),
        ),
      if (isAdmin)
        _HomeButton(
          label: 'إدارة الموظفين',
          icon: Icons.person_add,
          color: Colors.purple,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) =>  AddEmployeeScreen(currentUser: currentUser,)),
          ),
        ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('نظام POS - محل البن'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'تسجيل خروج',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: GridView.builder(
            itemCount: buttons.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // عدد الأعمدة
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
            ),
            itemBuilder: (context, index) {
              final btn = buttons[index];
              return GestureDetector(
                onTap: btn.onTap,
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: btn.color.withOpacity(0.8),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(btn.icon, size: 40, color: Colors.white),
                        const SizedBox(height: 12),
                        Text(
                          btn.label,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HomeButton {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  _HomeButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}
