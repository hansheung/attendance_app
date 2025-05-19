import 'package:attendance_app/data/repo/auth_repo.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  final authRepo = AuthRepo();

  void _login(BuildContext context) async {
    try {
      final user = await authRepo.login(
          emailController.text, passwordController.text);
      if (user != null) {
        final admin = await authRepo.isAdmin(user.uid);
        context.go(admin ? '/admin' : '/scanner');
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Login failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(controller: emailController, decoration: InputDecoration(labelText: 'Email')),
          TextField(controller: passwordController, obscureText: true, decoration: InputDecoration(labelText: 'Password')),
          ElevatedButton(onPressed: () => _login(context), child: const Text('Login')),
          TextButton(onPressed: () => context.go('/register'), child: const Text("Register")),
        ]),
      ),
    );
  }
}
