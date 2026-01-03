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
    if (!mounted) return;

    setState(() {
      loading = true;
      error = "";
    });

    try {
      final s = await ApiService.getUsers(role: "student");
      final t = await ApiService.getUsers(role: "teacher");
      final c = await ApiService.getClasses();

      if (!mounted) return;
      setState(() {
        students = s;
        teachers = t;
        classes = c;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = e.toString().replaceFirst("Exception: ", "");
      });
    } finally {
      if (!mounted) return;
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
    final adminName = (widget.admin["name"] ?? "Admin").toString();

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
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Color(0xFF5B6CFF),
            tabs: [
              Tab(text: "Assign"),
              Tab(text: "Create User"),
              Tab(text: "Users"),
              Tab(text: "Classes"),
            ],
          ),
          actions: [
            IconButton(onPressed: loading ? null : load, icon: const Icon(Icons.refresh, color: Colors.white)),
            IconButton(onPressed: logout, icon: const Icon(Icons.logout, color: Colors.white)),
          ],
        ),
        body: AppBackground(
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : error.isNotEmpty
                  ? Center(
                      child: Text(
                        error,
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : TabBarView(
                      children: [
                        _AssignTab(
                          students: students,
                          classes: classes,
                          onDone: load,
                        ),
                        _CreateUserTab(onDone: load),
                        _UsersTab(
                          students: students,
                          teachers: teachers,
                          onDone: load,
                        ),
                        _AdminClassesTab(
                          classes: classes,
                          onOpenClass: (klass) async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AdminClassDetailsPage(klass: klass),
                              ),
                            );
                            await load();
                          },
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
}

/* ---------------- Assign Tab ---------------- */

class _AssignTab extends StatefulWidget {
  final List students;
  final List classes;
  final Future<void> Function() onDone;

  const _AssignTab({
    required this.students,
    required this.classes,
    required this.onDone,
  });

  @override
  State<_AssignTab> createState() => _AssignTabState();
}

class _AssignTabState extends State<_AssignTab> {
  String? studentId;
  String? classId;
  String msg = "";

  @override
  Widget build(BuildContext context) {
    const cardColor = Color(0xFF2A3140);
    const fieldColor = Color(0xFF202633);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: cardColor,
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Assign student to class",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  value: studentId,
                  dropdownColor: cardColor,
                  style: const TextStyle(color: Colors.white),
                  items: widget.students.map<DropdownMenuItem<String>>((s) {
                    return DropdownMenuItem(
                      value: s["_id"],
                      child: Text("${s["name"]} (${s["email"]})"),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => studentId = v),
                  decoration: InputDecoration(
                    labelText: "Student",
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
                  value: classId,
                  dropdownColor: cardColor,
                  style: const TextStyle(color: Colors.white),
                  items: widget.classes.map<DropdownMenuItem<String>>((c) {
                    return DropdownMenuItem(
                      value: c["_id"],
                      child: Text("Grade ${c["grade"]} - ${c["section"]}"),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => classId = v),
                  decoration: InputDecoration(
                    labelText: "Class",
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: fieldColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 14),
                ElevatedButton.icon(
                  icon: const Icon(Icons.check),
                  onPressed: () async {
                    setState(() => msg = "");
                    if (studentId == null || classId == null) {
                      setState(() => msg = "Pick student and class.");
                      return;
                    }

                    try {
                      await ApiService.updateUser(studentId!, {"classId": classId});
                      await ApiService.addStudentToClass(classId!, studentId!);

                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("✅ Assigned successfully")),
                      );

                      await widget.onDone();
                    } catch (e) {
                      setState(() => msg = e.toString().replaceFirst("Exception: ", ""));
                    }
                  },
                  label: const Text("Assign"),
                ),

                const SizedBox(height: 8),
                if (msg.isNotEmpty)
                  Text(msg, style: const TextStyle(color: Colors.redAccent)),

                const SizedBox(height: 8),
                const Text(
                  "Student will see My Class + My Agenda automatically.",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/* ---------------- Create User Tab ---------------- */

class _CreateUserTab extends StatefulWidget {
  final Future<void> Function() onDone;
  const _CreateUserTab({required this.onDone});

  @override
  State<_CreateUserTab> createState() => _CreateUserTabState();
}

class _CreateUserTabState extends State<_CreateUserTab> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  String role = "student";

  int grade = 10;
  String section = "A";

  String msg = "";

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
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
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Create a user",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 12),

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

                DropdownButtonFormField<String>(
                  value: role,
                  dropdownColor: cardColor,
                  style: const TextStyle(color: Colors.white),
                  items: const [
                    DropdownMenuItem(value: "student", child: Text("student")),
                    DropdownMenuItem(value: "teacher", child: Text("teacher")),
                  ],
                  onChanged: (v) => setState(() => role = v ?? "student"),
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
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: grade,
                          dropdownColor: cardColor,
                          style: const TextStyle(color: Colors.white),
                          items: List.generate(
                            12,
                            (i) => DropdownMenuItem(value: i + 1, child: Text("Grade ${i + 1}")),
                          ),
                          onChanged: (v) => setState(() => grade = v ?? 10),
                          decoration: InputDecoration(
                            labelText: "Grade",
                            labelStyle: const TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: fieldColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: section,
                          dropdownColor: cardColor,
                          style: const TextStyle(color: Colors.white),
                          items: const [
                            DropdownMenuItem(value: "A", child: Text("A")),
                            DropdownMenuItem(value: "B", child: Text("B")),
                            DropdownMenuItem(value: "C", child: Text("C")),
                          ],
                          onChanged: (v) => setState(() => section = v ?? "A"),
                          decoration: InputDecoration(
                            labelText: "Section",
                            labelStyle: const TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: fieldColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () async {
                    setState(() => msg = "");
                    try {
                      if (nameCtrl.text.trim().isEmpty || emailCtrl.text.trim().isEmpty) {
                        setState(() => msg = "Name + Email required");
                        return;
                      }

                      final res = await ApiService.createUser(
                        name: nameCtrl.text.trim(),
                        email: emailCtrl.text.trim(),
                        role: role,
                        grade: role == "student" ? grade : null,
                        section: role == "student" ? section : null,
                      );

                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("✅ Created: ${res["email"]}")),
                      );

                      nameCtrl.clear();
                      emailCtrl.clear();
                      await widget.onDone();
                    } catch (e) {
                      setState(() => msg = e.toString().replaceFirst("Exception: ", ""));
                    }
                  },
                  child: const Text("Create"),
                ),

                const SizedBox(height: 8),
                if (msg.isNotEmpty) Text(msg, style: const TextStyle(color: Colors.redAccent)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/* ---------------- Users Tab ---------------- */

class _UsersTab extends StatelessWidget {
  final List students;
  final List teachers;
  final Future<void> Function() onDone;

  const _UsersTab({
    required this.students,
    required this.teachers,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    const cardColor = Color(0xFF2A3140);

    Widget userCard(dynamic u) => Card(
          color: cardColor,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: ListTile(
            title: Text(u["name"] ?? "", style: const TextStyle(color: Colors.white)),
            subtitle: Text(u["email"] ?? "", style: const TextStyle(color: Colors.white70)),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.white70),
              onPressed: () async {
                await ApiService.deleteUser(u["_id"]);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ Deleted")));
                await onDone();
              },
            ),
          ),
        );

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        const Text("Teachers", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 8),
        ...teachers.map(userCard),

        const SizedBox(height: 16),
        const Text("Students", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 8),
        ...students.map(userCard),
      ],
    );
  }
}

/* ---------------- Classes Tab (Admin) ---------------- */

class _AdminClassesTab extends StatelessWidget {
  final List classes;
  final Future<void> Function(Map<String, dynamic> klass) onOpenClass;

  const _AdminClassesTab({
    required this.classes,
    required this.onOpenClass,
  });

  @override
  Widget build(BuildContext context) {
    const cardColor = Color(0xFF2A3140);

    if (classes.isEmpty) {
      return const Center(
        child: Text("No classes.", style: TextStyle(color: Colors.white)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: classes.length,
      itemBuilder: (_, i) {
        final c = (classes[i] as Map).cast<String, dynamic>();
        final students = (c["students"] as List?) ?? [];

        return Card(
          color: cardColor,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: ListTile(
            leading: const Icon(Icons.class_, color: Colors.white),
            title: Text(
              "Grade ${c["grade"]} - Section ${c["section"]}",
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text("Students: ${students.length}", style: const TextStyle(color: Colors.white70)),
            trailing: const Icon(Icons.chevron_right, color: Colors.white70),
            onTap: () => onOpenClass(c),
          ),
        );
      },
    );
  }
}
