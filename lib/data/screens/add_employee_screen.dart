import 'package:flutter/material.dart';
import '../repositories/users_repository.dart';

class AddEmployeeScreen extends StatefulWidget {
  const AddEmployeeScreen({super.key});

  @override
  State<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  final repo = UsersRepository();

  final nameCtrl = TextEditingController();
  final userCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  String role = 'employee';

  @override
  Widget build(BuildContext context) {
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
                      labelText: 'كلمة المرور',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    initialValue: role,
                    items: const [
                      DropdownMenuItem(
                        value: 'employee',
                        child: Text('موظف'),
                      ),
                      DropdownMenuItem(
                        value: 'admin',
                        child: Text('أدمن'),
                      ),
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
                      onPressed: () async {
                        if (nameCtrl.text.isEmpty ||
                            userCtrl.text.isEmpty ||
                            passCtrl.text.isEmpty) {
                          return;
                        }

                        await repo.addUser(
                          name: nameCtrl.text,
                          username: userCtrl.text,
                          password: passCtrl.text,
                          role: role,
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('تم إضافة الموظف بنجاح ✅'),
                          ),
                        );

                        nameCtrl.clear();
                        userCtrl.clear();
                        passCtrl.clear();
                      },
                      child: const Text('حفظ الموظف'),
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
