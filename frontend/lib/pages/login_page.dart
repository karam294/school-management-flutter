import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'dashboard_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailCtrl = TextEditingController();
  String role = 'student';
  String error = '';
  bool loading = false;

  Future<void> login() async {
    setState(() {
      loading = true;
      error = '';
    });

    try {
      final users = await ApiService.getUsers(email: emailCtrl.text.trim(), role: role);
      if (users.isEmpty) {
        throw Exception("Account not found. Please register.");
      }

      final user = users.first as Map<String, dynamic>;

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DashboardPage(currentUser: user),
        ),
      );
    } catch (e) {
      setState(() => error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 520,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("School Management", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),

                  TextField(
                    controller: emailCtrl,
                    decoration: const InputDecoration(labelText: "Email", border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    value: role,
                    decoration: const InputDecoration(labelText: "Role", border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 'student', child: Text('student')),
                      DropdownMenuItem(value: 'teacher', child: Text('teacher')),
                      DropdownMenuItem(value: 'admin', child: Text('admin')), // login allowed, but register won't create admin
                    ],
                    onChanged: (v) => setState(() => role = v ?? 'student'),
                  ),

                  const SizedBox(height: 12),
                  if (error.isNotEmpty)
                    Text(error, style: const TextStyle(color: Colors.red)),

                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: loading ? null : login,
                          child: loading
                              ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Text("Login"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const RegisterPage()),
                          );
                        },
                        child: const Text("Register"),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),
                  const Text(
                    "Demo login: enter an email that exists in DB + correct role.\n(Admin is created manually.)",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
