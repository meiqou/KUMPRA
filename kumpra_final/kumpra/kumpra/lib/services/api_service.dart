import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class ApiService {
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<Map<String, String>> _headers({bool auth = false}) async {
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool auth = false,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('${AppConstants.baseUrl}/$endpoint'),
        headers: await _headers(auth: auth),
        body: jsonEncode(body),
      );
      return jsonDecode(res.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> get(
    String endpoint, {
    bool auth = false,
    Map<String, String>? params,
  }) async {
    try {
      var uri = Uri.parse('${AppConstants.baseUrl}/$endpoint');
      if (params != null) uri = uri.replace(queryParameters: params);
      final res = await http.get(uri, headers: await _headers(auth: auth));
      return jsonDecode(res.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}
