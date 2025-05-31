import 'package:attendance_app/data/repo/auth_repo.dart';
import 'package:attendance_app/nav/navigation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthRepo _authRepo = AuthRepo();

  @override
  void initState() {
    super.initState();
    _checkLoginState();
  }

  void _checkLoginState() async {
    final user = await _authRepo.getCurrentUser();
    if (user != null) {
      final isAdmin = await _authRepo.isAdmin(user.uid);
      if (!mounted) return;
      context.goNamed(isAdmin ? Screen.admin.name : Screen.user.name);
    } else {
      if (!mounted) return;
      context.goNamed(Screen.login.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // Simple loading spinner
      ),
    );
  }
}
