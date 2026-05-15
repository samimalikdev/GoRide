import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final http.Client client;
  final SharedPreferences prefs;
  final String baseUrl = 'http://192.168.100.168:3000/api';
  Function? onUnauthorized;

  ApiService({required this.client, required this.prefs, this.onUnauthorized});  

  Future<Map<String, String>> _headers() async {
    final token = prefs.getString('auth_token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  dynamic _processResponse(http.Response response) {
    print('API RESPONSE [${response.statusCode}]: ${response.request?.url}');
    
    dynamic body;
    try {
      body = jsonDecode(response.body);
    } catch (e) {
      print('JSON DECODE ERROR: ${e.toString()}');
      print('RAW RESPONSE BODY: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');
      
      if (response.body.contains('<!DOCTYPE html>') || response.body.contains('<html>')) {
        throw Exception(' Server error ${response.statusCode}');
      }
      throw Exception('Failed server response as JSON. Status: ${response.statusCode}');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    } else {
      if (response.statusCode == 401) {
        print('UNAUTHORIZED');
        onUnauthorized?.call();
      }
      final message = (body is Map && body.containsKey('message')) 
          ? body['message'] 
          : 'Server Error ${response.statusCode}';
      throw Exception(message);
    }
  }

  Future<dynamic> get(String endpoint, {Map<String, String>? query}) async {
    final url = Uri.parse('$baseUrl$endpoint').replace(queryParameters: query);
    print('API REQUEST [GET]: $url');

    try {
      final headers = await _headers();
      final response = await client.get(url, headers: headers);
      return _processResponse(response);
    } catch (e) {
      print('GET Error: $e');
      rethrow;
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl$endpoint');
    print('API REQUEST [POST]: $url');
    print('DATA: ${jsonEncode(data)}');

    try {
      final headers = await _headers();
      final response = await client.post(
        url,
        headers: headers,
        body: jsonEncode(data),
      );
      return _processResponse(response);
    } catch (e) {
      print('POST Error: $e');
      rethrow;
    }
  }

  Future<dynamic> patch(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl$endpoint');
    print('API REQUEST [PATCH]: $url');

    try {
      final headers = await _headers();
      final response = await client.patch(
        url,
        headers: headers,
        body: jsonEncode(data),
      );
      return _processResponse(response);
    } catch (e) {
      print('PATCH Error: $e');
      rethrow;
    }
  }

  Future<dynamic> delete(String endpoint, {Map<String, dynamic>? data}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    print('API REQUEST [DELETE]: $url');

    try {
      final headers = await _headers();
      final response = await client.delete(
        url,
        headers: headers,
        body: data != null ? jsonEncode(data) : null,
      );
      return _processResponse(response);
    } catch (e) {
      print('DELETE Error: $e');
      rethrow;
    }
  }

  Future<dynamic> multipart(String endpoint, Map<String, String> fields, Map<String, String> files) async {
    final url = Uri.parse('$baseUrl$endpoint');
    print('API REQUEST [MULTIPART]: $url');

    try {
      final token = prefs.getString('auth_token');
      var request = http.MultipartRequest('POST', url);
      
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      
      request.fields.addAll(fields);
      
      for (var file in files.entries) {
        request.files.add(await http.MultipartFile.fromPath(file.key, file.value));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      return _processResponse(response);
    } catch (e) {
      print('MULTIPART Error: $e');
      rethrow;
    }
  }
}
