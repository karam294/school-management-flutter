import 'package:flutter/material.dart';
import '../services/api_service.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  List users = [];
  String error = "";
  bool loading = true;

  Future<void> load() async {
    setState(() {
      loading = true;
      error = "";
    });

    try {
      final u = await ApiService.getUsers();
      setState(() => users = u);
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
        title: const Text("Users"),
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
                  itemCount: users.length,
                  itemBuilder: (_, i) {
                    final u = users[i];
                    return Card(
                      child: ListTile(
                        title: Text("${u["name"]}"),
                        subtitle: Text("role: ${u["role"]} | email: ${u["email"]}"),
                      ),
                    );
                  },
                ),
    );
  }
}
