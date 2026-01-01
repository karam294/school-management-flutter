import 'package:flutter/material.dart';
import '../pages/dashboard_page.dart';
import '../pages/users_page.dart';
import '../pages/classes_page.dart';
import '../pages/login_page.dart';

class AppDrawer extends StatelessWidget {
  final Map<String, dynamic> currentUser;
  const AppDrawer({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    final role = (currentUser['role'] ?? '').toString();

    void go(Widget page) {
      Navigator.pop(context);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
    }

    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text("${currentUser['name']} ($role)"),
            accountEmail: Text("${currentUser['email']}"),
          ),
          ListTile(
            title: const Text("Dashboard"),
            onTap: () => go(DashboardPage(currentUser: currentUser)),
          ),
          ListTile(
            title: const Text("Users"),
            onTap: () => go(UsersPage(currentUser: currentUser)),
          ),
          ListTile(
            title: const Text("Classes"),
            onTap: () => go(ClassesPage(currentUser: currentUser)),
          ),
          const Divider(),
          ListTile(
            title: const Text("Logout"),
            onTap: () {
              Navigator.pop(context);
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
