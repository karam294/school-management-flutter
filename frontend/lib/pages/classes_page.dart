import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/app_drawer.dart';

class ClassesPage extends StatefulWidget {
  final Map<String, dynamic> currentUser;
  const ClassesPage({super.key, required this.currentUser});

  @override
  State<ClassesPage> createState() => _ClassesPageState();
}

class _ClassesPageState extends State<ClassesPage> {
  List classes = [];
  bool loading = true;
  String error = '';

  bool get isAdmin => (widget.currentUser['role'] == 'admin');

  Future<void> load() async {
    setState(() { loading = true; error = ''; });
    try {
      classes = await ApiService.getClasses();
    } catch (e) {
      error = e.toString();
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> showCreateDialog() async {
    final gradeCtrl = TextEditingController(text: "10");
    final sectionCtrl = TextEditingController(text: "A");

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Create Class (Admin only)"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: gradeCtrl, decoration: const InputDecoration(labelText: "Grade (max 12)")),
            TextField(controller: sectionCtrl, decoration: const InputDecoration(labelText: "Section (A/B/...)")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              try {
                await ApiService.createClass(
                  grade: int.parse(gradeCtrl.text.trim()),
                  section: sectionCtrl.text.trim(),
                  students: const [],
                  meta: {'room': 'B12'},
                );
                if (mounted) Navigator.pop(context);
                await load();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
              }
            },
            child: const Text("Create"),
          )
        ],
      ),
    );
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
          if (isAdmin) IconButton(onPressed: showCreateDialog, icon: const Icon(Icons.add)),
        ],
      ),
      drawer: AppDrawer(currentUser: widget.currentUser),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error.isNotEmpty
              ? Center(child: Text(error))
              : ListView.builder(
                  itemCount: classes.length,
                  itemBuilder: (_, i) {
                    final c = classes[i];
                    final students = (c['students'] is List) ? (c['students'] as List).length : 0;
                    return Card(
                      child: ListTile(
                        title: Text("Grade ${c['grade']} - Section ${c['section']}"),
                        subtitle: Text("students: $students"),
                      ),
                    );
                  },
                ),
    );
  }
}
