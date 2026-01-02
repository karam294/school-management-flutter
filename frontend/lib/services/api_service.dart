import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:5000';

  /* ---------------- USERS ---------------- */

  static Future<List<dynamic>> getUsers({String? role, String? email}) async {
    final params = <String, String>{};
    if (role != null && role.isNotEmpty) params['role'] = role;
    if (email != null && email.isNotEmpty) params['email'] = email;

    final uri = Uri.parse('$baseUrl/users').replace(queryParameters: params);
    final res = await http.get(uri);

    if (res.statusCode >= 400) throw Exception(res.body);
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String role,
  }) async {
    final users = await getUsers(email: email, role: role);
    if (users.isEmpty) throw Exception("No user found with this email and role");
    return users.first as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> createUser({
    required String name,
    required String email,
    required String role,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/users'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'role': role}),
    );

    if (res.statusCode >= 400) throw Exception(res.body);
    return jsonDecode(res.body);
  }

  /* ---------------- CLASSES ---------------- */

  static Future<List<dynamic>> getClasses() async {
    final res = await http.get(Uri.parse('$baseUrl/classes'));
    if (res.statusCode >= 400) throw Exception(res.body);
    return jsonDecode(res.body);
  }

  // This endpoint already populates students in your backend
  static Future<Map<String, dynamic>> getClassWithStudents(String classId) async {
    final res = await http.get(Uri.parse('$baseUrl/classes/$classId'));
    if (res.statusCode >= 400) throw Exception(res.body);
    return jsonDecode(res.body);
  }

  // Alias so old code won’t crash:
  static Future<Map<String, dynamic>> getClassById(String classId) async {
    return getClassWithStudents(classId);
  }

  /* ---------------- AGENDA ---------------- */

  static Future<Map<String, dynamic>> createAgenda(Map<String, dynamic> body) async {
    final res = await http.post(
      Uri.parse('$baseUrl/agendas'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (res.statusCode >= 400) throw Exception(res.body);
    return jsonDecode(res.body);
  }

  static Future<List<dynamic>> getAgendaByCriteria(Map<String, String> params) async {
    final uri = Uri.parse('$baseUrl/agendas').replace(queryParameters: params);
    final res = await http.get(uri);
    if (res.statusCode >= 400) throw Exception(res.body);
    return jsonDecode(res.body);
  }

  // For student MySpace
  static Future<List<dynamic>> getAgendaForClass(String classId) async {
    return getAgendaByCriteria({'classId': classId});
  }

  /* ---------------- GRADES ---------------- */

  static Future<Map<String, dynamic>> createGrade(Map<String, dynamic> body) async {
    final res = await http.post(
      Uri.parse('$baseUrl/grades'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (res.statusCode >= 400) throw Exception(res.body);
    return jsonDecode(res.body);
  }

  static Future<List<dynamic>> getGradesByCriteria(Map<String, String> params) async {
    final uri = Uri.parse('$baseUrl/grades').replace(queryParameters: params);
    final res = await http.get(uri);
    if (res.statusCode >= 400) throw Exception(res.body);
    return jsonDecode(res.body);
  }

  // For student MySpace
  static Future<List<dynamic>> getGradesForStudent(String studentId) async {
    return getGradesByCriteria({'studentId': studentId});
  }
}
