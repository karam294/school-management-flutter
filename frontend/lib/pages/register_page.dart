import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/app_background.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController(); // Added password controller

  String role = 'student';
  int grade = 10;
  String section = 'A';

  String msg = '';
  String error = '';
  bool loading = false;

  Future<void> doRegister() async {
    setState(() {
      loading = true;
      error = '';
      msg = '';
    });

    try {
      if (role == 'admin') {
        throw Exception("Admin is manual (not allowed in Register).");
      }
      if (nameCtrl.text.trim().isEmpty ||
          emailCtrl.text.trim().isEmpty ||
          passwordCtrl.text.trim().isEmpty) {
        throw Exception("Name, Email, and Password are required.");
      }
      if (passwordCtrl.text.trim().length < 6) {
        throw Exception("Password must be at least 6 characters.");
      }

      await ApiService.createUser(
        name: nameCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        password: passwordCtrl.text.trim(), // send password
        role: role,
        grade: role == "student" ? grade : null,
        section: role == "student" ? section : null,
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
    passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const cardColor = Color(0xFF2A3140);
    const fieldColor = Color(0xFF202633);

    return Scaffold(
      backgroundColor: AppBackground.bg,
      appBar: AppBar(
        title: const Text("Register", style: TextStyle(color: Colors.white)),
        backgroundColor: AppBackground.bg,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: AppBackground(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
              color: cardColor,
              elevation: 8,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Name",
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: fieldColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: emailCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Email",
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: fieldColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: passwordCtrl, // Added password field
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Password",
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: fieldColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: role,
                      dropdownColor: cardColor,
                      style: const TextStyle(color: Colors.white),
                      items: const [
                        DropdownMenuItem(
                            value: 'student', child: Text('Student')),
                        DropdownMenuItem(
                            value: 'teacher', child: Text('Teacher')),
                        DropdownMenuItem(
                            value: 'admin', child: Text('Admin (manual)')),
                      ],
                      onChanged: (v) => setState(() => role = v ?? 'student'),
                      decoration: InputDecoration(
                        labelText: "Role",
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: fieldColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    if (role == "student") ...[
                      const SizedBox(height: 12),
                     
                    ],
                    const SizedBox(height: 16),
                    if (error.isNotEmpty)
                      Text(error,
                          style: const TextStyle(color: Colors.redAccent)),
                    if (msg.isNotEmpty)
                      Text(msg,
                          style:
                              const TextStyle(color: Colors.lightGreenAccent)),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: loading ? null : doRegister,
                        child: loading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
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
      ),
    );
  }
}
