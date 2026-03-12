import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  final String baseUrl = 'https://dev-soluciones.com/api';

  Uri _uri(String endpoint) => Uri.parse('$baseUrl/$endpoint');

  Future<Map<String, dynamic>> postJson(
    String endpoint,
    Map<String, dynamic> body, {
    Duration timeout = const Duration(seconds: 15),
  }) async {
    final res = await http
        .post(
          _uri(endpoint),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(timeout);

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }

    final decoded = jsonDecode(res.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Respuesta no válida (no es JSON objeto): ${res.body}');
    }

    // Si tu backend siempre manda {"ok": true/false}
    if (decoded['ok'] != true) {
      throw Exception(decoded['error'] ?? 'Error API');
    }

    return decoded;
  }

  Future<String> getRaw(String endpoint) async {
    final res = await http.get(_uri(endpoint));
    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }
    return res.body;
  }
}
