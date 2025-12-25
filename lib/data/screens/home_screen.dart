import 'package:coffee_pos/data/screens/profit_calculator.dart';
import 'package:coffee_pos/data/screens/monthly_report.dart';
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
    final bool isAdmin = currentUser['role'] == 'admin';
    final bool isLargeScreen = MediaQuery.of(context).size.width > 600;

    // زر تسجيل البيع - الأهم
    final Widget mainSaleButton = _buildMenuItem(
      label: 'تسجيل بيع',
      icon: Icons.add_shopping_cart,
      color: Colors
          .green, // Keep green logic but styled differently in internal method? Or just pass base color
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddSaleScreen(currentUser: currentUser),
          ),
        );
      },
      isMain: true,
    );

    // باقي الأزرار
    final List<Widget> otherButtons = [
      _buildMenuItem(
        label: 'تقرير الشيفت',
        icon: Icons.receipt_long,
        color: Colors.orange,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ShiftReportScreen(currentUser: currentUser),
            ),
          );
        },
      ),
      if (isAdmin)
        _buildMenuItem(
          label: 'التقرير الشهري',
          icon: Icons.calendar_month,
          color: Colors.teal,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MonthlyReportScreen()),
          ),
        ),
      if (isAdmin)
        _buildMenuItem(
          label: 'حاسبة صافي الربح',
          icon: Icons.calculate,
          color: Colors.amber,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfitCalculatorScreen()),
          ),
        ),
      if (isAdmin)
        _buildMenuItem(
          label: 'الاحصائيات',
          icon: Icons.dashboard,
          color: Colors.blue,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
          ),
        ),
      if (isAdmin)
        _buildMenuItem(
          label: 'إدارة الشيفتات',
          icon: Icons.access_time,
          color: Colors.red,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ShiftScreen()),
          ),
        ),
      if (isAdmin)
        _buildMenuItem(
          label: 'إدارة المنتجات',
          icon: Icons.coffee,
          color: Colors.brown,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProductsScreen()),
          ),
        ),
      if (isAdmin)
        _buildMenuItem(
          label: 'إدارة الموظفين',
          icon: Icons.people,
          color: Colors.purple,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddEmployeeScreen(currentUser: currentUser),
            ),
          ),
        ),
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'نظام POS - محل البن',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
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
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const NetworkImage(
              'https://images.unsplash.com/photo-1509042239860-f550ce710b93?ixlib=rb-4.0.3&auto=format&fit=crop&w=1920&q=80',
            ),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.7),
              BlendMode.darken,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
          child: Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'مرحباً، ${currentUser['name'] ?? currentUser['username']}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(height: 32),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isLargeScreen ? 4 : 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.1,
                      ),
                      itemCount: otherButtons.length + 1,
                      itemBuilder: (context, index) {
                        if (index == otherButtons.length) {
                          return mainSaleButton;
                        }
                        return otherButtons[index];
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isMain = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isMain
                ? color.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.2),
            width: isMain ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
          gradient: isMain
              ? LinearGradient(
                  colors: [
                    color.withValues(alpha: 0.3),
                    color.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(icon, size: isMain ? 40 : 32, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
