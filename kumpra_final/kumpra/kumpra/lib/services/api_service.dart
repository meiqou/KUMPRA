import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import 'php_response_parser.dart';

class ApiService {
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Map<String, String> _encodeFormBody(Map<String, dynamic> body) {
    final encoded = <String, String>{};
    void addValue(String key, dynamic value) {
      if (value == null) {
        encoded[key] = '';
      } else if (value is String || value is num || value is bool) {
        encoded[key] = value.toString();
      } else if (value is Map) {
        value.forEach((nestedKey, nestedValue) {
          addValue('$key[$nestedKey]', nestedValue);
        });
      } else if (value is Iterable) {
        var index = 0;
        for (final item in value) {
          addValue('$key[$index]', item);
          index++;
        }
      } else {
        encoded[key] = value.toString();
      }
    }

    body.forEach(addValue);
    return encoded;
  }

  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool auth = false,
  }) async {
    try {
      final requestBody = Map<String, dynamic>.from(body);
      if (auth) {
        final token = await getToken();
        if (token != null && token.isNotEmpty) {
          requestBody['token'] = token;
        }
      }

      final res = await http.post(
        Uri.parse('${AppConstants.baseUrl}/$endpoint'),
        body: _encodeFormBody(requestBody),
      );
      return parsePhpResponseBody(res.body);
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
      final queryParameters = <String, String>{...?params};
      if (auth) {
        final token = await getToken();
        if (token != null && token.isNotEmpty) {
          queryParameters['token'] = token;
        }
      }
      if (queryParameters.isNotEmpty) uri = uri.replace(queryParameters: queryParameters);
      final res = await http.get(uri);
      return parsePhpResponseBody(res.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}
