import '../consumoPHP.dart';

class RegistroRepoApi {
  final ApiService api;
  RegistroRepoApi(this.api);

  Future<List<Map<String, dynamic>>> obtenerDatos({
    required int idUsuario,
    required String fecha,
    required String producto,
    required String banco,
  }) async {
    final res = await api.postJson('RegistroRepo/obtener.php', {
      'idUsuario': idUsuario,
      'fecha': fecha,
      'producto': producto,
      'banco': banco,
    });

    final data = res['data'];

    if (data is List) {
      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    } else {
      throw Exception('Respuesta inesperada: "data" no es una lista');
    }
  }

  // registro de bancos
  Future<void> registrarDatos({
    required int idUsuario,
    required String fecha,
    required List<double> importes,
    required String producto,
    required String banco,
  }) async {
    await api.postJson('RegistroRepo/registrar.php', {
      'idUsuario': idUsuario,
      'fecha': fecha,
      'producto': producto,
      'importes': importes,
      'banco': banco,
    });
  }

  // Actualizacion de datos
  Future<void> actualizarDatos({
    required int idUsuario,
    required String fecha,
    required List<double> importes,
    required String producto,
    required String banco,
  }) async {
    await api.postJson('RegistroRepo/actualizar.php', {
      'idUsuario': idUsuario,
      'fecha': fecha,
      'producto': producto,
      'importes': importes,
      'banco': banco,
    });
  }
}
