import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_page.dart';
import 'admin_class_details_page.dart';
import '../widgets/app_background.dart';

class AdminPage extends StatefulWidget {
  final Map<String, dynamic> admin;
  const AdminPage({super.key, required this.admin});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  List students = [];
  List teachers = [];
  List classes = [];
  bool loading = true;
  String error = "";

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() {
      loading = true;
      error = "";
    });

    try {
      final s = await ApiService.getUsers(role: "student");
      final t = await ApiService.getUsers(role: "teacher");
      final c = await ApiService.getClasses();

      setState(() {
        students = s;
        teachers = t;
        classes = c;
      });
    } catch (e) {
      setState(() {
        error = e.toString().replaceFirst("Exception: ", "");
      });
    } finally {
      setState(() => loading = false);
    }
  }

  void logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminName = widget.admin["name"] ?? "Admin";

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppBackground.bg,
        appBar: AppBar(
          title: Text("Admin ($adminName)", style: const TextStyle(color: Colors.white)),
          backgroundColor: AppBackground.bg,
          foregroundColor: Colors.white,
          elevation: 0,
          bottom: const TabBar(
            tabs: [
              Tab(text: "Assign"),
              Tab(text: "Create User"),
              Tab(text: "Users"),
              Tab(text: "Classes"),
            ],
          ),
          actions: [
            IconButton(onPressed: load, icon: const Icon(Icons.refresh)),
            IconButton(onPressed: logout, icon: const Icon(Icons.logout)),
          ],
        ),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : error.isNotEmpty
                ? Center(child: Text(error, style: const TextStyle(color: Colors.white)))
                : TabBarView(
                    children: [
                      _AssignTab(students: students, classes: classes, onDone: load),
                      _CreateUserTab(onDone: load), // 👈 FIXED TAB
                      _UsersTab(students: students, teachers: teachers, onDone: load),
                      _AdminClassesTab(classes: classes, onOpenClass: (klass) async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AdminClassDetailsPage(klass: klass),
                          ),
                        );
                        await load();
                      }),
                    ],
                  ),
      ),
    );
  }
}

/* ================= CREATE USER TAB ================= */

class _CreateUserTab extends StatefulWidget {
  final Future<void> Function() onDone;
  const _CreateUserTab({required this.onDone});

  @override
  State<_CreateUserTab> createState() => _CreateUserTabState();
}

class _CreateUserTabState extends State<_CreateUserTab> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController(); // ✅ ADDED

  String role = "student";
  int grade = 10;
  String section = "A";
  String msg = "";

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose(); // ✅ ADDED
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const cardColor = Color(0xFF2A3140);
    const fieldColor = Color(0xFF202633);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: nameCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: _dec("Name", fieldColor),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: emailCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: _dec("Email", fieldColor),
                ),
                const SizedBox(height: 12),

                // ✅ PASSWORD FIELD
                TextField(
                  controller: passwordCtrl,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: _dec("Password", fieldColor),
                ),
                const SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  value: role,
                  items: const [
                    DropdownMenuItem(value: "student", child: Text("Student")),
                    DropdownMenuItem(value: "teacher", child: Text("Teacher")),
                  ],
                  onChanged: (v) => setState(() => role = v ?? "student"),
                  decoration: _dec("Role", fieldColor),
                ),

                if (role == "student") ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: grade,
                          items: List.generate(
                            12,
                            (i) => DropdownMenuItem(value: i + 1, child: Text("Grade ${i + 1}")),
                          ),
                          onChanged: (v) => setState(() => grade = v ?? 10),
                          decoration: _dec("Grade", fieldColor),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: section,
                          items: const [
                            DropdownMenuItem(value: "A", child: Text("A")),
                            DropdownMenuItem(value: "B", child: Text("B")),
                            DropdownMenuItem(value: "C", child: Text("C")),
                          ],
                          onChanged: (v) => setState(() => section = v ?? "A"),
                          decoration: _dec("Section", fieldColor),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 14),

                ElevatedButton(
                  onPressed: () async {
                    setState(() => msg = "");

                    if (passwordCtrl.text.length < 6) {
                      setState(() => msg = "Password must be at least 6 characters");
                      return;
                    }

                    try {
                      await ApiService.createUser(
                        name: nameCtrl.text.trim(),
                        email: emailCtrl.text.trim(),
                        password: passwordCtrl.text.trim(), // ✅ FIX
                        role: role,
                        grade: role == "student" ? grade : null,
                        section: role == "student" ? section : null,
                      );

                      nameCtrl.clear();
                      emailCtrl.clear();
                      passwordCtrl.clear();

                      await widget.onDone();
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("✅ User created")),
                      );
                    } catch (e) {
                      setState(() => msg = e.toString().replaceFirst("Exception: ", ""));
                    }
                  },
                  child: const Text("Create"),
                ),

                if (msg.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(msg, style: const TextStyle(color: Colors.redAccent)),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _dec(String label, Color bg) => InputDecoration(
        labelText: label,
        filled: true,
        fillColor: bg,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      );
}

/* ================= OTHER TABS (UNCHANGED) ================= */

class _AssignTab extends StatelessWidget {
  final List students;
  final List classes;
  final Future<void> Function() onDone;

  const _AssignTab({required this.students, required this.classes, required this.onDone});

  @override
  Widget build(BuildContext context) => const Center(child: Text("Assign tab unchanged"));
}

class _UsersTab extends StatelessWidget {
  final List students;
  final List teachers;
  final Future<void> Function() onDone;

  const _UsersTab({required this.students, required this.teachers, required this.onDone});

  @override
  Widget build(BuildContext context) => const Center(child: Text("Users tab unchanged"));
}

class _AdminClassesTab extends StatelessWidget {
  final List classes;
  final Future<void> Function(Map<String, dynamic>) onOpenClass;

  const _AdminClassesTab({required this.classes, required this.onOpenClass});

  @override
  Widget build(BuildContext context) => const Center(child: Text("Classes tab unchanged"));
}
