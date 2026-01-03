import 'package:flutter/material.dart';
import '../pages/login_page.dart';
import '../pages/users_page.dart';
import '../pages/classes_page.dart';
import '../pages/role_dashboard.dart';

class AppDrawer extends StatelessWidget {
  final Map<String, dynamic> currentUser;
  const AppDrawer({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    final role = (currentUser['role'] ?? '').toString();

    void go(Widget page) {
      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => page),
      );
    }

    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(currentUser['name'] ?? ''),
            accountEmail: Text("${currentUser['email']} ($role)"),
          ),

          // ✅ HOME (RoleDashboard)
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Home"),
            onTap: () => go(RoleDashboard(user: currentUser)),
          ),

          if (role == "admin") ...[
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text("Users"),
              onTap: () => go(UsersPage(currentUser: currentUser)),
            ),
            ListTile(
              leading: const Icon(Icons.class_),
              title: const Text("Classes"),
              onTap: () => go(ClassesPage(currentUser: currentUser)),
            ),
          ],

          const Divider(),

          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (_) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
