import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class AuthService {
  // Base URL from AppConstants
  static const String baseUrl = AppConstants.baseUrl;

  // 1. Fetch Clusters (Barangays)
  static Future<Map<String, dynamic>> getClusters() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/clusters/list.php'));
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
      return {'success': false, 'message': 'Server error: ${res.statusCode}'};
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // 2. Login Method
  static Future<Map<String, dynamic>> login(
      String username, String phone, String clusterId) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/login.php'),
        body: {
          'username': username,
          'phone': phone,
          'cluster_id': clusterId,
        },
      );
      return jsonDecode(res.body);
    } catch (e) {
      return {'success': false, 'message': 'Login failed: $e'};
    }
  }

  // 3. Register Method (Cleaned up from your duplicates)
  static Future<Map<String, dynamic>> register(
      String name, String username, String phone, String clusterId) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/register.php'),
        body: {
          'name': name,
          'username': username,
          'phone': phone,
          'cluster_id': clusterId,
        },
      );
      return jsonDecode(res.body);
    } catch (e) {
      return {'success': false, 'message': 'Registration failed: $e'};
    }
  }

  // 4. Session Management
  static Future<void> saveSession(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(userData));
    await prefs.setBool('is_logged_in', true);
    await prefs.setString('user_name', userData['name'] ?? '');
    await prefs.setString('user_username', userData['username'] ?? '');
    await prefs.setString('user_phone', userData['phone_number'] ?? '');
    await prefs.setString('cluster_name', userData['cluster_name'] ?? '');
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
