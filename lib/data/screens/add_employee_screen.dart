import 'package:flutter/material.dart';
import '../repositories/users_repository.dart';

class AddEmployeeScreen extends StatefulWidget {
  final Map<String, dynamic> currentUser;

  const AddEmployeeScreen({super.key, required this.currentUser});

  @override
  State<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  final repo = UsersRepository();

  final nameCtrl = TextEditingController();
  final userCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  String role = 'employee';
  bool isLoading = false;

  @override
  void dispose() {
    nameCtrl.dispose();
    userCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  Future<void> saveEmployee() async {
    if (nameCtrl.text.isEmpty ||
        userCtrl.text.isEmpty ||
        passCtrl.text.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('البيانات غير صحيحة')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await repo.addUser(
        name: nameCtrl.text,
        username: userCtrl.text,
        password: passCtrl.text,
        role: role,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إضافة الموظف بنجاح ✅')),
      );

      nameCtrl.clear();
      userCtrl.clear();
      passCtrl.clear();
      role = 'employee';
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اسم المستخدم موجود بالفعل ❌')),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    // 🔐 حماية الأدمن
    if (widget.currentUser['role'] != 'admin') {
      return const Scaffold(
        body: Center(child: Text('غير مصرح لك بالدخول')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('إضافة موظف')),
      body: Center(
        child: SizedBox(
          width: 500,
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'بيانات الموظف',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'الاسم',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: userCtrl,
                    decoration: const InputDecoration(
                      labelText: 'اسم المستخدم',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: passCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'كلمة المرور (4 أحرف على الأقل)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    value: role,
                    items: const [
                      DropdownMenuItem(value: 'employee', child: Text('موظف')),
                      DropdownMenuItem(value: 'admin', child: Text('أدمن')),
                    ],
                    onChanged: (v) => setState(() => role = v!),
                    decoration: const InputDecoration(
                      labelText: 'الصلاحية',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : saveEmployee,
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('حفظ الموظف'),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
