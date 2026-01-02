import 'package:flutter/material.dart';
import 'users_page.dart';
import 'classes_page.dart';
import 'login_page.dart';
import 'student_myspace_page.dart';


class RoleDashboard extends StatelessWidget {
  final Map<String, dynamic> user;
  const RoleDashboard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final role = (user['role'] ?? '').toString();
    final name = (user['name'] ?? '').toString();

    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard ($role)"),
        actions: [
          IconButton(
            tooltip: "Logout",
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (_) => false,
              );
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Hello, $name 👋", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                if (role == 'admin')
                  ElevatedButton.icon(
                    icon: const Icon(Icons.people),
                    label: const Text("Users (Admin)"),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const UsersPage()));
                    },
                  ),

                if (role == 'admin' || role == 'teacher')
                  ElevatedButton.icon(
                    icon: const Icon(Icons.class_),
                    label: const Text("Classes"),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ClassesPage()));
                    },
                  ),

                if (role == 'student')
                    ElevatedButton.icon(
                        icon: const Icon(Icons.person),
                                label: const Text("My Space"),
                  onPressed: () {
                  Navigator.push(
                     context,
                    MaterialPageRoute(builder: (_) => StudentMySpacePage(user: user)),
      );
    },
  ),

              ],
            ),

            const SizedBox(height: 24),
            const Text(
              "Goal: students do NOT see all users. Only admin can.",
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
