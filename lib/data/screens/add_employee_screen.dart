import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../user_cubit/user_cubit.dart';
import '../user_cubit/user_state.dart';

class AddEmployeeScreen extends StatelessWidget {
  final Map<String, dynamic> currentUser;

  AddEmployeeScreen({super.key, required this.currentUser});

  final nameCtrl = TextEditingController();
  final userCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final searchCtrl = TextEditingController();
  String role = 'employee';

  @override
  Widget build(BuildContext context) {
    // حماية الأدمن
    if (currentUser['role'] != 'admin') {
      return const Scaffold(
        body: Center(child: Text('غير مصرح لك بالدخول')),
      );
    }

    return Builder(builder: (context) {
      final cubit = context.read<UsersCubit>();

      void showAddEmployeeDialog() {
        nameCtrl.clear();
        userCtrl.clear();
        passCtrl.clear();
        role = 'employee';

        showDialog(
          context: context,
          builder: (dialogCtx) => AlertDialog(
            title: const Text('إضافة موظف جديد'),
            content: SizedBox(
              width: 400,
              child: SingleChildScrollView(
                child: Column(
                  children: [
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
                      value: role,
                      items: const [
                        DropdownMenuItem(
                            value: 'employee', child: Text('موظف')),
                        DropdownMenuItem(
                            value: 'admin', child: Text('أدمن')),
                      ],
                      onChanged: (v) => role = v!,
                      decoration: const InputDecoration(
                        labelText: 'الصلاحية',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nameCtrl.text.isEmpty ||
                      userCtrl.text.isEmpty ||
                      passCtrl.text.length < 4) return;

                  await cubit.addEmployee(
                    name: nameCtrl.text,
                    username: userCtrl.text,
                    password: passCtrl.text,
                    role: role,
                  );
                  Navigator.pop(dialogCtx);
                },
                child: const Text('حفظ'),
              ),
            ],
          ),
        );
      }

      return Scaffold(
        appBar: AppBar(
          title: const Text('الموظفين'),
          actions: [
            IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => cubit.loadEmployees()),
            IconButton(
                icon: const Icon(Icons.add),
                onPressed: showAddEmployeeDialog),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: searchCtrl,
                decoration: const InputDecoration(labelText: 'بحث'),
                onChanged: (_) => (context as Element).markNeedsBuild(),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: BlocBuilder<UsersCubit, UsersState>(
                  builder: (context, state) {
                    if (state is UsersLoading || state is UsersInitial) {
                      return const Center(
                          child: CircularProgressIndicator());
                    }

                    if (state is UsersLoaded) {
                      final filtered = state.employees.where((e) {
                        final q = searchCtrl.text.toLowerCase();
                        return e['name'].toString().toLowerCase().contains(q);
                      }).toList();

                      if (filtered.isEmpty) {
                        return const Center(child: Text('لا يوجد موظفين'));
                      }

                      return ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (ctx, i) {
                          final e = filtered[i];
                          return Card(
                            child: ListTile(
                              title: Text(e['name']),
                              subtitle: Text('اسم المستخدم: ${e['username']}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () =>
                                        cubit.deleteEmployee(e['id']),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }

                    if (state is UsersError) {
                      return Center(child: Text(state.message));
                    }

                    return const SizedBox();
                  },
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
