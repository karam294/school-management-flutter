import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_page.dart';

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
    setState(() {
      loading = true;
      error = "";
    });
    try {
      classes = await ApiService.getClasses();
    } catch (e) {
      error = e.toString().replaceFirst("Exception: ", "");
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Teacher (${widget.teacher["name"]})"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Classes"),
              Tab(text: "Create"),
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
                ? Center(child: Text(error))
                : TabBarView(
                    children: [
                      _ClassesTab(classes: classes),
                      _CreateTab(teacher: widget.teacher, classes: classes),
                    ],
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
    if (classes.isEmpty) return const Center(child: Text("No classes."));
    return ListView(
      padding: const EdgeInsets.all(12),
      children: classes.map((c) {
        return Card(
          child: ListTile(
            title: Text("Grade ${c["grade"]} - Section ${c["section"]}"),
            subtitle: Text("students: ${(c["students"] as List?)?.length ?? 0}"),
            onTap: () async {
              final full = await ApiService.getClassWithStudents(c["_id"]);

              if (!context.mounted) return;
              final students = (full["students"] as List?) ?? [];

              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text("Students (Grade ${full["grade"]} ${full["section"]})"),
                  content: SizedBox(
                    width: 420,
                    child: ListView(
                      shrinkWrap: true,
                      children: students.map((s) {
                        return ListTile(
                          title: Text(s["name"] ?? ""),
                          subtitle: Text(s["email"] ?? ""),
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
    // simple YYYY-MM-DD check
    return RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(s.trim());
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Choose Class", style: TextStyle(fontWeight: FontWeight.bold)),
          DropdownButtonFormField<String>(
            value: selectedClassId,
            items: widget.classes.map<DropdownMenuItem<String>>((c) {
              return DropdownMenuItem(
                value: c["_id"],
                child: Text("Grade ${c["grade"]} - ${c["section"]}"),
              );
            }).toList(),
            onChanged: (v) => setState(() => selectedClassId = v),
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),

          const SizedBox(height: 18),
          const Divider(),

          // AGENDA
          const Text("Create Agenda", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: "Title (required)")),
          DropdownButton<String>(
            value: agendaType,
            items: const [
              DropdownMenuItem(value: "homework", child: Text("homework")),
              DropdownMenuItem(value: "test", child: Text("test")),
              DropdownMenuItem(value: "other", child: Text("other")),
            ],
            onChanged: (v) => setState(() => agendaType = v!),
          ),
          TextField(controller: descCtrl, decoration: const InputDecoration(labelText: "Description (required)")),
          TextField(controller: dueDateCtrl, decoration: const InputDecoration(labelText: "Due date (YYYY-MM-DD)")),
          const SizedBox(height: 8),
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

                // clear inputs
                titleCtrl.clear();
                descCtrl.clear();
              } catch (e) {
                setState(() => msg = "❌ ${e.toString().replaceFirst("Exception: ", "")}");
              }
            },
            child: const Text("Create Agenda"),
          ),

          const SizedBox(height: 18),
          const Divider(),

          // GRADE
          const Text("Create Grade", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Text("Paste studentId from /users then create grade.", style: TextStyle(color: Colors.black54)),
          TextField(controller: studentIdCtrl, decoration: const InputDecoration(labelText: "StudentId")),
          TextField(controller: gradeCtrl, decoration: const InputDecoration(labelText: "Exam1 grade (number)")),
          const SizedBox(height: 8),
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
          if (msg.isNotEmpty) Text(msg),
        ],
      ),
    );
  }
}
