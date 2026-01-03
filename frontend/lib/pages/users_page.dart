import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/app_background.dart';

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
    if (!mounted) return;

    setState(() {
      loading = true;
      error = "";
    });

    try {
      final u = await ApiService.getUsers();
      if (!mounted) return;
      setState(() => users = u);
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
        title: const Text("Users", style: TextStyle(color: Colors.white)),
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
                    itemCount: users.length,
                    itemBuilder: (_, i) {
                      final u = users[i];
                      return Card(
                        color: cardColor,
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        child: ListTile(
                          leading: const Icon(Icons.person, color: Colors.white),
                          title: Text("${u["name"]}", style: const TextStyle(color: Colors.white)),
                          subtitle: Text(
                            "role: ${u["role"]} | email: ${u["email"]}",
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
