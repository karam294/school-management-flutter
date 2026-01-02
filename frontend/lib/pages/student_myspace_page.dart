import 'package:flutter/material.dart';
import '../services/api_service.dart';

class StudentMySpacePage extends StatefulWidget {
  final Map<String, dynamic> user;
  const StudentMySpacePage({super.key, required this.user});

  @override
  State<StudentMySpacePage> createState() => _StudentMySpacePageState();
}

class _StudentMySpacePageState extends State<StudentMySpacePage> {
  bool loading = true;
  String error = "";

  Map<String, dynamic>? myClass;
  List agenda = [];
  List grades = [];

  Future<void> load() async {
    setState(() {
      loading = true;
      error = "";
    });

    try {
      final studentId = widget.user["_id"];
      final classId = widget.user["classId"];

      // reset
      myClass = null;
      agenda = [];
      grades = [];

      // Class (populated)
      if (classId != null) {
        myClass = await ApiService.getClassById(classId);
      }

      // Agenda (by classId)
      final a = (classId == null)
          ? <dynamic>[]
          : await ApiService.getAgendaForClass(classId);

      // Grades (by studentId)
      final g = await ApiService.getGradesForStudent(studentId);

      setState(() {
        agenda = a;
        grades = g;
      });
    } catch (e) {
      setState(() => error = e.toString().replaceFirst("Exception: ", ""));
    } finally {
      setState(() => loading = false);
    }
  }

  String _formatDate(dynamic iso) {
    if (iso == null) return "";
    final s = iso.toString();
    // often comes like: 2026-01-02T00:00:00.000Z
    return s.length >= 10 ? s.substring(0, 10) : s;
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.user["name"] ?? "";
    final email = widget.user["email"] ?? "";

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Space (Student)"),
        actions: [
          IconButton(onPressed: load, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error.isNotEmpty
              ? Center(child: Text("Error:\n$error"))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hello $name 👋",
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(email, style: const TextStyle(color: Colors.black54)),
                      const SizedBox(height: 20),

                      // CLASS
                      const Text("My Class", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      myClass == null
                          ? const Text("No class assigned yet.")
                          : Card(
                              child: ListTile(
                                title: Text("Grade ${myClass!["grade"]} - Section ${myClass!["section"]}"),
                                subtitle: Text("Students in class: ${(myClass!["students"] as List).length}"),
                              ),
                            ),

                      const SizedBox(height: 20),

                      // AGENDA
                      const Text("My Agenda", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      if (agenda.isEmpty) const Text("No agenda items."),
                      ...agenda.map((a) {
                        final title = a["title"] ?? "";
                        final type = a["type"] ?? "";
                        final desc = a["description"] ?? "";
                        final due = _formatDate(a["dueDate"]);
                        final teacherName = a["teacherId"]?["name"] ?? "unknown";

                        return Card(
                          child: ListTile(
                            title: Text("$title  ($type)"),
                            subtitle: Text("Due: $due\nTeacher: $teacherName\n$desc"),
                          ),
                        );
                      }),

                      const SizedBox(height: 20),

                      // GRADES
                      const Text("My Grades", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      if (grades.isEmpty) const Text("No grades yet."),
                      ...grades.map((g) {
                        final c = g["classId"];
                        final classLabel = (c == null)
                            ? "Unknown class"
                            : "Grade ${c["grade"]} - ${c["section"]}";

                        final data = (g["gradesData"] as Map?) ?? {};
                        final exam1 = data["exam1"]; // 15
                        final exam1Text = (exam1 == null) ? "Exam1: -" : "Exam1: $exam1/20";

                        return Card(
                          child: ListTile(
                            title: Text(classLabel),
                            subtitle: Text(exam1Text),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
    );
  }
}
