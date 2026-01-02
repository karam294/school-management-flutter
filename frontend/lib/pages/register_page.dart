import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController(); // moved inside state

  String role = 'student';
  String msg = '';
  String error = '';
  bool loading = false;

  Future<void> doRegister() async {
    setState(() {
      loading = true;
      error = '';
      msg = '';
    });

    // Simple validation
    if (passwordCtrl.text.trim().isEmpty) {
      setState(() {
        error = "Password cannot be empty";
        loading = false;
      });
      return;
    }

    try {
      if (role == 'admin') {
        throw Exception("Admin is manual (not allowed in Register).");
      }

      await ApiService.createUser(
        name: nameCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        role: role,
        password: passwordCtrl.text.trim(), // send password
      );

      setState(() => msg = "Account created ✅ Now go back and login.");
    } catch (e) {
      setState(() => error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose(); // dispose password controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
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
                  // Name field
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: "Name",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Email field
                  TextField(
                    controller: emailCtrl,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Password field
                  TextField(
                    controller: passwordCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Password",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Role dropdown
                  DropdownButtonFormField<String>(
                    value: role,
                    items: const [
                      DropdownMenuItem(value: 'student', child: Text('student')),
                      DropdownMenuItem(value: 'teacher', child: Text('teacher')),
                      DropdownMenuItem(value: 'admin', child: Text('admin (manual)')),
                    ],
                    onChanged: (v) => setState(() => role = v ?? 'student'),
                    decoration: const InputDecoration(
                      labelText: "Role",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Error or success messages
                  if (error.isNotEmpty)
                    Text(error, style: const TextStyle(color: Colors.red)),
                  if (msg.isNotEmpty)
                    Text(msg, style: const TextStyle(color: Colors.green)),
                  const SizedBox(height: 10),

                  // Register button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: loading ? null : doRegister,
                      child: loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text("Create account"),
                    ),
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
 