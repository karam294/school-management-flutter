import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/app_background.dart';

class ClassesPage extends StatefulWidget {
  const ClassesPage({super.key});

  @override
  State<ClassesPage> createState() => _ClassesPageState();
}

class _ClassesPageState extends State<ClassesPage> {
  List classes = [];
  String error = "";
  bool loading = true;

  Future<void> load() async {
    if (!mounted) return;

    setState(() {
      loading = true;
      error = "";
    });

    try {
      final c = await ApiService.getClasses();
      if (!mounted) return;
      setState(() => classes = c);
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
    const cardColor = Color(0xFF2A3140);

    return Scaffold(
      backgroundColor: AppBackground.bg,
      appBar: AppBar(
        title: const Text("Classes", style: TextStyle(color: Colors.white)),
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
                      "Error:\n$error",
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: classes.length,
                    itemBuilder: (_, i) {
                      final c = classes[i];
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
                          subtitle: Text(
                            "students: ${students.length}",
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
