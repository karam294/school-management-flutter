import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:5000';

  static Map<String, String> _headers() => {'Content-Type': 'application/json'};

  static dynamic _decode(http.Response res) {
    try {
      return jsonDecode(res.body);
    } catch (_) {
      return res.body;
    }
  }

  static void _throwIfError(http.Response res) {
    if (res.statusCode >= 400) {
      final body = _decode(res);
      throw Exception(body is Map && body["error"] != null ? body["error"] : res.body);
    }
  }

  /* ---------------- USERS ---------------- */

  static Future<List<dynamic>> getUsers({String? role, String? email, String? name}) async {
    final params = <String, String>{};
    if (role != null && role.isNotEmpty) params["role"] = role;
    if (email != null && email.isNotEmpty) params["email"] = email;
    if (name != null && name.isNotEmpty) params["name"] = name;

    final uri = Uri.parse('$baseUrl/users')
        .replace(queryParameters: params.isEmpty ? null : params);
    final res = await http.get(uri);
    _throwIfError(res);
    return _decode(res) as List<dynamic>;
  }

  /* ---------------- LOGIN (UPDATED) ---------------- */
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/users/login'),
      headers: _headers(),
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    _throwIfError(res);
    return (_decode(res) as Map).cast<String, dynamic>();
  }

  /* ---------------- REGISTER (UPDATED) ---------------- */
  static Future<Map<String, dynamic>> createUser({
    required String name,
    required String email,
    required String password,
    required String role,
    int? grade,
    String? section,
  }) async {
    final body = <String, dynamic>{
      'name': name,
      'email': email,
      'password': password,
      'role': role,
    };

    if (role == "student") {
      if (grade != null) body["grade"] = grade;
      if (section != null) body["section"] = section;
    }

    final res = await http.post(
      Uri.parse('$baseUrl/users'),
      headers: _headers(),
      body: jsonEncode(body),
    );

    _throwIfError(res);
    return (_decode(res) as Map).cast<String, dynamic>();
  }

  static Future<Map<String, dynamic>> updateUser(String id, Map<String, dynamic> body) async {
    final res = await http.put(
      Uri.parse('$baseUrl/users/$id'),
      headers: _headers(),
      body: jsonEncode(body),
    );
    _throwIfError(res);
    return (_decode(res) as Map).cast<String, dynamic>();
  }

  static Future<void> deleteUser(String id) async {
    final res = await http.delete(Uri.parse('$baseUrl/users/$id'));
    _throwIfError(res);
  }

  /* ---------------- CLASSES ---------------- */

  static Future<List<dynamic>> getClasses() async {
    final res = await http.get(Uri.parse('$baseUrl/classes'));
    _throwIfError(res);
    return _decode(res) as List<dynamic>;
  }

  static Future<Map<String, dynamic>> getClassWithStudents(String classId) async {
    final res = await http.get(Uri.parse('$baseUrl/classes/$classId'));
    _throwIfError(res);
    return (_decode(res) as Map).cast<String, dynamic>();
  }

  static Future<Map<String, dynamic>> addStudentToClass(
      String classId, String studentId) async {
    final res = await http.post(
      Uri.parse('$baseUrl/classes/$classId/addStudent'),
      headers: _headers(),
      body: jsonEncode({"studentId": studentId}),
    );
    _throwIfError(res);
    return (_decode(res) as Map).cast<String, dynamic>();
  }

  /* ---------------- AGENDA ---------------- */

  static Future<Map<String, dynamic>> createAgenda(Map<String, dynamic> body) async {
    final res = await http.post(
      Uri.parse('$baseUrl/agendas'),
      headers: _headers(),
      body: jsonEncode(body),
    );
    _throwIfError(res);
    return (_decode(res) as Map).cast<String, dynamic>();
  }

  static Future<List<dynamic>> getAgendaByClass(String classId) async {
    final uri = Uri.parse('$baseUrl/agendas')
        .replace(queryParameters: {"classId": classId});
    final res = await http.get(uri);
    _throwIfError(res);
    return _decode(res) as List<dynamic>;
  }

  /* ---------------- GRADES ---------------- */

  static Future<Map<String, dynamic>> createGrade(Map<String, dynamic> body) async {
    final res = await http.post(
      Uri.parse('$baseUrl/grades'),
      headers: _headers(),
      body: jsonEncode(body),
    );
    _throwIfError(res);
    return (_decode(res) as Map).cast<String, dynamic>();
  }

  static Future<List<dynamic>> getGradesForStudent(String studentId) async {
    final uri = Uri.parse('$baseUrl/grades')
        .replace(queryParameters: {"studentId": studentId});
    final res = await http.get(uri);
    _throwIfError(res);
    return _decode(res) as List<dynamic>;
  }
}
