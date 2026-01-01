import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Backend stays on 5000
  static const String baseUrl = 'http://localhost:5000';

  static Future<List<dynamic>> getUsers({String? email, String? role}) async {
    final uri = Uri.parse('$baseUrl/users').replace(queryParameters: {
      if (email != null && email.isNotEmpty) 'email': email,
      if (role != null && role.isNotEmpty) 'role': role,
    });

    final response = await http.get(uri);
    if (response.statusCode >= 400) {
      throw Exception('Failed to load users: ${response.body}');
    }
    return json.decode(response.body);
  }

  static Future<List<dynamic>> getClasses() async {
    final response = await http.get(Uri.parse('$baseUrl/classes'));
    if (response.statusCode >= 400) {
      throw Exception('Failed to load classes: ${response.body}');
    }
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> createUser({
    required String name,
    required String email,
    required String role, // student/teacher only in UI
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'name': name, 'email': email, 'role': role}),
    );

    if (response.statusCode >= 400) {
      throw Exception('Create user failed: ${response.body}');
    }
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> createClass({
    required int grade,
    required String section,
    List<String> students = const [],
    Map<String, dynamic>? meta,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/classes'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'grade': grade,
        'section': section,
        'students': students,
        if (meta != null) 'meta': meta,
      }),
    );

    if (response.statusCode >= 400) {
      throw Exception('Create class failed: ${response.body}');
    }
    return json.decode(response.body);
  }
}
