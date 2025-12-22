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

  @override
  Widget build(BuildContext context) {
    if (currentUser['role'] != 'admin') {
      return const Scaffold(
        body: Center(child: Text('غير مصرح لك بالدخول')),
      );
    }

    final cubit = context.read<UsersCubit>();

    void showAddEmployeeDialog() {
      nameCtrl.clear();
      userCtrl.clear();
      passCtrl.clear();
      String role = 'employee';

      showDialog(
        context: context,
        builder: (_) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('إضافة مستخدم'),
                content: SizedBox(
                  width: 400,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'الاسم',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: userCtrl,
                        decoration: const InputDecoration(
                          labelText: 'اسم المستخدم',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: passCtrl,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'كلمة المرور',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: role,
                        items: const [
                          DropdownMenuItem(
                              value: 'employee', child: Text('موظف')),
                          DropdownMenuItem(
                              value: 'admin', child: Text('أدمن')),
                        ],
                        onChanged: (v) => setState(() => role = v!),
                        decoration: const InputDecoration(
                          labelText: 'الصلاحية',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('إلغاء'),
                  ),
                  ElevatedButton(
                    child: const Text('حفظ'),
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

                      Navigator.pop(context);
                    },
                  ),
                ],
              );
            },
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة المستخدمين'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: cubit.loadEmployees,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: showAddEmployeeDialog,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: searchCtrl,
              decoration: const InputDecoration(labelText: 'بحث'),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: BlocBuilder<UsersCubit, UsersState>(
                builder: (_, state) {
                  if (state is UsersLoading || state is UsersInitial) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is UsersError) {
                    return Center(child: Text(state.message));
                  }

                  if (state is UsersLoaded) {
                    final q = searchCtrl.text.toLowerCase();
                    final list = state.employees
                        .where((e) =>
                        e['name'].toString().toLowerCase().contains(q))
                        .toList();

                    if (list.isEmpty) {
                      return const Center(child: Text('لا يوجد مستخدمين'));
                    }

                    return ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (_, i) {
                        final e = list[i];
                        return Card(
                          child: ListTile(
                            title: Text(e['name']),
                            subtitle: Text(
                                '${e['username']} - ${e['role']}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () =>
                                  cubit.deleteEmployee(e['id']),
                            ),
                          ),
                        );
                      },
                    );
                  }

                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
