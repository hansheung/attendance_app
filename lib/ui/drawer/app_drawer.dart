import 'package:attendance_app/data/repo/auth_repo.dart';
import 'package:attendance_app/nav/navigation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final authRepo = AuthRepo();

  String? email;
  String? lastLoggedIn;

  @override
  void initState() {
    super.initState();
    _getLoggedInUser();
  }

  void _getLoggedInUser() async {
    final user = await authRepo.getCurrentUser();
    if (user != null) {
      setState(() {
        email = user.email;
        lastLoggedIn =
            user.metadata.lastSignInTime?.toLocal().toString().split('.')[0];
      });
    }
  }

  void _logout() async {
    await authRepo.logout();
    context.pushNamed(Screen.login.name);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          SizedBox(height: 40),

          Icon(Icons.account_circle, size: 80, color: Colors.blueAccent),

          SizedBox(height: 10),

          Text(email ?? "No email", style: TextStyle(fontSize: 18)),

          SizedBox(height: 10),

          Text(
            "Last login: ${lastLoggedIn ?? 'N/A'}",
            style: TextStyle(color: Colors.grey),
          ),

          SizedBox(height: 20),

          ListTile(
            leading: Icon(
              Icons.check_circle_outline,
              color: Colors.greenAccent,
            ),
            title: Text("Attendances"),
            onTap: () => context.pushNamed(Screen.admin.name),
          ),

          SizedBox(height: 16),

          ListTile(
            leading: Icon(Icons.location_on, color: Colors.blueAccent),
            title: Text("Site"),
            onTap: () => context.pushNamed(Screen.site.name),
          ),

          SizedBox(height: 16),

          ListTile(
            leading: Icon(Icons.download, color: Colors.black),
            title: Text("Export CSV"),
            onTap: () => context.pushNamed(Screen.export.name),
          ),

          Spacer(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text(
                "Logout",
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
