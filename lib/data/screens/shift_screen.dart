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

  @override
  void initState() {
    super.initState();
    loadShift();
  }

  Future<void> loadShift() async {
    final shift = await repo.getOpenShift();
    setState(() => openShift = shift);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إدارة الشيفتات')),
      body: Center(
        child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (openShift == null) ...[
                  const Text(
                    'لا يوجد شيفت مفتوح',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      await repo.openShift('morning');
                      await loadShift();
                    },
                    child: const Text('فتح شيفت صباحي'),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      await repo.openShift('night');
                      await loadShift();
                    },
                    child: const Text('فتح شيفت مسائي'),
                  ),
                ] else ...[
                  Text(
                    'شيفت مفتوح: ${openShift!['type']}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () async {
                      await repo.closeShift(openShift!['id']);
                      await loadShift();
                    },
                    child: const Text('قفل الشيفت'),
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}
