import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_page.dart';
import '../widgets/app_background.dart';

class TeacherPage extends StatefulWidget {
  final Map<String, dynamic> teacher;
  const TeacherPage({super.key, required this.teacher});

  @override
  State<TeacherPage> createState() => _TeacherPageState();
}

class _TeacherPageState extends State<TeacherPage> {
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
      classes = await ApiService.getClasses();
    } catch (e) {
      error = e.toString().replaceFirst("Exception: ", "");
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
    final tName = (widget.teacher["name"] ?? "Teacher").toString();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppBackground.bg,
        appBar: AppBar(
          title: Text("Teacher ($tName)", style: const TextStyle(color: Colors.white)),
          backgroundColor: AppBackground.bg,
          foregroundColor: Colors.white,
          elevation: 0,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Color(0xFF5B6CFF),
            tabs: [
              Tab(text: "Classes"),
              Tab(text: "Create"),
            ],
          ),
          actions: [
            IconButton(onPressed: load, icon: const Icon(Icons.refresh, color: Colors.white)),
            IconButton(onPressed: logout, icon: const Icon(Icons.logout, color: Colors.white)),
          ],
        ),
        body: AppBackground(
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : error.isNotEmpty
                  ? Center(child: Text(error, style: const TextStyle(color: Colors.white)))
                  : TabBarView(
                      children: [
                        _ClassesTab(classes: classes),
                        _CreateTab(teacher: widget.teacher, classes: classes),
                      ],
                    ),
        ),
      ),
    );
  }
}

class _ClassesTab extends StatelessWidget {
  final List classes;
  const _ClassesTab({required this.classes});

  @override
  Widget build(BuildContext context) {
    const cardColor = Color(0xFF2A3140);

    if (classes.isEmpty) {
      return const Center(child: Text("No classes.", style: TextStyle(color: Colors.white)));
    }

    return ListView(
      padding: const EdgeInsets.all(12),
      children: classes.map((c) {
        return Card(
          color: cardColor,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: ListTile(
            title: Text(
              "Grade ${c["grade"]} - Section ${c["section"]}",
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              "students: ${(c["students"] as List?)?.length ?? 0}",
              style: const TextStyle(color: Colors.white70),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.white70),
            onTap: () async {
              final full = await ApiService.getClassWithStudents(c["_id"]);

              if (!context.mounted) return;
              final students = (full["students"] as List?) ?? [];

              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: const Color(0xFF2A3140),
                  title: Text(
                    "Students (Grade ${full["grade"]} ${full["section"]})",
                    style: const TextStyle(color: Colors.white),
                  ),
                  content: SizedBox(
                    width: 420,
                    child: ListView(
                      shrinkWrap: true,
                      children: students.map((s) {
                        return ListTile(
                          title: Text(s["name"] ?? "", style: const TextStyle(color: Colors.white)),
                          subtitle: Text(s["email"] ?? "", style: const TextStyle(color: Colors.white70)),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }).toList(),
    );
  }
}

class _CreateTab extends StatefulWidget {
  final Map<String, dynamic> teacher;
  final List classes;
  const _CreateTab({required this.teacher, required this.classes});

  @override
  State<_CreateTab> createState() => _CreateTabState();
}

class _CreateTabState extends State<_CreateTab> {
  String? selectedClassId;

  // agenda
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final dueDateCtrl = TextEditingController(text: "2026-01-02");
  String agendaType = "homework";

  // grade
  final studentIdCtrl = TextEditingController();
  final gradeCtrl = TextEditingController(text: "15");

  String msg = "";

  @override
  void dispose() {
    titleCtrl.dispose();
    descCtrl.dispose();
    dueDateCtrl.dispose();
    studentIdCtrl.dispose();
    gradeCtrl.dispose();
    super.dispose();
  }

  bool _isValidDate(String s) {
    return RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(s.trim());
  }

  @override
  Widget build(BuildContext context) {
    const cardColor = Color(0xFF2A3140);
    const fieldColor = Color(0xFF202633);

    InputDecoration deco(String label) => InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: fieldColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        color: cardColor,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Choose Class", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                value: selectedClassId,
                dropdownColor: cardColor,
                style: const TextStyle(color: Colors.white),
                items: widget.classes.map<DropdownMenuItem<String>>((c) {
                  return DropdownMenuItem(
                    value: c["_id"],
                    child: Text("Grade ${c["grade"]} - ${c["section"]}"),
                  );
                }).toList(),
                onChanged: (v) => setState(() => selectedClassId = v),
                decoration: deco("Class"),
              ),

              const SizedBox(height: 18),
              Divider(color: Colors.white.withOpacity(0.15)),

              const Text("Create Agenda", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 10),

              TextField(controller: titleCtrl, style: const TextStyle(color: Colors.white), decoration: deco("Title (required)")),

              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: agendaType,
                dropdownColor: cardColor,
                style: const TextStyle(color: Colors.white),
                items: const [
                  DropdownMenuItem(value: "homework", child: Text("homework")),
                  DropdownMenuItem(value: "test", child: Text("test")),
                  DropdownMenuItem(value: "other", child: Text("other")),
                ],
                onChanged: (v) => setState(() => agendaType = v ?? "homework"),
                decoration: deco("Type"),
              ),

              const SizedBox(height: 10),
              TextField(controller: descCtrl, style: const TextStyle(color: Colors.white), decoration: deco("Description (required)")),

              const SizedBox(height: 10),
              TextField(controller: dueDateCtrl, style: const TextStyle(color: Colors.white), decoration: deco("Due date (YYYY-MM-DD)")),

              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  setState(() => msg = "");

                  if (selectedClassId == null) {
                    setState(() => msg = "❌ Pick a class first.");
                    return;
                  }
                  if (titleCtrl.text.trim().isEmpty || descCtrl.text.trim().isEmpty) {
                    setState(() => msg = "❌ Title and Description are required.");
                    return;
                  }
                  if (!_isValidDate(dueDateCtrl.text)) {
                    setState(() => msg = "❌ Date must be like 2026-01-02");
                    return;
                  }

                  try {
                    final body = {
                      "title": titleCtrl.text.trim(),
                      "type": agendaType,
                      "description": descCtrl.text.trim(),
                      "dueDate": dueDateCtrl.text.trim(),
                      "teacherId": widget.teacher["_id"],
                      "classId": selectedClassId,
                      "materials": [],
                    };

                    final res = await ApiService.createAgenda(body);
                    setState(() => msg = "✅ Agenda created: ${res["_id"] ?? res}");

                    titleCtrl.clear();
                    descCtrl.clear();
                  } catch (e) {
                    setState(() => msg = "❌ ${e.toString().replaceFirst("Exception: ", "")}");
                  }
                },
                child: const Text("Create Agenda"),
              ),

              const SizedBox(height: 18),
              Divider(color: Colors.white.withOpacity(0.15)),

              const Text("Create Grade", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 6),
              const Text("Paste studentId from /users then create grade.", style: TextStyle(color: Colors.white70)),

              const SizedBox(height: 10),
              TextField(controller: studentIdCtrl, style: const TextStyle(color: Colors.white), decoration: deco("StudentId")),
              const SizedBox(height: 10),
              TextField(controller: gradeCtrl, style: const TextStyle(color: Colors.white), decoration: deco("Exam1 grade (number)")),

              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  setState(() => msg = "");

                  if (selectedClassId == null) {
                    setState(() => msg = "❌ Pick a class first.");
                    return;
                  }
                  if (studentIdCtrl.text.trim().isEmpty) {
                    setState(() => msg = "❌ Paste a studentId first.");
                    return;
                  }

                  try {
                    final body = {
                      "studentId": studentIdCtrl.text.trim(),
                      "classId": selectedClassId,
                      "adminId": widget.teacher["_id"], // demo
                      "gradesData": {"exam1": int.tryParse(gradeCtrl.text) ?? 0},
                    };

                    final res = await ApiService.createGrade(body);
                    setState(() => msg = "✅ Grade created: ${res["_id"] ?? res}");
                  } catch (e) {
                    setState(() => msg = "❌ ${e.toString().replaceFirst("Exception: ", "")}");
                  }
                },
                child: const Text("Create Grade"),
              ),

              const SizedBox(height: 12),
              if (msg.isNotEmpty)
                Text(msg, style: TextStyle(color: msg.startsWith("✅") ? Colors.lightGreenAccent : Colors.redAccent)),
            ],
          ),
        ),
      ),
    );
  }
}
