import 'package:flutter/material.dart';
import '../repositories/users_repository.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final repo = UsersRepository();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> login() async {
    final user = await repo.login(
      usernameController.text,
      passwordController.text,
    );

    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(currentUser: user),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اسم المستخدم أو كلمة المرور خطأ')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تسجيل الدخول')),
      body: Center(
        child: SizedBox(
          width: 400,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: usernameController,
                    decoration: const InputDecoration(labelText: 'اسم المستخدم'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'كلمة المرور'),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: login,
                    child: const Text('تسجيل الدخول'),
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
