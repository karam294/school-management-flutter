import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'register_page.dart';
import 'role_dashboard.dart';
import 'teacher_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController(); // ✅ added
  String role = 'student';
  String error = '';
  bool loading = false;

  Future<void> doLogin() async {
    setState(() {
      loading = true;
      error = '';
    });

    // ✅ basic validation
    if (emailCtrl.text.trim().isEmpty ||
        passwordCtrl.text.trim().isEmpty) {
      setState(() {
        error = "Email and password are required";
        loading = false;
      });
      return;
    }

    try {
      final user = await ApiService.login(
        email: emailCtrl.text.trim(),
        password: passwordCtrl.text.trim(), // ✅ send password
        role: role,
      );

      if (!mounted) return;

      // ✅ Teacher goes to TeacherPage
      if (role == "teacher") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => TeacherPage(teacher: user)),
        );
        return;
      }

      // ✅ Admin + Student go to RoleDashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => RoleDashboard(user: user)),
      );
    } catch (e) {
      setState(() =>
          error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    passwordCtrl.dispose(); // ✅ dispose password
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "School Management",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Email
                  TextField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Password
                  TextField(
                    controller: passwordCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Password",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Role
                  DropdownButtonFormField<String>(
                    value: role,
                    items: const [
                      DropdownMenuItem(
                          value: 'student', child: Text('student')),
                      DropdownMenuItem(
                          value: 'teacher', child: Text('teacher')),
                      DropdownMenuItem(
                          value: 'admin', child: Text('admin')),
                    ],
                    onChanged: (v) =>
                        setState(() => role = v ?? 'student'),
                    decoration: const InputDecoration(
                      labelText: "Role",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  if (error.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        error,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),

                  // Login button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: loading ? null : doLogin,
                      child: loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text("Login"),
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterPage(),
                        ),
                      );
                    },
                    child: const Text("No account? Register"),
                  ),

                  const SizedBox(height: 6),
                  const Text(
                    "Use a registered email, password, and correct role",
                    style:
                        TextStyle(fontSize: 12, color: Colors.black54),
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
