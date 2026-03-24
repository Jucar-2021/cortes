import '../consumoPHP.dart';

class SantanderApi {
  final ApiService api;
  SantanderApi(this.api);

  Future<List<Map<String, dynamic>>> obtenerTarjetasSantander({
    required int idUsuario,
    required String fecha,
    required String producto,
  }) async {
    final res = await api.postJson('Santander/obtener.php', {
      'idUsuario': idUsuario,
      'fecha': fecha,
      'producto': producto,
    });

    final data = res['data'];

    if (data is List) {
      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    } else {
      throw Exception('Respuesta inesperada: "data" no es una lista');
    }
  }

  // registro de targetas santander
  Future<void> registrarTarjetasSantander({
    required int idUsuario,
    required String fecha,
    required List<double> importes,
    required String producto,
  }) async {
    await api.postJson('Santander/registrar.php', {
      'idUsuario': idUsuario,
      'fecha': fecha,
      'producto': producto,
      'importes': importes,
    });
  }

  // Actualizacion de tarjeta santander
  Future<void> actualizarTarjetasSantander({
    required int idUsuario,
    required String fecha,
    required List<double> importes,
    required String producto,
  }) async {
    await api.postJson('Santander/actualizar.php', {
      'idUsuario': idUsuario,
      'fecha': fecha,
      'producto': producto,
      'importes': importes,
    });
  }

  // Eliminacion de tarjeta santander
  Future<void> eliminarTarjetaSantander(int idSantander) async {
    await api.postJson('Santander/eliminar.php', {
      'idSantander': idSantander,
    });
  }
}
