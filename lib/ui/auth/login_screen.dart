import 'package:attendance_app/data/repo/auth_repo.dart';
import 'package:attendance_app/nav/navigation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    if (!mounted) return;
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
    context.goNamed(Screen.admin.name);
  }

  void _navigateToScanner() {
    context.goNamed(Screen.user.name);
  }

  void _login(BuildContext context) async {
    try {
      final user = await authRepo.login(
        emailController.text,
        passwordController.text,
      );
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid email or password')),
        );
        return;
      }

      final profile = await authRepo.getUserProfile(user.uid);
      if (profile == null) {
        await authRepo.logout();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid email or password')),
        );
        return;
      }

      await _completeLogin(user);
    } on FirebaseAuthException catch (e) {
      final invalidCredCodes = {
        'wrong-password',
        'user-not-found',
        'invalid-credential',
        'invalid-email',
      };
      final message =
          invalidCredCodes.contains(e.code)
              ? 'Invalid email or password'
              : 'Login failed: ${e.message ?? e.code}';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
    }
  }

  Future<void> _completeLogin(User? user) async {
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid email or password')),
      );
      return;
    }
    final admin = await authRepo.isAdmin(user.uid);
    if (!mounted) return;
    if (admin) {
      _navigateToAdmin();
    } else {
      _navigateToScanner();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login"), centerTitle: true, automaticallyImplyLeading: false,),
      body: SafeArea(
        child: SingleChildScrollView(
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
              TextButton(
                onPressed: () => context.pushNamed(Screen.forgot.name),
                child: const Text(
                  "Forgot password?",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
