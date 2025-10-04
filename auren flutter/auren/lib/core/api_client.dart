import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_storage.dart';

class ApiClient {
  final String baseUrl;
  ApiClient({required this.baseUrl});

  Future<Map<String, String>> _headers({bool auth = false}) async {
    final h = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    if (auth) {
      final st = await TokenStorage.read();
      final at = st?.accessToken;
      if (at != null && at.isNotEmpty) {
        h['Authorization'] = 'Bearer $at';
      }
    }
    return h;
  }

  Uri _uri(String path, [Map<String, String>? query]) {
    return Uri.parse('$baseUrl$path').replace(queryParameters: query);
  }

  Future<dynamic> get(
      String path, {
        required bool auth,
        Map<String, String>? query,
      }) async {
    final r = await http.get(_uri(path, query), headers: await _headers(auth: auth));
    if (r.statusCode >= 200 && r.statusCode < 300) {
      if (r.body.isEmpty) return null;
      try { return jsonDecode(r.body); } catch (_) { return r.body; }
    }
    throw Exception('HTTP ${r.statusCode}: ${r.body}');
  }

  Future<dynamic> post(
      String path,
      dynamic body, {
        required bool auth,
        Map<String, String>? query,
      }) async {
    final r = await http.post(
      _uri(path, query),
      headers: await _headers(auth: auth),
      body: jsonEncode(body),
    );
    if (r.statusCode >= 200 && r.statusCode < 300) {
      if (r.body.isEmpty) return null;
      try { return jsonDecode(r.body); } catch (_) { return r.body; }
    }
    throw Exception('HTTP ${r.statusCode}: ${r.body}');
  }
}
