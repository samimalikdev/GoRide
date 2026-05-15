import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String baseUrl = 'http://192.168.100.168:3000/api';
  final http.Client client;
  final SharedPreferences prefs;

  ApiService({required this.client, required this.prefs});

  Future<Map<String, String>> _headers() async {
    String? token = prefs.getString('auth_token');
    if (token == null) {
      final userJson = prefs.getString('CACHED_USER');
      if (userJson != null) {
        try {
          final map = jsonDecode(userJson);
          token = map['token'];
        } catch (_) {}
      }
    }
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> get(String endpoint, {Map<String, String>? query}) async {
    final url = Uri.parse('$baseUrl$endpoint').replace(queryParameters: query);
    print('REQUEST: GET $url');
    try {
      final headers = await _headers();
      final response = await client
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 15));
      return _processResponse(response);
    } catch (e) {
      print('GET ERROR: $e');
      rethrow;
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl$endpoint');
    print('REQUEST: POST $url');
    try {
      final headers = await _headers();
      final response = await client
          .post(url, headers: headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 15));
      return _processResponse(response);
    } catch (e) {
      print('POST ERROR: $e');
      rethrow;
    }
  }

  Future<dynamic> delete(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    print('REQUEST: DELETE $url');
    try {
      final headers = await _headers();
      final response = await client
          .delete(url, headers: headers)
          .timeout(const Duration(seconds: 15));
      return _processResponse(response);
    } catch (e) {
      print('DELETE ERROR: $e');
      rethrow;
    }
  }

  Future<dynamic> multipart(
    String endpoint,
    Map<String, String> fields,
    Map<String, String> files,
  ) async {
    final url = Uri.parse('$baseUrl$endpoint');
    print('REQUEST: MULTIPART $url');
    try {
      final request = http.MultipartRequest('POST', url);
      final headers = await _headers();
      request.headers.addAll(headers);
      request.fields.addAll(fields);

      for (var file in files.entries) {
        request.files.add(
          await http.MultipartFile.fromPath(file.key, file.value),
        );
      }

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
      );
      final response = await http.Response.fromStream(streamedResponse);
      return _processResponse(response);
    } catch (e) {
      print('MULTIPART ERROR: $e');
      rethrow;
    }
  }

  dynamic _processResponse(http.Response response) {
    print('RESPONSE: ${response.statusCode} for ${response.request?.url}');
    
    dynamic body;
    try {
      body = jsonDecode(response.body);
    } catch (e) {
      print('JSON DECODE ERROR: ${e.toString()}');
      print('RAW RESPONSE BODY: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');
      
      if (response.body.contains('<!DOCTYPE html>') || response.body.contains('<html>')) {
        throw Exception('Server error ${response.statusCode}');
      }
      throw Exception('Failed Status: ${response.statusCode}');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    } else {
      final message = (body is Map && body.containsKey('message')) 
          ? body['message'] 
          : 'Server Error ${response.statusCode}';
      throw Exception(message);
    }
  }
}
