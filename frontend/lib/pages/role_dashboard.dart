import 'package:flutter/material.dart';
import 'users_page.dart';
import 'classes_page.dart';
import 'login_page.dart';
import 'student_myspace_page.dart';
import '../widgets/app_background.dart';

class RoleDashboard extends StatelessWidget {
  final Map<String, dynamic> user;
  const RoleDashboard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final role = (user['role'] ?? '').toString();
    final name = (user['name'] ?? '').toString();

    String title = "Home";
    if (role == "admin") title = "Admin Home";
    if (role == "teacher") title = "Teacher Home";
    if (role == "student") title = "Student Home";

    return Scaffold(
      backgroundColor: AppBackground.bg,
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Colors.white)),
        backgroundColor: AppBackground.bg,
        foregroundColor: Colors.white,
        elevation: 0,
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
            icon: const Icon(Icons.logout, color: Colors.white),
          )
        ],
      ),
      body: AppBackground(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            color: const Color(0xFF2A3140),
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hello, $name 👋",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 16),

                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      if (role == 'admin')
                        ElevatedButton.icon(
                          icon: const Icon(Icons.people),
                          label: const Text("Users"),
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
                          icon: const Icon(Icons.school),
                          label: const Text("My Class"),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => StudentMySpacePage(user: user)),
                            );
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
