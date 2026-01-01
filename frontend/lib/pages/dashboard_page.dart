import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';

class DashboardPage extends StatelessWidget {
  final Map<String, dynamic> currentUser;
  const DashboardPage({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    final role = (currentUser['role'] ?? '').toString();

    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard")),
      drawer: AppDrawer(currentUser: currentUser),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: ListTile(
            title: Text("Welcome ${currentUser['name']}"),
            subtitle: Text("Role: $role | Email: ${currentUser['email']}"),
          ),
        ),
      ),
    );
  }
}
