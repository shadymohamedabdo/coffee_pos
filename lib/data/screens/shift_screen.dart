import 'package:flutter/material.dart';
import '../repositories/shifts_repository.dart';

class ShiftScreen extends StatefulWidget {
  const ShiftScreen({super.key});

  @override
  State<ShiftScreen> createState() => _ShiftScreenState();
}

class _ShiftScreenState extends State<ShiftScreen> {
  final repo = ShiftsRepository();
  Map<String, dynamic>? openShift;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadShift();
  }

  Future<void> loadShift() async {
    setState(() => isLoading = true);
    final shift = await repo.getOpenShift();
    if (mounted) {
      setState(() {
        openShift = shift;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'إدارة الشيفتات',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const NetworkImage(
              'https://images.unsplash.com/photo-1541167760496-1628856ab772?ixlib=rb-4.0.3&auto=format&fit=crop&w=1920&q=80',
            ),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.7),
              BlendMode.darken,
            ),
          ),
        ),
        child: Center(
          child: isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      width: 400,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            openShift != null ? Icons.lock_open : Icons.lock,
            size: 80,
            color: openShift != null ? Colors.greenAccent : Colors.white70,
          ),
          const SizedBox(height: 24),
          Text(
            openShift != null ? 'الشيفت الحالي مفتوح' : 'لا يوجد شيفت مفتوح',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          if (openShift != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'نوع الشيفت: ${openShift!['type']}',
                style: const TextStyle(color: Colors.white70, fontSize: 18),
              ),
            ),
          const SizedBox(height: 48),

          if (openShift == null) ...[
            _shiftButton(
              label: 'فتح شيفت صباحي',
              color: Colors.amber,
              icon: Icons.wb_sunny,
              onPressed: () async {
                await repo.openShift("صباحي");
                await loadShift();
              },
            ),
            const SizedBox(height: 16),
            _shiftButton(
              label: 'فتح شيفت مسائي',
              color: Colors.deepPurpleAccent,
              icon: Icons.nights_stay,
              onPressed: () async {
                await repo.openShift('مسائي');
                await loadShift();
              },
            ),
          ] else
            _shiftButton(
              label: 'إغلاق الشيفت الحالي',
              color: Colors.redAccent,
              icon: Icons.lock_clock,
              onPressed: () async {
                await repo.closeShift(openShift!['id']);
                await loadShift();
              },
            ),
        ],
      ),
    );
  }

  Widget _shiftButton({
    required String label,
    required Color color,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        icon: Icon(icon, color: Colors.white),
        label: Text(label),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 6,
        ),
      ),
    );
  }
}
