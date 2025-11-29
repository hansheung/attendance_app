import 'package:attendance_app/data/repo/auth_repo.dart';
import 'package:attendance_app/nav/navigation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final TextEditingController confirmController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  final AuthRepo authRepo = AuthRepo();
  bool _isRegistering = false;

  String? _validatePhone(String phone) {
    final pattern = RegExp(r'^\+60\d{8,10}$');
    if (!pattern.hasMatch(phone)) {
      return 'Phone must start with +60 and include 8-10 digits after it';
    }
    return null;
  }

  void _register(BuildContext context) async {
    try {
      final name = nameController.text.trim();
      final email = emailController.text.trim();
      final password = passwordController.text;
      final confirmPassword = confirmController.text;
      final phone = phoneController.text.trim();

      if (name.isEmpty ||
          email.isEmpty ||
          password.isEmpty ||
          confirmPassword.isEmpty ||
          phone.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("All fields are required.")));
        return;
      }

      if (password != confirmPassword) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Passwords are not the same.")));
        return;
      }

      final phoneError = _validatePhone(phone);
      if (phoneError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(phoneError)),
        );
        return;
      }

      setState(() => _isRegistering = true);

      final deviceId = await authRepo.getDeviceId();

      await authRepo.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
        deviceId: deviceId,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration successful!'),
          duration: Duration(seconds: 2),
        ),
      );

      // Navigate after short delay (optional)
      Future.delayed(const Duration(seconds: 2), () {
        context.pushNamed(Screen.login.name);
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Register failed: $e')));
    } finally {
      if (mounted) {
        setState(() => _isRegistering = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register"), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              SizedBox(height: 40.0),
              Center(
                child: Image.asset('assets/logo.png', height: 200, width: 200),
              ),
        
              SizedBox(height: 12.0),

              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
              ),

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
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone (+60...)',
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
        
              SizedBox(height: 12.0),
        
              TextField(
                controller: confirmController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(),
                ),
              ),
        
              SizedBox(height: 18.0),
        
              ElevatedButton(
                onPressed: _isRegistering ? null : () => _register(context),
                child: _isRegistering
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
