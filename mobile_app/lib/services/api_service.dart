import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../services/storage_service.dart';

const String baseUrl = 'https://community-project-abtu.onrender.com/api';

class ApiService {
  final StorageService storage = StorageService();

  Future<Map<String, String>?> _getHeaders() async {
    final token = await storage.getToken();
    if (token != null) {
      return {'Authorization': 'Token $token', 'Content-Type': 'application/json'};
    }
    return null;
  }

  Future<dynamic> get(String endpoint) async {
    final headers = await _getHeaders();
    if (headers == null) {
      throw Exception('No token');
    }
    final response = await http.get(Uri.parse('$baseUrl/$endpoint'), headers: headers).timeout(const Duration(seconds: 15));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    if (headers == null) {
      throw Exception('No token');
    }
    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: headers,
      body: json.encode(data),
    ).timeout(const Duration(seconds: 15));
    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to post data');
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    ).timeout(const Duration(seconds: 15));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await storage.saveToken(data['token']);
      if (data['user'] != null) {
        await storage.saveUser(data['user']);
      }
      return data;
    } else {
      throw Exception(json.decode(response.body)['error'] ?? 'Login failed');
    }
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(userData),
    ).timeout(const Duration(seconds: 15));
    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      await storage.saveToken(data['token']);
      return data;
    } else {
      String errorMsg = 'Registration failed';
      try {
        final errorData = json.decode(response.body);
        if (errorData is Map) {
          final errors = errorData.values.expand((v) => v is List ? v : [v]).toList();
          if (errors.isNotEmpty) errorMsg = errors.first.toString();
        }
      } catch (e) {
        // keep generic message
      }
      throw Exception(errorMsg);
    }
  }

  Future<List<dynamic>> getWards(String municipality) async {
    final response = await http.get(Uri.parse('$baseUrl/location/wards/?municipality=$municipality')).timeout(const Duration(seconds: 15));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load wards');
    }
  }

  Future<List<dynamic>> getMunicipalities() async {
    final response = await http.get(Uri.parse('$baseUrl/location/municipalities/')).timeout(const Duration(seconds: 15));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load municipalities');
    }
  }

  Future<Map<String, dynamic>> createReport(Map<String, dynamic> reportData) async {
    final result = await post('reports/', reportData);
    return Map<String, dynamic>.from(result);
  }

  Future<Map<String, dynamic>> getSummary() async {
    final headers = await _getHeaders();
    if (headers == null) throw Exception('No token');
    final response = await http.get(Uri.parse('$baseUrl/analytics/summary/'), headers: headers).timeout(const Duration(seconds: 15));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load summary');
    }
  }

  Future<Map<String, dynamic>> getWeeklyReports() async {
    final headers = await _getHeaders();
    if (headers == null) throw Exception('No token');
    final response = await http.get(Uri.parse('$baseUrl/reports/weekly/'), headers: headers).timeout(const Duration(seconds: 15));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load weekly reports');
    }
  }

  Future<List<dynamic>> getReports() async {
    final headers = await _getHeaders();
    if (headers == null) throw Exception('No token');
    final response = await http.get(Uri.parse('$baseUrl/reports/'), headers: headers).timeout(const Duration(seconds: 15));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load reports');
    }
  }

  Future<void> logout() async {
    await storage.clearToken();
  }
}
