import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/app_drawer.dart';

class UsersPage extends StatefulWidget {
  final Map<String, dynamic> currentUser;
  const UsersPage({super.key, required this.currentUser});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  List users = [];
  bool loading = true;
  String error = '';

  bool get isAdmin => (widget.currentUser['role'] == 'admin');

  Future<void> load() async {
    setState(() { loading = true; error = ''; });
    try {
      users = await ApiService.getUsers();
    } catch (e) {
      error = e.toString();
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> showCreateDialog() async {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    String role = 'student';

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Create User (Admin only)"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Name")),
            TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: "Email")),
            DropdownButtonFormField<String>(
              value: role,
              items: const [
                DropdownMenuItem(value: 'student', child: Text('student')),
                DropdownMenuItem(value: 'teacher', child: Text('teacher')),
                DropdownMenuItem(value: 'admin', child: Text('admin')),
              ],
              onChanged: (v) => role = v ?? 'student',
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              try {
                await ApiService.createUser(
                  name: nameCtrl.text.trim(),
                  email: emailCtrl.text.trim(),
                  role: role,
                );
                if (mounted) Navigator.pop(context);
                await load();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.toString())),
                );
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
        title: const Text("Users"),
        actions: [
          IconButton(onPressed: load, icon: const Icon(Icons.refresh)),
          if (isAdmin) IconButton(onPressed: showCreateDialog, icon: const Icon(Icons.person_add)),
        ],
      ),
      drawer: AppDrawer(currentUser: widget.currentUser),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error.isNotEmpty
              ? Center(child: Text(error))
              : ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (_, i) {
                    final u = users[i];
                    return Card(
                      child: ListTile(
                        title: Text("${u['name']}"),
                        subtitle: Text("role: ${u['role']} | email: ${u['email']}"),
                      ),
                    );
                  },
                ),
    );
  }
}
