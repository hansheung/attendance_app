import 'package:attendance_app/data/repo/auth_repo.dart';
import 'package:attendance_app/nav/navigation.dart';
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

  @override
  void initState() {
    super.initState();
    _checkIfUserIsLoggedIn();
    
  }

  void _checkIfUserIsLoggedIn() async{
    final user = await authRepo.getCurrentUser();
    
    if(user != null ){
      final isAdmin = await authRepo.isAdmin(user.uid);
      if(isAdmin){
        _navigateToAdmin();
      }else{
        _navigateToScanner();
      }
    }
  }

  void _navigateToAdmin() {
    context.pushNamed(Screen.admin.name);
  }

  void _navigateToScanner() {
    context.pushNamed(Screen.user.name);
  }

  void _login(BuildContext context) async {
    try {
      final user = await authRepo.login(
        emailController.text,
        passwordController.text,
      );
      if (user != null) {
        final admin = await authRepo.isAdmin(user.uid);
        if (admin) {
          _navigateToAdmin();
        } else {
          _navigateToScanner();
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login"), centerTitle: true, automaticallyImplyLeading: false,),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(height: 20.0),
          
            Center(child: Image.asset('assets/logo.png',height: 200, width: 200,)),

            SizedBox(height: 12.0),
            
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 12.0),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 15.0),

            ElevatedButton(
              onPressed: () => _login(context),
              child: const Text('Login'),
            ),
            TextButton(
              onPressed: () => context.go('/register'),
              child: const Text(
                "New user, please register here",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
