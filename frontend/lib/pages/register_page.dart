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
  String role = 'student';
  String msg = '';
  String error = '';
  bool loading = false;

  Future<void> register() async {
    setState(() {
      loading = true;
      msg = '';
      error = '';
    });

    try {
      await ApiService.createUser(
        name: nameCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        role: role, // only student/teacher
      );
      setState(() => msg = "Account created ✅ Now go back and login.");
    } catch (e) {
      setState(() => error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Center(
        child: SizedBox(
          width: 520,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: "Name", border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
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
                    ],
                    onChanged: (v) => setState(() => role = v ?? 'student'),
                  ),
                  const SizedBox(height: 12),

                  if (msg.isNotEmpty) Text(msg, style: const TextStyle(color: Colors.green)),
                  if (error.isNotEmpty) Text(error, style: const TextStyle(color: Colors.red)),

                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: loading ? null : register,
                    child: loading
                        ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text("Create account"),
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
