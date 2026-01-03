import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/app_background.dart';

class AdminClassDetailsPage extends StatefulWidget {
  final Map<String, dynamic> klass;
  const AdminClassDetailsPage({super.key, required this.klass});

  @override
  State<AdminClassDetailsPage> createState() => _AdminClassDetailsPageState();
}

class _AdminClassDetailsPageState extends State<AdminClassDetailsPage> {
  bool loading = true;
  String error = "";

  Map<String, dynamic>? fullClass;
  List agendas = [];
  List grades = [];

  Future<void> load() async {
    if (!mounted) return;

    setState(() {
      loading = true;
      error = "";
    });

    try {
      final classId = widget.klass["_id"].toString();

      final fc = await ApiService.getClassWithStudents(classId);
      final ag = await ApiService.getAgendaByClass(classId);

      final students = (fc["students"] as List?) ?? [];
      final all = <dynamic>[];

      for (final s in students) {
        final sid = s["_id"].toString();
        final g = await ApiService.getGradesForStudent(sid);
        all.addAll(g);
      }

      if (!mounted) return;
      setState(() {
        fullClass = fc;
        agendas = ag;
        grades = all;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => error = e.toString().replaceFirst("Exception: ", ""));
    } finally {
      if (!mounted) return;
      setState(() => loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  Widget build(BuildContext context) {
    final grade = widget.klass["grade"];
    final section = widget.klass["section"];

    return Scaffold(
      backgroundColor: AppBackground.bg,
      appBar: AppBar(
        title: Text("Class $grade-$section", style: const TextStyle(color: Colors.white)),
        backgroundColor: AppBackground.bg,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(onPressed: load, icon: const Icon(Icons.refresh, color: Colors.white)),
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
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _title("Students"),
                      const SizedBox(height: 8),
                      _studentsList(),

                      const SizedBox(height: 18),
                      _title("Agenda (for this class)"),
                      const SizedBox(height: 8),
                      agendas.isEmpty
                          ? const _Empty(text: "No agenda yet for this class.")
                          : Column(children: agendas.map((a) => _agendaCard(a)).toList()),

                      const SizedBox(height: 18),
                      _title("Grades"),
                      const SizedBox(height: 8),
                      grades.isEmpty
                          ? const _Empty(text: "No grades yet for students in this class.")
                          : Column(children: grades.map((g) => _gradeCard(g)).toList()),
                    ],
                  ),
      ),
    );
  }

  Widget _studentsList() {
    const cardColor = Color(0xFF2A3140);
    final students = (fullClass?["students"] as List?) ?? [];
    if (students.isEmpty) return const _Empty(text: "No students in this class.");

    return Column(
      children: students.map((s) {
        return Card(
          color: cardColor,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: ListTile(
            leading: const Icon(Icons.person, color: Colors.white),
            title: Text((s["name"] ?? "").toString(), style: const TextStyle(color: Colors.white)),
            subtitle: Text((s["email"] ?? "").toString(), style: const TextStyle(color: Colors.white70)),
          ),
        );
      }).toList(),
    );
  }

  Widget _agendaCard(dynamic a) {
    const cardColor = Color(0xFF2A3140);
    final title = (a["title"] ?? "").toString();
    final type = (a["type"] ?? "").toString();
    final due = (a["dueDate"] ?? "").toString().split("T").first;

    return Card(
      color: cardColor,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: const Icon(Icons.event_note, color: Colors.white),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        subtitle: Text("Type: $type • Due: $due", style: const TextStyle(color: Colors.white70)),
      ),
    );
  }

  Widget _gradeCard(dynamic g) {
    const cardColor = Color(0xFF2A3140);
    final student = g["studentId"];
    final name = student?["name"] ?? "student";

    final data = (g["gradesData"] ?? {}) as Map;
    final exam1 = data["exam1"]?.toString() ?? "-";

    return Card(
      color: cardColor,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: const Icon(Icons.grade, color: Colors.white),
        title: Text("$name", style: const TextStyle(color: Colors.white)),
        subtitle: Text("Exam1: $exam1/20 • All: $data", style: const TextStyle(color: Colors.white70)),
      ),
    );
  }

  Widget _title(String t) => Text(
        t,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      );
}

class _Empty extends StatelessWidget {
  final String text;
  const _Empty({required this.text});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF2A3140),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Text(text, style: const TextStyle(color: Colors.white70)),
      ),
    );
  }
}
