import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SessionExpiredException implements Exception {
  final String message;

  SessionExpiredException([
    this.message = 'Sesi login habis. Silakan login ulang.',
  ]);

  @override
  String toString() => message;
}

class ApiService {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000/api',
  );

  Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  dynamic _decodeBody(http.Response response) {
    if (response.body.isEmpty) return null;
    return jsonDecode(response.body);
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('role');
  }

  Future<Exception> _buildHttpException(
    http.Response response,
    String fallbackMessage,
  ) async {
    final body = _decodeBody(response);
    final message = body is Map<String, dynamic>
        ? body['message']?.toString()
        : null;
    final error = body is Map<String, dynamic>
        ? body['error']?.toString()
        : null;

    if (response.statusCode == 401) {
      await _clearSession();
      return SessionExpiredException(
        message ?? 'Sesi login habis. Silakan login ulang.',
      );
    }

    if (body is Map<String, dynamic>) {
      if (message != null && error != null && error.isNotEmpty) {
        return Exception('$message: $error');
      }
      if (message != null && message.isNotEmpty) {
        return Exception(message);
      }
    }

    return Exception('$fallbackMessage (${response.statusCode})');
  }

  Future<dynamic> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      if (response.statusCode == 200) {
        return _decodeBody(response);
      }
      throw await _buildHttpException(response, 'Failed to login');
    } on http.ClientException {
      throw Exception(
        'Tidak bisa terhubung ke server. Pastikan backend berjalan di $baseUrl',
      );
    }
  }

  // --- Admin API ---
  Future<List<dynamic>> getUsers() async {
    final response = await http.get(
      Uri.parse('$baseUrl/users'),
      headers: await _headers(),
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw await _buildHttpException(response, 'Failed to load users');
  }

  Future<dynamic> createUser(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users'),
      headers: await _headers(),
      body: jsonEncode(data),
    );
    if (response.statusCode == 201) return _decodeBody(response);
    throw await _buildHttpException(response, 'Failed to create user');
  }

  Future<dynamic> updateUser(int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/$id'),
      headers: await _headers(),
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) return _decodeBody(response);
    throw await _buildHttpException(response, 'Failed to update user');
  }

  Future<dynamic> deleteUser(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/users/$id'),
      headers: await _headers(),
    );
    if (response.statusCode == 200) return _decodeBody(response);
    throw await _buildHttpException(response, 'Failed to delete user');
  }

  Future<List<dynamic>> getSchedules() async {
    final response = await http.get(
      Uri.parse('$baseUrl/schedules'),
      headers: await _headers(),
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw await _buildHttpException(response, 'Failed to load schedules');
  }

  Future<List<dynamic>> getAllAttendances() async {
    final response = await http.get(
      Uri.parse('$baseUrl/attendance/all'),
      headers: await _headers(),
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw await _buildHttpException(response, 'Failed to load attendances');
  }

  // --- User API ---
  Future<dynamic> checkIn(double lat, double lng) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/attendance/check-in'),
        headers: await _headers(),
        body: jsonEncode({'lat': lat, 'lng': lng}),
      );
      if (response.statusCode == 200) return _decodeBody(response);
      throw await _buildHttpException(response, 'Check-in failed');
    } on http.ClientException {
      throw Exception(
        'Check-in gagal: tidak bisa terhubung ke server $baseUrl',
      );
    }
  }

  Future<dynamic> checkOut(double lat, double lng) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/attendance/check-out'),
        headers: await _headers(),
        body: jsonEncode({'lat': lat, 'lng': lng}),
      );
      if (response.statusCode == 200) return _decodeBody(response);
      throw await _buildHttpException(response, 'Check-out failed');
    } on http.ClientException {
      throw Exception(
        'Check-out gagal: tidak bisa terhubung ke server $baseUrl',
      );
    }
  }

  Future<dynamic> getProfile() async {
    final response = await http.get(
      Uri.parse('$baseUrl/auth/profile'),
      headers: await _headers(),
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw await _buildHttpException(response, 'Failed to load profile');
  }

  Future<void> logout() => _clearSession();

  Future<dynamic> updateProfile(Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/auth/profile'),
      headers: await _headers(),
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw await _buildHttpException(response, 'Failed to update profile');
  }

  Future<List<dynamic>> getHistory() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/attendance/history'),
        headers: await _headers(),
      );
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw await _buildHttpException(response, 'Failed to load history');
    } on http.ClientException {
      throw Exception(
        'History gagal dimuat: tidak bisa terhubung ke server $baseUrl',
      );
    }
  }
}
