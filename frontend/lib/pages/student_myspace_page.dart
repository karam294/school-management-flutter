import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_page.dart';
import '../widgets/app_background.dart';

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
    if (!mounted) return;

    setState(() {
      loading = true;
      error = "";
    });

    try {
      final studentId = widget.user["_id"];
      final classId = widget.user["classId"];

      if (classId != null) {
        myClass = await ApiService.getClassWithStudents(classId.toString());
        agenda = await ApiService.getAgendaByClass(classId.toString());
      } else {
        myClass = null;
        agenda = [];
      }

      grades = await ApiService.getGradesForStudent(studentId.toString());

      if (!mounted) return;
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      setState(() => error = e.toString().replaceFirst("Exception: ", ""));
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
  void initState() {
    super.initState();
    load();
  }

  @override
  Widget build(BuildContext context) {
    final name = (widget.user["name"] ?? "").toString();
    final email = (widget.user["email"] ?? "").toString();

    return Scaffold(
      backgroundColor: AppBackground.bg,
      appBar: AppBar(
        title: const Text("My Class", style: TextStyle(color: Colors.white)),
        backgroundColor: AppBackground.bg,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(onPressed: load, icon: const Icon(Icons.refresh, color: Colors.white)),
          IconButton(onPressed: logout, icon: const Icon(Icons.logout, color: Colors.white)),
        ],
      ),
      body: AppBackground(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : error.isNotEmpty
                ? Center(
                    child: Text(
                      "Error:\n$error",
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _HeaderCard(name: name, email: email),

                      const SizedBox(height: 14),
                      _SectionTitle(icon: Icons.school, title: "My Class"),
                      const SizedBox(height: 8),
                      myClass == null
                          ? const _EmptyCard(
                              text:
                                  "No class assigned yet.\n(Ask admin to assign or register with grade/section)",
                            )
                          : _ClassCard(myClass: myClass!),

                      const SizedBox(height: 16),
                      _SectionTitle(icon: Icons.event_note, title: "My Agenda"),
                      const SizedBox(height: 8),
                      agenda.isEmpty
                          ? const _EmptyCard(text: "No agenda items for your class.")
                          : Column(
                              children: agenda.map((a) => _AgendaCard(a: a)).toList(),
                            ),

                      const SizedBox(height: 16),
                      _SectionTitle(icon: Icons.grade, title: "My Grades"),
                      const SizedBox(height: 8),
                      grades.isEmpty
                          ? const _EmptyCard(text: "No grades yet.")
                          : Column(
                              children: grades.map((g) => _GradeCard(g: g)).toList(),
                            ),
                    ],
                  ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final String name;
  final String email;
  const _HeaderCard({required this.name, required this.email});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF2A3140),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 22,
              backgroundColor: Color(0xFF202633),
              child: Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hello, $name 👋",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 2),
                  Text(email, style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.white),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String text;
  const _EmptyCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF2A3140),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Text(text, style: const TextStyle(color: Colors.white70)),
      ),
    );
  }
}

class _ClassCard extends StatelessWidget {
  final Map<String, dynamic> myClass;
  const _ClassCard({required this.myClass});

  @override
  Widget build(BuildContext context) {
    final grade = myClass["grade"];
    final section = myClass["section"];
    final students = (myClass["students"] as List?) ?? [];

    return Card(
      color: const Color(0xFF2A3140),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: const Icon(Icons.class_, color: Colors.white),
        title: Text("Grade $grade - Section $section", style: const TextStyle(color: Colors.white)),
        subtitle: Text("Students in class: ${students.length}", style: const TextStyle(color: Colors.white70)),
      ),
    );
  }
}

class _AgendaCard extends StatelessWidget {
  final dynamic a;
  const _AgendaCard({required this.a});

  @override
  Widget build(BuildContext context) {
    final title = (a["title"] ?? "").toString();
    final type = (a["type"] ?? "").toString();
    final desc = (a["description"] ?? "").toString();
    final due = (a["dueDate"] ?? "").toString().split("T").first;
    final teacher = (a["teacherId"]?["name"] ?? "Teacher").toString();

    IconData icon = Icons.assignment;
    if (type == "test") icon = Icons.quiz;
    if (type == "other") icon = Icons.push_pin;

    return Card(
      color: const Color(0xFF2A3140),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        subtitle: Text(
          "Type: $type • Due: $due\nBy: $teacher\n$desc",
          style: const TextStyle(color: Colors.white70),
        ),
      ),
    );
  }
}

class _GradeCard extends StatelessWidget {
  final dynamic g;
  const _GradeCard({required this.g});

  @override
  Widget build(BuildContext context) {
    final classObj = g["classId"];
    final classLabel = classObj == null ? "Class" : "Grade ${classObj["grade"]} - ${classObj["section"]}";

    final data = (g["gradesData"] ?? {}) as Map;
    final exam1 = data["exam1"]?.toString() ?? "-";

    return Card(
      color: const Color(0xFF2A3140),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: const Icon(Icons.grade, color: Colors.white),
        title: Text(classLabel, style: const TextStyle(color: Colors.white)),
        subtitle: Text("Exam1: $exam1/20\nAll: $data", style: const TextStyle(color: Colors.white70)),
      ),
    );
  }
}
