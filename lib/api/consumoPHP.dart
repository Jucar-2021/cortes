import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  Future<String> fetchData(String endpoint) async {
    final url = Uri.parse('$baseUrl/$endpoint'); // ❌ quita el /

    try {
      final response = await http.get(url);

      print('StatusCode: ${response.statusCode}');
      print('Body: ${response.body}');

      return response.body;
    } catch (e) {
      print('Error al conectar con la API->: $e');
      rethrow;
    }
  }

  Future<bool> registrarUsuario(String usuarios, String pass) async {
    try {
      final url = Uri.parse('$baseUrl/User/registrar.php');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'usuarios': usuarios,
          'pass': pass,
        }),
      );

      final body = jsonDecode(response.body);

      if (response.statusCode == 200 && body['ok'] == true) {
        print('Usuario registrado. ID: ${body["idUsuario"]}');
        return true;
      } else {
        print('No se pudo registrar: ${body["error"] ?? response.body}');
        return false;
      }
    } catch (e) {
      print('Error al registrar por HTTP: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> obtenerSantanderUsuarioFechaProducto({
    required int idUsuario,
    required String fecha,
    required String producto,
  }) async {
    final url = Uri.parse("$baseUrl/santander/obtener.php");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "idUsuario": idUsuario,
        "fecha": fecha,
        "producto": producto,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Error HTTP: ${response.statusCode}");
    }

    final json = jsonDecode(response.body);

    if (json["ok"] == true) {
      return List<Map<String, dynamic>>.from(json["data"]);
    } else {
      throw Exception("Error API");
    }
  }

  //Metodo para validar el usuario y contraseña iniciar sesion
  Future<int> validarUsuario(String usuario, String pass) async {
    try {
      final url = Uri.parse('$baseUrl/User/validar.php');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'usuarios': usuario, 'pass': pass}),
      );

      // Debug útil
      // print("Status: ${response.statusCode}");
      // print("Body: ${response.body}");

      final body = jsonDecode(response.body);

      if (response.statusCode == 200 && body['ok'] == true) {
        final id = body['idUsuario'];
        if (id is int) return id;
        if (id is String) return int.tryParse(id) ?? -1;
        return -1;
      }

      return -1;
    } catch (e) {
      print('Error al validar por HTTP: $e');
      return -1;
    }
  }
}
