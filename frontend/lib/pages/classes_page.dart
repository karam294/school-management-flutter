import 'package:flutter/material.dart';
import '../services/api_service.dart';

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
    setState(() {
      loading = true;
      error = "";
    });

    try {
      final c = await ApiService.getClasses();
      setState(() => classes = c);
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Classes"),
        actions: [
          IconButton(onPressed: load, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error.isNotEmpty
              ? Center(child: Text("Error:\n$error"))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: classes.length,
                  itemBuilder: (_, i) {
                    final c = classes[i];
                    final students = (c["students"] as List?) ?? [];
                    return Card(
                      child: ListTile(
                        title: Text("Grade ${c["grade"]} - Section ${c["section"]}"),
                        subtitle: Text("students: ${students.length}"),
                      ),
                    );
                  },
                ),
    );
  }
}
